context("Reg and regressor")

library(testthat)

# Helper HRF that returns 1 for t in [0,1] and 0 otherwise
box_hrf_fun <- function(t) {
  ifelse(t >= 0 & t <= 1, 1, 0)
}
BOX_HRF <- as_hrf(box_hrf_fun, name = "box", span = 1)


test_that("regressor constructs valid Reg objects", {
  reg <- regressor(onsets = c(0, 10, 20),
                   hrf = HRF_GAMMA,
                   duration = 2,
                   amplitude = c(1, 2, 3),
                   span = 30)

  expect_s3_class(reg, "Reg")
  expect_true(inherits(reg, "list"))
  expect_equal(reg$onsets, c(0, 10, 20))
  expect_equal(reg$duration, rep(2, 3))
  expect_equal(reg$amplitude, c(1, 2, 3))
  expect_identical(reg$hrf, HRF_GAMMA)
  # span should take from HRF when provided
  expect_equal(reg$span, attr(HRF_GAMMA, "span"))
  expect_false(attr(reg, "filtered_all"))
})


test_that("events with zero amplitude are filtered", {
  reg <- regressor(onsets = c(1, 2, 3), amplitude = c(1, 0, 2))
  expect_equal(reg$onsets, c(1, 3))
  expect_equal(reg$duration, c(0, 0))
  expect_equal(reg$amplitude, c(1, 2))
  expect_false(attr(reg, "filtered_all"))

  reg_empty <- regressor(onsets = c(1, 2), amplitude = c(0, 0))
  expect_length(reg_empty$onsets, 0)
  expect_true(attr(reg_empty, "filtered_all"))
})

test_that("NA inputs trigger errors", {
  # Single NA onset is treated as empty regressor (special case)
  expect_no_error(regressor(onsets = NA_real_))
  expect_error(regressor(onsets = c(1, NA)), "onsets")
  expect_error(regressor(onsets = 1, duration = NA_real_), "duration")
  expect_error(regressor(onsets = 1, amplitude = NA_real_), "amplitude")
  expect_error(regressor(onsets = 1, span = NA_real_), "span")
})


test_that("invalid inputs are rejected", {
  expect_error(regressor(onsets = c(-1, 1)), "onsets")
  expect_error(regressor(onsets = 1, duration = -2), "duration")
  expect_error(regressor(onsets = 1, span = 0), "span")
  expect_error(regressor(onsets = c(1, Inf)), "onsets")
  expect_error(regressor(onsets = 1, duration = Inf), "duration")
  expect_error(regressor(onsets = 1, amplitude = Inf), "amplitude")
  expect_error(regressor(onsets = 1, span = Inf), "span")
})


test_that("single_trial_regressor returns a length-1 Reg", {
  st <- single_trial_regressor(onsets = 5, duration = 2, amplitude = 3)
  expect_s3_class(st, "Reg")
  expect_equal(length(st$onsets), 1)
  expect_equal(st$onsets, 5)
  expect_equal(st$duration, 2)
  expect_equal(st$amplitude, 3)
})


test_that("shift.Reg shifts onsets correctly", {
  reg <- regressor(c(0, 2), hrf = HRF_SPMG1)
  shifted <- shift(reg, 5)
  expect_equal(shifted$onsets, c(5, 7))
  expect_identical(shifted$duration, reg$duration)
  expect_identical(shifted$amplitude, reg$amplitude)
})

test_that("shift.Reg accepts offset argument", {
  reg <- regressor(c(1, 3), hrf = HRF_SPMG1)
  shifted <- shift(reg, offset = 2)
  expect_equal(shifted$onsets, c(3, 5))
})

test_that("shift.Reg keeps zero-amplitude events kept by drop_zero_amplitude = FALSE", {
  reg <- regressor(c(1, 5, 9), amplitude = c(1, 0, 2), drop_zero_amplitude = FALSE)
  shifted <- shift(reg, 2)
  expect_equal(shifted$onsets, c(3, 7, 11))
  expect_equal(shifted$amplitude, c(1, 0, 2))
  expect_equal(evaluate(shifted, 0:30), evaluate(reg, 0:30 - 2))
})

