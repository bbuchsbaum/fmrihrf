#' @rdname penalty_matrix
#' @export
penalty_matrix.HRF <- function(x, order = 2, ...) {
  # Get number of basis functions
  nb <- nbasis(x)
  
  # Default to identity matrix (ridge penalty)
  # For more sophisticated penalties, specific HRF types could override this
  R <- diag(nb)
  
  # For multi-basis HRFs, could implement different penalties
  # For example, penalize derivatives more than the main function
  if (nb > 1 && !is.null(attr(x, "name"))) {
    hrf_name <- attr(x, "name")
    
    # Special handling for SPM with derivatives
    if (grepl("SPMG[23]", hrf_name)) {
      # Don't penalize canonical, penalize derivatives more
      R[1, 1] <- 0
      if (nb >= 2) R[2, 2] <- 2  # Temporal derivative
      if (nb >= 3) R[3, 3] <- 2  # Dispersion derivative
    }
  }
  
  return(R)
}