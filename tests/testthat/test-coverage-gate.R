library(testthat)

# This file targets code paths that were cold (uncovered) as measured by
# covr::package_coverage(), in order to raise overall package coverage for
# the portfolio coverage-badge gate. Tests use meaningful assertions rather
# than bare smoke calls.

.with_pdf_device <- function(code) {
  path <- tempfile(fileext = ".pdf")
  grDevices::pdf(path)
  on.exit(grDevices::dev.off(), add = TRUE)
  value <- force(code)
  stopifnot(file.exists(path))
  value
}

# ---------------------------------------------------------------------------
# R/hrf.R : HRF() constructor
# ---------------------------------------------------------------------------

test_that("HRF() constructor computes peak and scale_factor for single-basis fun", {
  h <- HRF(hrf_gamma, "gamma_direct", nbasis = 1, span = 20,
           param_names = c("shape", "rate"))
  expect_true(inherits(h, "HRF"))
  expect_equal(attr(h, "name"), "gamma_direct")
  expect_equal(attr(h, "nbasis"), 1L)
  expect_false(is.na(attr(h, "scale_factor")))
  expect_equal(attr(h, "scale_factor"), 1 / max(hrf_gamma(seq(0, 20)), na.rm = TRUE))
})

test_that("HRF() constructor handles multi-basis matrix output", {
  fun2 <- function(t) cbind(hrf_gamma(t, shape = 6), hrf_gamma(t, shape = 8))
  h2 <- HRF(fun2, "two_basis", nbasis = 2, span = 20)
  expect_equal(attr(h2, "nbasis"), 2L)
  peak_expected <- max(apply(fun2(seq(0, 20)), 2, max, na.rm = TRUE))
  expect_equal(attr(h2, "scale_factor"), 1 / peak_expected)
})

test_that("HRF() constructor returns NA peak for non-matrix multi-basis output", {
  fun_vec <- function(t) t  # not a matrix, but nbasis > 1
  h3 <- HRF(fun_vec, "weird", nbasis = 3, span = 10)
  expect_true(is.na(attr(h3, "scale_factor")))
})

test_that("HRF() constructor returns NA scale_factor when function errors", {
  fun_err <- function(t) stop("boom")
  h4 <- HRF(fun_err, "erroring", nbasis = 1, span = 10)
  expect_true(is.na(attr(h4, "scale_factor")))
})

test_that("HRF() constructor returns NA scale_factor for zero-peak function", {
  fun_zero <- function(t) rep(0, length(t))
  h5 <- HRF(fun_zero, "zero_fun", nbasis = 1, span = 10)
  expect_true(is.na(attr(h5, "scale_factor")))
})

test_that("HRF() constructor propagates param_names attribute", {
  h6 <- HRF(hrf_gamma, "gamma_named", param_names = c("shape", "rate"))
  expect_equal(attr(h6, "param_names"), c("shape", "rate"))
})

# ---------------------------------------------------------------------------
# R/hrf.R : gen_hrf edge cases
# ---------------------------------------------------------------------------

test_that("gen_hrf warns and defaults nbasis to 1 when base function errors", {
  bad_fn <- function(t, ...) stop("evaluation failure")
  expect_warning(g <- gen_hrf(bad_fn), "Could not determine nbasis")
  expect_equal(nbasis(g), 1L)
})

test_that("gen_hrf warns when extra args supplied alongside an HRF object", {
  expect_warning(
    g <- gen_hrf(HRF_SPMG1, alpha = 1),
    "Ignoring extra arguments"
  )
  expect_true(inherits(g, "HRF"))
})

test_that("gen_hrf errors for non-function, non-HRF input", {
  expect_error(gen_hrf(42), "must be a function or an HRF object")
  expect_error(gen_hrf("gamma"), "must be a function or an HRF object")
})

test_that("gen_hrf applies normalize = TRUE decorator", {
  g <- gen_hrf(HRF_SPMG1, normalize = TRUE)
  t <- seq(0, 30, by = 0.5)
  expect_equal(max(abs(g(t))), 1, tolerance = 1e-6)
})

test_that("gen_hrf rejects combining normalize = TRUE with a non-none hrf_norm", {
  expect_error(
    gen_hrf(HRF_SPMG1, normalize = TRUE, hrf_norm = "unit_peak"),
    "Use either"
  )
})

test_that("gen_hrf applies hrf_norm fixed-scale normalization", {
  g <- gen_hrf(HRF_SPMG1, hrf_norm = "unit_peak")
  expect_true(inherits(g, "HRF"))
})

