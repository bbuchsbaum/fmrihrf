# Evaluate method for Reg objects
#' 
#' This is the primary method for evaluating regressor objects created by the `Reg` constructor
#' (and thus also works for objects created by `regressor`).
#' It dispatches to different internal methods based on the `method` argument.
#' 
#' @rdname evaluate
#' @param x A `Reg` object (or an object inheriting from it, like `regressor`).
#' @param grid Numeric vector specifying the time points (seconds) for evaluation.
#' @param precision Numeric sampling precision for internal HRF evaluation and convolution (seconds).
#' @param method The evaluation method:
#'   \describe{
#'     \item{conv}{(Default, recommended) C++ direct convolution. Fastest in
#'       every configuration benchmarked -- typically 3-10x faster than `fft`
#'       and 10-100x faster than `loop` -- and accurate to ~1e-3 relative
#'       against numerical integration of the same design.}
#'     \item{loop}{Pure R, evaluating the HRF at exact per-event relative times.
#'       Roughly twice as accurate as `conv` because event onsets are never
#'       quantised to the internal grid, but far slower. Retained as a
#'       reference implementation, and used automatically when `hrf` is a list
#'       of per-event HRFs.}
#'     \item{fft}{Deprecated. The HRF is short relative to the sampled design,
#'       so an FFT never repaid its zero-padding; it was also the only method
#'       that could fail outright, on an internal FFT size above ~1e7. Now
#'       evaluates via `conv` and warns.}
#'     \item{Rconv}{Deprecated. An R reimplementation of `conv` that required a
#'       regular grid and constant durations and silently fell back to `loop`
#'       otherwise. Now evaluates via `conv` and warns.}
#'   }
#' @param sparse Logical indicating whether to return a sparse matrix (from the Matrix package). Default is FALSE.
#' @param normalize Logical; if TRUE, scale evaluated regressor output to unit peak
#'   (maximum absolute value of 1). For multi-basis regressors, each basis column
#'   is normalized independently.
#' @param ... Additional arguments passed down (e.g., to `evaluate.HRF` in the loop method).
#' @examples
#' # Create a regressor
#' reg <- regressor(onsets = c(10, 30, 50), hrf = HRF_SPMG1)
#' 
#' # Evaluate with default method (conv)
#' times <- seq(0, 80, by = 0.5)
#' response <- evaluate(reg, times)
#' 
#' # Try different evaluation methods
#' response_loop <- evaluate(reg, times, method = "loop")
#' 
#' # With higher precision
#' response_precise <- evaluate(reg, times, precision = 0.1)
#' @export
#' @method evaluate Reg
#' @importFrom Matrix Matrix
#' @importFrom Rcpp evalCpp
evaluate.Reg <- function(x, grid, precision=.33, method=c("conv", "loop", "fft", "Rconv"),
                         sparse = FALSE, normalize = FALSE, ...) {

  method <- match.arg(method)

  # `fft` and `Rconv` were never faster than `conv` and carried failure modes of
  # their own, so they now route to it rather than being maintained in parallel.
  if (method %in% c("fft", "Rconv")) {
    warning("Method '", method, "' is deprecated and now evaluates via 'conv', ",
            "which is faster and at least as accurate. Drop the `method` ",
            "argument to silence this warning.", call. = FALSE)
    method <- "conv"
  }

  # Validate inputs
  if (!is.numeric(grid) || length(grid) == 0 || anyNA(grid)) {
    stop("`grid` must be a non-empty numeric vector with no NA values.",
         call. = FALSE)
  }
  if (!is.numeric(precision) || length(precision) != 1 || is.na(precision) ||
      precision <= 0) {
    stop("`precision` must be a positive numeric value.", call. = FALSE)
  }
  if (!is.logical(normalize) || length(normalize) != 1 || is.na(normalize)) {
    stop("`normalize` must be a single logical value.", call. = FALSE)
  }

  p <- prep_reg_inputs(x, grid, precision)

  result <- if (length(p$valid_ons) == 0) {
    # No event reaches the grid
    matrix(0, nrow = length(grid), ncol = p$nb)
  } else if (method == "loop" || p$hrf_is_list) {
    # Pure R reference; also the only engine for per-event HRF lists.
    # Pass ... through to evaluate.HRF.
    eval_loop(p, ...)
  } else {
    eval_conv(p)
  }

  if (p$nb == 1) result <- as.vector(result)
  if (normalize) result <- .normalise_result(result)

  if (sparse) Matrix::Matrix(result, sparse = TRUE) else result
}


