#' Construct a Feature Regressor from a Sampled Time Series
#'
#' Creates a regressor from a continuously sampled feature (for example RMS
#' energy of an acoustic stimulus) by treating each sample as a zero-order-hold
#' bin of width \eqn{\Delta t}. The result is the Riemann-sum / ZOH approximation
#' of convolving the feature with an HRF, not a train of unit-mass impulses.
#'
#' Amplitude modulation on this sampling grid is the same linear model as
#' convolving the sampled series: if \eqn{x} is the (possibly centered) feature
#' and \eqn{H} is the convolution operator, the regressor is \eqn{Hx}. Zeros are
#' kept, so an all-TR / all-sample series stays an all-sample series. No
#' unmodulated companion regressor is added.
#'
#' Centering and scaling are applied to the feature **before** convolution.
#' For a whole-run series (`mask = NULL`),
#' \deqn{H(x-\mu\mathbf{1}) = Hx - \mu H\mathbf{1}.}
#' Away from the run edges, \eqn{H\mathbf{1}} is nearly constant (overlapping
#' HRFs sum to a plateau), so with a GLM intercept the centered and raw
#' columns are affinely equivalent. They differ by the HRF-length ramp of
#' \eqn{H\mathbf{1}} at the start and end of the run. Default `center = TRUE`
#' removes that boundary term; `center = FALSE` keeps it. `scale = "sd"`
#' only changes the feature's units (still pre-convolution). It is not
#' standardization of the final BOLD-space column after filtering.
#'
#' Use `mask` when the feature should be centered only during an on-period
#' (stimulus present, task on, and so on). Center and scale then use only the
#' on-samples, and off-mask samples stay 0:
#' \deqn{H[m(x-\mu_{\mathrm{on}})] = H(mx) - \mu_{\mathrm{on}} Hm.}
#' That is **not** an affine transform of the all-sample series. Pair it with
#' a separate boxcar for the on-period if you want presence and intensity as
#' two questions.
#'
#' Each sample is a zero-order-hold bin of width \eqn{\Delta t}, not a
#' unit-mass impulse. Evaluate with `precision` less than or equal to the
#' feature sampling interval. Compared with
#' `regressor(times, amplitude = values, duration = 0)`, the predicted BOLD
#' is smaller by about \eqn{\Delta t}.
#'
#' @section Event-timed features:
#' The zero-order hold is right for a densely sampled signal but wrong for a
#' sparse, event-locked feature such as word surprisal or a per-phone feature:
#' holding each value until the next sample fills every pause with the value
#' of the preceding event. Supply `durations` (with `times`) to treat sample
#' `i` as an event that starts at `times[i]`, lasts `durations[i]` seconds
#' (`0` is an impulse) and has amplitude `values[i]`. Nothing is held across
#' gaps, and the result is the same as
#' `regressor(times, hrf, duration = durations, amplitude = values,
#' drop_zero_amplitude = FALSE)` after centering and scaling. Zero-amplitude
#' events are kept. Events that overlap in time add. `times` must then be
#' non-decreasing rather than strictly increasing, so simultaneous events
#' (ties) are allowed, and a single event is accepted.
#'
#' `center` and `scale` keep their meaning: the statistics are taken over the
#' samples, that is, over events, and each event counts once whatever its
#' duration. This is the parametric-modulator convention (the amplitude is
#' centered across events). The centered column no longer carries the mean
#' response to the events themselves; model that with a separate unmodulated
#' regressor if it is of interest.
#'
#' @md
#' @param values Numeric vector of feature samples. Matrix and array inputs are
#'   rejected; construct one feature regressor per column instead.
#' @param hrf The hemodynamic response function to convolve with the feature.
#'   Same types as [regressor()], except a list of per-event HRFs is not
#'   allowed. Defaults to `HRF_SPMG1`.
#' @param times Numeric vector of sample times in seconds, same length as
#'   `values`. Mutually exclusive with `dt`. Times must be strictly increasing
#'   and non-negative. The last bin width is the last inter-sample gap. When
#'   `durations` is supplied, times are event onsets and need only be
#'   non-decreasing.
#' @param dt Positive sampling interval in seconds. Mutually exclusive with
#'   `times`. Sample times are `start + seq(0, by = dt, length.out = length(values))`.
#' @param start Start time in seconds used only when `dt` is supplied.
#'   Defaults to 0.
#' @param center Logical; if `TRUE` (default), subtract the mean of the
#'   (masked) samples before convolution. For an all-sample series this
#'   removes \eqn{\mu H\mathbf{1}}, including the HRF-length run-boundary ramp.
#' @param scale Character; `"none"` (default) leaves native units, `"sd"`
#'   divides by the standard deviation of the (masked) samples after centering.
#'   This z-scores the feature, not the convolved design column.
#' @param mask Optional logical vector the same length as `values`. Center and
#'   scale statistics are computed on `mask == TRUE` samples only; off-mask
#'   samples are set to 0. This is not equivalent to global all-sample
#'   centering.
#' @param span Temporal window in seconds over which the HRF is evaluated.
#'   If `NULL` (default), the HRF's own span is used. An explicit value is
#'   honoured even when the HRF carries its own span.
#' @param durations Optional event durations in seconds, only valid with
#'   `times`: a single number or one per sample, finite and non-negative. If
#'   `NULL` (default), each sample is held until the next one (zero-order
#'   hold). If supplied, the samples are events; see the section on
#'   event-timed features.
#'
#' @return An S3 object of class `c("FeatureReg", "Reg", "list")`. Evaluation
#'   uses the same convolution path as [regressor()].
#'
#' @examples
#' # 10 Hz envelope over 8 seconds, demeaned
#' dt <- 0.1
#' t <- seq(0, 8, by = dt)
#' rms <- abs(sin(2 * pi * t / 4))
#' feat <- feature_regressor(rms, dt = dt, hrf = HRF_SPMG1)
#'
#' grid <- seq(0, 12, by = 1)
#' y <- evaluate(feat, grid, precision = dt)
#'
#' # Same ZOH encoding as a duration-dt event regressor (no centering)
#' feat_raw <- feature_regressor(rms, dt = dt, center = FALSE, scale = "none")
#' ev <- regressor(t, HRF_SPMG1, duration = dt, amplitude = rms)
#' all.equal(evaluate(feat_raw, grid, precision = dt),
#'           evaluate(ev, grid, precision = dt))
#'
#' # Event-timed feature: word onsets, word durations and a per-word value.
#' # The value of the second word is not carried across the pause before the
#' # third.
#' onsets <- c(0.5, 1.1, 6.0)
#' word_dur <- c(0.4, 0.5, 0.3)
#' surprisal <- c(2, 7, 4)
#' words <- feature_regressor(surprisal, times = onsets, durations = word_dur)
#' y_words <- evaluate(words, grid, precision = 0.1)
#'
#' @seealso [regressor()], [evaluate()]
#' @export
feature_regressor <- function(values,
                              hrf = HRF_SPMG1,
                              times = NULL,
                              dt = NULL,
                              start = 0,
                              center = TRUE,
                              scale = c("none", "sd"),
                              mask = NULL,
                              span = NULL,
                              durations = NULL) {

  scale <- match.arg(scale)

  if (!is.null(dim(values))) {
    stop("`values` must be a numeric vector; matrix and array inputs are not ",
         "supported. Pass one feature column at a time.", call. = FALSE)
  }
  if (!is.numeric(values) || length(values) == 0L) {
    stop("`values` must be a non-empty numeric vector.", call. = FALSE)
  }
  if (anyNA(values) || any(!is.finite(values))) {
    stop("`values` must contain finite numeric values.", call. = FALSE)
  }

  if (!is.logical(center) || length(center) != 1L || is.na(center)) {
    stop("`center` must be a single logical value.", call. = FALSE)
  }

  has_times <- !is.null(times)
  has_dt <- !is.null(dt)
  if (has_times == has_dt) {
    stop("Supply exactly one of `times` or `dt`.", call. = FALSE)
  }

  has_durations <- !is.null(durations)
  if (has_durations && !has_times) {
    stop("`durations` can only be used with `times`.", call. = FALSE)
  }

  n <- length(values)
  hrf_is_list <- is.list(hrf) && !inherits(hrf, "HRF")
  if (hrf_is_list) {
    stop("`hrf` cannot be a list of per-event HRFs for a feature regressor.",
         call. = FALSE)
  }

  if (has_dt) {
    if (!is.numeric(dt) || length(dt) != 1L || is.na(dt) || !is.finite(dt) ||
        dt <= 0) {
      stop("`dt` must be a single positive finite number.", call. = FALSE)
    }
    if (!is.numeric(start) || length(start) != 1L || is.na(start) ||
        !is.finite(start) || start < 0) {
      stop("`start` must be a single non-negative finite number.", call. = FALSE)
    }
    times <- start + seq(0, by = dt, length.out = n)
    duration <- rep(dt, n)
    dt_attr <- dt
  } else {
    times <- as.numeric(times)
    if (length(times) != n) {
      stop("`times` must have the same length as `values`.", call. = FALSE)
    }
    if (anyNA(times) || any(!is.finite(times))) {
      stop("`times` must contain finite numeric values.", call. = FALSE)
    }
    if (any(times < 0)) {
      stop("`times` must be non-negative.", call. = FALSE)
    }
    if (has_durations) {
      # Event-timed samples: each one lasts its own duration and nothing is
      # held across the gap to the next. Ties are simultaneous events.
      if (!is.numeric(durations) || !(length(durations) %in% c(1L, n))) {
        stop("`durations` must be a single number or a numeric vector the ",
             "same length as `values`.", call. = FALSE)
      }
      if (anyNA(durations) || any(!is.finite(durations))) {
        stop("`durations` must contain finite numeric values.", call. = FALSE)
      }
      if (any(durations < 0)) {
        stop("`durations` must be non-negative.", call. = FALSE)
      }
      if (is.unsorted(times)) {
        stop("`times` must be non-decreasing.", call. = FALSE)
      }
      duration <- rep_len(as.numeric(durations), n)
      dt_attr <- NA_real_
    } else {
      if (n < 2L) {
        stop("`times` must have at least two samples so the last bin width ",
             "can be inferred.", call. = FALSE)
      }
      if (is.unsorted(times, strictly = TRUE)) {
        stop("`times` must be strictly increasing.", call. = FALSE)
      }
      gaps <- diff(times)
      duration <- c(gaps, gaps[length(gaps)])
      dt_attr <- if ((max(gaps) - min(gaps)) <=
                     sqrt(.Machine$double.eps) * max(1, stats::median(gaps))) {
        gaps[[1L]]
      } else {
        NA_real_
      }
    }
  }

  amplitude <- as.numeric(values)
  if (is.null(mask)) {
    stats_idx <- seq_len(n)
  } else {
    if (!is.logical(mask) || length(mask) != n || anyNA(mask)) {
      stop("`mask` must be a non-missing logical vector the same length as ",
           "`values`.", call. = FALSE)
    }
    stats_idx <- which(mask)
    if (length(stats_idx) == 0L) {
      stop("`mask` must contain at least one TRUE value.", call. = FALSE)
    }
  }

  if (center) {
    amplitude[stats_idx] <- amplitude[stats_idx] - mean(amplitude[stats_idx])
  }

  if (identical(scale, "sd")) {
    sdv <- stats::sd(amplitude[stats_idx])
    if (!is.finite(sdv) || sdv == 0) {
      stop("`scale = \"sd\"` requires a non-zero standard deviation after ",
           "centering.", call. = FALSE)
    }
    amplitude[stats_idx] <- amplitude[stats_idx] / sdv
  }

  if (!is.null(mask)) {
    amplitude[!mask] <- 0
  }

  if (!is.null(span) && (!is.numeric(span) || length(span) != 1L)) {
    stop("`span` must be a single positive finite number.", call. = FALSE)
  }
  out <- Reg(
    onsets = times,
    hrf = hrf,
    duration = duration,
    amplitude = amplitude,
    span = if (is.null(span)) 40 else span,
    summate = TRUE,
    drop_zero_amplitude = FALSE
  )
  # Reg() prefers the HRF's own span attribute, which every HRF built by
  # make_hrf() carries, so an explicit `span` has to be applied afterwards.
  if (!is.null(span)) {
    out$span <- as.numeric(span)
  }

  class(out) <- c("FeatureReg", class(out))
  attr(out, "center") <- center
  attr(out, "scale") <- scale
  attr(out, "dt") <- dt_attr
  attr(out, "event_timed") <- has_durations
  out
}


