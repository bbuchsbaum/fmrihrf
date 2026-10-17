test_that("fmrihrf_cli help paths return success", {
  out <- capture.output(status <- fmrihrf_cli("--help"))
  expect_equal(status, 0L)
  expect_true(any(grepl("Usage: fmrihrf", out, fixed = TRUE)))

  out <- capture.output(status <- fmrihrf_cli(c("help", "eval")))
  expect_equal(status, 0L)
  expect_true(any(grepl("Usage: fmrihrf eval", out, fixed = TRUE)))

  out <- capture.output(status <- fmrihrf_cli(c("eval", "--help")))
  expect_equal(status, 0L)
  expect_true(any(grepl("Usage: fmrihrf eval", out, fixed = TRUE)))
})

test_that("help lists exactly the options and defaults each command accepts", {
  specs <- fmrihrf:::.cli_specs
  main <- capture.output(fmrihrf_cli("help"))
  commands <- sub("^  (\\S+).*", "\\1", grep("^  [a-z]", main, value = TRUE))
  expect_setequal(commands, names(specs))
  for (command in names(specs)) {
    spec <- specs[[command]]
    help <- capture.output(fmrihrf_cli(c("help", command)))
    lines <- grep("^  --", help, value = TRUE)
    options <- sub("^  --(\\S+).*", "\\1", lines)
    negated <- if (length(spec$false_flags)) paste0("no-", spec$false_flags)
    expect_setequal(options, c(spec$flags, names(spec$values), negated))
    # Defaults shown as "[value]" are exactly the parser's non-boolean defaults
    shown <- grepl("\\[[^]]+\\]$", lines)
    defaults <- stats::setNames(sub(".*\\[([^]]+)\\]$", "\\1", lines[shown]),
                                options[shown])
    expected <- Filter(Negate(is.logical), spec$defaults)
    expect_equal(sort(names(defaults)), sort(as.character(names(expected))),
                 info = command)
    for (name in names(expected)) {
      expect_equal(defaults[[name]], as.character(expected[[name]]),
                   info = paste(command, name))
    }
  }
})

test_that("parser rejects unknown options and missing values", {
  expect_equal(suppressMessages(fmrihrf_cli(c("list", "--bogus"))), 2L)
  expect_equal(suppressMessages(fmrihrf_cli(c("eval", "--hrf"))), 2L)
})

test_that("parser handles boolean flags, negation and required options", {
  expect_equal(suppressMessages(fmrihrf_cli(c("list", "--json=1"))), 2L)
  expect_equal(suppressMessages(fmrihrf_cli(c("list", "--no-json"))), 2L)
  expect_equal(suppressMessages(fmrihrf_cli(c("eval", "--no-summate=1"))), 2L)
  out <- capture.output(
    status <- fmrihrf_cli(c("eval", "--no-summate", "--width", "2", "--times", "0,1"))
  )
  expect_equal(status, 0L)
  expect_message(status <- fmrihrf_cli(c("design", "--events", "events.csv")),
                 "Missing required option(s): --blocklens, --tr", fixed = TRUE)
  expect_equal(status, 2L)
  expect_message(status <- fmrihrf_cli(c("regressor", "--events", tempfile())),
                 "File does not exist")
  expect_equal(status, 1L)
})

test_that("every supplied option value is validated, whether used or not", {
  invalid <- list(
    c("eval", "--nbasis", "x"),
    c("eval", "--nbasis", "2.5"),
    c("eval", "--span", "2,3"),
    c("eval", "--times", "0,1", "--from", "x"),
    c("eval", "--times", "0,1", "--by", "0"),
    c("eval", "--output="),
    c("regressor", "--onsets", "0", "--blocklens", "4", "--tr", "1", "--to", "x"),
    c("regressor", "--onsets", "0", "--start-time", "x"),
    c("regressor", "--events", "events.csv", "--duration", "x"),
    c("design", "--events", "events.csv", "--blocklens", "6", "--tr", "1",
      "--nbasis", "x")
  )
  for (args in invalid) {
    expect_equal(suppressMessages(fmrihrf_cli(args)), 2L,
                 info = paste(args, collapse = " "))
  }
  expect_message(fmrihrf_cli(c("eval", "--nbasis", "x")),
                 "--nbasis must contain only numeric values", fixed = TRUE)

  # Valid values of options that the chosen HRF or grid does not use still work
  out <- capture.output(status <- fmrihrf_cli(c(
    "eval", "--hrf", "spmg1", "--nbasis", "3", "--span", "30",
    "--times", "0,1", "--from", "5", "--by", "2"
  )))
  expect_equal(status, 0L)
  expect_equal(length(out), 3L)
})

