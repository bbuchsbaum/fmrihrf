context("feature_regressor")

library(testthat)

.with_pdf_device <- function(code) {
  path <- tempfile(fileext = ".pdf")
  grDevices::pdf(path)
  on.exit(grDevices::dev.off(), add = TRUE)
  value <- force(code)
  stopifnot(file.exists(path))
  value
}


# --- Construction / validation ----------------------------------------------

test_that("dt builds a regular sample grid", {
  feat <- feature_regressor(c(1, 2, 3), dt = 0.5, start = 1,
                            center = FALSE, scale = "none")
  expect_s3_class(feat, "FeatureReg")
  expect_s3_class(feat, "Reg")
  expect_equal(feat$onsets, c(1, 1.5, 2.0))
  expect_equal(feat$duration, c(0.5, 0.5, 0.5))
  expect_equal(feat$amplitude, c(1, 2, 3))
  expect_equal(attr(feat, "dt"), 0.5)
  expect_true(feat$summate)
})

test_that("times uses the last inter-sample gap as the last duration", {
  feat <- feature_regressor(c(1, 2, 3), times = c(0, 0.1, 0.25),
                            center = FALSE, scale = "none")
  expect_equal(feat$onsets, c(0, 0.1, 0.25))
  expect_equal(feat$duration, c(0.1, 0.15, 0.15))
  expect_true(is.na(attr(feat, "dt")))
})

test_that("regular times store a scalar dt attribute", {
  feat <- feature_regressor(c(1, 2, 3), times = c(0, 0.2, 0.4),
                            center = FALSE, scale = "none")
  expect_equal(attr(feat, "dt"), 0.2)
})

test_that("exactly one of times or dt is required", {
  expect_error(feature_regressor(1:3), "times")
  expect_error(feature_regressor(1:3, times = c(0, 1, 2), dt = 1), "times")
})

test_that("times validation errors", {
  expect_error(feature_regressor(1:3, times = c(0, 1)), "length")
  expect_error(feature_regressor(1:3, times = c(0, 2, 1)), "strictly increasing")
  expect_error(feature_regressor(1:3, times = c(0, 1, 1)), "strictly increasing")
  expect_error(feature_regressor(1:3, times = c(-0.1, 0, 1)), "non-negative")
  expect_error(feature_regressor(1:2, times = c(0, NA)), "finite")
  expect_error(feature_regressor(1, times = 0), "at least two")
})

test_that("dt and start validation errors", {
  expect_error(feature_regressor(1:3, dt = 0), "dt")
  expect_error(feature_regressor(1:3, dt = -0.1), "dt")
  expect_error(feature_regressor(1:3, dt = 0.1, start = -1), "start")
})

test_that("values must be finite", {
  expect_error(feature_regressor(numeric(0), dt = 0.1), "values")
  expect_error(feature_regressor(c(1, NA, 2), dt = 0.1), "values")
  expect_error(feature_regressor(c(1, Inf), dt = 0.1), "values")
})

test_that("matrix and array values are rejected instead of flattened", {
  expect_error(
    feature_regressor(matrix(1:6, nrow = 3), dt = 0.1),
    "matrix and array inputs"
  )
  expect_error(
    feature_regressor(array(1:8, dim = c(2, 2, 2)), dt = 0.1),
    "matrix and array inputs"
  )
})

test_that("per-event HRF lists are rejected", {
  expect_error(
    feature_regressor(1:3, hrf = list(HRF_SPMG1, HRF_SPMG1, HRF_SPMG1), dt = 0.1),
    "list"
  )
})

test_that("zero-valued samples are retained", {
  feat <- feature_regressor(c(1, 0, 2), dt = 0.5, start = 0,
                            center = FALSE, scale = "none")
  expect_equal(feat$onsets, c(0, 0.5, 1.0))
  expect_equal(feat$amplitude, c(1, 0, 2))
  expect_false(attr(feat, "filtered_all"))
})

