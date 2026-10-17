.onLoad <- function(libname, pkgname) {
  # Memoise the fine-grid HRF sampler here rather than at build time, so the
  # cache size option is read in the session that uses it.
  .memo_hrf <<- memoise::memoise(
    .memo_hrf,
    cache = cachem::cache_mem(
      max_size = getOption("fmrihrf.hrf_cache_max_size", 50 * 1024^2), # 50 MB
      evict = "lru"
    )
  )

  # knitr is suggested, not imported: register the knit_print method for
  # fmrihrf_plot whenever knitr is (or later becomes) loaded.
  register <- function(...) {
    registerS3method("knit_print", "fmrihrf_plot", knit_print.fmrihrf_plot,
                     envir = asNamespace("knitr"))
  }
  if (isNamespaceLoaded("knitr")) {
    register()
  } else {
    setHook(packageEvent("knitr", "onLoad"), register)
  }
  invisible()
}
