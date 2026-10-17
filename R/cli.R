#' Command line entrypoint for fmrihrf
#'
#' @param args Character vector of command line arguments.
#' @return Integer exit status. `0` indicates success, `1` indicates a domain
#'   failure, and `2` indicates usage or runtime errors.
#' @export
fmrihrf_cli <- function(args = commandArgs(trailingOnly = TRUE)) {
  tryCatch(
    .fmrihrf_cli_main(args),
    fmrihrf_cli_domain_error = function(e) {
      message(conditionMessage(e))
      1L
    },
    fmrihrf_cli_usage_error = function(e) {
      message(conditionMessage(e))
      2L
    },
    error = function(e) {
      message("fmrihrf: ", conditionMessage(e))
      2L
    }
  )
}

#' Install fmrihrf command line wrappers
#'
#' @param dest_dir Directory where wrapper commands should be copied.
#' @param overwrite Logical; overwrite an existing command only when `TRUE`.
#' @param commands Optional character vector of command names to install.
#' @return Invisibly, a named character vector of installed command paths.
#' @export
install_cli <- function(dest_dir = "~/.local/bin",
                        overwrite = FALSE,
                        commands = NULL) {
  command_map <- c(fmrihrf = "fmrihrf")
  if (is.null(commands)) {
    commands <- names(command_map)
  }
  unknown <- setdiff(commands, names(command_map))
  if (length(unknown) > 0) {
    stop("Unknown command(s): ", paste(unknown, collapse = ", "),
         call. = FALSE)
  }

  exec_dir <- .fmrihrf_exec_dir()
  if (!dir.exists(exec_dir)) {
    stop("Cannot find fmrihrf exec directory.", call. = FALSE)
  }

  dest_dir <- path.expand(dest_dir)
  if (!dir.exists(dest_dir)) {
    dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
  }
  if (!dir.exists(dest_dir)) {
    stop("Could not create destination directory: ", dest_dir, call. = FALSE)
  }

  installed <- stats::setNames(character(length(commands)), commands)
  for (cmd in commands) {
    src <- file.path(exec_dir, command_map[[cmd]])
    if (!file.exists(src)) {
      stop("Cannot find command wrapper: ", src, call. = FALSE)
    }
    dest <- file.path(dest_dir, cmd)
    if (file.exists(dest) && !isTRUE(overwrite)) {
      stop("Refusing to overwrite existing command: ", dest,
           "\nUse overwrite = TRUE to replace it.", call. = FALSE)
    }
    ok <- file.copy(src, dest, overwrite = TRUE)
    if (!ok) {
      stop("Could not copy command wrapper to: ", dest, call. = FALSE)
    }
    Sys.chmod(dest, mode = "0755")
    installed[[cmd]] <- dest
  }

  path_dirs <- strsplit(Sys.getenv("PATH"), .Platform$path.sep, fixed = TRUE)[[1]]
  if (!normalizePath(dest_dir, mustWork = FALSE) %in%
      normalizePath(path_dirs, mustWork = FALSE)) {
    message("Add ", dest_dir, " to PATH to run installed commands directly.")
  }

  invisible(installed)
}

.fmrihrf_cli_main <- function(args) {
  if (length(args) == 0 || args[[1]] %in% c("-h", "--help", "help")) {
    topic <- if (length(args) >= 2 && args[[1]] == "help") args[[2]]
    return(.fmrihrf_cli_help(topic))
  }

  command <- args[[1]]
  command_args <- args[-1]
  if (any(c("--help", "-h") %in% command_args)) {
    return(.fmrihrf_cli_help(command))
  }
  if (!command %in% names(.cli_specs)) {
    .cli_usage_error("Unknown command: ", command,
                     "\nRun `fmrihrf --help` for available commands.")
  }

  opts <- .parse_cli_args(command_args, .cli_specs[[command]])
  switch(command,
    list = .fmrihrf_cli_list(opts),
    eval = .fmrihrf_cli_eval(opts),
    regressor = .fmrihrf_cli_regressor(opts),
    design = .fmrihrf_cli_design(opts)
  )
}

