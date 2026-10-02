# ggplot2 colour scales matching fmrihrf plots

Discrete colour and fill scales built on
[`hrf_palette()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_palette.md).
Use them in your own ggplot2 figures to match the output of
[`plot_hrfs()`](https://bbuchsbaum.github.io/fmrihrf/reference/plot_hrfs.md)
and
[`plot_regressors()`](https://bbuchsbaum.github.io/fmrihrf/reference/plot_regressors.md).

## Usage

``` r
scale_colour_hrf(
  type = c("categorical", "ordered"),
  ...,
  aesthetics = "colour"
)

scale_color_hrf(type = c("categorical", "ordered"), ..., aesthetics = "colour")

scale_fill_hrf(type = c("categorical", "ordered"), ..., aesthetics = "fill")
```

## Arguments

- type:

  Either `"categorical"` or `"ordered"`; see
  [`hrf_palette()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_palette.md).

- ...:

  Further arguments passed to
  [`ggplot2::discrete_scale()`](https://ggplot2.tidyverse.org/reference/discrete_scale.html),
  such as `name`, `labels`, or `guide`.

- aesthetics:

  The aesthetics the scale applies to.

## Value

A ggplot2 scale object.

## Examples

``` r
if (requireNamespace("ggplot2", quietly = TRUE)) {
  t <- seq(0, 24, by = 0.2)
  df <- data.frame(
    time = rep(t, 3),
    response = c(HRF_SPMG1(t), HRF_GAMMA(t), HRF_GAUSSIAN(t)),
    hrf = rep(c("SPMG1", "Gamma", "Gaussian"), each = length(t))
  )
  ggplot2::ggplot(df, ggplot2::aes(time, response, colour = hrf)) +
    ggplot2::geom_line() +
    scale_colour_hrf()
}
```