test_that("parser supports equals values and negative numeric values", {
  out <- capture.output(
    status <- fmrihrf_cli(c("eval", "--hrf=spmg1", "--times", "-0.5,0,0.5"))
  )
  expect_equal(status, 0L)
  expect_equal(out[1], "\"time\",\"value\"")
  expect_match(out[2], "^-0.5,")
})

test_that("list command emits parseable JSON", {
  out <- capture.output(status <- fmrihrf_cli(c("list", "--json")))
  expect_equal(status, 0L)
  parsed <- jsonlite::fromJSON(paste(out, collapse = "\n"))
  expect_true(all(c("name", "type", "nbasis_default") %in% names(parsed)))
  expect_true("spmg1" %in% parsed$name)
})

test_that("--key=value keeps every \"=\" after the first in the value", {
  path <- file.path(tempfile(), "out=a=")
  dir.create(dirname(path))
  status <- fmrihrf_cli(c("eval", "--to", "1", paste0("--output=", path)))
  expect_equal(status, 0L)
  expect_true(file.exists(path))
  expect_equal(utils::read.csv(path)$time, c(0, 0.5, 1))
  expect_message(status <- fmrihrf_cli(c("eval", "--to=3=4")),
                 "--to must contain only numeric values", fixed = TRUE)
  expect_equal(status, 2L)
})

test_that("eval command emits expected columns", {
  path <- tempfile(fileext = ".csv")
  status <- fmrihrf_cli(c(
    "eval", "--hrf", "spmg3", "--from", "0", "--to", "1", "--by", "1",
    "--output", path
  ))
  expect_equal(status, 0L)
  out <- utils::read.csv(path, check.names = FALSE)
  expect_equal(names(out), c("time", "basis1", "basis2", "basis3"))
  expect_equal(out$time, c(0, 1))
})

test_that("regressor command evaluates onsets over a sampling frame", {
  path <- tempfile(fileext = ".csv")
  status <- fmrihrf_cli(c(
    "regressor", "--onsets", "0,4", "--blocklens", "4", "--tr", "1",
    "--hrf", "spmg1", "--output", path
  ))
  expect_equal(status, 0L)
  out <- utils::read.csv(path, check.names = FALSE)
  expect_equal(names(out), c("time", "value"))
  expect_equal(nrow(out), 4L)
})

test_that("design command creates condition columns from an events table", {
  events <- tempfile(fileext = ".csv")
  writeLines(c(
    "onset,condition,block,duration,amplitude",
    "0,A,1,0,1",
    "4,B,1,0,1"
  ), events)
  path <- tempfile(fileext = ".csv")
  status <- fmrihrf_cli(c(
    "design", "--events", events, "--blocklens", "6", "--tr", "1",
    "--output", path
  ))
  expect_equal(status, 0L)
  out <- utils::read.csv(path, check.names = FALSE)
  expect_equal(names(out), c("time", "A", "B"))
  expect_equal(nrow(out), 6L)
})

test_that("design command names basis columns after each condition", {
  events <- tempfile(fileext = ".tsv")
  writeLines(c("onset\tcond\trun", "0\tA\t1", "4\tB\t1", "1\tA\t2"), events)
  path <- tempfile(fileext = ".csv")
  status <- fmrihrf_cli(c(
    "design", "--events", events, "--condition", "cond", "--block", "run",
    "--blocklens", "6,5", "--tr", "1", "--hrf", "spmg2", "--sparse",
    "--output", path
  ))
  expect_equal(status, 0L)
  out <- utils::read.csv(path, check.names = FALSE)
  expect_equal(names(out), c("time", "A_basis1", "A_basis2", "B_basis1", "B_basis2"))
  expect_equal(nrow(out), 11L)
})

test_that("install_cli copies the wrapper and refuses accidental overwrite", {
  dest_dir <- tempfile()
  installed <- install_cli(dest_dir)
  expect_true(file.exists(installed[["fmrihrf"]]))
  if (.Platform$OS.type != "windows") {
    expect_equal(unname(file.access(installed[["fmrihrf"]], mode = 1)), 0L)
  }
  expect_error(install_cli(dest_dir), "Refusing to overwrite")
})

test_that("exec wrapper has a valid help path", {
  wrapper <- system.file("exec", "fmrihrf", package = "fmrihrf")
  if (!nzchar(wrapper)) {
    wrapper <- file.path(getwd(), "exec", "fmrihrf")
  }
  skip_if_not(file.exists(wrapper))
  rscript <- file.path(
    R.home("bin"),
    if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"
  )
  result <- system2(rscript,
                    c(shQuote(wrapper), "--help"), stdout = TRUE, stderr = TRUE)
  status <- attr(result, "status")
  if (is.null(status)) {
    status <- 0L
  }
  expect_equal(status, 0L)
  expect_true(any(grepl("Usage: fmrihrf", result, fixed = TRUE)))
})
