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


test_that("events with zero or NA amplitude are filtered", {
  reg <- regressor(onsets = c(1, 2, 3), amplitude = c(1, 0, NA))
  expect_equal(reg$onsets, 1)
  expect_equal(reg$duration, 0)
  expect_equal(reg$amplitude, 1)
  expect_false(attr(reg, "filtered_all"))

  reg_empty <- regressor(onsets = c(1, 2), amplitude = c(0, 0))
  expect_length(reg_empty$onsets, 0)
  expect_true(attr(reg_empty, "filtered_all"))
})


test_that("invalid inputs are rejected", {
  expect_error(regressor(onsets = c(-1, 1)), "onsets")
  expect_error(regressor(onsets = 1, duration = -2), "duration")
  expect_error(regressor(onsets = 1, span = 0), "span")
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


test_that("evaluate.Reg computes convolution correctly", {
  reg <- regressor(onsets = c(0, 2), hrf = BOX_HRF, span = 1)
  grid <- 0:4
  result <- evaluate(reg, grid, method = "conv", precision = 1)
  expect_equal(result, c(1, 1, 1, 1, 0))
})


test_that("unsorted grid triggers warning and sorted output", {
  reg <- regressor(onsets = 0, hrf = BOX_HRF, span = 1)
  expect_warning(out <- evaluate(reg, c(3, 0, 1), method = "conv", precision = 1))
  expect_equal(out, evaluate(reg, sort(c(3, 0, 1)), method = "conv", precision = 1))
})
