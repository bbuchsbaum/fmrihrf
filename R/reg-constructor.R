#' Internal Constructor for Regressor Objects
#' 
#' @keywords internal
#' @return An S3 object of class `Reg` (and `list`) with components:
#'   * `onsets`: Numeric vector of event onset times (seconds).
#'   * `hrf`: An object of class `HRF` used for convolution.
#'   * `duration`: Numeric vector of event durations (seconds).
#'   * `amplitude`: Numeric vector of event amplitudes/scaling factors.
#'   * `span`: Numeric scalar indicating the HRF span (seconds).
#'   * `summate`: Logical indicating if overlapping HRF responses should summate.
#'   * `filtered_all`: Logical attribute set to `TRUE` when all events were
#'     removed due to zero or `NA` amplitudes.
#' @importFrom assertthat assert_that
Reg <- function(onsets, hrf=HRF_SPMG1, duration=0, amplitude=1, span=40, summate=TRUE) {
  
  # Initial conversions
  onsets    <- as.numeric(onsets)
  duration  <- as.numeric(duration)
  amplitude <- as.numeric(amplitude)
  assert_that(is.logical(summate), length(summate) == 1)
  summate   <- as.logical(summate)
  span_arg  <- as.numeric(span) # Store original arg

  # Handle NA onset case explicitly (represents intent for zero events)
  if (length(onsets) == 1 && is.na(onsets[1])) {
      onsets <- numeric(0)
  }

  # Validate converted inputs for finiteness/NA
  if (anyNA(onsets) || any(!is.finite(onsets))) {
      stop("`onsets` must contain finite numeric values.", call. = FALSE)
  }
  if (anyNA(duration) || any(!is.finite(duration))) {
      stop("`duration` must contain finite numeric values.", call. = FALSE)
  }
  if (anyNA(amplitude) || any(!is.finite(amplitude))) {
      stop("`amplitude` must contain finite numeric values.", call. = FALSE)
  }
  if (is.na(span_arg) || !is.finite(span_arg) || span_arg <= 0) {
      stop("`span` must be a positive, finite number.", call. = FALSE)
  }
  n_onsets <- length(onsets)

  # Check for invalid onsets *before* recycling other args
  if (any(onsets < 0)) {
      stop("`onsets` must be non-negative.", call. = FALSE)
  }
  
  # Recycle/Validate inputs *before* filtering
  # Use recycle_or_error from utils-internal.R
  duration  <- recycle_or_error(duration, n_onsets, "duration")
  amplitude <- recycle_or_error(amplitude, n_onsets, "amplitude")
  
  # Check for invalid inputs early
  if (any(duration < 0, na.rm = TRUE)) stop("`duration` cannot be negative.")
  

  # Filter events based on non-zero and non-NA amplitude
  if (n_onsets > 0) { 
      keep_indices <- which(amplitude != 0 & !is.na(amplitude))
      # Store whether filtering occurred
      filtered_some <- length(keep_indices) < n_onsets
      # Store whether *all* were filtered
      filtered_all <- length(keep_indices) == 0
      
      if (filtered_some) {
          onsets    <- onsets[keep_indices]
          duration  <- duration[keep_indices]
          amplitude <- amplitude[keep_indices]
          n_onsets  <- length(onsets) # Update count after filtering
      }
  } else {
      filtered_all <- TRUE # If input was empty, effectively all are filtered
  }
  
  # Ensure HRF is a valid HRF object using make_hrf
  hrf  <- make_hrf(hrf, lag = 0) 
  assert_that(inherits(hrf, "HRF"), msg = "Invalid 'hrf' provided or generated.")
  
  # Determine final span using %||% helper (ensure helper is available)
  final_span <- attr(hrf, "span") %||% span_arg
  # Optional: Adjust span based on max duration? (kept from old regressor, review)
  # if (n_onsets > 0 && any(duration > final_span / 2)) {
  #    final_span <- max(duration, na.rm=TRUE) * 2
  # }

  # Construct the final object
  out <- structure(list(
    onsets      = onsets,
    duration    = duration,
    amplitude   = amplitude,
    hrf         = hrf,
    span        = final_span,
    summate     = summate
  ), class = c("Reg", "list"))
  
  # Add attribute to signal if all events were filtered
  attr(out, "filtered_all") <- filtered_all 
  return(out)
}


