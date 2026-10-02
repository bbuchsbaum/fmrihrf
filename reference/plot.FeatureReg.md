# Plot a Feature Regressor

Plot a Feature Regressor

## Usage

``` r
# S3 method for class 'FeatureReg'
plot(
  x,
  grid = NULL,
  show_onsets = FALSE,
  onset_color = NULL,
  onset_alpha = 0.5,
  precision = NULL,
  layout = c("stack", "overlay"),
  ...
)
```

## Arguments

- x:

  A `FeatureReg` object created by
  [`feature_regressor()`](https://bbuchsbaum.github.io/fmrihrf/reference/feature_regressor.md).

- grid:

  Numeric vector of time points for evaluation. If `NULL` (default), a
  grid from 0 to max(times) + span with step 0.25 s is used.

- show_onsets:

  Logical; if `TRUE`, mark sample times with ticks on the time axis.
  Defaults to `FALSE` because a dense feature has one sample per bin.

- onset_color:

  Colour for sample-time ticks. If NULL (default), a neutral grey.

- onset_alpha:

  Alpha transparency for sample-time ticks. Default is 0.5.

- precision:

  Numeric sampling precision for HRF evaluation. If NULL (default), the
  grid spacing capped at 0.33 s.

- layout:

  For multi-basis HRFs, `"stack"` (default) or `"overlay"`.

- ...:

  Additional arguments passed to the underlying plot functions.

## Value

Invisibly returns a data frame with the time and response values.

## Examples

``` r
feat <- feature_regressor(abs(sin(seq(0, 8, by = 0.1))), dt = 0.1)
plot(feat, grid = seq(0, 12, by = 0.5))
```
