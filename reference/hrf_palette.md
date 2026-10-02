# Colour palettes for HRF and regressor plots

`hrf_palette()` returns the colours used by every plotting function in
fmrihrf, so figures made with
[`plot_hrfs()`](https://bbuchsbaum.github.io/fmrihrf/reference/plot_hrfs.md),
[`plot_regressors()`](https://bbuchsbaum.github.io/fmrihrf/reference/plot_regressors.md),
and the [`plot()`](https://rdrr.io/r/graphics/plot.default.html) methods
share one visual language.

## Usage

``` r
hrf_palette(n = NULL, type = c("categorical", "ordered"))
```

## Arguments

- n:

  Number of colours. If `NULL`, returns the six categorical colours (or
  five ramp anchors for `type = "ordered"`).

- type:

  Either `"categorical"` or `"ordered"`.

## Value

A character vector of hex colours.

## Details

Two palette types are provided:

- `"categorical"`: up to six distinct hues for unordered series
  (conditions, HRF families). Every colour has at least 3:1 contrast
  against both white and near-black backgrounds, and the first four stay
  distinguishable under simulated deuteranopia, protanopia, and
  tritanopia. When more than six colours are requested the ordered
  palette is used instead.

- `"ordered"`: a hue ramp (violet, blue, teal, green, ochre) for series
  with a natural order, such as the functions of a basis set, lags, or
  event durations. Lightness is held in the same mid range, so the ramp
  is readable on light and dark backgrounds. Brick red, the first
  categorical colour, is left out of the ramp so that it keeps one
  meaning.

## See also

[`scale_colour_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/scale_colour_hrf.md)
for the matching ggplot2 scales.

## Examples

``` r
hrf_palette()
#> [1] "#BD4B3F" "#1A95AE" "#7A51C8" "#B08214" "#2B8667" "#9C6687"
hrf_palette(3)
#> [1] "#BD4B3F" "#1A95AE" "#7A51C8"
hrf_palette(8, type = "ordered")
#> [1] "#7951C7" "#5D63CC" "#3D74CB" "#2D8AB7" "#259099" "#2B8871" "#758549"
#> [8] "#B08113"
```
