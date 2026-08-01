# Put this in R/utils-internal.R

# Declare global variables to avoid R CMD check NOTEs for ggplot2 aes() usage
utils::globalVariables(c("time", "response", "HRF", "Regressor", "onset"))

#' @keywords keyword
#' @noRd
recycle_or_error <- function(x, n, name) {
  if (length(x) == n) {
    return(x)
  }
  if (length(x) == 1) {
    return(rep(x, n))
  }
  stop(paste0("`", name, "` must have length 1 or ", n, ", not ", length(x)), call. = FALSE)
}

#' @keywords internal
#' @noRd
`%||%` <- function(a, b) {
  if (is.null(a)) b else a
}

# Zero a response outside the causal support t >= 0.
#
# Several shape functions (gaussian, mexican hat, inverse logit, LWU) are
# defined by formulas that are non-zero at negative lag. The regressor path
# masks negative lags itself, but decorators such as block_hrf() and lag_hrf()
# sample h(t - offset) directly and would otherwise mix in pre-onset values.
#' @keywords internal
#' @noRd
.causal <- function(t, values) {
  values[!is.na(t) & t < 0] <- 0
  values
}

#' @importFrom utils tail
#' @keywords internal
#' @noRd
.block_offsets_weights <- function(width, precision) {
  offsets <- seq(0, width, by = precision)
  if (tail(offsets, 1) < width) {
    offsets <- c(offsets, width)
  }
  if (length(offsets) == 1) {
    return(list(offsets = offsets, weights = 1))
  }

  deltas <- diff(offsets)
  weights <- numeric(length(offsets))
  weights[1] <- deltas[1] / 2
  weights[length(offsets)] <- deltas[length(deltas)] / 2
  if (length(offsets) > 2) {
    weights[2:(length(offsets) - 1)] <- (deltas[-length(deltas)] + deltas[-1]) / 2
  }
  list(offsets = offsets, weights = weights)
}