#' Construct a Regressor Object
#' 
#' Creates an object representing event-related regressors for fMRI modeling.
#' This function defines event onsets and associates them with a hemodynamic 
#' response function (HRF) to generate predicted time courses.
#' 
#' @param onsets A numeric vector of event onset times in seconds.
#' @param hrf The hemodynamic response function (HRF) to convolve with the events.
#'   This can be a pre-defined `HRF` object (e.g., `HRF_SPMG1`), a custom `HRF` 
#'   object created with `as_hrf`, a function `f(t)`, or a character string 
#'   referring to a known HRF type (e.g., "spmg1", "gaussian"). Defaults to `HRF_SPMG1`.
#' @param duration A numeric scalar or vector specifying the duration of each event 
#'   in seconds. If scalar, it's applied to all events. Defaults to 0 (impulse events).
#' @param amplitude A numeric scalar or vector specifying the amplitude (scaling factor) 
#'   for each event. If scalar, it's applied to all events. Defaults to 1.
#' @param span The temporal window (in seconds) over which the HRF is defined 
#'   or evaluated. This influences the length of the convolution. If not provided, 
#'   it may be inferred from the `hrf` object or default to 40s. **Note:** Unlike some
#'   previous versions, the `span` is not automatically adjusted based on `duration`;
#'   ensure the provided or inferred `span` is sufficient for your longest event duration.
#' @param summate Logical scalar; if `TRUE` (default), the HRF response amplitude scales
#'   with the duration of sustained events (via internal convolution/summation). If `FALSE`,
#'   the response reflects the peak HRF reached during the event duration.
#'   
#' @details 
#' This function serves as the main public interface for creating regressor objects. 
#' Internally, it utilizes the `Reg()` constructor which performs validation and 
#' efficient storage. The resulting object can be evaluated at specific time points 
#' using the `evaluate()` function.
#' 
#' Events with an amplitude of 0 are automatically filtered out.
#' 
#' @return An S3 object of class `Reg` and `list`
#'   containing processed event information and the HRF specification. The
#'   object includes a `filtered_all` attribute indicating whether all events
#'   were removed due to zero or `NA` amplitudes.
#' @examples
#' # Create a simple regressor with 3 events
#' reg <- regressor(onsets = c(10, 30, 50), hrf = HRF_SPMG1)
#' 
#' # Regressor with durations and amplitudes
#' reg2 <- regressor(
#'   onsets = c(10, 30, 50),
#'   duration = c(2, 2, 2),
#'   amplitude = c(1, 1.5, 0.8),
#'   hrf = HRF_SPMG1
#' )
#' 
#' # Using different HRF types
#' reg_gamma <- regressor(onsets = c(10, 30), hrf = "gamma")
#' 
#' # Evaluate regressor at specific time points
#' times <- seq(0, 60, by = 0.1)
#' response <- evaluate(reg, times)
#' @importFrom assertthat assert_that
#' @export
regressor <- Reg # Assign Reg directly to regressor


#' Create an Empty Regressor Object
#' 
#' A convenience function to create a regressor object representing no events. 
#' Useful for placeholder or baseline scenarios.
#' 
#' @param hrf The HRF object to associate (defaults to `HRF_SPMG1`).
#' @param span The span to associate (defaults to 24).
#' @return A `Reg` object representing zero events.
#' @noRd
null_regressor <- function(hrf=HRF_SPMG1, span=24) {
  # Calls Reg directly, ensuring amplitude=0 triggers empty result
  Reg(onsets = numeric(0), hrf = hrf, span = span, amplitude = 0) 
}


#' Create a single trial regressor
#'
#' Creates a regressor object for modeling a single trial event in an fMRI experiment.
#' This is particularly useful for trial-wise analyses where each trial needs to be
#' modeled separately. The regressor represents the predicted BOLD response for a single
#' event using a specified hemodynamic response function (HRF).
#'
#' This is a convenience wrapper around `regressor` that ensures inputs have length 1.
#'
#' @param onsets the event onset in seconds, must be of length 1.
#' @param hrf a hemodynamic response function, e.g. \code{HRF_SPMG1}
#' @param duration duration of the event (default is 0), must be length 1.
#' @param amplitude scaling vector (default is 1), must be length 1.
#' @param span the temporal window of the impulse response function (default is 24).
#' @return A `Reg` object (inheriting from `regressor` and `list`).
#' @examples
#' # Create single trial regressor at 10 seconds
#' str1 <- single_trial_regressor(onsets = 10, hrf = HRF_SPMG1)
#' 
#' # Single trial with duration and custom amplitude
#' str2 <- single_trial_regressor(
#'   onsets = 15,
#'   duration = 3,
#'   amplitude = 2,
#'   hrf = HRF_SPMG1
#' )
#' 
#' # Evaluate the response
#' times <- seq(0, 40, by = 0.1)
#' response <- evaluate(str1, times)
#' @seealso \code{\link{regressor}}
#' @importFrom assertthat assert_that
#' @export
single_trial_regressor <- function(onsets, hrf=HRF_SPMG1, duration=0, amplitude=1, span=24) {
  # Basic validation specific to single trial before calling Reg
  assertthat::assert_that(
    length(onsets) == 1,
    msg = "`onsets` must be of length 1"
  )
  assertthat::assert_that(
    length(duration) <= 1,
    msg = "`duration` must have length 1 or be a scalar"
  )
  assertthat::assert_that(
    length(amplitude) <= 1,
    msg = "`amplitude` must have length 1 or be a scalar"
  )
  
  # Call Reg constructor, which now sets correct classes
  Reg(onsets       = onsets,
      hrf          = hrf,
      duration     = duration,
      amplitude    = amplitude,
      span         = span, # Keep original default span 
      summate      = TRUE)
} 