.fmrihrf_cli_help <- function(command = NULL) {
  text <- switch(command %||% "main",
    main = c(
      "Usage: fmrihrf <command> [options]",
      "",
      "Commands:",
      "  list        List available HRFs and basis generators",
      "  eval        Evaluate an HRF or basis over a time grid",
      "  regressor   Build and evaluate one event regressor",
      "  design      Build a condition design matrix from an events table",
      "",
      "Run `fmrihrf help <command>` for command-specific options."
    ),
    list = c(
      "Usage: fmrihrf list [--details] [--json] [--output FILE]",
      "",
      "Options:",
      "  --details       Include descriptions from the HRF registry",
      "  --json          Write JSON instead of CSV",
      "  --output FILE   Write output to FILE instead of stdout"
    ),
    eval = c(
      "Usage: fmrihrf eval [options]",
      "",
      "Core options:",
      "  --hrf NAME          HRF name from `fmrihrf list` [spmg1]",
      "  --from SEC          Grid start in seconds [0]",
      "  --to SEC            Grid end in seconds [32]",
      "  --by SEC            Grid step in seconds [0.5]",
      "  --times LIST        Comma-separated grid values; overrides from/to/by",
      "  --nbasis N          Basis count for generated HRFs [5]",
      "  --span SEC          HRF span in seconds [24]",
      "  --lag SEC           Shift HRF by this many seconds [0]",
      "  --width SEC         Block HRF width in seconds [0]",
      "  --amplitude VALUE   Event amplitude for HRF evaluation [1]",
      "  --duration SEC      Event duration for HRF evaluation [0]",
      "  --precision SEC     Internal block precision [0.2]",
      "  --normalize         Normalize columns to unit peak",
      "  --summate           Summate the block response (the default)",
      "  --no-summate        Average block response instead of summating",
      "  --json              Write JSON instead of CSV",
      "  --output FILE       Write output to FILE instead of stdout"
    ),
    regressor = c(
      "Usage: fmrihrf regressor [options]",
      "",
      "Options:",
      "  --onsets LIST       Comma-separated onset times in seconds",
      "  --events FILE       CSV/TSV with onset[,duration,amplitude] columns",
      "  --hrf NAME          HRF name from `fmrihrf list` [spmg1]",
      "  --blocklens LIST    Scans per block for acquisition grid",
      "  --tr LIST           Repetition time(s) in seconds",
      "  --start-time LIST   First acquisition offset(s); default TR / 2",
      "  --from SEC          Grid start when no sampling frame is supplied [0]",
      "  --to SEC            Grid end when no sampling frame is supplied;",
      "                      default last onset + span",
      "  --by SEC            Grid step when no sampling frame is supplied [1]",
      "  --duration LIST     Event duration(s) when --events is not used [0]",
      "  --amplitude LIST    Event amplitude(s) when --events is not used [1]",
      "  --nbasis N          Basis count for generated HRFs [5]",
      "  --span SEC          HRF/regressor span in seconds [24]",
      "  --precision SEC     Internal convolution precision [0.33]",
      "  --method METHOD     conv, fft, Rconv, or loop [conv]",
      "  --normalize         Normalize output columns to unit peak",
      "  --json              Write JSON instead of CSV",
      "  --output FILE       Write output to FILE instead of stdout"
    ),
    design = c(
      "Usage: fmrihrf design --events FILE --blocklens LIST --tr LIST [options]",
      "",
      "The events file must include onset, condition, and block columns.",
      "Optional duration and amplitude columns are used when present.",
      "",
      "Options:",
      "  --events FILE       CSV/TSV events table",
      "  --condition COL     Condition column name [condition]",
      "  --onset COL         Onset column name [onset]",
      "  --block COL         Block column name [block]",
      "  --duration COL      Duration column name [duration]",
      "  --amplitude COL     Amplitude column name [amplitude]",
      "  --blocklens LIST    Scans per block",
      "  --tr LIST           Repetition time(s) in seconds",
      "  --start-time LIST   First acquisition offset(s); default TR / 2",
      "  --hrf NAME          HRF name from `fmrihrf list` [spmg1]",
      "  --nbasis N          Basis count for generated HRFs [5]",
      "  --span SEC          HRF/regressor span in seconds [24]",
      "  --precision SEC     Internal convolution precision [0.33]",
      "  --method METHOD     conv, fft, Rconv, or loop [conv]",
      "  --sparse            Return sparse design internally before writing dense output",
      "  --json              Write JSON instead of CSV",
      "  --output FILE       Write output to FILE instead of stdout"
    ),
    .cli_usage_error("Unknown help topic: ", command)
  )
  cat(paste(text, collapse = "\n"), "\n", sep = "")
  0L
}