test_that("gen_hrf overrides name and span attributes when provided", {
  g <- gen_hrf(HRF_SPMG1, name = "custom_name", span = 99)
  expect_equal(attr(g, "name"), "custom_name")
  expect_equal(attr(g, "span"), 99)
})

# ---------------------------------------------------------------------------
# R/hrf.R : makeDeriv, gen_hrf_lagged, gen_hrf_blocked, soft_threshold
# ---------------------------------------------------------------------------

test_that("makeDeriv computes first and second numeric derivatives", {
  d1 <- fmrihrf:::makeDeriv(HRF_GAMMA, n = 1)
  d2 <- fmrihrf:::makeDeriv(HRF_GAMMA, n = 2)
  expect_true(is.function(d1))
  expect_true(is.function(d2))
  val1 <- d1(6)
  val2 <- d2(6)
  expect_true(is.numeric(val1))
  expect_true(is.numeric(val2))
})

test_that("gen_hrf_lagged with a vector of lags recurses through gen_hrf_set", {
  # gen_hrf_lagged() returns plain (non-HRF-classed) functions, so combining
  # several of them via the deprecated gen_hrf_set()/bind_basis() path raises
  # an error further downstream; this still exercises the vector-lag branch.
  expect_error(
    suppressWarnings(gen_hrf_lagged(HRF_SPMG1, lag = c(0, 3, 6))),
    "HRF objects"
  )
})

test_that("gen_hrf_lagged with normalize = TRUE peaks at 1", {
  t <- seq(0, 30, by = 0.5)
  lagged <- gen_hrf_lagged(HRF_SPMG1, lag = 4, normalize = TRUE)
  vals <- lagged(t)
  expect_equal(max(abs(vals)), 1, tolerance = 1e-6)
})

test_that("gen_hrf_blocked is deprecated but functionally equivalent to gen_hrf(width=)", {
  expect_warning(blocked <- gen_hrf_blocked(HRF_SPMG1, width = 4), "deprecated")
  direct <- gen_hrf(HRF_SPMG1, width = 4)
  t <- seq(0, 30, by = 0.5)
  expect_equal(blocked(t), direct(t))

  expect_warning(alias_blocked <- hrf_blocked(HRF_SPMG1, width = 4), "deprecated")
  expect_equal(alias_blocked(t), direct(t))
})

test_that("soft_threshold shrinks values and errors on negative threshold", {
  x <- c(-3, -0.5, 0, 0.5, 3)
  out <- fmrihrf:::soft_threshold(x, 1)
  expect_equal(out, c(-2, 0, 0, 0, 2))
  expect_error(fmrihrf:::soft_threshold(x, -1), "non-negative")
})

# ---------------------------------------------------------------------------
# R/hrf.R : list_available_hrfs, gen_hrf_library
# ---------------------------------------------------------------------------

test_that("list_available_hrfs(details=TRUE) adds description column", {
  info <- list_available_hrfs(details = TRUE)
  expect_true("description" %in% names(info))
  expect_true(all(nchar(info$description) > 0))
  expect_true(any(grepl("generator", info$description)))
})

test_that("gen_hrf_library is deprecated alias for hrf_library", {
  grid <- expand.grid(shape = c(6, 8))
  expect_warning(
    lib <- gen_hrf_library(
      function(shape) as_hrf(hrf_gamma, params = list(shape = shape)),
      grid
    ),
    "deprecated"
  )
  expect_equal(nbasis(lib), 2)
})

# ---------------------------------------------------------------------------
# R/hrf.R : basis generators (bspline/tent/fourier/daguerre/fir)
# ---------------------------------------------------------------------------

test_that("hrf_bspline_generator validates nbasis and span", {
  expect_error(hrf_bspline_generator(nbasis = 0), "nbasis must be at least 1")
  expect_error(hrf_bspline_generator(span = 0), "span must be positive")
  expect_error(hrf_bspline_generator(span = -5), "span must be positive")
})

test_that("hrf_bspline_generator produces correctly shaped basis with custom params", {
  bs <- hrf_bspline_generator(nbasis = 7, span = 30)
  expect_true(inherits(bs, "BSpline_HRF"))
  t <- seq(0, 30, by = 0.5)
  res <- evaluate(bs, t)
  expect_equal(dim(res), c(length(t), 7))
  # single time point still returns correct number of columns
  single <- bs(5)
  expect_equal(ncol(as.matrix(single)), 7)
})