test_that("shift.Reg errors without shift specification", {
  reg <- regressor(0, hrf = HRF_SPMG1)
  expect_error(shift(reg), "shift_amount")
})


test_that("evaluate.Reg computes convolution correctly", {
  reg <- regressor(onsets = c(0, 2), hrf = BOX_HRF, span = 1)
  grid <- 0:4
  result <- evaluate(reg, grid, method = "conv", precision = 1)
  expect_equal(result, c(1, 1, 1, 1, 0))
})


test_that("deprecated Rconv method warns and routes to conv", {
  reg <- regressor(onsets = c(0, 2), duration = 2, amplitude = c(1, 1),
                   hrf = BOX_HRF, span = 1)
  grid <- 0:6
  res_conv <- evaluate(reg, grid, method = "conv", precision = 1)
  expect_warning(res_rconv <- evaluate(reg, grid, method = "Rconv", precision = 1),
                 "deprecated")
  expect_equal(res_rconv, res_conv)
})


test_that("unsorted grid triggers warning and sorted output", {
  reg <- regressor(onsets = 0, hrf = BOX_HRF, span = 1)
  expect_warning(out <- evaluate(reg, c(3, 0, 1), method = "conv", precision = 1))
  expect_equal(out, evaluate(reg, sort(c(3, 0, 1)), method = "conv", precision = 1))
})


test_that("evaluate.Reg validates grid and precision", {
  reg <- regressor(onsets = 0, hrf = BOX_HRF, span = 1)
  expect_error(evaluate(reg, numeric(0), method = "conv"), "grid")
  expect_error(evaluate(reg, c(0, NA), method = "conv"), "grid")
  expect_error(evaluate(reg, 0:1, precision = 0, method = "conv"), "precision")
  expect_error(evaluate(reg, 0:1, precision = -1, method = "conv"), "precision")
})

test_that("single-trial regressors with different durations normalize to peak 1", {
  grid <- seq(0, 40, by = 0.1)
  st_short <- single_trial_regressor(onsets = 10, duration = 1, hrf = HRF_SPMG1)
  st_long <- single_trial_regressor(onsets = 10, duration = 6, hrf = HRF_SPMG1)

  y_short <- evaluate(st_short, grid, method = "conv", precision = 0.1, normalize = TRUE)
  y_long <- evaluate(st_long, grid, method = "conv", precision = 0.1, normalize = TRUE)

  expect_equal(max(abs(y_short)), 1, tolerance = 1e-6)
  expect_equal(max(abs(y_long)), 1, tolerance = 1e-6)
})

test_that("evaluate.Reg normalize is consistent across methods", {
  reg <- regressor(onsets = c(2, 10), duration = c(1, 4), amplitude = c(1, 1), hrf = HRF_SPMG1)
  grid <- seq(0, 30, by = 0.25)

  y_conv <- evaluate(reg, grid, method = "conv", precision = 0.1, normalize = TRUE)
  y_loop <- evaluate(reg, grid, method = "loop", precision = 0.1, normalize = TRUE)

  expect_equal(max(abs(y_conv)), 1, tolerance = 1e-6)
  expect_equal(max(abs(y_loop)), 1, tolerance = 1e-6)
  expect_equal(y_conv, y_loop, tolerance = 0.05)
})

test_that("evaluate.Reg validates normalize argument", {
  reg <- regressor(onsets = 0, hrf = BOX_HRF, span = 1)
  expect_error(evaluate(reg, 0:1, normalize = NA), "normalize")
  expect_error(evaluate(reg, 0:1, normalize = 1), "normalize")
})