test_that("regressor still drops zero amplitudes", {
  reg <- regressor(onsets = c(1, 2, 3), amplitude = c(1, 0, 2))
  expect_equal(reg$onsets, c(1, 3))
})


# --- Center / scale / mask --------------------------------------------------

test_that("center = TRUE demeans the amplitudes", {
  values <- c(1, 2, 3, 4)
  feat <- feature_regressor(values, dt = 0.2, center = TRUE, scale = "none")
  expect_equal(mean(feat$amplitude), 0)
  expect_equal(feat$amplitude, values - mean(values))
  expect_true(attr(feat, "center"))
})

test_that("center = FALSE leaves values unchanged", {
  values <- c(1, 2, 3, 4)
  feat <- feature_regressor(values, dt = 0.2, center = FALSE, scale = "none")
  expect_equal(amplitudes(feat), values)
  expect_false(attr(feat, "center"))
})

test_that("a constant feature with center = TRUE evaluates to zero", {
  feat <- feature_regressor(rep(3, 20), dt = 0.2, hrf = HRF_SPMG1,
                            center = TRUE, scale = "none")
  grid <- seq(0, 10, by = 1)
  expect_equal(evaluate(feat, grid, precision = 0.2), rep(0, length(grid)))
})

test_that("centering is linear and happens before convolution", {
  dt <- 0.1
  set.seed(1)
  s <- rnorm(40)
  m <- mean(s)
  grid <- seq(0, 8, by = 0.5)

  feat_c <- feature_regressor(s, dt = dt, hrf = HRF_SPMG1,
                              center = TRUE, scale = "none")
  feat_manual <- feature_regressor(s - m, dt = dt, hrf = HRF_SPMG1,
                                   center = FALSE, scale = "none")
  feat_raw <- feature_regressor(s, dt = dt, hrf = HRF_SPMG1,
                                center = FALSE, scale = "none")
  feat_mean <- feature_regressor(rep(m, length(s)), dt = dt, hrf = HRF_SPMG1,
                                 center = FALSE, scale = "none")

  y_c <- evaluate(feat_c, grid, precision = dt)
  expect_equal(y_c, evaluate(feat_manual, grid, precision = dt),
               tolerance = 1e-8)
  expect_equal(y_c,
               evaluate(feat_raw, grid, precision = dt) -
                 evaluate(feat_mean, grid, precision = dt),
               tolerance = 1e-6)
})

test_that("all-TR z-scoring is Hx/sd - (mean/sd) H1", {
  dt <- 0.2
  set.seed(2)
  s <- abs(rnorm(80, mean = 2, sd = 0.4))
  mu <- mean(s)
  sdv <- stats::sd(s)
  grid <- seq(0, 20, by = 0.5)

  y_z <- evaluate(
    feature_regressor(s, dt = dt, hrf = HRF_SPMG1, center = TRUE, scale = "sd"),
    grid, precision = dt
  )
  y_raw <- evaluate(
    feature_regressor(s, dt = dt, hrf = HRF_SPMG1, center = FALSE, scale = "none"),
    grid, precision = dt
  )
  y_ones <- evaluate(
    feature_regressor(rep(1, length(s)), dt = dt, hrf = HRF_SPMG1,
                      center = FALSE, scale = "none"),
    grid, precision = dt
  )
  expect_equal(y_z, y_raw / sdv - (mu / sdv) * y_ones, tolerance = 1e-6)
})

test_that("interior all-TR centered and raw columns are nearly collinear", {
  dt <- 0.2
  set.seed(3)
  s <- abs(rnorm(500, mean = 2, sd = 0.5))
  grid <- seq(0, 100, by = 1)
  y_raw <- evaluate(
    feature_regressor(s, dt = dt, hrf = HRF_SPMG1, center = FALSE, scale = "none"),
    grid, precision = dt
  )
  y_cen <- evaluate(
    feature_regressor(s, dt = dt, hrf = HRF_SPMG1, center = TRUE, scale = "none"),
    grid, precision = dt
  )
  interior <- grid > 30 & grid < 80
  expect_gt(stats::cor(y_raw[interior], y_cen[interior]), 0.999)
})

