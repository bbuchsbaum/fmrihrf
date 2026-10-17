#' Build a Design Matrix from Block-wise Onsets
#'
#' `regressor_design` extends [regressor_set()] by allowing onsets to be
#' specified relative to individual blocks and by directly returning the
#' evaluated design matrix.
#'
#' @param onsets Numeric vector of event onset times, expressed relative to the
#'   start of their corresponding block.
#' @param fac A factor (or object coercible to a factor) indicating the
#'   condition for each onset.
#' @param block Integer vector identifying the block for each onset. Values must
#'   be valid block indices for `sframe`.
#' @param sframe A [sampling_frame] describing the temporal structure of the
#'   experiment.
#' @param hrf Hemodynamic response function shared by all conditions.
#' @param duration Numeric scalar or vector of event durations.
#' @param amplitude Numeric scalar or vector of event amplitudes.
#' @param span Numeric scalar giving the HRF span in seconds.
#' @param precision Numeric precision used during convolution.
#' @param method Evaluation method passed to [evaluate()].
#' @param sparse Logical; if `TRUE` a sparse design matrix is returned.
#' @param summate Logical; passed to [regressor()].
#'
#' Each block (run) is convolved separately: the rows of a block depend only
#' on the events of that block, so a response that starts near the end of one
#' run is truncated at the run boundary rather than carried into the next run.
#'
#' @return A numeric matrix (or sparse matrix) with one row per sample defined
#'   by `sframe` (blocks stacked in order) and `nbasis(hrf)` columns per factor
#'   level, in the order of `levels(fac)`. Columns are named after the levels;
#'   when `nbasis(hrf) > 1` they are named `<level>_basis<k>`.
#' @examples
#' # Create a sampling frame for 2 blocks, 100 scans each, TR=2
#' sframe <- sampling_frame(blocklens = c(100, 100), TR = 2)
#' 
#' # Events in block-relative time
#' onsets <- c(10, 30, 50, 20, 40, 60)
#' conditions <- factor(c("A", "B", "A", "B", "A", "B"))
#' blocks <- c(1, 1, 1, 2, 2, 2)
#' 
#' # Build design matrix
#' design <- regressor_design(
#'   onsets = onsets,
#'   fac = conditions,
#'   block = blocks,
#'   sframe = sframe,
#'   hrf = HRF_SPMG1
#' )
#' 
#' # Design matrix has 200 rows (total scans) and 2 columns (conditions)
#' dim(design)
#' @export
regressor_design <- function(onsets, fac, block, sframe,
                             hrf = HRF_SPMG1, duration = 0,
                             amplitude = 1, span = 40,
                             precision = .33,
                             method = c("conv", "loop", "fft", "Rconv"),
                             sparse = FALSE,
                             summate = TRUE) {
  fac   <- as.factor(fac)
  block <- as.integer(block)

  if (length(onsets) != length(fac) || length(onsets) != length(block)) {
    stop("`onsets`, `fac` and `block` must have the same length", call. = FALSE)
  }

  method <- match.arg(method)

  if (anyNA(block) || any(block < 1L) || any(block > length(sframe$blocklens))) {
    stop("`block` values must be valid block indices for `sframe`",
         call. = FALSE)
  }

  onsets    <- as.numeric(onsets)
  duration  <- recycle_or_error(as.numeric(duration), length(onsets), "duration")
  amplitude <- recycle_or_error(as.numeric(amplitude), length(onsets), "amplitude")
  levs      <- levels(fac)

  # Each run is convolved on its own: a run's regressors depend only on that
  # run's events, so responses never carry over into the next run's scans.
  # Onsets are run-relative, and so is the evaluation grid of each run.
  mats <- lapply(seq_along(sframe$blocklens), function(b) {
    idx <- which(block == b)
    rs <- regressor_set(onsets[idx], factor(as.character(fac[idx]), levels = levs),
                        hrf = hrf, duration = duration[idx],
                        amplitude = amplitude[idx], span = span,
                        summate = summate)
    evaluate(rs, grid = samples(sframe, blockids = b, global = FALSE),
             precision = precision, method = method, sparse = FALSE)
  })

  out <- do.call(rbind, mats)
  if (sparse) {
    Matrix::Matrix(out, sparse = TRUE)
  } else {
    out
  }
}
