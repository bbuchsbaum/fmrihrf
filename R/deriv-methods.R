#' Default derivative method for HRF objects
#'
#' Uses numerical differentiation via numDeriv::grad when analytic derivatives
#' are not available for a specific HRF type.
#'
#' @param x An HRF object
#' @param t Numeric vector of time points at which to evaluate the derivative
#' @param ... Additional arguments (currently unused)
#' @return Numeric vector or matrix of derivative values
#' @importFrom numDeriv grad
#' @examples
#' t <- seq(0, 30, by = 0.5)
#' d <- deriv(HRF_SPMG1, t)
#' @export
#' @method deriv HRF
deriv.HRF <- function(x, t, ...) {
  nb <- nbasis(x)
  result <- matrix(0, nrow = length(t), ncol = nb)
  for (j in seq_len(nb)) {
    # numDeriv::grad needs a scalar function: the j-th basis at one time point
    f_j <- function(time) {
      val <- evaluate(x, time)
      if (is.matrix(val)) val[1, j] else val[1]
    }
    for (i in seq_along(t)) {
      result[i, j] <- numDeriv::grad(f_j, t[i])
    }
  }
  if (nb > 1) result else result[, 1]
}


#' Derivative method for SPMG1 HRF
#'
#' Uses the analytic derivative formula for the SPM canonical HRF.
#'
#' @param x An SPMG1_HRF object
#' @param t Numeric vector of time points at which to evaluate the derivative
#' @param ... Additional arguments (currently unused)
#' @return Numeric vector of derivative values
#' @rdname deriv.HRF
#' @export
#' @method deriv SPMG1_HRF
deriv.SPMG1_HRF <- function(x, t, ...) {
  params <- attr(x, "params") %||% list(P1 = 5, P2 = 15, A1 = 1/120)
  hrf_spmg1_deriv(t, P1 = params$P1, P2 = params$P2, A1 = params$A1)
}


#' Derivative method for SPMG2 HRF
#'
#' Returns derivatives for both the canonical HRF and its temporal derivative.
#' The first column contains the derivative of the canonical HRF, and the second
#' column contains the second derivative (derivative of the temporal derivative).
#'
#' @param x An SPMG2_HRF object
#' @param t Numeric vector of time points at which to evaluate the derivative
#' @param ... Additional arguments (currently unused)
#' @return Matrix with 2 columns of derivative values
#' @rdname deriv.HRF
#' @export
#' @method deriv SPMG2_HRF
deriv.SPMG2_HRF <- function(x, t, ...) {
  # HRF_SPMG2/HRF_SPMG3 are built from the canonical parameters
  # (P1 = 5, P2 = 15, A1 = 1/120), which are the derivative helpers' defaults.
  matrix(c(hrf_spmg1_deriv(t), hrf_spmg1_second_deriv(t)),
         nrow = length(t), ncol = 2)
}


#' Derivative method for SPMG3 HRF
#'
#' Returns derivatives for the canonical HRF and its two derivatives.
#' Returns the first and second time derivatives of the canonical, followed by
#' the time derivative of the dispersion basis.
#'
#' @param x An SPMG3_HRF object
#' @param t Numeric vector of time points at which to evaluate the derivative
#' @param ... Additional arguments (currently unused)
#' @return Matrix with 3 columns of derivative values
#' @rdname deriv.HRF
#' @export
#' @method deriv SPMG3_HRF
deriv.SPMG3_HRF <- function(x, t, ...) {
  # Third column: time derivative of the dispersion basis.
  matrix(c(deriv.SPMG2_HRF(x, t), hrf_spmg1_dispersion_time_deriv(t)),
         nrow = length(t), ncol = 3)
}