test_that("mask centering is not an affine transform of the all-sample series", {
  dt <- 0.2
  set.seed(4)
  values <- c(rep(0, 40), runif(40, 1, 3), rep(0, 40))
  mask <- values > 0
  grid <- seq(0, 30, by = 0.5)

  y_raw <- evaluate(
    feature_regressor(values, dt = dt, hrf = HRF_SPMG1,
                      center = FALSE, scale = "none"),
    grid, precision = dt
  )
  y_mask <- evaluate(
    feature_regressor(values, dt = dt, hrf = HRF_SPMG1,
                      center = TRUE, scale = "none", mask = mask),
    grid, precision = dt
  )
  y_ones <- evaluate(
    feature_regressor(rep(1, length(values)), dt = dt, hrf = HRF_SPMG1,
                      center = FALSE, scale = "none"),
    grid, precision = dt
  )
  mu <- mean(values)
  all_tr_centered <- y_raw - mu * y_ones
  expect_gt(max(abs(y_mask - all_tr_centered)), 0.05 * max(abs(all_tr_centered)))
})

test_that("scale = 'sd' unit-variances the (centered) feature", {
  values <- c(1, 2, 3, 4, 5)
  feat <- feature_regressor(values, dt = 0.2, center = TRUE, scale = "sd")
  expect_equal(mean(feat$amplitude), 0)
  expect_equal(stats::sd(feat$amplitude), 1)
  expect_equal(attr(feat, "scale"), "sd")
})

test_that("scale = 'sd' errors on a zero post-center SD", {
  expect_error(
    feature_regressor(rep(2, 5), dt = 0.2, center = TRUE, scale = "sd"),
    "standard deviation"
  )
})

test_that("mask centers and scales on-samples and zeros the rest", {
  values <- c(1, 2, 3, 4, 5)
  mask <- c(TRUE, TRUE, FALSE, TRUE, FALSE)
  on_vals <- values[mask]
  feat <- feature_regressor(values, dt = 0.2, center = TRUE, scale = "none",
                            mask = mask)
  expect_equal(feat$amplitude[!mask], c(0, 0))
  expect_equal(mean(feat$amplitude[mask]), 0)
  expect_equal(feat$amplitude[mask], on_vals - mean(on_vals))

  feat_raw <- feature_regressor(values, dt = 0.2, center = FALSE, scale = "none",
                                mask = mask)
  expect_equal(feat_raw$amplitude[mask], on_vals)
  expect_equal(feat_raw$amplitude[!mask], c(0, 0))

  feat_sd <- feature_regressor(values, dt = 0.2, center = TRUE, scale = "sd",
                               mask = mask)
  expect_equal(mean(feat_sd$amplitude[mask]), 0)
  expect_equal(stats::sd(feat_sd$amplitude[mask]), 1)
  expect_equal(feat_sd$amplitude[!mask], c(0, 0))
})

test_that("mask validation errors", {
  expect_error(
    feature_regressor(1:3, dt = 0.1, mask = c(TRUE, FALSE)),
    "mask"
  )
  expect_error(
    feature_regressor(1:3, dt = 0.1, mask = c(FALSE, FALSE, FALSE)),
    "TRUE"
  )
})


# --- Convolution contracts --------------------------------------------------

test_that("feature_regressor matches ZOH event regressor", {
  dt <- 0.1
  times <- seq(0, 4, by = dt)
  values <- sin(2 * pi * times / 2) + 1.5
  feat <- feature_regressor(values, dt = dt, hrf = HRF_SPMG1,
                            center = FALSE, scale = "none")
  ev <- regressor(times, HRF_SPMG1, duration = dt, amplitude = values)
  grid <- seq(0, 8, by = 0.5)
  expect_equal(
    evaluate(feat, grid, precision = dt),
    evaluate(ev, grid, precision = dt),
    tolerance = 1e-8
  )
})

