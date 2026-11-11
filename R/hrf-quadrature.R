# Quadrature (Hilbert-pair) basis and amplitude/latency estimation ----------

.quadrature_cache <- new.env(parent = emptyenv())

# Tabulate the quadrature partner of hrf_spmg1() on [0, span]: the Hilbert
# transform of the canonical HRF, made orthogonal to it and scaled to the same
# L2 norm over the span.
.spmg1_quadrature_table <- function(P1, P2, A1, span, dt = 0.01) {
  key <- paste(P1, P2, A1, span, sep = "_")
  tab <- .quadrature_cache[[key]]
  if (!is.null(tab)) return(tab)

  tt <- seq(0, span, by = dt)
  h <- hrf_spmg1(tt, P1 = P1, P2 = P2, A1 = A1)
  # Discrete Hilbert transform with generous zero padding, so the periodic
  # wrap-around of the FFT does not reach the span.
  n <- stats::nextn(8L * length(tt), factors = 2L)
  H <- stats::fft(c(h, numeric(n - length(h))))
  mult <- c(0, rep(-1i, n / 2 - 1), 0, rep(1i, n / 2 - 1))
  q <- Re(stats::fft(H * mult, inverse = TRUE) / n)[seq_along(tt)]
  q <- q - h * sum(h * q) / sum(h^2)
  q <- q * sqrt(sum(h^2) / sum(q^2))

  tab <- list(t = tt, q = q)
  assign(key, tab, envir = .quadrature_cache)
  tab
}

#' Quadrature partner of the SPM canonical HRF
#'
#' @description
#' The Hilbert transform of the SPM canonical HRF ([hrf_spmg1()]) on
#' `[0, span]`, made orthogonal to the canonical HRF and scaled to the same L2
#' norm. Together the two functions form a quadrature pair: a small shift of
#' the response in time acts, to a good approximation, as a rotation of the
#' two coefficients, so their length carries amplitude and their angle carries
#' latency. The temporal derivative in [HRF_SPMG2] plays the same role but
#' only for shifts of about a second.
#'
#' @inheritParams hrf_spmg1
#' @param span Length in seconds of the window on which the function is
#'   defined (default 32). It is zero outside `[0, span]`.
#' @return A numeric vector the same length as `t`.
#' @details
#' The function is tabulated once per parameter set on a 0.01 s grid (the
#' Hilbert transform is computed with a zero-padded FFT) and interpolated
#' linearly.
#' Unlike the canonical HRF, the Hilbert transform of a causal function is
#' not causal, so the quadrature partner does not start at zero: restricted to
#' `[0, span]` it begins at about -0.37 of the canonical peak. Treat it as a
#' companion regressor for estimating latency, not as a response shape.
#' @references
#' Saad, Z. S., Ropella, K. M., Cox, R. W., & DeYoe, E. A. (2001). Analysis
#' and use of FMRI response delays. *Human Brain Mapping*, 13(2), 74-93.
#' \doi{10.1002/hbm.1026}
#' @family hrf_functions
#' @seealso [HRF_SPMGQ], [amplitude_latency()]
#' @export
#' @examples
#' t <- seq(0, 32, by = 0.1)
#' h <- hrf_spmg1(t)
#' q <- hrf_spmg1_quadrature(t)
#' matplot(t, cbind(h, q), type = "l", lty = 1, ylab = "response")
#' sum(h * q)              # orthogonal
#' sum(h^2) / sum(q^2)     # equal norm
hrf_spmg1_quadrature <- function(t, P1 = 5, P2 = 15, A1 = 1 / 120, span = 32) {
  assertthat::assert_that(is.numeric(span), length(span) == 1L, span > 0,
                          msg = "`span` must be a single positive number.")
  tab <- .spmg1_quadrature_table(P1, P2, A1, span)
  out <- stats::approx(tab$t, tab$q, xout = t, rule = 1)$y
  out[is.na(out)] <- 0
  out
}

