# Regression tests for the defects reported in GitHub issue #45.

# --- Issue 1: block quadrature is the same on every evaluation path ---------

test_that("epoch regressor amplitude converges as precision decreases", {
  grid <- seq(0, 80, by = 2)
  reg <- regressor(onsets = c(10, 30), hrf = HRF_SPMG1, duration = 4)

  peaks <- vapply(c(0.5, 0.2, 0.1, 0.05), function(p) {
    max(abs(evaluate(reg, grid, precision = p)))
  }, numeric(1))

  # Previously this grew as ~1/precision (13.1 -> 60.6 between 0.5 and 0.1).
  # It must now settle on the integral of the HRF over the block.
  expect_lt(max(peaks) - min(peaks), 0.15)

  reference <- max(abs(evaluate(HRF_SPMG1, grid - 10, duration = 4,
                                precision = 0.05)))
  expect_equal(peaks[length(peaks)], reference, tolerance = 1e-3)
})

test_that("the surviving evaluation methods agree on block regressors", {
  grid <- seq(0, 80, by = 2)
  reg <- regressor(onsets = c(10, 30), hrf = HRF_SPMG1, duration = 4)

  res <- lapply(c("conv", "loop"), function(m) {
    as.vector(evaluate(reg, grid, precision = 0.1, method = m))
  })
  for (i in 2:length(res)) {
    expect_equal(res[[i]], res[[1]], tolerance = 1e-3)
  }
})

test_that("point-event regressors stay precision invariant", {
  grid <- seq(0, 80, by = 2)
  reg <- regressor(onsets = c(10, 30), hrf = HRF_SPMG1, duration = 0)
  expect_equal(as.vector(evaluate(reg, grid, precision = 0.5)),
               as.vector(evaluate(reg, grid, precision = 0.05)),
               tolerance = 1e-6)
})

# --- Issue 2: summate reaches every engine ---------------------------------

test_that("summate = FALSE is honoured by all evaluation methods", {
  grid <- seq(0, 80, by = 2)
  reg <- regressor(onsets = c(10, 30), hrf = HRF_SPMG1, duration = 4,
                   summate = FALSE)

  reference <- max(abs(evaluate(HRF_SPMG1, seq(0, 40, by = 2) - 10,
                                duration = 4, precision = 0.1,
                                summate = FALSE)))

  for (m in c("conv", "loop")) {
    peak <- max(abs(evaluate(reg, grid, precision = 0.1, method = m)))
    # Before the fix the compiled engines silently ignored summate and
    # returned the summated value (~60) on all but method = "loop".
    expect_equal(peak, reference, tolerance = 1e-2,
                 info = paste("method =", m))
  }
})

test_that("summate = FALSE is continuous as duration approaches zero", {
  grid <- seq(0, 40, by = 0.1)
  peak0 <- max(abs(evaluate(HRF_SPMG1, grid - 10, duration = 0)))
  peak_small <- max(abs(evaluate(HRF_SPMG1, grid - 10, duration = 0.05,
                                 precision = 0.2, summate = FALSE)))
  expect_equal(peak_small, peak0, tolerance = 1e-2)
})

test_that("evaluate.HRF block branch does not key on precision", {
  grid <- seq(0, 40, by = 0.1)
  # duration = 0.19 straddles the old `duration < precision` threshold: at
  # precision 0.2 it was treated as an impulse, at precision 0.05 as a block,
  # a five-fold jump driven purely by the quadrature step.
  coarse <- max(abs(evaluate(HRF_SPMG1, grid - 10, duration = 0.19,
                             precision = 0.2)))
  fine <- max(abs(evaluate(HRF_SPMG1, grid - 10, duration = 0.19,
                           precision = 0.05)))
  expect_equal(coarse, fine, tolerance = 1e-2)
})

# --- Issue 3: scalar t on vapply-built bases -------------------------------

test_that("hrf_sine and hrf_fourier accept a scalar t", {
  expect_equal(dim(hrf_fourier(-1, span = 24, nbasis = 4)), c(1L, 4L))
  expect_equal(dim(hrf_sine(-1, span = 24, N = 4)), c(1L, 4L))
  expect_equal(dim(hrf_fourier(5, span = 24, nbasis = 4)), c(1L, 4L))

  # Out of support means zero, not an error.
  expect_true(all(hrf_fourier(-1, span = 24, nbasis = 4) == 0))
  expect_true(all(hrf_sine(-1, span = 24, N = 4) == 0))

  # A scalar query must agree with the same point inside a vector query.
  vec <- hrf_fourier(c(4, 5, 6), span = 24, nbasis = 4)
  expect_equal(as.vector(hrf_fourier(5, span = 24, nbasis = 4)),
               as.vector(vec[2, ]))
})

