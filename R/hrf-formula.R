
#' Create an HRF from a basis specification
#'
#' `make_hrf` resolves a basis specification to an `HRF` object and
#' applies an optional temporal lag. The basis may be given as the name
#' of a built-in HRF, as a generating function, or as an existing `HRF`
#' object.
#'
#' @param basis Character name of a built-in HRF, a function that
#'   generates HRF values, or an object of class `HRF`.
#' @param lag Numeric scalar giving the shift in seconds applied to the
#'   HRF.
#' @param nbasis Number of basis functions. `NULL` (the default) gives a
#'   basis-set name such as `"bspline"` or `"fir"` the default size used by
#'   [getHRF()], and a plain function as many basis functions as the columns it
#'   returns. Ignored for fixed HRFs such as `"spmg1"` or an `HRF` object.
#'
#' @return An object of class `HRF` representing the lagged basis.
#'
#' @examples
#' # Canonical SPM HRF delayed by 2 seconds
#' h <- make_hrf("spmg1", lag = 2)
#' h(0:5)
#'
#' @export
make_hrf <- function(basis, lag, nbasis = NULL) {
  if (!is.numeric(lag) || length(lag) != 1 || !is.finite(lag)) {
    stop("`lag` must be a single finite numeric value.")
  }
  if (!is.null(nbasis)) {
    if (!is.numeric(nbasis) || length(nbasis) != 1 || !is.finite(nbasis) ||
        nbasis < 1 || nbasis %% 1 != 0) {
      stop("`nbasis` must be a single positive integer.")
    }
    nbasis <- as.integer(nbasis)
  }

  base <- if (is.character(basis)) {
    if (is.null(nbasis)) getHRF(basis, lag = 0) else getHRF(basis, nbasis = nbasis, lag = 0)
  } else if (inherits(basis, "HRF")) {
    basis
  } else if (is.function(basis)) {
    # Convert a plain function explicitly so that the number of basis
    # functions is set correctly before applying any decorators.
    as_hrf(basis, nbasis = nbasis %||% .detect_nbasis(basis, "basis"))
  } else {
    stop(sprintf(
      "invalid basis function '%s' of class %s: must be 1) character string indicating hrf type, e.g. 'gamma', 2) a function or 3) an object of class 'HRF'",
      deparse(substitute(basis)), paste(class(basis), collapse = ", ")
    ))
  }

  gen_hrf(base, lag = lag)
}
