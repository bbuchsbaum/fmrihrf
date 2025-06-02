
#' Compute an HRF smoothing kernel
#'
#' This function computes a temporal similarity matrix from a series of hemodynamic response functions.
#'
#' @param len The number of scans.
#' @param TR The repetition time (default is 2 seconds).
#' @param form the `trialwise` formula expression, see examples.
#' @param buffer_scans The number of scans to buffer before and after the event.
#' @param normalise Whether to normalise the kernel.
#' @param method The method to use for computing the kernel.
#' @export
#' @examples
#' \dontrun{
#' form <- onsets ~ trialwise(basis="gaussian")
#' sk <- hrf_smoothing_kernel(100, TR=1.5, form)
#' }
#' @return a smoothing matrix
hrf_smoothing_kernel <- function(len, TR = 2,
                                 form  = onset ~ trialwise(),
                                 buffer_scans = 3L,
                                 normalise = TRUE,
                                 method = c("gram", "cosine")) {
  # This function requires event_model and design_matrix which are not yet implemented
  stop("hrf_smoothing_kernel requires event_model and design_matrix functions that are not yet implemented")
}

#' Design kernel for a given design matrix
#'
#' This internal function calculates a design kernel for the given design matrix (`dmat`). It can also compute the derivative of the design kernel if the `deriv` parameter is set to TRUE.
#' @noRd
#' @param dmat A design matrix.
#' @param deriv A logical value indicating whether to compute the derivative (default is FALSE).
#' @keywords internal
#' @examples
#' onsets <- sort(runif(25, 0, 200))
#' fac <- factor(sample(letters[1:4], length(onsets), replace=TRUE))
#' sframe <- sampling_frame(200, TR=1)
#' des <- data.frame(onsets=onsets, fac=fac, constant = factor(rep(1, length(fac))), block=rep(1, length(fac)))
#' emod <- event_model(onsets ~ hrf(constant) + hrf(fac), data=des, sampling_frame=sframe, block = ~ block)
#' dmat <- design_matrix(emod)
design_kernel <- function(dmat, deriv=FALSE) {
  dd <- rbind(rep(0, ncol(dmat)), apply(dmat, 2, diff))
}