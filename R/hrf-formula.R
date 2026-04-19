
#' Create an HRF from a basis specification
#'
#' `make_hrf()` is the unified entry point for constructing an `HRF` object.
#' It accepts a built-in HRF name, a plain function, or an existing `HRF`
#' object, resolves it against the HRF registry when applicable, and applies
#' optional block, lag, and normalization decorators in one call.
#'
#' Positional compatibility is preserved with the previous (simpler)
#' `make_hrf(basis, lag, nbasis)` signature so downstream packages that
#' call it positionally continue to work.
#'
#' @param basis Character name of a built-in HRF (see
#'   [list_available_hrfs()]), a function `f(t)` that returns HRF values,
#'   or an existing object of class `HRF`.
#' @param lag Numeric scalar shift in seconds applied to the HRF (default 0).
#' @param nbasis Integer number of basis functions (used when `basis` is a
#'   name of a basis-set generator or a plain function). Default 1.
#' @param width Numeric block width in seconds. If `> 0`, applies
#'   [block_hrf()]. Default 0.
#' @param precision Sampling precision used by [block_hrf()]. Default 0.1.
#' @param half_life Exponential decay half-life in seconds used by
#'   [block_hrf()]. Default `Inf` (no decay).
#' @param summate Logical; if `TRUE` (default), block responses accumulate.
#'   If `FALSE`, the integrated response is rescaled by total block weight.
#' @param normalize Logical; if `TRUE`, applies [normalise_hrf()] after the
#'   other decorators. Default `FALSE`.
#' @param span Optional numeric span in seconds. For character `basis` this
#'   is forwarded to the generator (e.g. `make_hrf("fir", span = 30)`). For
#'   function or HRF basis it overrides the `span` attribute on the result.
#' @param ... Additional arguments. For character `basis`, forwarded to the
#'   generator (e.g. `scale` for `"daguerre"`). For function `basis`,
#'   captured by the wrapping closure and passed to the function at
#'   evaluation time.
#'
#' @return An object of class `HRF`.
#'
#' @examples
#' # Canonical SPM HRF delayed by 2 seconds
#' h <- make_hrf("spmg1", lag = 2)
#' h(0:5)
#'
#' # Custom FIR basis with 20 bins over 30 seconds
#' fir20 <- make_hrf("fir", nbasis = 20, span = 30)
#'
#' # Blocked Gaussian HRF, 5 s block
#' block_gauss <- make_hrf("gaussian", width = 5)
#'
#' @export
make_hrf <- function(basis,
                     lag = 0,
                     nbasis = 1,
                     width = 0, precision = 0.1, half_life = Inf,
                     summate = TRUE, normalize = FALSE,
                     span = NULL,
                     ...) {
  if (!is.numeric(lag) || length(lag) != 1 || !is.finite(lag)) {
    stop("`lag` must be a single finite numeric value.")
  }
  if (!is.numeric(nbasis) || length(nbasis) != 1 || !is.finite(nbasis) ||
      nbasis < 1 || nbasis %% 1 != 0) {
    stop("`nbasis` must be a single positive integer.")
  }
  nbasis <- as.integer(nbasis)
  if (!is.numeric(width) || length(width) != 1 || is.na(width) || width < 0) {
    stop("`width` must be a single non-negative numeric value.")
  }

  dots <- list(...)

  base_hrf <- if (is.character(basis)) {
    key <- match.arg(tolower(basis), names(HRF_REGISTRY))
    entry <- HRF_REGISTRY[[key]]
    resolved <- if (inherits(entry, "HRF")) {
      # Pre-defined HRF object; nbasis / span are already baked in.
      entry
    } else {
      gen_args <- c(list(nbasis = nbasis), dots)
      if (!is.null(span)) gen_args$span <- span
      valid <- gen_args[names(gen_args) %in% names(formals(entry))]
      do.call(entry, valid)
    }
    attr(resolved, "name") <- key
    resolved
  } else if (inherits(basis, "HRF")) {
    if (length(dots) > 0) {
      warning("Ignoring extra arguments (...) because 'basis' is already an HRF object.",
              call. = FALSE)
    }
    basis
  } else if (is.function(basis)) {
    basis_name <- deparse(substitute(basis))
    wrapped <- if (length(dots) > 0) {
      function(t) do.call(basis, c(list(t), dots))
    } else {
      basis
    }
    as_hrf(wrapped, name = basis_name, nbasis = nbasis)
  } else {
    stop(sprintf(
      "invalid basis '%s' of class %s: must be a character string, a function, or an HRF object",
      deparse(substitute(basis)), paste(class(basis), collapse = ", ")
    ))
  }

  if (width > 0) {
    base_hrf <- block_hrf(base_hrf, width = width, precision = precision,
                          half_life = half_life, summate = summate,
                          normalize = FALSE)
  }
  if (lag != 0) {
    base_hrf <- lag_hrf(base_hrf, lag = lag)
  }
  if (normalize) {
    base_hrf <- normalise_hrf(base_hrf)
  }

  if (!is.null(span) && !is.character(basis)) {
    attr(base_hrf, "span") <- span
  }

  base_hrf
}
