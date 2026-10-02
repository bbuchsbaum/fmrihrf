# Plot an HRF Object

Draws an HRF with base graphics. Single-basis HRFs show the response
curve with its peak annotated. Multi-basis HRFs (e.g.,
[HRF_SPMG3](https://bbuchsbaum.github.io/fmrihrf/reference/HRF_objects.md))
show every basis function, coloured along the ordered
[`hrf_palette()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_palette.md).

## Usage

``` r
# S3 method for class 'HRF'
plot(x, time = NULL, normalize = FALSE, show_peak = TRUE, ...)
```

## Arguments

- x:

  An HRF object

- time:

  Numeric vector of time points. If NULL (default), uses seq(0, span, by
  = 0.1) where span is the HRF's span attribute.

- normalize:

  Logical; if TRUE, normalize responses to peak at 1. Default is FALSE.

- show_peak:

  Logical; if TRUE (default for single-basis HRFs), annotate the peak
  time on the plot.

- ...:

  Additional arguments passed to
  [`graphics::plot()`](https://rdrr.io/r/graphics/plot.default.html),
  such as `main` or `ylim`.

## Value

Invisibly returns a data frame with the time and response values (useful
for further customization).

## See also

[`plot_hrfs()`](https://bbuchsbaum.github.io/fmrihrf/reference/plot_hrfs.md)
for ggplot2 comparisons of several HRFs.

## Examples

``` r
# Plot single-basis HRF
plot(HRF_SPMG1)


# Plot multi-basis HRF
plot(HRF_SPMG3)


# Plot with normalization
plot(HRF_GAMMA, normalize = TRUE)


# Custom time range
plot(HRF_SPMG1, time = seq(0, 30, by = 0.5))
```
