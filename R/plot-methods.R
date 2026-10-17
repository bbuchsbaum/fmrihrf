#' Plot an HRF Object
#'
#' Draws an HRF with base graphics. Single-basis HRFs show the response curve
#' with its peak annotated. Multi-basis HRFs (e.g., [HRF_SPMG3]) show every
#' basis function, coloured along the ordered [hrf_palette()].
#'
#' @md
#' @param x An HRF object
#' @param time Numeric vector of time points. If NULL (default), uses
#'   seq(0, span, by = 0.1) where span is the HRF's span attribute.
#' @param normalize Logical; if TRUE, normalize responses to peak at 1.
#'   Default is FALSE.
#' @param show_peak Logical; if TRUE (default for single-basis HRFs), annotate
#'   the peak time on the plot.
#' @param ... Additional arguments passed to [graphics::plot()], such as
#'   `main` or `ylim`.
#' @return Invisibly returns a data frame with the time and response values
#'   (useful for further customization).
#' @seealso [plot_hrfs()] for ggplot2 comparisons of several HRFs.
#' @examples
#' # Plot single-basis HRF
#' plot(HRF_SPMG1)
#'
#' # Plot multi-basis HRF
#' plot(HRF_SPMG3)
#'
#' # Plot with normalization
#' plot(HRF_GAMMA, normalize = TRUE)
#'
#' # Custom time range
#' plot(HRF_SPMG1, time = seq(0, 30, by = 0.5))
#' @method plot HRF
#' @export
plot.HRF <- function(x, time = NULL, normalize = FALSE, show_peak = TRUE, ...) {
  span <- attr(x, "span") %||% 24
  if (is.null(time)) {
    time <- seq(0, span, by = 0.1)
  }

  y <- evaluate(x, time, normalize = normalize)
  hrf_name <- attr(x, "name") %||% "HRF"
  args <- list(...)
  main <- args$main %||% hrf_name
  args$main <- NULL
  ylab <- if (normalize) "Response / peak" else "Response"

  if (is.matrix(y)) {
    nb <- ncol(y)
    cols <- .basis_palette(nb)
    do.call(.base_series_panel, c(list(time = time, Y = y, colours = cols,
                                       labels = paste0("B", seq_len(nb)),
                                       main = main, ylab = ylab), args))
  } else {
    if (show_peak && length(y) > 0 && is.null(args$ylim)) {
      limits <- range(y, 0, finite = TRUE)
      limits[2] <- limits[2] + max(diff(limits), abs(limits[2]), 1e-6) * 0.18
      args$ylim <- limits
    }
    do.call(.base_series_panel, c(list(time = time, Y = y,
                                       colours = hrf_palette(1),
                                       main = main, ylab = ylab), args))
    if (show_peak && length(y) > 0) {
      peak_idx <- which.max(y)
      graphics::points(time[peak_idx], y[peak_idx], pch = 19, cex = 0.9,
                       col = hrf_palette(1))
      graphics::text(time[peak_idx], y[peak_idx],
                     sprintf("Peak: %.1f s", time[peak_idx]),
                     pos = 3, offset = 0.5, cex = 0.85, col = .hrf_neutral)
    }
  }

  invisible(.wide_frame(time, y))
}

