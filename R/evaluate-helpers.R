#' @importFrom memoise memoise
#' @keywords internal
#' @noRd
# Bounded in-memory LRU cache for HRF evaluations to prevent
# unbounded growth in long-running sessions. If cachem isn't
# available at runtime, fall back to memoise's default memory cache.
.hrf_eval_cache <- tryCatch(
  cachem::cache_mem(
    max_size = getOption("fmrihrf.hrf_cache_max_size", 50 * 1024^2), # 50 MB default
    evict = "lru"
  ),
  error = function(e) memoise::cache_memory()
)

.memo_hrf <- memoise::memoise(
  function(hrf, span, dt) {
    if (!is.numeric(span) || length(span) != 1 || span <= 0) {
        stop("`span` must be a single numeric value strictly greater than 0.", call. = FALSE)
    }
    if (!is.numeric(dt) || length(dt) != 1 || dt <= 0) {
        stop("`dt` must be a single numeric value strictly greater than 0.", call. = FALSE)
    }
    times <- seq(0, span, by = dt)
    # Evaluate HRF - ensure it returns a matrix
    val <- fmrihrf::evaluate(hrf, times)
    if (is.vector(val)) matrix(val, ncol = 1) else val
  },
  cache = .hrf_eval_cache
)

#' Prepare Inputs for Regressor Evaluation Engines
#'
#' Internal helper performing the setup shared by the evaluation engines:
#' sorts the grid, drops events whose response cannot reach it, and samples
#' (memoised) the HRF on the fine grid.
#'
#' @param x A `Reg` object.
#' @param grid The target evaluation time grid (numeric vector).
#' @param precision The precision for internal calculations (numeric scalar).
#' @return A list containing prepared inputs:
#'   * `nb`: Number of basis functions.
#'   * `hrf_span`: The span of the HRF.
#'   * `valid_ons`: Filtered onset times relevant to the grid.
#'   * `valid_durs`: Corresponding durations.
#'   * `valid_amp`: Corresponding amplitudes.
#'   * `grid`: The (sorted) target grid.
#'   * `precision`: The precision value.
#'   * `hrf_fine_matrix`: HRF values sampled every `precision` seconds over
#'     `[0, hrf_span]` (memoised). NULL if hrf_is_list is TRUE.
#'   * `summate`: Logical summation flag from the regressor.
#'   * `hrf`: The original HRF object (single HRF or list of HRFs).
#'   * `hrf_is_list`: Logical indicating if hrf is a list of per-event HRFs.
#'   * `valid_hrfs`: If hrf_is_list, the subset of HRFs corresponding to valid events.
#'   When no event reaches the grid only `nb`, `grid`, `valid_ons` (empty) and
#'   `hrf_is_list` are returned.
#' @keywords internal
#' @noRd
prep_reg_inputs <- function(x, grid, precision) {

  if (is.unsorted(grid)) {
      warning("Input grid is unsorted. Sorting grid for evaluation.")
      grid <- sort(grid)
  }

  hrf_is_list <- isTRUE(attr(x, "hrf_is_list"))
  nb <- nbasis(x)
  hrf_span <- x$span

  # Keep events whose response can reach the grid. A block can begin before
  # the ordinary point-event bound and still overlap the requested grid
  # through its duration, so filter on the end of the neural input, not only
  # on its onset. (Zero amplitudes were already dropped by Reg().)
  event_ends <- x$onsets + pmax(x$duration, 0)
  keep <- which(event_ends >= grid[1] - hrf_span &
                x$onsets <= grid[length(grid)])

  if (length(keep) == 0) {
    # Minimal info needed to signal zero output
    return(list(nb = nb, grid = grid, valid_ons = numeric(0), hrf_is_list = hrf_is_list))
  }

  list(
    nb         = nb,
    hrf_span   = hrf_span,
    valid_ons  = x$onsets[keep],
    valid_durs = x$duration[keep],
    valid_amp  = x$amplitude[keep],
    grid       = grid,
    precision  = precision,
    # Per-event HRFs are evaluated event by event in eval_loop instead.
    hrf_fine_matrix = if (!hrf_is_list) .memo_hrf(x$hrf, hrf_span, precision),
    summate    = x$summate,
    hrf        = x$hrf,
    hrf_is_list = hrf_is_list,
    valid_hrfs = if (hrf_is_list) x$hrf[keep]
  )
}

# Internal Evaluation Engines -----

#' Direct Convolution Regressor Evaluation Engine
#' @param p A list returned by prep_reg_inputs (single HRF).
#' @keywords internal
#' @noRd
eval_conv <- function(p) {
  evaluate_regressor_cpp(
    grid = p$grid,
    onsets = p$valid_ons,
    durations = p$valid_durs,
    amplitudes = p$valid_amp,
    hrf_matrix = p$hrf_fine_matrix,
    hrf_span = p$hrf_span,
    precision = p$precision,
    summate = isTRUE(p$summate)
  )
}

#' R Loop Regressor Evaluation Engine
#' @param p A list returned by prep_reg_inputs.
#' @param ... Additional arguments passed to evaluate.HRF.
#' @keywords internal
#' @noRd
eval_loop <- function(p, ...) {
  grid <- p$grid
  hrf_span <- p$hrf_span
  valid_ons <- p$valid_ons
  valid_durs <- p$valid_durs

  # Match the finite kernel sampled by the convolution engine. Mask before
  # block integration, not after: a block near the end of the span contains
  # both supported and unsupported kernel lags.
  bounded <- function(kernel) {
    out <- function(t) {
      values <- kernel(t)
      outside <- t < 0 | t > hrf_span
      if (is.matrix(values)) values[outside, ] <- 0 else values[outside] <- 0
      values
    }
    attributes(out) <- attributes(kernel)
    out
  }
  shared_hrf <- if (!p$hrf_is_list) bounded(p$hrf)

  # Index of the grid point just before or at each onset
  start_idx <- pmax(findInterval(valid_ons, grid), 1L)

  outmat <- matrix(0, length(grid), p$nb)

  for (i in seq_along(valid_ons)) {
    # A blocked event responds out to hrf_span + duration, not hrf_span. Using
    # the bare span truncated the tail of every block, leaving a residual error
    # that did not shrink with `precision`.
    event_span <- hrf_span + max(valid_durs[i], 0)

    # Select the final grid point inside the event's support directly. Unlike
    # estimating an index count from median(diff(grid)), this also works for a
    # one-point grid and for irregular or duplicated sampling grids.
    end_idx <- findInterval(valid_ons[i] + event_span, grid)
    if (end_idx < start_idx[i]) next
    idx <- seq.int(start_idx[i], end_idx)

    rel <- grid[idx] - valid_ons[i]
    in_support <- rel >= 0 & rel <= event_span
    if (!any(in_support)) next
    idx <- idx[in_support]

    kernel <- if (p$hrf_is_list) bounded(p$valid_hrfs[[i]]) else shared_hrf
    resp <- evaluate(kernel, rel[in_support], amplitude = p$valid_amp[i],
                     duration = valid_durs[i], precision = p$precision,
                     summate = p$summate, ...)

    outmat[idx, ] <- outmat[idx, , drop = FALSE] + matrix(resp, ncol = p$nb)
  }

  outmat
}
