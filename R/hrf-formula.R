
#' @export
make_hrf <- function(basis, lag, nbasis=1) {
  if (!is.numeric(lag) || length(lag) > 1) {
    stop("hrf: 'lag' must be a numeric scalar")
  }
  
  if (is.character(basis)) {
    # Resolve character name to a base HRF object or function using getHRF
    # Note: getHRF itself might need simplification later; it currently calls
    # gen_hrf internally for most types.
    base_hrf_obj <- getHRF(basis, nbasis=nbasis, lag=0)
    # Apply lag using gen_hrf
    final_hrf <- gen_hrf(base_hrf_obj, lag = lag)

  } else if (inherits(basis, "HRF")) {
    # If it's already an HRF object, apply lag using gen_hrf
    final_hrf <- gen_hrf(basis, lag = lag)
    
  } else if (is.function(basis)) {
    # If it's a raw function, gen_hrf will handle conversion via as_hrf and apply lag
    final_hrf <- gen_hrf(basis, lag = lag)

  } else {
    stop("invalid basis function: must be 1) character string indicating hrf type, e.g. 'gamma' 2) a function or 3) an object of class 'HRF': ", basis)
  }
  
  return(final_hrf)
}