#' Compare Multiple HRF Functions
#'
#' Plots one or more HRF objects on shared axes. Multi-basis HRFs are
#' expanded into one curve per basis function, so `plot_hrfs(HRF_SPMG3)`
#' shows the canonical response and both derivatives. Uses ggplot2 when
#' available, otherwise base graphics. Colours come from [hrf_palette()].
#'
#' Inside a knitr document the result is returned visibly and printed by
#' knitr, which lets document themes (for example dark-mode figure twins)
#' handle the ggplot. At the console the plot is drawn immediately and the
#' data are returned invisibly.
#'
#' @md
#' @param ... HRF objects to compare. Can be passed as individual arguments
#'   or as a named list.
#' @param time Numeric vector of time points. If NULL (default), uses
#'   seq(0, max_span, by = 0.1) where max_span is the maximum span across
#'   all HRFs.
#' @param normalize Logical; if TRUE, normalize all HRFs to peak at 1.
#'   Useful for comparing shapes regardless of amplitude. Default is FALSE.
#' @param labels Character vector of labels, either one per HRF or one per
#'   plotted curve (after basis expansion). If NULL (default), uses the 'name'
#'   attribute of each HRF; basis functions of a single basis set are labelled
#'   `B1`, `B2`, and so on.
#' @param title Character string for the plot title. If NULL (default), uses
#'   the HRF name for a single HRF and "HRF comparison" otherwise.
#' @param subtitle Character string for the plot subtitle. If NULL (default),
#'   no subtitle is shown.
#' @param use_ggplot Logical; if TRUE and ggplot2 is available, use ggplot2
#'   for plotting. If FALSE, use base R graphics. Default is TRUE.
#' @param draw Logical; draw the plot (default TRUE). With `use_ggplot = TRUE`,
#'   set FALSE to customize the returned data frame's `"plot"` attribute.
#' @param basis Either `"all"` (default) to plot every basis function of a
#'   multi-basis HRF, or `"first"` to plot only its first column.
#' @param layout Either `"overlay"` (default) to draw all curves in one panel
#'   or `"stack"` to give each curve its own panel on a shared time axis.
#' @param scales For `layout = "stack"`: `"free_y"` (default) or `"fixed"`
#'   (one shared y range).
#' @param palette Colour palette: `"auto"` (default) uses the ordered palette
#'   for a single basis set with more than three functions and the
#'   categorical palette otherwise; `"categorical"` or `"ordered"` force one
#'   (see [hrf_palette()]). Use `"ordered"` when the HRFs differ along one
#'   parameter (lag, width).
#' @param reference Optional HRF drawn as a dashed grey reference curve (for
#'   example the canonical HRF), outside the colour legend. It is evaluated on
#'   the same time grid and normalized like the other HRFs.
#' @param reference_label Text naming the reference curve, shown as a caption.
#'   Defaults to the reference HRF's name.
#' @return A data frame in long format with columns 'time', 'HRF', and
#'   'response'. With ggplot2, the plot is stored in the `"plot"` attribute.
#'   The value is invisible except when drawing inside knitr, where it prints
#'   like a ggplot object: it is drawn when it is the visible value of a chunk
#'   (not when assigned), and subsetting or modifying it, or calling
#'   `as.data.frame()`, returns a plain data frame. Call `as.data.frame()`
#'   before combining results with `rbind()` or dplyr verbs.
#' @examples
#' # Compare canonical HRFs
#' plot_hrfs(HRF_SPMG1, HRF_GAMMA, HRF_GAUSSIAN)
#'
#' # A basis set: one curve per basis function
#' plot_hrfs(HRF_SPMG3,
#'           labels = c("Canonical", "Temporal derivative", "Dispersion derivative"))
#'
#' # HRFs ordered by a parameter use the ordered palette
#' plot_hrfs(block_hrf(HRF_SPMG1, width = 1), block_hrf(HRF_SPMG1, width = 3),
#'           block_hrf(HRF_SPMG1, width = 5),
#'           labels = c("1 s", "3 s", "5 s"), palette = "ordered",
#'           title = "Effect of event duration")
#'
#' # Normalize for shape comparison
#' plot_hrfs(HRF_SPMG1, HRF_GAMMA, HRF_GAUSSIAN, normalize = TRUE,
#'           subtitle = "All HRFs normalized to peak at 1")
#'
#' # Use base R graphics instead of ggplot2
#' plot_hrfs(HRF_SPMG1, HRF_GAMMA, use_ggplot = FALSE)
#' @export
plot_hrfs <- function(..., time = NULL, normalize = FALSE, labels = NULL,
                      title = NULL, subtitle = NULL, use_ggplot = TRUE,
                      draw = TRUE, basis = c("all", "first"),
                      layout = c("overlay", "stack"),
                      palette = c("auto", "categorical", "ordered"),
                      reference = NULL, reference_label = NULL,
                      scales = c("free_y", "fixed")) {
  scales <- match.arg(scales)
  basis <- match.arg(basis)
  layout <- match.arg(layout)
  palette <- match.arg(palette)
  if (!is.null(reference) && !inherits(reference, "HRF")) {
    stop("'reference' must be an HRF object")
  }
  hrfs <- .plot_inputs(list(...), "HRF", "an HRF")
  n_hrfs <- length(hrfs)

  if (is.null(time)) {
    spans <- vapply(hrfs, function(h) as.numeric(attr(h, "span") %||% 24), numeric(1))
    time <- seq(0, max(spans), by = 0.1)
  }

  curves <- .eval_curves(hrfs, basis, time, normalize = normalize)
  resp <- curves$resp
  nb <- curves$nb
  n_series <- sum(nb)
  single_set <- n_hrfs == 1 && nb[1] > 1

  hrf_names <- vapply(hrfs, function(h) as.character(attr(h, "name") %||% "HRF")[1],
                      character(1))
  default_labels <- if (any(duplicated(hrf_names))) {
    paste0(hrf_names, "_", seq_along(hrf_names))
  } else {
    hrf_names
  }
  series_labels <- .series_labels(nb, labels, default_labels, "HRFs")
  df <- .long_frame(time, resp, series_labels, "HRF")

  if (is.null(title)) {
    title <- if (n_hrfs == 1) hrf_names[1] else "HRF comparison"
  }
  pal <- .series_palette(n_series, palette, ordered_hint = single_set && nb[1] > 3)
  ylab <- if (normalize) "Response / peak" else "Response"
  ref_df <- NULL
  if (!is.null(reference)) {
    ref_y <- as.matrix(evaluate(reference, time, normalize = normalize))[, 1]
    ref_df <- data.frame(time = time, response = ref_y)
    reference_label <- reference_label %||% as.character(attr(reference, "name") %||% "reference")
  }

  if (use_ggplot && requireNamespace("ggplot2", quietly = TRUE)) {
    direct <- single_set && is.null(labels) && layout == "overlay"
    p <- .gg_series(df, pal, title = title, subtitle = subtitle,
                    ylab = ylab, layout = layout, direct_labels = direct,
                    reference = ref_df, scales = scales)
    if (!is.null(ref_df)) {
      p <- p + ggplot2::labs(caption = paste("Dashed grey:", reference_label)) +
        ggplot2::theme(plot.caption = ggplot2::element_text(hjust = 0),
                       plot.caption.position = "plot")
    }
    return(.finish_gg(df, p, draw))
  }
  if (draw) {
    .base_series_panel(time, resp, pal$colours, labels = series_labels,
                       main = title, ylab = ylab)
    if (!is.null(ref_df)) {
      graphics::lines(ref_df$time, ref_df$response, col = .hrf_neutral, lty = 2)
    }
  }
  invisible(df)
}

