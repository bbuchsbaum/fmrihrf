# Put this in R/utils-internal.R
recycle_or_error <- function(x, n, name) {
  if (length(x) == n) {
    return(x)
  }
  if (length(x) == 1) {
    return(rep(x, n))
  }
  stop(paste0("`", name, "` must have length 1 or ", n, ", not ", length(x)), call. = FALSE)
}

# Helper for default values (used in reg-constructor.R)
`%||%` <- function(a, b) {
  if (is.null(a)) b else a
} 