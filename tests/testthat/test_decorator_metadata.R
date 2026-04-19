library(testthat)

# These tests lock in the metadata namespace convention: parameter names
# prefixed with "." are internal bookkeeping (stored in `params`) and must
# never appear in `param_names`. Decorators (`lag_hrf`, `block_hrf`,
# `normalise_hrf`) and direct `as_hrf()` calls are all covered.

test_that("lag_hrf stores .lag as metadata, not in param_names", {
  lagged <- suppressWarnings(lag_hrf(HRF_SPMG1, lag = 2))

  params <- attr(lagged, "params")
  expect_true(".lag" %in% names(params))
  expect_equal(params[[".lag"]], 2)

  pn <- attr(lagged, "param_names")
  expect_false(any(startsWith(pn, ".")))
})

test_that("block_hrf stores all block settings as dotted metadata", {
  blocked <- suppressWarnings(
    block_hrf(HRF_SPMG1, width = 4, precision = 0.2,
              half_life = 10, summate = FALSE, normalize = TRUE)
  )

  params <- attr(blocked, "params")
  expect_true(all(c(".width", ".precision", ".half_life",
                    ".summate", ".normalize") %in% names(params)))
  expect_equal(params[[".width"]], 4)
  expect_equal(params[[".precision"]], 0.2)
  expect_equal(params[[".half_life"]], 10)
  expect_identical(params[[".summate"]], FALSE)
  expect_identical(params[[".normalize"]], TRUE)

  pn <- attr(blocked, "param_names")
  expect_false(any(startsWith(pn, ".")))
})

test_that("normalise_hrf flags .normalised without leaking into param_names", {
  normed <- suppressWarnings(normalise_hrf(HRF_SPMG1))

  params <- attr(normed, "params")
  expect_true(".normalised" %in% names(params))
  expect_identical(params[[".normalised"]], TRUE)

  pn <- attr(normed, "param_names")
  expect_false(".normalised" %in% pn)
  expect_false(any(startsWith(pn, ".")))
})

test_that("stacked decorators accumulate metadata in params", {
  stacked <- suppressWarnings(
    normalise_hrf(lag_hrf(block_hrf(HRF_SPMG1, width = 3), lag = 2))
  )

  params <- attr(stacked, "params")
  expect_true(all(c(".width", ".lag", ".normalised") %in% names(params)))

  pn <- attr(stacked, "param_names")
  expect_false(any(startsWith(pn, ".")))
})

test_that("as_hrf excludes dotted keys from param_names but keeps them in params", {
  h <- as_hrf(
    function(t) exp(-t / 5),
    name = "exp",
    params = list(.custom_flag = TRUE)
  )

  expect_identical(attr(h, "params")[[".custom_flag"]], TRUE)
  expect_false(".custom_flag" %in% attr(h, "param_names"))
  expect_equal(length(attr(h, "param_names")), 0L)
})

test_that("as_hrf still exposes non-dotted callable params in param_names", {
  # Sanity check: ordinary params for HRFs whose function accepts them are
  # still surfaced in param_names (HRF_SPMG1 wraps hrf_spmg1 with P1/P2/A1).
  expect_setequal(attr(HRF_SPMG1, "param_names"), c("P1", "P2", "A1"))
  expect_setequal(attr(HRF_GAMMA, "param_names"), c("shape", "rate"))
})