#' Plot a Regressor Object
#'
#' Draws the predicted BOLD time course of a regressor with base graphics.
#' Event onsets are marked with ticks along the time axis. Regressors built
#' from a basis set are drawn one basis function per panel by default.
#'
#' @md
#' @param x A `Reg` object created by `regressor()`.
#' @param grid Numeric vector of time points for evaluation. If NULL (default),
#'   uses a grid from 0 to max(onsets) + span with step 0.25 s.
#' @param show_onsets Logical; if TRUE (default), mark event onsets with ticks
#'   on the time axis.
#' @param onset_color Colour for onset ticks. If NULL (default), a neutral grey.
#' @param onset_alpha Alpha transparency for onset ticks. Default is 0.5.
#' @param precision Numeric sampling precision for HRF evaluation. If NULL
#'   (default), the grid spacing capped at 0.33 s, so sharp HRF edges are
#'   drawn where they occur.
#' @param layout For multi-basis regressors, `"stack"` (default) draws one
#'   panel per basis function; `"overlay"` draws them in a single panel.
#' @param ... Additional arguments passed to [graphics::plot()].
#' @return Invisibly returns a data frame with the time and response values.
#' @seealso [plot_regressors()] for ggplot2 comparisons of several regressors.
#' @examples
#' # Create and plot a simple regressor
#' reg <- regressor(onsets = c(10, 30, 50), hrf = HRF_SPMG1)
#' plot(reg)
#'
#' # Plot with custom time grid
#' plot(reg, grid = seq(0, 80, by = 1))
#'
#' # Plot without onset markers
#' plot(reg, show_onsets = FALSE)
#'
#' # A basis-set regressor: one panel per basis function
#' plot(regressor(c(10, 40), HRF_SPMG3))
#' @method plot Reg
#' @export
plot.Reg <- function(x, grid = NULL, show_onsets = TRUE,
                     onset_color = NULL, onset_alpha = 0.5,
                     precision = NULL, layout = c("stack", "overlay"), ...) {
  layout <- match.arg(layout)
  hrf_is_list <- isTRUE(attr(x, "hrf_is_list"))
  hrf_name <- if (hrf_is_list) {
    "trial-varying HRF"
  } else {
    attr(x$hrf, "name") %||% "custom HRF"
  }
  n_events <- length(x$onsets)
  title <- sprintf("%s regressor, %d event%s", hrf_name, n_events,
                   if (n_events == 1) "" else "s")
  .plot_reg_base(x, grid, precision, title, show_onsets, onset_color,
                 onset_alpha, layout, ...)
}

