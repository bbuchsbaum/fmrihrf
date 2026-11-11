test_that("the quadrature partner is orthogonal to the canonical HRF with equal norm", {
  t <- seq(0, 32, by = 0.01)
  h <- hrf_spmg1(t)
  q <- hrf_spmg1_quadrature(t)
  expect_equal(sum(h * q) / sum(h^2), 0, tolerance = 1e-8)
  expect_equal(sum(q^2) / sum(h^2), 1, tolerance = 1e-8)
  expect_equal(hrf_spmg1_quadrature(c(-1, 33)), c(0, 0))
  expect_error(hrf_spmg1_quadrature(1, span = -1), "span")
})

test_that("HRF_SPMGQ is a registered two-function basis", {
  expect_s3_class(HRF_SPMGQ, "HRF")
  expect_equal(nbasis(HRF_SPMGQ), 2L)
  expect_equal(attr(HRF_SPMGQ, "span"), 32)
  t <- seq(0, 30, by = 0.5)
  B <- evaluate(HRF_SPMGQ, t)
  expect_equal(B[, 1], hrf_spmg1(t))
  expect_equal(B[, 2], hrf_spmg1_quadrature(t))
  expect_equal(evaluate(getHRF("spmgq"), t), B)
  expect_equal(evaluate(getHRF("quadrature"), t), B)
  reg <- regressor(c(5, 30), HRF_SPMGQ)
  expect_equal(ncol(evaluate(reg, seq(0, 60, by = 2))), 2L)
})

test_that("hrf_shift_curve gives (1, 0) at zero shift and the derivative sign", {
  cc <- hrf_shift_curve(HRF_SPMG2, shifts = c(-1, 0, 1))
  expect_equal(dim(cc), c(3L, 2L))
  expect_equal(unname(cc[2, ]), c(1, 0), tolerance = 1e-8)
  # a later response loads negatively on the temporal derivative
  expect_lt(cc[3, 2], 0)
  expect_gt(cc[1, 2], 0)
  expect_error(hrf_shift_curve(HRF_SPMG1), "at least two")
})

test_that("amplitude_latency recovers amplitude and latency of shifted responses", {
  t <- seq(0, 44, by = 0.05)
  shifts <- c(-3, -1.5, 0, 0.5, 2, 3.5)
  for (basis in list(HRF_SPMG2, HRF_SPMGQ)) {
    B <- basis(t)
    beta <- t(vapply(shifts, function(s) qr.solve(B, 2 * hrf_spmg1(t - s)), numeric(2)))
    est <- amplitude_latency(beta, basis)
    expect_equal(est$latency, shifts, tolerance = 0.051)
    expect_equal(est$amplitude, rep(2, length(shifts)), tolerance = 0.01)
    expect_gt(min(est$fit), 0.999)
    # the canonical coefficient alone underestimates shifted responses
    expect_lt(beta[1, 1], 1.5)
  }
  # negative responses keep their latency and get a negative amplitude
  b_neg <- qr.solve(HRF_SPMG2(t), -1.5 * hrf_spmg1(t - 1))
  est <- amplitude_latency(b_neg, HRF_SPMG2)
  expect_equal(est$amplitude, -1.5, tolerance = 0.01)
  expect_equal(est$latency, 1, tolerance = 0.051)
})

test_that("the boost estimate is exact at zero shift and biased low beyond it", {
  t <- seq(0, 44, by = 0.05)
  B <- HRF_SPMG2(t)
  b0 <- qr.solve(B, hrf_spmg1(t))
  b3 <- qr.solve(B, hrf_spmg1(t - 3))
  boost <- amplitude_latency(rbind(b0, b3), HRF_SPMG2, method = "boost")
  expect_equal(boost$amplitude[1], 1, tolerance = 1e-6)
  expect_lt(boost$amplitude[2], 0.9)
  expect_gt(boost$amplitude[2], b3[1])
  expect_true(all(is.na(boost$latency)))
})

test_that("amplitude_latency validates its inputs", {
  expect_error(amplitude_latency(1:3, HRF_SPMG2), "2 columns")
  expect_error(amplitude_latency(c(1, 0), HRF_SPMG2, metric = diag(3)), "2 x 2")
  z <- amplitude_latency(rbind(c(0, 0), c(1, 0)), HRF_SPMG2)
  expect_true(is.na(z$amplitude[1]))
  expect_equal(z$latency[2], 0)
  expect_equal(rownames(amplitude_latency(rbind(a = c(1, 0), b = c(1, -1)), HRF_SPMG2)),
               c("a", "b"))
})