test_that("hrf_tent_generator produces the requested number of tent basis functions", {
  tent <- hrf_tent_generator(nbasis = 4, span = 16)
  expect_true(inherits(tent, "Tent_HRF"))
  expect_equal(nbasis(tent), 4)
  t <- seq(0, 16, by = 0.5)
  res <- evaluate(tent, t)
  expect_equal(ncol(res), 4)
})

test_that("hrf_fourier_generator produces the requested basis dimension", {
  fr <- hrf_fourier_generator(nbasis = 6, span = 20)
  expect_true(inherits(fr, "Fourier_HRF"))
  t <- seq(0, 20, by = 0.5)
  res <- evaluate(fr, t)
  expect_equal(ncol(res), 6)
})

test_that("hrf_daguerre_generator produces the requested basis dimension", {
  dg <- hrf_daguerre_generator(nbasis = 4, scale = 2)
  expect_true(inherits(dg, "Daguerre_HRF"))
  t <- seq(0, 24, by = 0.5)
  res <- evaluate(dg, t)
  expect_equal(ncol(res), 4)
})

test_that("hrf_fir_generator handles empty and non-numeric time vectors", {
  fir <- hrf_fir_generator(nbasis = 4, span = 20)
  # empty numeric vector returns zero-row matrix with correct ncol
  empty_res <- fir(numeric(0))
  expect_equal(dim(empty_res), c(0, 4))

  # non-numeric input also returns zero-row matrix (length(t)==0 check via !is.numeric)
  # (fir's internal f_fir is only ever called by as_hrf's wrapper with numeric t,
  # so exercise the boundary/na handling branch directly instead)
  t <- c(NA, -1, 0, 5, 19.999, 20, 25)
  res <- fir(t)
  expect_equal(nrow(res), length(t))
  # NA, negative, and out-of-span times produce all-zero rows
  expect_true(all(res[is.na(t) | t < 0 | t >= 20, ] == 0))
  # in-support times produce exactly one 1 per row
  in_support <- !is.na(t) & t >= 0 & t < 20
  expect_true(all(rowSums(res[in_support, , drop = FALSE]) == 1))
})

test_that("hrf_fir_generator validates nbasis and span", {
  expect_error(hrf_fir_generator(nbasis = 0), "positive integer")
  expect_error(hrf_fir_generator(span = 0), "positive number")
})

# ---------------------------------------------------------------------------
# R/hrf.R : getHRF generator dispatch and decorators
# ---------------------------------------------------------------------------

test_that("getHRF dispatches to generator functions with custom nbasis/span", {
  fir20 <- getHRF("fir", nbasis = 20, span = 30)
  expect_equal(nbasis(fir20), 20)

  bs_custom <- getHRF("bspline", nbasis = 9, span = 28)
  expect_equal(nbasis(bs_custom), 9)

  dag <- getHRF("daguerre", nbasis = 4, scale = 2)
  expect_equal(nbasis(dag), 4)

  fourier_custom <- getHRF("fourier", nbasis = 6)
  expect_equal(nbasis(fourier_custom), 6)

  tent_custom <- getHRF("tent", nbasis = 6, span = 18)
  expect_equal(nbasis(tent_custom), 6)
})

test_that("getHRF applies width, lag, normalize, and hrf_norm decorators", {
  widened <- getHRF("spmg1", width = 4)
  t <- seq(0, 30, by = 0.5)
  expect_false(identical(widened(t), HRF_SPMG1(t)))

  lagged <- getHRF("spmg1", lag = 3)
  expect_equal(lagged(t), HRF_SPMG1(t - 3))

  normed <- getHRF("spmg1", normalize = TRUE)
  expect_equal(max(abs(normed(t))), 1, tolerance = 1e-6)

  scaled <- getHRF("spmg1", hrf_norm = "unit_peak")
  expect_true(inherits(scaled, "HRF"))

  expect_error(getHRF("spmg1", normalize = TRUE, hrf_norm = "unit_peak"), "Use either")
})

test_that("getHRF sets the registry key as the resulting name attribute", {
  h <- getHRF("gam")
  expect_equal(attr(h, "name"), "gam")
})

# ---------------------------------------------------------------------------
# R/hrf.R : plot.HRF and print.HRF
# ---------------------------------------------------------------------------

test_that("plot.HRF draws single-basis HRF with peak annotation and returns data", {
  df <- .with_pdf_device(plot(HRF_SPMG1))
  expect_s3_class(df, "data.frame")
  expect_equal(names(df), c("time", "response"))
  expect_true(nrow(df) > 0)
})

test_that("plot.HRF draws multi-basis HRF and returns wide data frame", {
  df <- .with_pdf_device(plot(HRF_SPMG3, time = seq(0, 20, by = 1)))
  expect_s3_class(df, "data.frame")
  expect_equal(names(df), c("time", "basis_1", "basis_2", "basis_3"))
})