test_that("impulse quadrature with amplitude * dt is close to the ZOH feature", {
  dt <- 0.1
  times <- seq(0, 4, by = dt)
  values <- sin(2 * pi * times / 2) + 1.5
  feat <- feature_regressor(values, dt = dt, hrf = HRF_SPMG1,
                            center = FALSE, scale = "none")
  ev <- regressor(times, HRF_SPMG1, duration = 0, amplitude = values * dt)
  grid <- seq(0, 8, by = 0.5)
  y_feat <- evaluate(feat, grid, precision = dt)
  y_imp <- evaluate(ev, grid, precision = dt)
  relative_peak_error <- max(abs(y_feat - y_imp)) / max(abs(y_feat))
  expect_lt(relative_peak_error, 0.02)
})

test_that("duration-0 events with raw values differ by about 1/dt", {
  dt <- 0.1
  times <- seq(0, 4, by = dt)
  values <- sin(2 * pi * times / 2) + 1.5
  feat <- feature_regressor(values, dt = dt, hrf = HRF_SPMG1,
                            center = FALSE, scale = "none")
  ev <- regressor(times, HRF_SPMG1, duration = 0, amplitude = values)
  grid <- seq(0, 8, by = 0.5)
  y_feat <- evaluate(feat, grid, precision = dt)
  y_raw <- evaluate(ev, grid, precision = dt)
  ratio <- max(abs(y_raw)) / max(abs(y_feat))
  expect_lt(abs(ratio - 1 / dt) / (1 / dt), 0.05)
})

test_that("conv and loop agree at precision = dt", {
  dt <- 0.2
  values <- sin(seq(0, 6, by = dt))
  feat <- feature_regressor(values, dt = dt, hrf = HRF_SPMG1,
                            center = FALSE, scale = "none")
  grid <- seq(0, 10, by = 0.5)
  y_conv <- evaluate(feat, grid, method = "conv", precision = dt)
  y_loop <- evaluate(feat, grid, method = "loop", precision = dt)
  expect_equal(y_conv, y_loop, tolerance = 0.01)
})

test_that("a multi-basis HRF returns one column per basis", {
  dt <- 0.2
  feat <- feature_regressor(rnorm(20), dt = dt, hrf = HRF_SPMG3,
                            center = FALSE, scale = "none")
  out <- evaluate(feat, seq(0, 10, by = 1), precision = dt)
  expect_true(is.matrix(out))
  expect_equal(ncol(out), nbasis(HRF_SPMG3))
})


# --- Event-timed features (durations) ---------------------------------------

test_that("durations make each sample an event with its own duration", {
  feat <- feature_regressor(c(2, 0, 4), times = c(1, 3, 9),
                            durations = c(0.5, 0, 2),
                            center = FALSE, scale = "none")
  expect_s3_class(feat, "FeatureReg")
  expect_equal(feat$onsets, c(1, 3, 9))
  expect_equal(feat$duration, c(0.5, 0, 2))
  # zero-amplitude events are kept
  expect_equal(feat$amplitude, c(2, 0, 4))
  expect_true(is.na(attr(feat, "dt")))
  expect_true(attr(feat, "event_timed"))
  expect_output(print(feat), "explicit durations")

  scalar <- feature_regressor(c(2, 0, 4), times = c(1, 3, 9), durations = 0.3,
                              center = FALSE, scale = "none")
  expect_equal(scalar$duration, rep(0.3, 3))

  legacy <- feature_regressor(c(2, 0, 4), times = c(1, 3, 9),
                              center = FALSE, scale = "none")
  expect_false(attr(legacy, "event_timed"))
  expect_equal(legacy$duration, c(2, 6, 6))
})