test_that("conv matches a full convolution of the fine-grid impulse train", {
  # Reference: unit-mass impulses split linearly over the two bracketing
  # fine-grid bins, convolved with the sampled kernel over the whole fine
  # grid, then linearly interpolated onto the evaluation grid.
  conv_reference <- function(grid, onsets, amp, hrf, dt) {
    span <- attr(hrf, "span")
    hmat <- as.matrix(evaluate(hrf, seq(0, span, by = dt)))
    start <- min(grid) - span
    end <- max(grid, onsets) + span
    n <- floor((end - start) / dt) + 1
    neural <- numeric(n + 1)
    pos <- (onsets - start) / dt
    a <- floor(pos)
    for (i in which(pos >= 0)) {  # earlier events end before the grid's reach
      neural[a[i] + 1:2] <- neural[a[i] + 1:2] + amp[i] * c(1 - (pos[i] - a[i]), pos[i] - a[i])
    }
    neural <- neural[seq_len(n)]
    fine <- start + (seq_len(n) - 1) * dt
    out <- vapply(seq_len(ncol(hmat)), function(b) {
      h <- hmat[, b]
      full <- vapply(seq_len(n), function(k) {
        lags <- seq_len(min(k, length(h)))
        sum(h[lags] * neural[k - lags + 1])
      }, numeric(1))
      stats::approx(fine, full, grid, rule = 2)$y
    }, numeric(length(grid)))
    matrix(out, nrow = length(grid))
  }

  onsets <- c(3.17, 20, 41.9, 42.4, 75)
  amp <- c(1, -0.5, 2, 1.25, 0.8)
  grids <- list(
    scans = seq(1, by = 2, length.out = 45),
    denser_than_fine = seq(0, 30, by = 0.1),
    irregular = c(0.5, 0.52, 7, 7, 33.3, 61, 88.8, 120),
    single = 44.4
  )
  for (hrf in list(HRF_SPMG1, HRF_SPMG3)) {
    reg <- regressor(onsets, hrf, amplitude = amp)
    for (dt in c(0.1, 0.33, 1)) {
      for (g in names(grids)) {
        expected <- conv_reference(grids[[g]], onsets, amp, hrf, dt)
        if (nbasis(hrf) == 1) expected <- as.vector(expected)
        expect_equal(evaluate(reg, grids[[g]], precision = dt), expected,
                     tolerance = 1e-10,
                     info = paste(attr(hrf, "name"), dt, g))
      }
    }
  }
})

test_that("a block at the start of the convolution window keeps its mass", {
  # conv's fine window starts one span before the first grid point. A block
  # starting within one fine bin of that edge used to gain up to half a bin
  # of mass, so a grid point's value depended on which other points were
  # requested. Both grids below share the fine-grid alignment.
  box <- as_hrf(function(t) ifelse(t >= 0 & t <= 1, 1, 0), name = "box", span = 1)
  reg <- regressor(0, box, duration = 0.5)

  at_edge <- evaluate(reg, c(1, 2, 3), precision = 0.1)
  inside <- evaluate(reg, c(0.5, 1, 2, 3), precision = 0.1)[-1]
  expect_equal(at_edge, inside, tolerance = 1e-10)
  expect_equal(at_edge[1], 0.5, tolerance = 1e-10)

  # Block starting half a fine bin before the window
  at_edge <- evaluate(reg, c(1.05, 2.05), precision = 0.1)
  inside <- evaluate(reg, c(0.55, 1.05, 2.05), precision = 0.1)[-1]
  expect_equal(at_edge, inside, tolerance = 1e-10)
})

test_that("neural_input samples block events and handles empty regressors", {
  reg <- regressor(onsets = c(2, 6), duration = c(2, 1), amplitude = c(1, 3))
  ni <- neural_input(reg, start = 0, end = 10, resolution = 1)
  expect_equal(ni$time, 0:10)
  expect_equal(ni$neural_input, c(0, 0, 1, 1, 0, 0, 3, 0, 0, 0, 0))
  expect_equal(range(neural_input(reg, resolution = 0.5)$time), c(0, 17))

  # An empty regressor used to fail on max(numeric(0)) when `end` was not given.
  empty <- regressor(onsets = c(1, 2), amplitude = 0)
  expect_no_warning(ni0 <- neural_input(empty, start = 5, resolution = 1))
  expect_equal(ni0$time, 5:15)
  expect_equal(ni0$neural_input, numeric(11))
})