# Options accepted by each subcommand. `flags` are booleans (`false_flags`
# also accept --no-<flag>); `values` gives the type every value is parsed and
# validated as when the command line is read (see .cli_value()); `defaults`
# are already parsed. The help text lists the same options and defaults.
.cli_specs <- list(
  list = list(
    flags = c("details", "json"),
    values = c(output = "text")
  ),
  eval = list(
    flags = c("normalize", "json", "summate"),
    false_flags = "summate",
    values = c(hrf = "text", from = "number", to = "number", by = "step",
               times = "numbers", nbasis = "count", span = "number",
               lag = "number", width = "number", amplitude = "number",
               duration = "number", precision = "number", output = "text"),
    defaults = list(hrf = "spmg1", from = 0, to = 32, by = 0.5, nbasis = 5L,
                    span = 24, lag = 0, width = 0, amplitude = 1,
                    duration = 0, precision = 0.2, summate = TRUE)
  ),
  regressor = list(
    flags = c("normalize", "json"),
    values = c(onsets = "numbers", events = "text", hrf = "text",
               blocklens = "numbers", tr = "numbers", `start-time` = "numbers",
               from = "number", to = "number", by = "step",
               duration = "numbers", amplitude = "numbers", nbasis = "count",
               span = "number", precision = "number", method = "method",
               output = "text"),
    defaults = list(hrf = "spmg1", from = 0, by = 1, duration = 0,
                    amplitude = 1, nbasis = 5L, span = 24, precision = 0.33,
                    method = "conv")
  ),
  design = list(
    flags = c("sparse", "json"),
    values = c(events = "text", condition = "text", onset = "text",
               block = "text", duration = "text", amplitude = "text",
               blocklens = "numbers", tr = "numbers", `start-time` = "numbers",
               hrf = "text", nbasis = "count", span = "number",
               precision = "number", method = "method", output = "text"),
    defaults = list(condition = "condition", onset = "onset", block = "block",
                    duration = "duration", amplitude = "amplitude",
                    hrf = "spmg1", nbasis = 5L, span = 24, precision = 0.33,
                    method = "conv")
  )
)

.fmrihrf_cli_list <- function(opts) {
  .cli_write(list_available_hrfs(details = isTRUE(opts$details)), opts)
}

.fmrihrf_cli_eval <- function(opts) {
  grid <- .grid_from_options(opts)
  hrf <- .cli_hrf(opts, lag = opts$lag, width = opts$width,
                  summate = isTRUE(opts$summate),
                  normalize = isTRUE(opts$normalize))
  values <- evaluate(
    hrf, grid,
    amplitude = opts$amplitude,
    duration = opts$duration,
    precision = opts$precision,
    summate = isTRUE(opts$summate),
    normalize = isTRUE(opts$normalize)
  )
  .cli_write(.values_to_frame(grid, values), opts)
}

.fmrihrf_cli_regressor <- function(opts) {
  events <- .events_for_regressor(opts)
  reg <- regressor(
    onsets = events$onset,
    hrf = .cli_hrf(opts),
    duration = events$duration,
    amplitude = events$amplitude,
    span = opts$span
  )
  grid <- .regressor_grid(opts, events$onset)
  values <- evaluate(reg, grid = grid, precision = opts$precision,
                     method = opts$method, normalize = isTRUE(opts$normalize))
  .cli_write(.values_to_frame(grid, values), opts)
}

.fmrihrf_cli_design <- function(opts) {
  .require_options(opts, c("events", "blocklens", "tr"))
  events <- .read_events_table(opts$events)
  .require_columns(events, c(opts$onset, opts$condition, opts$block))
  sframe <- .sampling_frame_from_options(opts)

  design <- regressor_design(
    onsets = events[[opts$onset]],
    fac = events[[opts$condition]],
    block = events[[opts$block]],
    sframe = sframe,
    hrf = .cli_hrf(opts),
    duration = .column_or(events, opts$duration, 0),
    amplitude = .column_or(events, opts$amplitude, 1),
    span = opts$span,
    precision = opts$precision,
    method = opts$method,
    sparse = isTRUE(opts$sparse)
  )
  # regressor_design() names the columns after the condition levels.
  .cli_write(.values_to_frame(samples(sframe, global = TRUE), as.matrix(design)),
             opts)
}

