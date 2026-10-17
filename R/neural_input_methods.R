#' @rdname neural_input
#' @details
#' For a \code{Reg} object the input is built exactly as the default
#' \code{"conv"} engine of \code{\link{evaluate}} builds it, on the time grid
#' \code{seq(start, end, by = resolution)}. A point event (duration 0) is an
#' impulse of mass \code{amplitude}, split linearly between the two samples
#' bracketing its onset. A block is projected onto linear (hat) basis
#' functions centred on the samples, with both edges at their exact
#' positions, so it carries mass \code{amplitude * duration} (divided by
#' \code{duration} when the regressor has \code{summate = FALSE}), however
#' short it is. The values are a density, mass per second: a block is
#' \code{amplitude} high away from its edges, a point event is a spike of area
#' \code{amplitude}, and \code{sum(neural_input) * resolution} is the input
#' mass inside the window. Convolving \code{neural_input * resolution} with
#' the HRF sampled every \code{resolution} seconds is the convolution that
#' \code{evaluate(x, grid, precision = resolution)} computes.
#' @export
neural_input.Reg <- function(x, start = 0, end = NULL, resolution = 0.33, ...) {
  # Determine end time if not provided: a 10 s buffer past the last event,
  # or past `start` when there are no events.
  if (is.null(end)) {
    end <- if (length(x$onsets) > 0) max(x$onsets + x$duration) + 10 else start + 10
  }

  time <- seq(from = start, to = end, by = resolution)
  mass <- neural_input_cpp(x$onsets, x$duration, x$amplitude, start = start,
                           dt = resolution, n = length(time),
                           summate = isTRUE(x$summate))

  list(time = time, neural_input = mass / resolution)
}