# Shared base-graphics body for plot.Reg() and plot.FeatureReg(): evaluate `x`
# (by default on .reg_plot_grid()) and draw it. A `main` passed through the
# methods' `...` replaces the default title.
.plot_reg_base <- function(x, grid, precision, title, show_onsets,
                           onset_color, onset_alpha, layout, main = NULL, ...) {
  title <- main %||% title
  if (is.null(grid)) {
    grid <- .reg_plot_grid(list(x))
  }
  response <- evaluate(x, grid, precision = .plot_precision(precision, grid))
  onset_col <- grDevices::adjustcolor(onset_color %||% .hrf_neutral,
                                      alpha.f = onset_alpha)
  marks <- if (show_onsets) x$onsets else NULL

  if (is.matrix(response)) {
    nb <- ncol(response)
    cols <- .basis_palette(nb)
    if (layout == "stack" && nb > 1) {
      op <- graphics::par(mfrow = c(nb, 1), mar = c(1.6, 4.1, 1.4, 1.1),
                          oma = c(2.6, 0, 1.8, 0))
      on.exit(graphics::par(op), add = TRUE)
      for (j in seq_len(nb)) {
        .base_series_panel(grid, response[, j], cols[j], main = NULL,
                           xlab = "", ylab = paste0("B", j), onsets = marks,
                           onset_col = onset_col, legend = FALSE,
                           xaxt = if (j < nb) "n" else "s", ...)
      }
      graphics::mtext("Time (s)", side = 1, outer = TRUE, line = 1.2,
                      cex = graphics::par("cex.lab") %||% 1)
      graphics::mtext(title, side = 3, outer = TRUE, line = 0.4, adj = 0,
                      font = 2)
    } else {
      .base_series_panel(grid, response, cols, labels = paste0("B", seq_len(nb)),
                         main = title, onsets = marks, onset_col = onset_col, ...)
    }
  } else {
    .base_series_panel(grid, response, hrf_palette(1), main = title,
                       onsets = marks, onset_col = onset_col, ...)
  }
  invisible(.wide_frame(grid, response))
}

# Data returned by the base plot() methods: time plus `response`, or one
# `basis_<k>` column per basis function.
.wide_frame <- function(time, y) {
  if (!is.matrix(y)) {
    return(data.frame(time = time, response = y))
  }
  df <- data.frame(time = time, y)
  colnames(df)[-1] <- paste0("basis_", seq_len(ncol(y)))
  df
}