test_that("impulse events match regressor() with the same onsets", {
  onsets <- c(1, 4.5, 12, 13)
  values <- c(2, -1, 3, 0.5)
  grid <- seq(0, 40, by = 0.5)
  feat <- feature_regressor(values, times = onsets, durations = 0,
                            center = FALSE, scale = "none")
  ev <- regressor(onsets, HRF_SPMG1, duration = 0, amplitude = values)
  for (method in c("conv", "loop")) {
    expect_equal(evaluate(feat, grid, precision = 0.1, method = method),
                 evaluate(ev, grid, precision = 0.1, method = method),
                 tolerance = 1e-12)
  }
})

test_that("block events match regressor() with the same durations", {
  onsets <- c(1, 4.5, 12, 13)
  durs <- c(0.4, 2, 0, 3)
  values <- c(2, -1, 3, 0.5)
  grid <- seq(0, 40, by = 0.5)
  feat <- feature_regressor(values, times = onsets, durations = durs,
                            center = FALSE, scale = "none")
  ev <- regressor(onsets, HRF_SPMG1, duration = durs, amplitude = values)
  expect_equal(evaluate(feat, grid, precision = 0.1),
               evaluate(ev, grid, precision = 0.1), tolerance = 1e-12)

  # centering is over events: the parametric-modulator convention
  feat_c <- feature_regressor(values, times = onsets, durations = durs,
                              center = TRUE, scale = "none")
  expect_equal(feat_c$amplitude, values - mean(values))
  ev_c <- regressor(onsets, HRF_SPMG1, duration = durs,
                    amplitude = values - mean(values),
                    drop_zero_amplitude = FALSE)
  expect_equal(evaluate(feat_c, grid, precision = 0.1),
               evaluate(ev_c, grid, precision = 0.1), tolerance = 1e-12)
})

test_that("a value is not carried across a pause when durations are given", {
  # Two short events 30 s apart. Late in the pause the response to the first
  # event has died away, unless its value is held until the second event.
  onsets <- c(0, 30)
  values <- c(1, 1)
  probe <- 27

  events <- feature_regressor(values, times = onsets, durations = 0.5,
                              center = FALSE, scale = "none")
  held <- feature_regressor(values, times = onsets,
                            center = FALSE, scale = "none")
  y_events <- evaluate(events, probe, precision = 0.1)
  y_held <- evaluate(held, probe, precision = 0.1)

  # 27 s lies beyond event end (0.5 s) + HRF span (24 s): exactly no response
  expect_equal(y_events, 0)
  # legacy zero-order hold: the first value fills the whole 30 s gap
  expect_equal(held$duration, c(30, 30))
  boxcar <- regressor(0, HRF_SPMG1, duration = 30, amplitude = 1)
  expect_equal(y_held, evaluate(boxcar, probe, precision = 0.1))
  expect_gt(abs(y_held), 0.1)
})

test_that("overlapping and simultaneous events add", {
  grid <- seq(0, 40, by = 0.5)
  feat <- feature_regressor(c(1, 2, 3), times = c(2, 2, 3),
                            durations = c(0, 4, 2),
                            center = FALSE, scale = "none")
  parts <- evaluate(regressor(2, HRF_SPMG1, duration = 0, amplitude = 1),
                    grid, precision = 0.1) +
    evaluate(regressor(2, HRF_SPMG1, duration = 4, amplitude = 2),
             grid, precision = 0.1) +
    evaluate(regressor(3, HRF_SPMG1, duration = 2, amplitude = 3),
             grid, precision = 0.1)
  expect_equal(evaluate(feat, grid, precision = 0.1), parts, tolerance = 1e-10)
})

test_that("a single event is allowed when durations are given", {
  feat <- feature_regressor(3, times = 2, durations = 1,
                            center = FALSE, scale = "none")
  expect_equal(feat$onsets, 2)
  expect_equal(feat$duration, 1)
})