#' Coefficients of a time-shifted response in an HRF basis
#'
#' @description
#' For each shift `s`, the least-squares coefficients of the reference
#' response delayed by `s` seconds, `reference(t - s)`, in the basis `hrf`.
#' As `s` varies the coefficients trace a curve in coefficient space;
#' [amplitude_latency()] locates fitted coefficients on that curve.
#'
#' @param hrf A multi-basis `HRF` object, e.g. [HRF_SPMG2] or [HRF_SPMGQ].
#' @param shifts Numeric vector of delays in seconds (positive = later).
#' @param reference An `HRF` object or function of time giving the response
#'   shape whose shifts are fitted. Defaults to the first basis function of
#'   `hrf`.
#' @param dt Time step in seconds of the grid used for the projection.
#' @return A matrix with one row per shift and one column per basis function,
#'   with attributes `shifts` and `gram` (the Gram matrix of the basis on the
#'   projection grid).
#' @seealso [amplitude_latency()]
#' @export
#' @examples
#' cc <- hrf_shift_curve(HRF_SPMG2, shifts = c(-2, -1, 0, 1, 2))
#' cc   # an unshifted response is (1, 0); the derivative picks up the shift
hrf_shift_curve <- function(hrf, shifts = seq(-4, 4, by = 0.05),
                            reference = NULL, dt = 0.05) {
  assertthat::assert_that(inherits(hrf, "HRF"), msg = "`hrf` must be an HRF object.")
  assertthat::assert_that(nbasis(hrf) >= 2L,
                          msg = "`hrf` must have at least two basis functions.")
  assertthat::assert_that(is.numeric(shifts), length(shifts) >= 1L, !anyNA(shifts),
                          msg = "`shifts` must be a numeric vector without NAs.")
  span <- attr(hrf, "span")
  tt <- seq(min(0, min(shifts)), span + max(0, max(shifts)), by = dt)
  B <- as.matrix(hrf(tt))
  ref <- if (is.null(reference)) {
    function(x) as.matrix(hrf(x))[, 1L]
  } else if (is.function(reference)) {
    function(x) as.numeric(reference(x))
  } else {
    stop("`reference` must be NULL, an HRF object or a function of time.", call. = FALSE)
  }
  G <- crossprod(B)
  Y <- vapply(shifts, function(s) ref(tt - s), numeric(length(tt)))
  C <- t(solve(G, crossprod(B, Y)))
  dimnames(C) <- list(NULL, paste0("b", seq_len(ncol(B))))
  attr(C, "shifts") <- shifts
  attr(C, "gram") <- G * dt
  C
}

