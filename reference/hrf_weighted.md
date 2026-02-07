# Weighted HRF (No Hemodynamic Delay)

Creates a flexible weighted HRF starting at t=0 with user-specified
weights. Unlike traditional HRFs, this has no built-in hemodynamic
delay - it directly maps weights to time points, allowing for arbitrary
temporal response shapes.

## Usage

``` r
hrf_weighted(
  weights,
  width = NULL,
  times = NULL,
  method = c("constant", "linear"),
  normalize = FALSE
)
```

## Arguments

- weights:

  Numeric vector of weights. Required.

- width:

  Total duration of the window in seconds. If provided without `times`,
  weights are evenly spaced from 0 to `width`.

- times:

  Numeric vector of time points (in seconds, relative to t=0) where
  weights are specified. Must be strictly increasing and start at 0 for
  consistency with other HRFs. If provided, `width` is ignored.

- method:

  Interpolation method between time points:

  "constant"

  :   Step function - weight is constant until the next time point
      (default). Good for discrete time bins.

  "linear"

  :   Linear interpolation between points. Good for smooth weight
      transitions.

- normalize:

  Logical; if `TRUE`, weights are scaled so they sum to 1 (for
  `method = "constant"`) or integrate to 1 (for `method = "linear"`).
  This makes the regression coefficient interpretable as a weighted
  mean. Default is `FALSE`.

## Value

An HRF object that can be used with
[`regressor()`](https://bbuchsbaum.github.io/fmrihrf/reference/regressor.md)
and other fmrihrf functions.

## Details

This is useful for extracting weighted averages of data at specific time
points. When `normalize = TRUE` and the HRF is used in a GLM, the
estimated coefficient represents a weighted mean of the data at the
specified times.

There are two ways to specify the temporal structure:

1.  `width + weights`: Weights are evenly spaced from 0 to `width`

2.  `times + weights`: Explicit time points for each weight (relative to
    t=0)

For delayed windows (not starting at t=0), use
[`lag_hrf`](https://bbuchsbaum.github.io/fmrihrf/reference/lag_hrf.md)
to shift the weighted HRF in time.

## Note on durations

The temporal structure (`width` or `times`) is fixed when the HRF is
created. The `duration` parameter in
[`regressor()`](https://bbuchsbaum.github.io/fmrihrf/reference/regressor.md)
does **not** modify the weighted HRF's structure—it controls how long
the neural input is sustained (which then gets convolved with this HRF).
For trial-varying weighted HRFs, use a list of HRFs:

    hrf_early <- hrf_weighted(width = 6, weights = c(1, 1, 0, 0), normalize = TRUE)
    hrf_late <- hrf_weighted(width = 6, weights = c(0, 0, 1, 1), normalize = TRUE)
    reg <- regressor(onsets = c(0, 20), hrf = list(hrf_early, hrf_late))

## See also

[`hrf_boxcar`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_boxcar.md)
for simple uniform boxcars,
[`lag_hrf`](https://bbuchsbaum.github.io/fmrihrf/reference/lag_hrf.md)
to shift the window in time,
[`empirical_hrf`](https://bbuchsbaum.github.io/fmrihrf/reference/empirical_hrf.md)
for HRFs from measured data

Other hrf_functions:
[`hrf_basis_lwu()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_basis_lwu.md),
[`hrf_boxcar()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_boxcar.md),
[`hrf_bspline()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_bspline.md),
[`hrf_gamma()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_gamma.md),
[`hrf_gaussian()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_gaussian.md),
[`hrf_inv_logit()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_inv_logit.md),
[`hrf_lwu()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_lwu.md),
[`hrf_mexhat()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_mexhat.md),
[`hrf_sine()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_sine.md),
[`hrf_spmg1()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_spmg1.md),
[`hrf_time()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_time.md)

## Examples

``` r
# Simple: 6s window with 4 evenly-spaced weights (at 0, 2, 4, 6s)
hrf1 <- hrf_weighted(width = 6, weights = c(0.2, 0.5, 0.8, 0.3))
#> Warning: Parameters times, weights, width, method, normalize are not arguments to function weighted[4 pts, constant] and will be ignored
t <- seq(-1, 10, by = 0.1)
plot(t, evaluate(hrf1, t), type = "s", main = "Weighted HRF (width + weights)")


# Explicit times for precise control
hrf2 <- hrf_weighted(
  times = c(0, 1, 3, 5, 6),
  weights = c(0.1, 0.5, 0.8, 0.5, 0.1),
  method = "linear"
)
#> Warning: Parameters times, weights, width, method, normalize are not arguments to function weighted[5 pts, linear] and will be ignored
plot(t, evaluate(hrf2, t), type = "l", main = "Smooth Weighted HRF")


# Normalized weights - coefficient estimates weighted mean of signal
hrf3 <- hrf_weighted(
  width = 8,
  weights = c(1, 2, 2, 1),
  normalize = TRUE
)
#> Warning: Parameters times, weights, width, method, normalize are not arguments to function weighted[4 pts, constant] and will be ignored

# Trial-varying weighted HRFs
hrf_early <- hrf_weighted(width = 6, weights = c(1, 1, 0, 0), normalize = TRUE)
#> Warning: Parameters times, weights, width, method, normalize are not arguments to function weighted[4 pts, constant] and will be ignored
hrf_late <- hrf_weighted(width = 6, weights = c(0, 0, 1, 1), normalize = TRUE)
#> Warning: Parameters times, weights, width, method, normalize are not arguments to function weighted[4 pts, constant] and will be ignored
reg <- regressor(onsets = c(0, 20), hrf = list(hrf_early, hrf_late))

# For delayed windows, use lag_hrf
hrf_delayed <- lag_hrf(hrf_weighted(width = 5, weights = c(1, 2, 1)), lag = 10)
#> Warning: Parameters times, weights, width, method, normalize are not arguments to function weighted[3 pts, constant] and will be ignored
```