#' @export
#' @method print FeatureReg
print.FeatureReg <- function(x, ...) {
  n_samp <- length(x$onsets)
  hrf_name <- attr(x$hrf, "name") %||% "custom function"
  nb <- nbasis(x$hrf)
  dt_attr <- attr(x, "dt")
  centered <- isTRUE(attr(x, "center"))
  scale_attr <- attr(x, "scale") %||% "none"

  cat("-- FeatureReg ", paste(rep("-", 50), collapse = ""), "\n", sep = "")
  cat("   Samples:", n_samp, "\n")
  if (n_samp > 0L) {
    cat("   Time range:", round(min(x$onsets), 2), "s to",
        round(max(x$onsets), 2), "s\n")
    if (isTRUE(attr(x, "event_timed"))) {
      cat("   Timing: events with explicit durations\n")
    } else if (!is.null(dt_attr) && length(dt_attr) == 1L && !is.na(dt_attr)) {
      cat("   Sampling interval:", dt_attr, "s\n")
    } else {
      cat("   Sampling interval: irregular\n")
    }
  }
  cat("   Center:", centered, "\n")
  cat("   Scale:", scale_attr, "\n")
  if (n_samp > 0L) {
    cat("   Amplitude range:", round(min(x$amplitude), 2), "to",
        round(max(x$amplitude), 2), "\n")
  }
  cat("   HRF:", hrf_name, paste0("(", nb, " basis function",
                                  if (nb == 1L) ")" else "s)"), "\n")
  cat("   HRF span:", x$span, "s\n")

  invisible(x)
}


#' @rdname shift
#' @export
#' @method shift FeatureReg
shift.FeatureReg <- function(x, shift_amount, ...) {
  shift_amount <- resolve_shift_amount(shift_amount, list(...))

  if (length(x$onsets) == 0L) {
    return(x)
  }

  # Move the samples in place: rebuilding through Reg() would drop the
  # FeatureReg class and attributes. Centering is not re-applied.
  shifted <- x$onsets + shift_amount
  if (any(shifted < 0)) {
    stop("Shifting would produce negative sample times.", call. = FALSE)
  }

  x$onsets <- shifted
  x
}
