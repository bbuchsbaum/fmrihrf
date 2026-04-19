library(testthat)

# make_hrf() is the unified HRF constructor. These tests lock in backward
# compatibility with the old gen_hrf()/getHRF() interfaces and verify the
# decorator pipeline (width -> lag -> normalise) composes correctly.

t_grid <- seq(0, 24, by = 0.5)

test_that("character basis returns pre-defined HRF for spmg1", {
  h <- make_hrf("spmg1")
  expect_s3_class(h, "HRF")
  expect_equal(attr(h, "name"), "spmg1")
  expect_equal(h(t_grid), HRF_SPMG1(t_grid))
})

test_that("character basis forwards nbasis and span to generators", {
  h <- make_hrf("fir", nbasis = 20, span = 30)
  expect_equal(nbasis(h), 20L)
  expect_equal(attr(h, "span"), 30)
  expect_equal(attr(h, "name"), "fir")
})

test_that("character basis forwards extra args to generators", {
  h <- make_hrf("daguerre", nbasis = 4, scale = 3)
  expect_equal(nbasis(h), 4L)
  expect_equal(attr(h, "name"), "daguerre")
})

test_that("HRF basis is used directly", {
  h <- make_hrf(HRF_GAMMA)
  expect_equal(h(t_grid), HRF_GAMMA(t_grid))
})

test_that("function basis is wrapped with supplied nbasis", {
  custom <- function(t) exp(-t / 5)
  h <- make_hrf(custom, nbasis = 1)
  expect_s3_class(h, "HRF")
  expect_equal(nbasis(h), 1L)
  expect_equal(h(t_grid), custom(t_grid))
})

test_that("function basis forwards ... to the underlying function", {
  h <- make_hrf(hrf_gamma, shape = 8, rate = 1.2)
  expect_equal(h(t_grid), hrf_gamma(t_grid, shape = 8, rate = 1.2))
})

test_that("lag decorator is applied when lag != 0", {
  h <- make_hrf("spmg1", lag = 3)
  expect_equal(h(t_grid), HRF_SPMG1(t_grid - 3))
})

test_that("block decorator is applied when width > 0", {
  h <- make_hrf("spmg1", width = 4, precision = 0.2)
  manual <- block_hrf(HRF_SPMG1, width = 4, precision = 0.2)
  expect_equal(h(t_grid), manual(t_grid))
})

test_that("normalize decorator is applied after other decorators", {
  h <- make_hrf("gaussian", width = 2, lag = 1, normalize = TRUE)
  # Use a dense grid so we land close enough to the true peak.
  fine <- seq(0, 30, by = 0.01)
  expect_equal(max(abs(h(fine))), 1, tolerance = 1e-4)
})

test_that("decorator order is width -> lag -> normalize", {
  h_auto <- make_hrf("spmg1", width = 3, lag = 2, normalize = TRUE)
  h_manual <- normalise_hrf(lag_hrf(block_hrf(HRF_SPMG1, width = 3), lag = 2))
  expect_equal(h_auto(t_grid), h_manual(t_grid), tolerance = 1e-10)
})

test_that("positional compatibility: make_hrf(basis, lag, nbasis) still works", {
  h <- make_hrf("fir", 0, 8)
  expect_equal(nbasis(h), 8L)

  # Backward-compat: single positional lag for pre-defined HRF
  h2 <- make_hrf("spmg1", 2)
  expect_equal(h2(t_grid), HRF_SPMG1(t_grid - 2))
})

test_that("invalid lag and nbasis are rejected", {
  expect_error(make_hrf("spmg1", lag = c(1, 2)), "single finite")
  expect_error(make_hrf("spmg1", lag = NA), "single finite")
  expect_error(make_hrf("spmg1", nbasis = 0), "positive integer")
  expect_error(make_hrf("spmg1", nbasis = 1.5), "positive integer")
})

test_that("invalid basis raises a clear error", {
  expect_error(make_hrf(42), "invalid basis")
  expect_error(make_hrf(list(1, 2)), "invalid basis")
})

test_that("negative width is rejected", {
  expect_error(make_hrf("spmg1", width = -1), "non-negative")
})

test_that("gen_hrf is deprecated but still delegates correctly", {
  withCallingHandlers(
    h <- gen_hrf(HRF_SPMG1, lag = 2),
    warning = function(w) invokeRestart("muffleWarning")
  )
  expect_equal(h(t_grid), HRF_SPMG1(t_grid - 2))
  expect_warning(gen_hrf(HRF_SPMG1, lag = 1), "deprecated|make_hrf")
})

test_that("getHRF is deprecated but still delegates correctly", {
  withCallingHandlers(
    h <- getHRF("fir", nbasis = 10, span = 20),
    warning = function(w) invokeRestart("muffleWarning")
  )
  expect_equal(nbasis(h), 10L)
  expect_equal(attr(h, "span"), 20)
  expect_warning(getHRF("spmg1"), "deprecated|make_hrf")
})

test_that("gen_hrf_lagged is deprecated and now returns an HRF", {
  withCallingHandlers(
    h <- gen_hrf_lagged(HRF_SPMG1, lag = 3),
    warning = function(w) invokeRestart("muffleWarning")
  )
  expect_s3_class(h, "HRF")
  expect_equal(h(t_grid), HRF_SPMG1(t_grid - 3))
})