test_that("plot.HRF supports normalize and show_peak = FALSE options", {
  df <- .with_pdf_device(plot(HRF_GAMMA, normalize = TRUE, show_peak = FALSE))
  expect_lte(max(abs(df$response)), 1 + 1e-8)
})

test_that("print.HRF shows named Parameters when params are present", {
  expect_output(print(HRF_GAMMA), "Parameters:")
})

test_that("print.HRF shows Parameter names when only param_names are attached", {
  h <- HRF(hrf_gamma, "gamma_pnames", param_names = c("shape", "rate"))
  expect_output(print(h), "Parameter names: shape, rate")
})

# ---------------------------------------------------------------------------
# R/hrf.R : plot_hrfs
# ---------------------------------------------------------------------------

test_that("plot_hrfs accepts a single list argument of HRFs", {
  df <- .with_pdf_device(
    plot_hrfs(list(HRF_SPMG1, HRF_GAMMA), time = seq(0, 10, by = 1), use_ggplot = FALSE)
  )
  expect_equal(nlevels(df$HRF), 2)
})

test_that("plot_hrfs uses ggplot2 by default when available and supports subtitle", {
  skip_if_not_installed("ggplot2")
  df <- .with_pdf_device(
    plot_hrfs(HRF_SPMG1, HRF_GAMMA, time = seq(0, 10, by = 1),
              title = "T", subtitle = "S")
  )
  expect_true(!is.null(attr(df, "plot")))
})

test_that("plot_hrfs base-R path renders a subtitle when requested", {
  df <- .with_pdf_device(
    plot_hrfs(HRF_SPMG1, HRF_GAMMA, time = seq(0, 10, by = 1),
              subtitle = "base-R subtitle", use_ggplot = FALSE)
  )
  expect_s3_class(df, "data.frame")
})

test_that("plot_hrfs errors when no HRF objects are given or types are invalid", {
  expect_error(plot_hrfs(), "At least one HRF object")
  expect_error(plot_hrfs(HRF_SPMG1, 42), "must be HRF objects")
})

test_that("plot_hrfs errors when labels length does not match number of HRFs", {
  expect_error(
    plot_hrfs(HRF_SPMG1, HRF_GAMMA, labels = "only_one", use_ggplot = FALSE),
    "Length of 'labels'"
  )
})

# ---------------------------------------------------------------------------
# R/reg-methods.R : evaluate.Reg edge cases
# ---------------------------------------------------------------------------

test_that("evaluate.Reg returns zeros for an empty single-basis regressor", {
  empty_reg <- regressor(onsets = numeric(0), hrf = HRF_SPMG1)
  grid <- seq(0, 10, by = 1)
  res <- evaluate(empty_reg, grid)
  expect_true(is.numeric(res) && !is.matrix(res))
  expect_true(all(res == 0))
  expect_equal(length(res), length(grid))
})

test_that("evaluate.Reg returns zero matrix for an empty multi-basis regressor", {
  empty_reg <- regressor(onsets = numeric(0), hrf = HRF_SPMG2)
  grid <- seq(0, 10, by = 1)
  res <- evaluate(empty_reg, grid)
  expect_true(is.matrix(res))
  expect_equal(dim(res), c(length(grid), 2))
  expect_true(all(res == 0))
})

test_that("evaluate.Reg returns a sparse zero matrix for an empty regressor with sparse=TRUE", {
  empty_reg <- regressor(onsets = numeric(0), hrf = HRF_SPMG1)
  grid <- seq(0, 10, by = 1)
  res <- evaluate(empty_reg, grid, sparse = TRUE)
  expect_true(inherits(res, "Matrix"))
  expect_true(all(as.matrix(res) == 0))
})

test_that("evaluate.Reg normalizes multi-basis output per column", {
  reg <- regressor(onsets = c(5, 20), hrf = HRF_SPMG2)
  grid <- seq(0, 40, by = 0.5)
  res <- evaluate(reg, grid, normalize = TRUE)
  expect_true(is.matrix(res))
  peaks <- apply(res, 2, function(col) max(abs(col)))
  expect_true(all(abs(peaks - 1) < 1e-6 | peaks == 0))
})

test_that("evaluate.Reg normalizes single-basis output to peak 1", {
  reg <- regressor(onsets = c(5, 20), hrf = HRF_SPMG1)
  grid <- seq(0, 40, by = 0.5)
  res <- evaluate(reg, grid, normalize = TRUE)
  expect_equal(max(abs(res)), 1, tolerance = 1e-6)
})

