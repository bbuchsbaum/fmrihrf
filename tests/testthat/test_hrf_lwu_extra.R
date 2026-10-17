context("hrf_lwu and related functions")

test_that("hrf_lwu computes response and normalisation", {
  t <- seq(0, 20, by = 0.5)
  raw <- hrf_lwu(t, tau = 6, sigma = 2, rho = 0.4)
  expect_equal(length(raw), length(t))
  expect_true(is.numeric(raw))

  # height normalisation
  norm <- hrf_lwu(t, tau = 6, sigma = 2, rho = 0.4, normalize = "height")
  expect_equal(max(abs(norm)), 1)

  # area normalisation currently behaves like none and warns
  expect_warning(area <- hrf_lwu(t, tau = 6, sigma = 2, rho = 0.4, normalize = "area"))
  expect_equal(area, raw)
})


test_that("hrf_basis_lwu returns derivatives", {
  theta <- c(tau = 6, sigma = 2, rho = 0.4)
  t <- seq(0, 20, by = 1)
  basis <- hrf_basis_lwu(theta, t)
  expect_equal(dim(basis), c(length(t), 4))
  expect_equal(basis[, "h0"], hrf_lwu(t, tau = theta["tau"], sigma = theta["sigma"], rho = theta["rho"]))

  # finite-difference check of derivative w.r.t tau at one point
  delta <- 1e-4
  t0 <- 4
  fd_tau <- (hrf_lwu(t0, tau = theta["tau"] + delta, sigma = theta["sigma"], rho = theta["rho"]) -
              hrf_lwu(t0, tau = theta["tau"] - delta, sigma = theta["sigma"], rho = theta["rho"])) / (2 * delta)
  idx <- which(t == t0)
  expect_equal(as.numeric(basis[idx, "d_tau"]), as.numeric(fd_tau), tolerance = 1e-3)
})

test_that("hrf_basis_lwu derivatives match per-point numDeriv::grad", {
  theta <- c(6, 1.5, 0.35)
  t <- c(-1, 0, 2.5, 6, 9.75, 25)
  basis <- hrf_basis_lwu(theta, t)
  expect_identical(colnames(basis), c("h0", "d_tau", "d_sigma", "d_rho"))
  for (i in seq_along(t)) {
    g <- numDeriv::grad(function(p) hrf_lwu(t[i], p[1], p[2], p[3]), theta)
    expect_equal(unname(basis[i, -1]), g, tolerance = 1e-10)
  }
  expect_equal(dim(hrf_basis_lwu(theta, numeric(0))), c(0L, 4L))
  expect_error(hrf_basis_lwu(theta, c(1, NA)), "NA")
})

test_that("getHRF('lwu') builds an LWU HRF with its parameters passed through", {
  t <- seq(-2, 30, by = 0.5)
  h <- getHRF("lwu")
  expect_s3_class(h, "HRF")
  expect_equal(nbasis(h), 1L)
  expect_equal(attr(h, "name"), "lwu")
  expect_equal(h(t), hrf_lwu(t))

  h2 <- getHRF("lwu", tau = 5, sigma = 1.5, rho = 0.2)
  expect_equal(h2(t), hrf_lwu(t, tau = 5, sigma = 1.5, rho = 0.2))
  expect_equal(attr(h2, "params"), list(tau = 5, sigma = 1.5, rho = 0.2))
  expect_equal(getHRF("lwu", tau = 5, lag = 2)(t), hrf_lwu(t - 2, tau = 5))
  expect_error(getHRF("lwu", sigma = 0.01), "sigma")

  info <- list_available_hrfs()
  expect_equal(info$type[info$name == "lwu"], "generator")
  expect_equal(info$nbasis_default[info$name == "lwu"], "1")
})

test_that("hrf_basis_lwu works for theta0 at the validated parameter bounds", {
  t <- seq(0, 30, by = 0.25)
  # h is linear in rho: d_rho is minus the (causal) undershoot Gaussian
  d_rho <- function(tau, sigma) -exp(-(t - tau - 2 * sigma)^2 / (2 * (1.6 * sigma)^2))
  for (rho in c(0, 1e-6, 1.5, 1.4999)) {
    b <- hrf_basis_lwu(c(6, 2.5, rho), t)
    expect_true(all(is.finite(b)))
    expect_equal(unname(b[, "d_rho"]), d_rho(6, 2.5), tolerance = 1e-8)
    g <- t(vapply(t, function(ti) {
      numDeriv::grad(function(p) hrf_lwu(ti, p[1], p[2], rho), c(6, 2.5))
    }, numeric(2)))
    expect_equal(unname(b[, c("d_tau", "d_sigma")]), g, tolerance = 1e-8)
  }

  # sigma just above its 0.05 lower bound: compare d_sigma with the analytic form
  tau <- 4; sigma <- 0.05 + 1e-7; rho <- 0.3
  tt <- seq(0, 8, by = 0.01)
  b <- hrf_basis_lwu(c(tau, sigma, rho), tt)
  expect_true(all(is.finite(b)))
  u <- tt - tau - 2 * sigma
  d_sigma <- exp(-(tt - tau)^2 / (2 * sigma^2)) * (tt - tau)^2 / sigma^3 -
    rho * exp(-u^2 / (2 * (1.6 * sigma)^2)) *
      (20.48 * u * sigma + 10.24 * u^2) / (26.2144 * sigma^3)
  expect_equal(unname(b[, "d_sigma"]), d_sigma, tolerance = 1e-4)
})