test_that("durations validation errors", {
  expect_error(feature_regressor(1:3, dt = 0.5, durations = 0.1),
               "only be used with `times`")
  expect_error(feature_regressor(1:3, times = c(0, 1, 2), durations = c(1, 2)),
               "same length")
  expect_error(feature_regressor(1:3, times = c(0, 1, 2), durations = "a"),
               "durations")
  expect_error(feature_regressor(1:3, times = c(0, 1, 2), durations = -1),
               "non-negative")
  expect_error(feature_regressor(1:3, times = c(0, 1, 2),
                                 durations = c(1, NA, 1)), "finite")
  expect_error(feature_regressor(1:3, times = c(0, 1, 2),
                                 durations = c(1, Inf, 1)), "finite")
  expect_error(feature_regressor(1:3, times = c(0, 2, 1), durations = 0),
               "non-decreasing")
})


# --- Span -------------------------------------------------------------------

test_that("span = NULL uses the HRF's own span", {
  feat <- feature_regressor(1:3, dt = 0.5, center = FALSE, scale = "none")
  expect_equal(feat$span, attr(HRF_SPMG1, "span"))
})

test_that("an explicit span is honoured", {
  feat <- feature_regressor(1:3, dt = 0.5, center = FALSE, scale = "none",
                            span = 12)
  expect_equal(feat$span, 12)
  expect_output(print(feat), "HRF span: 12 s")

  # the response is cut off at event end + span
  short <- feature_regressor(1, times = 0, durations = 0, center = FALSE,
                             scale = "none", span = 12)
  full <- feature_regressor(1, times = 0, durations = 0, center = FALSE,
                            scale = "none")
  expect_equal(evaluate(short, 14, precision = 0.1), 0)
  expect_false(evaluate(full, 14, precision = 0.1) == 0)
  expect_equal(evaluate(short, 6, precision = 0.1),
               evaluate(full, 6, precision = 0.1))

  expect_error(feature_regressor(1:3, dt = 0.5, span = -1), "span")
  expect_error(feature_regressor(1:3, dt = 0.5, span = c(10, 20)), "span")
  expect_error(feature_regressor(1:3, dt = 0.5, span = "a"), "span")
})


# --- Methods ----------------------------------------------------------------

test_that("shift keeps FeatureReg and does not re-center", {
  values <- c(1, 2, 3, 4)
  feat <- feature_regressor(values, dt = 0.5, start = 1,
                            center = TRUE, scale = "none")
  shifted <- shift(feat, 2)
  expect_s3_class(shifted, "FeatureReg")
  expect_equal(shifted$onsets, feat$onsets + 2)
  expect_equal(shifted$amplitude, feat$amplitude)
  expect_equal(attr(shifted, "center"), TRUE)
  expect_equal(attr(shifted, "dt"), 0.5)

  by_offset <- shift(feat, offset = 1)
  expect_equal(by_offset$onsets, feat$onsets + 1)
  expect_equal(by_offset$amplitude, feat$amplitude)
})

test_that("shift errors on missing amount or negative times", {
  feat <- feature_regressor(1:4, dt = 0.5, center = FALSE, scale = "none")
  expect_error(shift(feat), "shift_amount")
  expect_error(shift(feat, -1), "negative")
})

test_that("print reports samples, center, and scale", {
  feat <- feature_regressor(1:5, dt = 0.2, center = TRUE, scale = "none")
  expect_output(returned <- print(feat), "Samples")
  expect_output(print(feat), "Center")
  expect_output(print(feat), "Scale")
  expect_identical(returned, feat)
})

test_that("plot defaults to no onset overlay and matches evaluate", {
  expect_false(eval(formals(plot.FeatureReg)$show_onsets))

  dt <- 0.2
  feat <- feature_regressor(abs(sin(seq(0, 6, by = dt))), dt = dt,
                            hrf = HRF_SPMG1, center = TRUE, scale = "none")
  grid <- seq(0, 10, by = 0.5)
  plotted <- .with_pdf_device(plot(feat, grid = grid, precision = dt))
  expect_s3_class(plotted, "data.frame")
  expect_equal(names(plotted), c("time", "response"))
  expect_equal(plotted$time, grid)
  expect_equal(plotted$response, evaluate(feat, grid, precision = dt))
})