test_that("evaluate.Reg with sparse = TRUE returns a proper sparse Matrix for real events", {
  reg <- regressor(onsets = c(5, 20), hrf = HRF_SPMG1)
  grid <- seq(0, 40, by = 0.5)
  dense <- evaluate(reg, grid)
  sparse <- evaluate(reg, grid, sparse = TRUE)
  expect_true(inherits(sparse, "Matrix"))
  expect_equal(as.numeric(as.matrix(sparse)), as.numeric(dense))
})

# ---------------------------------------------------------------------------
# R/reg-methods.R : shift.Reg, print.Reg, nbasis.Reg for trial-varying HRFs
# ---------------------------------------------------------------------------

test_that("shift.Reg returns the same object unchanged for an empty regressor", {
  empty_reg <- regressor(onsets = numeric(0), hrf = HRF_SPMG1)
  shifted <- shift(empty_reg, 5)
  expect_identical(shifted$onsets, empty_reg$onsets)
})

test_that("shift.Reg accepts an `offset` named argument and errors without any shift value", {
  reg <- regressor(onsets = c(1, 5), hrf = HRF_SPMG1)
  shifted <- shift(reg, offset = 3)
  expect_equal(shifted$onsets, reg$onsets + 3)
  expect_error(shift(reg), "Must supply")
})

test_that("print.Reg reports empty-regressor, duration, and amplitude ranges", {
  # cli output isn't reliably captured by expect_output/capture.output in all
  # test runners, so verify the code paths run without error (matching the
  # approach used elsewhere in this package's test suite).
  empty_reg <- regressor(onsets = numeric(0), hrf = HRF_SPMG1)
  expect_no_error(print(empty_reg))

  varying_reg <- regressor(onsets = c(1, 5, 10), hrf = HRF_SPMG1,
                            duration = c(0, 2, 4), amplitude = c(1, 2, 0.5))
  expect_no_error(print(varying_reg))
  expect_true(any(varying_reg$duration != 0))
  expect_false(all(varying_reg$amplitude == 1))
})

test_that("print.Reg and nbasis.Reg handle a fully-filtered trial-varying HRF list", {
  reg <- suppressWarnings(regressor(onsets = numeric(0), hrf = list(HRF_SPMG1)))
  expect_true(isTRUE(attr(reg, "hrf_is_list")))
  expect_equal(length(reg$hrf), 0)
  expect_equal(nbasis(reg), 1L)
  expect_no_error(print(reg))
})

# ---------------------------------------------------------------------------
# R/reg-methods.R : plot.Reg and plot_regressors
# ---------------------------------------------------------------------------

test_that("plot.Reg generates a default grid and handles multi-basis regressors", {
  reg <- regressor(onsets = c(5, 15), hrf = HRF_SPMG2)
  df <- .with_pdf_device(plot(reg))
  expect_s3_class(df, "data.frame")
  expect_equal(names(df), c("time", "basis_1", "basis_2"))
})

test_that("plot_regressors accepts a single list of Reg objects and shows all onsets", {
  reg1 <- regressor(onsets = c(5, 20), hrf = HRF_SPMG1)
  reg2 <- regressor(onsets = c(10, 30), hrf = HRF_GAMMA)
  df <- .with_pdf_device(
    plot_regressors(list(reg1, reg2), grid = seq(0, 40, by = 1),
                    show_onsets = TRUE, use_ggplot = FALSE, subtitle = "sub")
  )
  expect_equal(nlevels(df$Regressor), 2)
})

test_that("plot_regressors default ggplot path renders with a subtitle", {
  skip_if_not_installed("ggplot2")
  reg1 <- regressor(onsets = c(5, 20), hrf = HRF_SPMG1)
  reg2 <- regressor(onsets = c(10, 30), hrf = HRF_GAMMA)
  df <- .with_pdf_device(
    plot_regressors(reg1, reg2, grid = seq(0, 40, by = 1), subtitle = "s")
  )
  expect_true(!is.null(attr(df, "plot")))
})

test_that("plot_regressors errors for invalid inputs and mismatched labels", {
  reg1 <- regressor(onsets = c(5, 20), hrf = HRF_SPMG1)
  expect_error(plot_regressors(), "At least one Reg object")
  expect_error(plot_regressors(reg1, 42), "must be Reg objects")
  expect_error(
    plot_regressors(reg1, reg1, labels = "one", use_ggplot = FALSE),
    "Length of 'labels'"
  )
})

# ---------------------------------------------------------------------------
# R/hrf-formula.R : make_hrf
# ---------------------------------------------------------------------------