#' Compare Multiple Regressor Objects
#'
#' Plots one or more regressors on a shared time axis. Regressors built from a
#' basis set are expanded into one curve per basis function, and a
#' `regressor_set()` is expanded into one curve per condition. Event onsets
#' (and durations) are drawn as bars under the curves; zero-duration events get
#' a minimum bar width of 0.4% of the time range so that they stay visible. Uses ggplot2 when
#' available, otherwise base graphics. Colours come from [hrf_palette()].
#'
#' Inside a knitr document the result is returned visibly and printed by
#' knitr, which lets document themes (for example dark-mode figure twins)
#' handle the ggplot. At the console the plot is drawn immediately and the
#' data are returned invisibly.
#'
#' @md
#' @param ... Regressor objects (`Reg`) or a `RegSet` to compare. Can be
#'   passed as individual arguments or as a named list.
#' @param grid Numeric vector of time points for evaluation. If NULL (default),
#'   a 0.25 s grid covering all regressors is used. Use a fine grid for the
#'   curve and `samples` to show scan times.
#' @param labels Character vector of labels, one per regressor or one per
#'   plotted curve. If NULL (default), uses list names, condition levels, or
#'   "Regressor_1", "Regressor_2", etc.
#' @param title Character string for the plot title. If NULL (default),
#'   uses "Regressor comparison".
#' @param subtitle Character string for the plot subtitle. If NULL, no subtitle.
#' @param show_onsets Logical or character. If TRUE, mark events for every
#'   regressor in its own colour. If "first", mark only the first regressor's
#'   events, in grey. If FALSE, hide event marks. If NULL (default), uses
#'   "first" for `layout = "overlay"` and TRUE for `layout = "stack"`, so each
#'   panel shows its own events.
#' @param onset_alpha Alpha transparency for event marks. Default is 0.8.
#' @param precision Numeric sampling precision for HRF evaluation. If NULL
#'   (default), the grid spacing capped at 0.33 s.
#' @param use_ggplot Logical; if TRUE and ggplot2 is available, use ggplot2
#'   for plotting. If FALSE, use base R graphics. Default is TRUE.
#' @param draw Logical; draw the plot (default TRUE). With `use_ggplot = TRUE`,
#'   set FALSE to customize the returned data frame's `"plot"` attribute.
#' @param basis Either `"all"` (default) to plot every basis column of a
#'   multi-basis regressor, or `"first"` for the first column only.
#' @param layout Either `"overlay"` (default) or `"stack"` (one panel per
#'   curve on a shared time axis). Stacked panels mark their own events in
#'   grey.
#' @param scales For `layout = "stack"`: `"free_y"` (default) gives each panel
#'   its own y range; `"fixed"` shares one range so amplitudes can be compared.
#' @param samples Optional numeric vector of sample times (for example scan
#'   acquisition times). The regressors are evaluated there and drawn as
#'   points on the curves.
#' @param palette Colour palette: `"auto"` (default), `"categorical"`, or
#'   `"ordered"`; see [plot_hrfs()].
#' @return A data frame in long format with columns 'time', 'Regressor', and
#'   'response'. With ggplot2, the plot is stored in the `"plot"` attribute.
#'   The value is invisible except when drawing inside knitr, where it prints
#'   like a ggplot object (see [plot_hrfs()]).
#' @examples
#' # Create regressors with different HRFs
#' onsets <- c(10, 30, 50)
#' reg1 <- regressor(onsets, HRF_SPMG1)
#' reg2 <- regressor(onsets, HRF_GAMMA)
#' reg3 <- regressor(onsets, HRF_GAUSSIAN)
#'
#' # Compare regressors
#' plot_regressors(reg1, reg2, reg3,
#'                 labels = c("SPM Canonical", "Gamma", "Gaussian"))
#'
#' # Show the scan-time samples of a regressor (TR = 2 s)
#' plot_regressors(reg1, samples = seq(0, 80, by = 2), labels = "SPMG1")
#'
#' # One panel per basis function of a basis-set regressor
#' plot_regressors(regressor(c(10, 40), HRF_SPMG3), layout = "stack")
#'
#' # Compare original vs shifted regressor
#' reg_shifted <- shift(reg1, 5)
#' plot_regressors(reg1, reg_shifted, labels = c("Original", "Shifted +5s"),
#'                 show_onsets = TRUE)
#' @export
plot_regressors <- function(..., grid = NULL, labels = NULL,
                            title = NULL, subtitle = NULL,
                            show_onsets = NULL, onset_alpha = 0.8,
                            precision = NULL, use_ggplot = TRUE, draw = TRUE,
                            basis = c("all", "first"),
                            layout = c("overlay", "stack"), samples = NULL,
                            palette = c("auto", "categorical", "ordered"),
                            scales = c("free_y", "fixed")) {
  scales <- match.arg(scales)
  basis <- match.arg(basis)
  layout <- match.arg(layout)
  palette <- match.arg(palette)
  regs <- list(...)
  if (length(regs) == 1 && inherits(regs[[1]], "RegSet")) {
    regs <- stats::setNames(regs[[1]]$regs, regs[[1]]$levels)
  }
  regs <- .plot_inputs(regs, "Reg", "a Reg")
  n_regs <- length(regs)

  if (is.null(grid)) {
    grid <- .reg_plot_grid(regs)
  }

  if (is.null(show_onsets)) {
    show_onsets <- if (layout == "stack") TRUE else "first"
  }
  precision <- .plot_precision(precision, grid)
  curves <- .eval_curves(regs, basis, grid, precision = precision)
  resp <- curves$resp
  nb <- curves$nb
  n_series <- sum(nb)
  single_set <- n_regs == 1 && nb[1] > 1

  default_labels <- names(regs)
  if (is.null(default_labels) || any(!nzchar(default_labels))) {
    default_labels <- paste0("Regressor_", seq_len(n_regs))
  }
  series_labels <- .series_labels(nb, labels, default_labels, "regressors")
  owner <- rep(seq_len(n_regs), nb)
  df <- .long_frame(grid, resp, series_labels, "Regressor")

  # Event marks, one row per event and curve: every curve gets its own
  # regressor's events, or with "first" only the first regressor's curve(s).
  onset_data <- NULL
  if (!isFALSE(show_onsets)) {
    first_only <- identical(show_onsets, "first")
    marked <- if (first_only) which(owner == 1) else seq_len(n_series)
    rows <- lapply(marked, function(s) {
      r <- regs[[owner[s]]]
      if (length(r$onsets) == 0) return(NULL)
      dur <- r$duration %||% 0
      data.frame(onset = r$onsets, duration = rep_len(dur, length(r$onsets)),
                 series = series_labels[s])
    })
    onset_data <- do.call(rbind, rows)
    if (!is.null(onset_data)) {
      # Only mark events that fall inside the plotted window.
      onset_data <- onset_data[onset_data$onset >= min(grid) &
                                 onset_data$onset <= max(grid), , drop = FALSE]
      attr(onset_data, "by_series") <- !first_only
      attr(onset_data, "alpha") <- onset_alpha
    }
  }

  sample_data <- NULL
  if (!is.null(samples)) {
    smat <- .eval_curves(regs, basis, samples, precision = precision)$resp
    sample_data <- .long_frame(samples, smat, series_labels)
  }

  if (is.null(title)) {
    title <- if (n_series == 1) series_labels[1] else "Regressor comparison"
  }
  pal <- .series_palette(n_series, palette, ordered_hint = single_set && nb[1] > 3)

  if (use_ggplot && requireNamespace("ggplot2", quietly = TRUE)) {
    p <- .gg_series(df, pal, title = title, subtitle = subtitle,
                    layout = layout, onsets = onset_data, samples = sample_data,
                    scales = scales)
    return(.finish_gg(df, p, draw))
  }
  if (draw) {
    .base_series_panel(grid, resp, pal$colours, labels = series_labels,
                       main = title, onsets = unique(onset_data$onset),
                       onset_col = grDevices::adjustcolor(.hrf_neutral, alpha.f = onset_alpha))
    if (!is.null(sample_data)) {
      graphics::points(sample_data$time, sample_data$response, pch = 19, cex = 0.6,
                       col = pal$colours[as.integer(sample_data$series)])
    }
  }
  invisible(df)
}

