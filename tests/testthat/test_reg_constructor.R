context("Reg constructor and single_trial_regressor")

library(testthat)

# Verify Reg error handling

test_that("Reg validates inputs", {
  expect_error(fmrihrf:::Reg(onsets = -1), "onsets")
  expect_error(fmrihrf:::Reg(onsets = c(0, NA)), "onsets")
  expect_error(fmrihrf:::Reg(onsets = 1, span = 0), "span")
  expect_error(fmrihrf:::Reg(onsets = c(0,1), duration = c(1,2,3)), "duration")
  expect_error(fmrihrf:::Reg(onsets = c(0,1), amplitude = c(1,2,3)), "amplitude")
})

test_that("Reg rejects a missing summate flag", {
  # NA used to be accepted: conv treated it as FALSE while loop errored.
  expect_error(regressor(onsets = 1, summate = NA), "summate")
  expect_error(regressor(onsets = 1, summate = c(TRUE, FALSE)), "summate")
  expect_error(regressor(onsets = 1, summate = "yes"), "summate")
})

test_that("a list-HRF regressor without events keeps its basis and span", {
  # All events dropped: this used to warn, store span = -Inf and report a
  # single basis, so evaluate() returned a vector for a 3-basis HRF.
  expect_no_warning(
    reg <- regressor(c(1, 2), hrf = list(HRF_SPMG3), amplitude = 0)
  )
  single <- regressor(c(1, 2), hrf = HRF_SPMG3, amplitude = 0)
  expect_equal(reg$span, single$span)
  expect_equal(nbasis(reg), 3L)
  expect_true(attr(reg, "filtered_all"))
  expect_identical(evaluate(reg, 0:5), matrix(0, 6, 3))
  expect_identical(evaluate(reg, 0:5, method = "loop"), evaluate(single, 0:5))

  expect_no_warning(none <- regressor(numeric(0), hrf = list(HRF_SPMG2)))
  expect_equal(nbasis(none), 2L)
  expect_no_warning(bare <- regressor(numeric(0), hrf = list(), span = 30))
  expect_equal(bare$span, 30)
})

# Verify single_trial_regressor construction and errors

test_that("single_trial_regressor constructs single event", {
  st <- single_trial_regressor(onsets = 5, duration = 2, amplitude = 3)
  expect_s3_class(st, "Reg")
  expect_equal(length(st$onsets), 1)
  expect_equal(st$onsets, 5)
  expect_equal(st$duration, 2)
  expect_equal(st$amplitude, 3)
})

test_that("single_trial_regressor validates lengths", {
  expect_error(single_trial_regressor(onsets = c(1,2)), "onsets")
  expect_error(single_trial_regressor(onsets = 1, duration = c(1,2)), "duration")
  expect_error(single_trial_regressor(onsets = 1, amplitude = c(1,2)), "amplitude")
})
