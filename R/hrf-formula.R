
#' @export
make_hrf <- function(basis, lag, nbasis = 1) {
  if (!is.numeric(lag) || length(lag) != 1 || !is.finite(lag)) {
    stop("`lag` must be a single finite numeric value.")
  }
  if (!is.numeric(nbasis) || length(nbasis) != 1 || !is.finite(nbasis) ||
      nbasis < 1 || nbasis %% 1 != 0) {
    stop("`nbasis` must be a single positive integer.")
  }
  nbasis <- as.integer(nbasis)
  
  if (is.character(basis)) {
    # Directly retrieve the HRF object with lag applied
    final_hrf <- getHRF(basis, nbasis = nbasis, lag = lag)

  } else if (inherits(basis, "HRF")) {
    # If it's already an HRF object, apply lag using gen_hrf
    final_hrf <- gen_hrf(basis, lag = lag)
    
  } else if (is.function(basis)) {
    # If a plain function is provided, explicitly convert it to an HRF so that
    # the number of basis functions is set correctly before applying any
    # decorators.
    basis <- as_hrf(basis, nbasis = nbasis)
    final_hrf <- gen_hrf(basis, lag = lag)

  } else {
    stop("invalid basis function: must be 1) character string indicating hrf type, e.g. 'gamma' 2) a function or 3) an object of class 'HRF': ", basis)
  }
  
  return(final_hrf)
}