#' Plot a Feature Regressor
#'
#' @md
#' @param x A `FeatureReg` object created by [feature_regressor()].
#' @param grid Numeric vector of time points for evaluation. If `NULL`
#'   (default), a grid from 0 to max(times) + span with step 0.25 s is used.
#' @param show_onsets Logical; if `TRUE`, mark sample times with ticks on the
#'   time axis. Defaults to `FALSE` because a dense feature has one sample per
#'   bin.
#' @param onset_color Colour for sample-time ticks. If NULL (default), a
#'   neutral grey.
#' @param onset_alpha Alpha transparency for sample-time ticks. Default is 0.5.
#' @param precision Numeric sampling precision for HRF evaluation. If NULL
#'   (default), the grid spacing capped at 0.33 s.
#' @param layout For multi-basis HRFs, `"stack"` (default) or `"overlay"`.
#' @param ... Additional arguments passed to the underlying plot functions.
#' @return Invisibly returns a data frame with the time and response values.
#' @examples
#' feat <- feature_regressor(abs(sin(seq(0, 8, by = 0.1))), dt = 0.1)
#' plot(feat, grid = seq(0, 12, by = 0.5))
#' @method plot FeatureReg
#' @export
plot.FeatureReg <- function(x, grid = NULL, show_onsets = FALSE,
                            onset_color = NULL, onset_alpha = 0.5,
                            precision = NULL, layout = c("stack", "overlay"), ...) {
  layout <- match.arg(layout)
  hrf_name <- attr(x$hrf, "name") %||% "custom HRF"
  title <- sprintf("Feature regressor (%s), %d samples", hrf_name, length(x$onsets))
  .plot_reg_base(x, grid, precision, title, show_onsets, onset_color,
                 onset_alpha, layout, ...)
}