# The HRF named by --hrf; `...` holds further getHRF() arguments.
.cli_hrf <- function(opts, ...) {
  getHRF(opts$hrf, nbasis = opts$nbasis, span = opts$span, ...)
}

# Parse `--key value`, `--key=value`, boolean `--flag` and `--no-flag`
# options as described by `spec` (one of .cli_specs) into a named list of
# parsed values, filled in from the spec's defaults.
.parse_cli_args <- function(args, spec) {
  out <- list()
  i <- 1L
  while (i <= length(args)) {
    token <- args[[i]]
    if (!startsWith(token, "--")) {
      .cli_usage_error("Unexpected positional argument: ", token)
    }
    token <- substring(token, 3L)
    value <- NULL
    if (grepl("=", token, fixed = TRUE)) {
      parts <- strsplit(token, "=", fixed = TRUE)[[1]]
      key <- parts[[1]]
      value <- paste(parts[-1], collapse = "=")
    } else {
      key <- token
    }

    negated <- startsWith(key, "no-") && substring(key, 4L) %in% spec$false_flags
    if (negated || key %in% spec$flags) {
      if (!is.null(value)) {
        .cli_usage_error("Boolean option does not take a value: --", key)
      }
      out[[if (negated) substring(key, 4L) else key]] <- !negated
    } else if (key %in% names(spec$values)) {
      if (is.null(value)) {
        i <- i + 1L
        if (i > length(args) || startsWith(args[[i]], "--")) {
          .cli_usage_error("Missing value for option: --", key)
        }
        value <- args[[i]]
      }
      out[[key]] <- .cli_value(value, spec$values[[key]], key)
    } else {
      .cli_usage_error("Unknown option: --", key)
    }
    i <- i + 1L
  }
  utils::modifyList(spec$defaults %||% list(), out)
}

# Parse and validate the value of option --<name> as `type`: "text" (any
# non-empty string), "method" (an evaluate() method), "numbers" (a
# comma-separated list), "number", "step" (a positive number) or "count" (a
# whole number).
.cli_value <- function(x, type, name) {
  invalid <- function(...) .cli_usage_error("--", name, ...)
  if (type == "text") {
    if (!nzchar(x)) invalid(" must not be empty")
    return(x)
  }
  if (type == "method") {
    methods <- c("conv", "loop", "fft", "Rconv")
    if (!x %in% methods) invalid(" must be one of: ", paste(methods, collapse = ", "))
    return(x)
  }
  values <- .parse_numeric_list(x, name)
  if (type == "numbers") {
    return(values)
  }
  if (length(values) != 1) invalid(" must be a single number")
  value <- values[[1]]
  if (type == "step" && value <= 0) invalid(" must be positive")
  if (type == "count") {
    if (!is.finite(value) || value %% 1 != 0) invalid(" must be a whole number")
    value <- as.integer(value)
  }
  value
}

.require_options <- function(opts, names) {
  missing <- setdiff(names, names(opts))
  if (length(missing) > 0) {
    .cli_usage_error("Missing required option(s): ",
                     paste(paste0("--", missing), collapse = ", "))
  }
}

.require_columns <- function(data, columns) {
  missing <- setdiff(columns, names(data))
  if (length(missing) > 0) {
    .cli_domain_error("Missing required column(s): ", paste(missing, collapse = ", "))
  }
}

.grid_from_options <- function(opts) {
  if (!is.null(opts$times)) {
    if (length(opts$times) == 0) {
      .cli_usage_error("--times must contain at least one number")
    }
    return(opts$times)
  }
  if (opts$to < opts$from) {
    .cli_usage_error("--to must be greater than or equal to --from")
  }
  seq(opts$from, opts$to, by = opts$by)
}

.regressor_grid <- function(opts, onsets) {
  if (!is.null(opts$blocklens) || !is.null(opts$tr)) {
    .require_options(opts, c("blocklens", "tr"))
    return(samples(.sampling_frame_from_options(opts), global = TRUE))
  }
  if (is.null(opts$to)) {
    opts$to <- (if (length(onsets) > 0) max(onsets) else 0) + opts$span
  }
  .grid_from_options(opts)
}