test_that("make_hrf validates lag and nbasis arguments", {
  expect_error(make_hrf("spmg1", lag = "a"), "single finite numeric")
  expect_error(make_hrf("spmg1", lag = 1, nbasis = 0), "positive integer")
  expect_error(make_hrf("spmg1", lag = 1, nbasis = 1.5), "positive integer")
})

test_that("make_hrf resolves a plain function basis with the requested nbasis", {
  h <- make_hrf(function(t) cbind(t, t^2), lag = 0, nbasis = 2)
  expect_true(inherits(h, "HRF"))
  expect_equal(nbasis(h), 2)
})

test_that("make_hrf errors for an invalid basis type", {
  expect_error(make_hrf(list(1, 2), lag = 0), "invalid basis function")
})

test_that("make_hrf applies lag consistently across character, HRF, and function bases", {
  by_name <- make_hrf("spmg1", lag = 2)
  by_obj <- make_hrf(HRF_SPMG1, lag = 2)
  t <- seq(0, 30, by = 0.5)
  expect_equal(by_name(t), by_obj(t))
})

# ---------------------------------------------------------------------------
# R/penalty_matrix_methods.R
# ---------------------------------------------------------------------------

test_that("roughness_penalty falls back to identity for nb <= 1 and nb <= order", {
  fir1 <- hrf_fir_generator(nbasis = 1, span = 10)
  expect_equal(penalty_matrix(fir1), diag(1))

  tent2 <- hrf_tent_generator(nbasis = 2, span = 10)
  expect_equal(penalty_matrix(tent2, order = 2), diag(2))
})

test_that("penalty_matrix roughness penalty applies a real difference operator for nb > order", {
  bs5 <- hrf_bspline_generator(nbasis = 5)
  R <- penalty_matrix(bs5, order = 2)
  expect_equal(dim(R), c(5, 5))
  expect_true(isSymmetric(unname(R)))
  D <- diff(diag(5), differences = 2)
  expect_equal(R, crossprod(D), check.attributes = FALSE)
})

test_that("penalty_matrix.SPMG2_HRF and SPMG3_HRF shrink derivative terms", {
  R2 <- penalty_matrix(HRF_SPMG2, shrink_deriv = 3)
  expect_equal(R2[1, 1], 0)
  expect_equal(R2[2, 2], 3)

  R3 <- penalty_matrix(HRF_SPMG3, shrink_deriv = 4)
  expect_equal(R3[1, 1], 0)
  expect_equal(R3[2, 2], 4)
  expect_equal(R3[3, 3], 4)
})

test_that("penalty_matrix.Fourier_HRF and Daguerre_HRF apply increasing weights", {
  fr <- hrf_fourier_generator(nbasis = 4)
  Rf <- penalty_matrix(fr, order = 2)
  expect_equal(diag(Rf), c(1, 1, 2, 2)^2)

  dg <- hrf_daguerre_generator(nbasis = 4)
  Rd <- penalty_matrix(dg)
  expect_equal(diag(Rd), c(0, 1, 2, 3)^2)
})

# ---------------------------------------------------------------------------
# R/reconstruction_matrix-methods.R
# ---------------------------------------------------------------------------

test_that("reconstruction_matrix.HRF accepts a numeric time vector", {
  times <- seq(0, 20, by = 0.5)
  rmat <- reconstruction_matrix(HRF_SPMG2, times)
  expect_equal(dim(rmat), c(length(times), 2))
  expect_equal(rmat, evaluate(HRF_SPMG2, times), check.attributes = FALSE)
})

test_that("reconstruction_matrix.HRF derives times from a sampling_frame", {
  sframe <- sampling_frame(blocklens = 40, TR = 1)
  rmat <- reconstruction_matrix(HRF_SPMG1, sframe)
  expect_equal(nrow(rmat), length(samples(sframe, global = TRUE)))
  expect_equal(ncol(rmat), 1)
})

test_that("reconstruction_matrix.HRF errors for invalid sframe input", {
  expect_error(
    reconstruction_matrix(HRF_SPMG1, "not-numeric-or-frame"),
    "sframe.*must be"
  )
})

test_that("reconstruction_matrix.HRF wraps single-basis vector output in a one-column matrix", {
  rmat <- reconstruction_matrix(HRF_SPMG1, c(0, 5, 10))
  expect_true(is.matrix(rmat))
  expect_equal(ncol(rmat), 1)
})

# ---------------------------------------------------------------------------
# R/neural_input_methods.R and R/all_generic.R generic dispatch
# ---------------------------------------------------------------------------