#' Amplitude and latency from the coefficients of a multi-basis HRF
#'
#' @description
#' Summarises the fitted coefficients of a multi-basis HRF (canonical plus
#' temporal derivative, [HRF_SPMG2], or the quadrature pair [HRF_SPMGQ]) as a
#' response amplitude and a latency. The coefficients of a unit-amplitude
#' response delayed by `s` seconds trace a known curve ([hrf_shift_curve()]);
#' each coefficient vector is matched to the point of the curve it is most
#' nearly proportional to. That point's shift is the latency, and the
#' proportionality constant is the amplitude.
#'
#' With `method = "boost"` the amplitude is instead the derivative-boost
#' estimate of Calhoun et al. (2004), `sign(b1) * sqrt(b' G b / G[1, 1])`,
#' which needs no curve but is biased low for shifts beyond about a second.
#'
#' @param beta Numeric vector of length `nbasis(hrf)`, or a matrix with one
#'   row per response (voxel, condition, ...) and `nbasis(hrf)` columns, in
#'   the order of the basis functions.
#' @param hrf The multi-basis `HRF` object the coefficients were fitted with.
#' @param shifts Candidate latencies in seconds. Estimates are limited to
#'   this range; estimates at either end mean the response lies outside it.
#' @param method `"curve"` (default) or `"boost"`.
#' @param metric Optional positive-definite `nbasis` x `nbasis` matrix that
#'   defines proportionality: the inverse covariance of the coefficients, up
#'   to scale. Defaults to the Gram matrix of the basis, which is appropriate
#'   for well-separated events and white noise.
#' @param min_fit Responses whose coefficients match the curve with a cosine
#'   below this value get `NA` latency and amplitude (default 0, i.e. only
#'   responses pointing away from every candidate are dropped).
#' @inheritParams hrf_shift_curve
#' @return A data frame with one row per response and columns `amplitude`,
#'   `latency` (seconds, positive = later than the reference; `NA` for
#'   `method = "boost"`) and `fit` (cosine between the coefficients and the
#'   matched curve point; 1 is a perfect match).
#' @details
#' Amplitude is signed: a negative response at the reference latency has a
#' negative amplitude rather than a half-cycle shift. Latency is poorly
#' determined when the amplitude is close to zero; mask such responses (for
#' example by a test on the amplitude) before interpreting it.
#' @references
#' Calhoun, V. D., Stevens, M. C., Pearlson, G. D., & Kiehl, K. A. (2004).
#' fMRI analysis with the general linear model: removal of latency-induced
#' amplitude bias by incorporation of hemodynamic derivative terms.
#' *NeuroImage*, 22(1), 252-257. \doi{10.1016/j.neuroimage.2003.12.029}
#'
#' Henson, R. N. A., Price, C. J., Rugg, M. D., Turner, R., & Friston, K. J.
#' (2002). Detecting latency differences in event-related BOLD responses:
#' application to words versus nonwords and initial versus repeated face
#' presentations. *NeuroImage*, 15(1), 83-97. \doi{10.1006/nimg.2001.0940}
#'
#' Liao, C. H., Worsley, K. J., Poline, J.-B., Aston, J. A. D., Duncan, G. H.,
#' & Evans, A. C. (2002). Estimating the delay of the fMRI response.
#' *NeuroImage*, 16(3), 593-606. \doi{10.1006/nimg.2002.1096}
#'
#' Saad, Z. S., Ropella, K. M., Cox, R. W., & DeYoe, E. A. (2001). Analysis
#' and use of FMRI response delays. *Human Brain Mapping*, 13(2), 74-93.
#' \doi{10.1002/hbm.1026}
#' @seealso [hrf_shift_curve()], [HRF_SPMGQ]
#' @export
#' @examples
#' # Coefficients of a canonical response of amplitude 2, delayed by 1.5 s
#' t <- seq(0, 40, by = 0.05)
#' y <- 2 * hrf_spmg1(t - 1.5)
#' beta <- qr.solve(HRF_SPMG2(t), y)
#' beta                                   # the canonical coefficient is not 2
#' amplitude_latency(beta, HRF_SPMG2)
#' amplitude_latency(beta, HRF_SPMG2, method = "boost")
amplitude_latency <- function(beta, hrf, shifts = seq(-4, 4, by = 0.05),
                              method = c("curve", "boost"), metric = NULL,
                              reference = NULL, min_fit = 0, dt = 0.05) {
  method <- match.arg(method)
  assertthat::assert_that(inherits(hrf, "HRF"), msg = "`hrf` must be an HRF object.")
  k <- nbasis(hrf)
  if (is.null(dim(beta))) beta <- matrix(beta, nrow = 1L)
  beta <- as.matrix(beta)
  if (!is.numeric(beta) || ncol(beta) != k) {
    stop(sprintf("`beta` must be numeric with %d columns (one per basis function of `hrf`).", k),
         call. = FALSE)
  }
  C <- hrf_shift_curve(hrf, shifts = shifts, reference = reference, dt = dt)
  G <- if (is.null(metric)) attr(C, "gram") else as.matrix(metric)
  if (!all(dim(G) == k) || any(!is.finite(G))) {
    stop(sprintf("`metric` must be a finite %d x %d matrix.", k, k), call. = FALSE)
  }
  beta_norm <- sqrt(pmax(rowSums((beta %*% G) * beta), 0))

  if (method == "boost") {
    amp <- sign(beta[, 1L]) * beta_norm / sqrt(G[1L, 1L])
    return(data.frame(amplitude = amp, latency = NA_real_, fit = NA_real_,
                      row.names = rownames(beta)))
  }

  CG <- C %*% G
  c_norm2 <- rowSums(CG * C)
  # Signed cosine between every response and every curve point. A response is
  # matched in absolute value, and the sign goes to the amplitude.
  cosang <- (beta %*% t(CG)) / outer(beta_norm, sqrt(c_norm2))
  cosang[!is.finite(cosang)] <- NA_real_
  best <- apply(abs(cosang), 1L, function(z) if (all(is.na(z))) NA_integer_ else which.max(z))
  idx <- cbind(seq_len(nrow(beta)), best)
  fit <- abs(cosang[idx])
  amp <- (beta %*% t(CG))[idx] / c_norm2[best]
  lat <- shifts[best]
  drop <- is.na(fit) | fit < min_fit
  amp[drop] <- NA_real_
  lat[drop] <- NA_real_
  data.frame(amplitude = amp, latency = lat, fit = fit, row.names = rownames(beta))
}