test_that("decorators can evaluate fourier bases at scalar negative lag", {
  hf <- as_hrf(function(t) hrf_fourier(t, span = 24, nbasis = 4),
               name = "fourier", nbasis = 4, span = 24)
  expect_silent(lag_hrf(hf, 2)(1))
  expect_true(all(lag_hrf(hf, 2)(1) == 0))
})

# --- Issue 4: daguerre normalization is fixed at construction --------------

test_that("daguerre_basis does not normalize against the caller's grid", {
  f <- fmrihrf:::daguerre_basis
  at_zero_alone <- f(0, n_basis = 3, scale = 4)[1]

  grid <- seq(-2, 32, by = 0.5)
  at_zero_in_grid <- f(grid, n_basis = 3, scale = 4)[which(grid == 0), 1]

  expect_equal(at_zero_alone, at_zero_in_grid)

  grid2 <- seq(0, 32, by = 0.5)
  expect_equal(f(grid2, n_basis = 3, scale = 4)[1, 1], at_zero_alone)
})

test_that("daguerre basis carries no pre-onset response", {
  f <- fmrihrf:::daguerre_basis
  expect_true(all(f(c(-10, -1, -0.1), n_basis = 3, scale = 4) == 0))
})

# --- Issue 5: B-spline knots fixed by span, not by t -----------------------

test_that("HRF_BSPLINE is a function of t alone", {
  gA <- seq(0, 24, by = 0.5)
  gB <- sort(unique(c(seq(0, 23.76, by = 0.33), 8)))
  gC <- seq(0, 24, by = 2)

  at8 <- function(g) evaluate(fmrihrf::HRF_BSPLINE, g)[which(g == 8), ]

  expect_equal(at8(gB), at8(gA))
  expect_equal(at8(gC), at8(gA))
})

test_that("HRF_BSPLINE agrees with hrf_bspline", {
  g <- seq(0, 24, by = 0.5)
  expect_equal(
    unname(evaluate(fmrihrf::HRF_BSPLINE, g)),
    unname(matrix(as.numeric(hrf_bspline(g, span = 24, N = 5, degree = 3)),
                  nrow = length(g))),
    tolerance = 1e-10
  )
})

test_that("HRF_BSPLINE is not degenerate on a single time point", {
  scalar <- evaluate(fmrihrf::HRF_BSPLINE, 0.33)
  from_vector <- evaluate(fmrihrf::HRF_BSPLINE, c(0.33, 8, 16))[1, ]
  expect_equal(as.vector(scalar), as.vector(from_vector))
  # The old code collapsed the knots onto the supplied point and returned
  # (0, 0.986, 0.014, 0, 0) here.
  expect_lt(scalar[1, 2], 0.5)
})

# --- Issue 6: causal support ----------------------------------------------

test_that("HRF kernels carry no response before the event", {
  tneg <- c(-10, -5, -1, -0.1)
  expect_true(all(hrf_gaussian(tneg) == 0))
  expect_true(all(hrf_mexhat(tneg) == 0))
  expect_true(all(hrf_inv_logit(tneg) == 0))
  expect_true(all(hrf_lwu(tneg) == 0))

  # Unchanged for kernels that were already causal.
  expect_true(all(hrf_spmg1(tneg) == 0))
  expect_true(all(hrf_gamma(tneg) == 0))

  # Still non-trivial inside the support.
  expect_gt(max(hrf_gaussian(seq(0, 24, by = 0.1))), 0.1)
  expect_gt(max(abs(hrf_mexhat(seq(0, 24, by = 0.1)))), 0.1)
})

test_that("block_hrf does not mix in pre-onset values", {
  hm <- as_hrf(hrf_mexhat, name = "mexhat", span = 24)
  blocked <- block_hrf(hm, width = 5, precision = 0.1)
  tneg <- seq(-3, -0.05, by = 0.05)
  # Was 2% of peak before the fix.
  expect_true(all(blocked(tneg) == 0))
})