# Collect the objects given to plot_hrfs() / plot_regressors(), either as
# separate arguments or as one list, and check that each inherits from `cls`.
.plot_inputs <- function(objs, cls, noun) {
  if (length(objs) == 1 && is.list(objs[[1]]) && !inherits(objs[[1]], cls)) {
    objs <- objs[[1]]
  }
  if (length(objs) == 0) {
    stop("At least one ", cls, " object must be provided", call. = FALSE)
  }
  bad <- which(!vapply(objs, inherits, logical(1), what = cls))
  if (length(bad) > 0) {
    stop("All arguments must be ", cls, " objects. Argument ", bad[1],
         " is not ", noun, ".", call. = FALSE)
  }
  objs
}

# Evaluate HRFs or regressors (`...` goes to evaluate()) and bind their curves
# column-wise: all basis columns, or only the first with basis = "first".
# `nb` is the number of curves contributed by each object.
.eval_curves <- function(objs, basis, ...) {
  mats <- lapply(objs, function(obj) {
    y <- as.matrix(evaluate(obj, ...))
    if (basis == "first") y[, 1, drop = FALSE] else y
  })
  list(resp = do.call(cbind, mats), nb = vapply(mats, ncol, integer(1)))
}

# One label per curve. `labels` may name every curve or every object;
# otherwise `defaults` name the objects. The basis columns of an object are
# labelled "<object> B<k>", or just "B<k>" when a single basis set is shown.
.series_labels <- function(nb, labels, defaults, what) {
  if (!is.null(labels) && length(labels) == sum(nb)) {
    out <- as.character(labels)
  } else {
    if (!is.null(labels) && length(labels) != length(nb)) {
      stop("Length of 'labels' must match number of ", what, call. = FALSE)
    }
    base <- labels %||% defaults
    single_set <- length(nb) == 1 && nb[1] > 1
    out <- unlist(lapply(seq_along(nb), function(i) {
      if (nb[i] == 1) return(base[i])
      if (single_set) paste0("B", seq_len(nb[i])) else paste0(base[i], " B", seq_len(nb[i]))
    }))
  }
  if (any(duplicated(out))) {
    out <- make.unique(out, sep = " ")
  }
  out
}

# Long-form curve data: columns time, <name> (factor of curve labels), response.
.long_frame <- function(time, resp, labels, name = "series") {
  df <- data.frame(
    time = rep(time, length(labels)),
    series = factor(rep(labels, each = length(time)), levels = labels),
    response = as.vector(resp)
  )
  names(df)[2] <- name
  df
}

# Default plotting grid for regressors: 0.25 s steps from 0 to the last onset
# plus span (just the span for a regressor without events).
.reg_plot_grid <- function(regs) {
  ends <- vapply(regs, function(r) {
    if (length(r$onsets) == 0) return(as.numeric(r$span))
    max(r$onsets, na.rm = TRUE) + r$span
  }, numeric(1))
  seq(0, max(ends), by = 0.25)
}

# Evaluation precision for plotting: the grid spacing, capped at 0.33 s (the
# evaluate() default) and floored at 0.01 s.
.plot_precision <- function(precision, grid) {
  if (!is.null(precision)) return(precision)
  # signif() removes floating-point residue from seq() spacing (0.0499999...)
  step <- if (length(grid) > 1) signif(min(diff(sort(unique(grid)))), 8) else 0.33
  min(0.33, max(0.01, step))
}

# Colours for the columns of one basis set: categorical for up to three
# functions (e.g. canonical + derivatives), ordered beyond that.
.basis_palette <- function(nb) {
  hrf_palette(nb, if (nb > 3) "ordered" else "categorical")
}
