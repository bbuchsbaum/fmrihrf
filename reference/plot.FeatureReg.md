# Plot a Feature Regressor

Plot a Feature Regressor

## Usage

``` r
# S3 method for class 'FeatureReg'
plot(
  x,
  grid = NULL,
  show_onsets = FALSE,
  onset_color = "red",
  onset_alpha = 0.5,
  precision = 0.33,
  ...
)
```

## Arguments

- x:

  A \`FeatureReg\` object created by \[feature_regressor()\].

- grid:

  Numeric vector of time points for evaluation. If \`NULL\` (default), a
  grid from 0 to max(times) + span with step 0.5s is used.

- show_onsets:

  Logical; if \`TRUE\`, show vertical lines at sample times. Defaults to
  \`FALSE\` because a dense feature has one sample per bin.

- onset_color:

  Color for sample-time lines. Default is \`"red"\`.

- onset_alpha:

  Alpha transparency for sample-time lines. Default is 0.5.

- precision:

  Numeric sampling precision for HRF evaluation. Default is 0.33.

- ...:

  Additional arguments passed to the underlying plot functions.

## Value

Invisibly returns a data frame with the time and response values.

## Examples

``` r
feat <- feature_regressor(abs(sin(seq(0, 8, by = 0.1))), dt = 0.1)
plot(feat, grid = seq(0, 12, by = 0.5))
```