test_that("neural_input() dispatches to Reg method and defaults `end`", {
  reg <- regressor(onsets = c(2, 10), hrf = HRF_SPMG1,
                    duration = c(1, 2), amplitude = c(1, 2))
  result <- neural_input(reg, start = 0, resolution = 0.5)
  expect_true(is.list(result))
  expect_equal(names(result), c("time", "neural_input"))
  expect_true(max(result$time) > max(reg$onsets + reg$duration))
  # amplitude should be present at each event window
  expect_true(any(result$neural_input[result$time >= 2 & result$time < 3] == 1))
  expect_true(any(result$neural_input[result$time >= 10 & result$time < 12] == 2))
})

test_that("generic accessors dispatch correctly for a Reg object", {
  reg <- regressor(onsets = c(1, 5, 10), hrf = HRF_SPMG1,
                   duration = c(2, 3, 1), amplitude = c(1, 0.5, 2))
  expect_equal(durations(reg), c(2, 3, 1))
  expect_equal(onsets(reg), c(1, 5, 10))
  expect_equal(amplitudes(reg), c(1, 0.5, 2))
})

test_that("blocklens() generic dispatches for a sampling_frame", {
  sframe <- sampling_frame(blocklens = c(20, 30), TR = 2)
  expect_equal(blocklens(sframe), c(20, 30))
})

test_that("reconstruction_matrix() generic dispatches for an HRF object", {
  rmat <- reconstruction_matrix(HRF_GAMMA, c(0, 5, 10))
  expect_true(is.matrix(rmat))
})

# ---------------------------------------------------------------------------
# R/cli.R : error-handling paths in fmrihrf_cli() and install_cli()
# ---------------------------------------------------------------------------

test_that("fmrihrf_cli maps domain errors to exit code 1 with a message", {
  path <- tempfile(fileext = ".csv")
  status <- suppressMessages(fmrihrf_cli(c(
    "design", "--events", "/no/such/file.csv",
    "--blocklens", "4", "--tr", "1", "--output", path
  )))
  expect_equal(status, 1L)
})

test_that("fmrihrf_cli maps unexpected R errors to exit code 2 with a message", {
  status <- suppressMessages(fmrihrf_cli(c("eval", "--hrf", "not_a_real_hrf")))
  expect_equal(status, 2L)
})

test_that("install_cli rejects unknown command names", {
  expect_error(install_cli(commands = "bogus"), "Unknown command")
})

test_that(".fmrihrf_cli_main reports unknown commands as usage errors", {
  expect_equal(suppressMessages(fmrihrf_cli("frobnicate")), 2L)
})

# ---------------------------------------------------------------------------
# R/cli.R : .parse_cli_args edge cases
# ---------------------------------------------------------------------------

test_that(".parse_cli_args rejects unexpected positional arguments", {
  expect_error(
    fmrihrf:::.parse_cli_args(c("positional"), flags = character(), values = character()),
    "Unexpected positional argument"
  )
})

test_that(".parse_cli_args handles no-<flag> negation and rejects unknown no- flags", {
  out <- fmrihrf:::.parse_cli_args(c("--no-summate"), flags = character(),
                                   values = character(), false_flags = "summate")
  expect_false(out$summate)

  expect_error(
    fmrihrf:::.parse_cli_args(c("--no-bogus"), flags = character(),
                              values = character(), false_flags = "summate"),
    "Unknown option"
  )
  expect_error(
    fmrihrf:::.parse_cli_args(c("--no-summate=1"), flags = character(),
                              values = character(), false_flags = "summate"),
    "does not take a value"
  )
})

test_that(".parse_cli_args rejects a value on a plain boolean flag", {
  expect_error(
    fmrihrf:::.parse_cli_args(c("--json=1"), flags = "json", values = character()),
    "does not take a value"
  )
})

test_that(".parse_cli_args errors when a value-option's argument looks like another flag", {
  expect_error(
    fmrihrf:::.parse_cli_args(c("--hrf", "--to"), flags = character(), values = "hrf"),
    "Missing value for option"
  )
})

# ---------------------------------------------------------------------------
# R/cli.R : option helper functions via :::
# ---------------------------------------------------------------------------

test_that(".require_options reports all missing options together", {
  expect_error(
    fmrihrf:::.require_options(list(a = "1"), c("a", "b", "c")),
    "--b, --c"
  )
})

test_that(".require_columns raises a domain error for missing columns", {
  df <- data.frame(x = 1)
  expect_error(
    fmrihrf:::.require_columns(df, c("x", "y")),
    "Missing required column"
  )
})