#' @method shift Reg
#' @rdname shift
#' @export
shift.Reg <- function(x, shift_amount, ...) {
  shift_amount <- resolve_shift_amount(shift_amount, list(...))

  # Returning the original empty object is appropriate for a shift
  if (length(x$onsets) == 0) {
    return(x)
  }

  # Reconstruct the object using the core Reg constructor, which validates the
  # shifted onsets. Zero amplitudes were already dropped (or deliberately
  # kept) when `x` was built.
  Reg(onsets = x$onsets + shift_amount,
      hrf = x$hrf,
      duration = x$duration,
      amplitude = x$amplitude,
      span = x$span,
      summate = x$summate,
      drop_zero_amplitude = FALSE)
}

# `shift_amount` for the shift() methods, which also accept it as `offset`.
#' @importFrom assertthat assert_that
#' @keywords internal
#' @noRd
resolve_shift_amount <- function(shift_amount, dots) {
  if (missing(shift_amount) && "offset" %in% names(dots)) {
    shift_amount <- dots$offset
  }
  if (missing(shift_amount)) {
    stop("Must supply `shift_amount` or `offset`.", call. = FALSE)
  }
  assert_that(is.numeric(shift_amount) && length(shift_amount) == 1,
              msg = "`shift_amount` must be a single numeric value")
  shift_amount
}

#' Print method for Reg objects
#'
#' Provides a concise summary of the regressor object using the cli package.
#'
#' @param x A `Reg` object.
#' @param ... Not used.
#' @return No return value, called for side effects (prints to console)
#' @importFrom cli cli_h1 cli_text cli_div cli_li
#' @examples
#' r <- regressor(onsets = c(1, 10, 20), hrf = HRF_SPMG1,
#'                duration = 0, amplitude = 1,
#'                span = 40)
#' print(r)
#' @export
#' @method print Reg
#' @rdname print
print.Reg <- function(x, ...) {

  n_ons <- length(x$onsets)
  nb <- nbasis(x)
  hrf_name <- if (!isTRUE(attr(x, "hrf_is_list"))) {
    attr(x$hrf, "name") %||% "custom function"
  } else if (length(x$hrf) > 0) {
    paste0("trial-varying (", length(x$hrf), " HRFs)")
  } else {
    "trial-varying (empty)"
  }
  hrf_span <- x$span

  cli::cli_h1("fMRI Regressor Object")

  # Use cli_div for potentially better alignment than cli_ul
  cli::cli_div(theme = list(ul = list("margin-left" = 2), li = list("margin-bottom" = 0.5)))
  cli::cli_li("Type: {.cls {class(x)[1]}}")
  if (n_ons == 0) {
    cli::cli_li("Events: 0 (Empty Regressor)")
  } else {
    cli::cli_li("Events: {n_ons}")
    cli::cli_li("Onset Range: {round(min(x$onsets), 2)}s to {round(max(x$onsets), 2)}s")
    if (any(x$duration != 0)) {
      cli::cli_li("Duration Range: {round(min(x$duration), 2)}s to {round(max(x$duration), 2)}s")
    }
    if (!all(x$amplitude == 1)) {
      cli::cli_li("Amplitude Range: {round(min(x$amplitude), 2)} to {round(max(x$amplitude), 2)}")
    }
  }
  cli::cli_li("HRF: {hrf_name} ({nb} basis function{?s})")
  cli::cli_li("HRF Span: {hrf_span}s")
  cli::cli_li("Summation: {x$summate}")
  cli::cli_end()

  invisible(x)
}

# S3 Methods for Reg class -----

#' @export
#' @rdname nbasis
#' @method nbasis Reg
nbasis.Reg <- function(x, ...) {
  # Handle list HRFs (trial-varying case)
  if (isTRUE(attr(x, "hrf_is_list"))) {
    if (length(x$hrf) > 0) {
      return(nbasis(x$hrf[[1]]))
    } else {
      return(1L)
    }
  }
  nbasis(x$hrf)
}

#' @export
#' @rdname onsets
#' @method onsets Reg
onsets.Reg <- function(x, ...) x$onsets

#' @export
#' @rdname durations
#' @method durations Reg
durations.Reg <- function(x, ...) x$duration

#' @export
#' @rdname amplitudes
#' @method amplitudes Reg
amplitudes.Reg <- function(x, ...) x$amplitude