.sampling_frame_from_options <- function(opts) {
  sampling_frame(
    blocklens = opts$blocklens,
    TR = opts$tr,
    start_time = opts[["start-time"]] %||% (opts$tr / 2),
    precision = opts$precision
  )
}

.events_for_regressor <- function(opts) {
  if (!is.null(opts$events)) {
    events <- .read_events_table(opts$events)
    .require_columns(events, "onset")
    return(data.frame(
      onset = as.numeric(events$onset),
      duration = as.numeric(.column_or(events, "duration", 0)),
      amplitude = as.numeric(.column_or(events, "amplitude", 1))
    ))
  }
  if (is.null(opts$onsets)) {
    .cli_usage_error("Provide --onsets or --events")
  }
  n <- length(opts$onsets)
  data.frame(
    onset = opts$onsets,
    duration = recycle_or_error(opts$duration, n, "duration"),
    amplitude = recycle_or_error(opts$amplitude, n, "amplitude")
  )
}

.read_events_table <- function(path) {
  if (!file.exists(path)) {
    .cli_domain_error("File does not exist: ", path)
  }
  ext <- tolower(tools::file_ext(path))
  sep <- if (ext %in% c("tsv", "tab")) "\t" else ","
  utils::read.table(path, header = TRUE, sep = sep, stringsAsFactors = FALSE,
                    check.names = FALSE, comment.char = "", quote = "\"")
}

# Column `name` of an events table, or `default` when the table has none.
.column_or <- function(data, name, default) {
  if (name %in% names(data)) data[[name]] else default
}

.parse_numeric_list <- function(x, name) {
  pieces <- trimws(strsplit(x, ",", fixed = TRUE)[[1]])
  if (any(!nzchar(pieces))) {
    .cli_usage_error("--", name, " contains an empty value")
  }
  values <- suppressWarnings(as.numeric(pieces))
  if (anyNA(values)) {
    .cli_usage_error("--", name, " must contain only numeric values")
  }
  values
}

# A time column followed by one `value` column, or one column per basis
# function (unnamed columns become `basis<k>`).
.values_to_frame <- function(grid, values) {
  if (is.null(dim(values))) {
    return(data.frame(time = grid, value = as.numeric(values)))
  }
  values <- as.matrix(values)
  nm <- colnames(values) %||% character(ncol(values))
  empty <- !nzchar(nm)
  nm[empty] <- paste0("basis", which(empty))
  colnames(values) <- nm
  data.frame(time = grid, values, check.names = FALSE)
}

# Write a table as CSV, or JSON with --json, to stdout or --output, and
# return the success status.
.cli_write <- function(data, opts) {
  text <- if (isTRUE(opts$json)) {
    jsonlite::toJSON(data, dataframe = "rows", auto_unbox = TRUE,
                     pretty = TRUE, na = "null")
  } else {
    paste(utils::capture.output(utils::write.csv(data, row.names = FALSE, na = "")),
          collapse = "\n")
  }
  if (is.null(opts$output)) {
    cat(text, "\n", sep = "")
  } else {
    writeLines(text, opts$output, useBytes = TRUE)
  }
  0L
}

.cli_usage_error <- function(...) .cli_stop("fmrihrf_cli_usage_error", ...)

.cli_domain_error <- function(...) .cli_stop("fmrihrf_cli_domain_error", ...)

.cli_stop <- function(class, ...) {
  stop(structure(list(message = paste0(...), call = NULL),
                 class = c(class, "error", "condition")))
}

.fmrihrf_exec_dir <- function() {
  exec_dir <- system.file("exec", package = "fmrihrf")
  if (nzchar(exec_dir) && dir.exists(exec_dir)) {
    return(exec_dir)
  }

  source_exec <- file.path(getwd(), "exec")
  if (dir.exists(source_exec)) {
    return(source_exec)
  }

  if (requireNamespace("pkgload", quietly = TRUE)) {
    pkg_path <- tryCatch(pkgload::pkg_path(), error = function(e) NULL)
    if (!is.null(pkg_path)) {
      pkg_exec <- file.path(pkg_path, "exec")
      if (dir.exists(pkg_exec)) {
        return(pkg_exec)
      }
    }
  }

  ""
}