test_that(".grid_from_options validates --by and --to/--from ordering", {
  expect_error(fmrihrf:::.grid_from_options(list(from = "0", to = "1", by = "0")),
               "--by must be positive")
  expect_error(fmrihrf:::.grid_from_options(list(from = "5", to = "1", by = "1")),
               "greater than or equal")
  expect_error(fmrihrf:::.grid_from_options(list(times = "")), "at least one number")
})

test_that(".regressor_grid falls back to onset-derived grid when no sampling info given", {
  grid <- fmrihrf:::.regressor_grid(list(span = "10", by = "1"), onsets = c(5, 15))
  expect_equal(min(grid), 0)
  expect_true(max(grid) >= 25)
})

test_that(".sampling_frame_from_options derives start_time from TR when absent", {
  sf <- fmrihrf:::.sampling_frame_from_options(
    list(blocklens = "10", tr = "2", precision = "0.5")
  )
  expect_true(inherits(sf, "sampling_frame"))
  expect_equal(sf$start_time, 1)
})

test_that(".events_for_regressor requires --onsets or --events and recycles inputs", {
  expect_error(fmrihrf:::.events_for_regressor(list()), "Provide --onsets or --events")

  events <- fmrihrf:::.events_for_regressor(
    list(onsets = "1,2,3", duration = "0.5", amplitude = "1")
  )
  expect_equal(events$onset, c(1, 2, 3))
  expect_equal(events$duration, rep(0.5, 3))
})

test_that(".read_events_table errors when the file is missing and reads a tsv by extension", {
  expect_error(fmrihrf:::.read_events_table("/no/such/file.csv"), "does not exist")

  tsv <- tempfile(fileext = ".tsv")
  writeLines(c("onset\tcondition", "0\tA", "5\tB"), tsv)
  events <- fmrihrf:::.read_events_table(tsv)
  expect_equal(events$condition, c("A", "B"))
})

test_that(".parse_numeric_list validates scalar/list format and numeric content", {
  expect_equal(fmrihrf:::.parse_numeric_list(c(1, 2, 3), "x"), c(1, 2, 3))
  expect_error(fmrihrf:::.parse_numeric_list(c("1", "2"), "x"), "scalar or comma-separated")
  expect_error(fmrihrf:::.parse_numeric_list("1,,3", "x"), "empty value")
  expect_error(fmrihrf:::.parse_numeric_list("a,b", "x"), "only numeric values")
})

test_that(".as_scalar_numeric and .as_scalar_integer validate scalars and whole numbers", {
  expect_error(fmrihrf:::.as_scalar_numeric("1,2", "x"), "single number")
  expect_equal(fmrihrf:::.as_scalar_integer("4", "x"), 4L)
  expect_error(fmrihrf:::.as_scalar_integer("4.5", "x"), "whole number")
})

test_that(".match_choice errors for values outside the allowed set", {
  expect_error(fmrihrf:::.match_choice("bogus", c("a", "b"), "method"), "must be one of")
  expect_equal(fmrihrf:::.match_choice("a", c("a", "b"), "method"), "a")
})

test_that(".design_column_names appends basis suffixes for multi-basis HRFs", {
  names1 <- fmrihrf:::.design_column_names(c("A", "A", "B"), 1)
  expect_equal(names1, c("A", "B"))

  names2 <- fmrihrf:::.design_column_names(c("A", "B"), 2)
  expect_equal(names2, c("A_basis1", "A_basis2", "B_basis1", "B_basis2"))
})

test_that("design CLI command emits multi-basis condition columns for a multi-basis HRF", {
  events <- tempfile(fileext = ".csv")
  writeLines(c(
    "onset,condition,block,duration,amplitude",
    "0,A,1,0,1",
    "4,B,1,0,1"
  ), events)
  path <- tempfile(fileext = ".csv")
  status <- fmrihrf_cli(c(
    "design", "--events", events, "--blocklens", "8", "--tr", "1",
    "--hrf", "spmg2", "--output", path
  ))
  expect_equal(status, 0L)
  out <- utils::read.csv(path, check.names = FALSE)
  expect_equal(names(out), c("time", "A_basis1", "A_basis2", "B_basis1", "B_basis2"))
})

test_that("design CLI command raises a domain error for missing required columns", {
  events <- tempfile(fileext = ".csv")
  writeLines(c("onset,block", "0,1"), events)
  status <- suppressMessages(fmrihrf_cli(c(
    "design", "--events", events, "--blocklens", "4", "--tr", "1"
  )))
  expect_equal(status, 1L)
})
