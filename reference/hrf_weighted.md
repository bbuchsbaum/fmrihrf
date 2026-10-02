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
  `[0, width)` is divided into `length(weights)` equal bins (constant
  method), or the weights are placed at evenly spaced points from 0 to
  `width` (linear method).

- times:

  Numeric vector of time points (in seconds, relative to t=0) where
  weights are specified. Must be strictly increasing and start at 0 for
  consistency with other HRFs. If provided, `width` is ignored.

- method:

  Interpolation method between time points:

  "constant"

  :   Step function (default): each weight applies to one time bin. With
      `times`, weight `i` covers `[times[i], times[i + 1])` and the last
      weight covers a bin as wide as the one before it. Every weight is
      used.

  "linear"

  :   Linear interpolation between points. Good for smooth weight
      transitions.

- normalize:

  Logical; if `TRUE`, weights are scaled so all of them sum to 1 (for
  `method = "constant"`) or the curve integrates to 1 (for
  `method = "linear"`). This fixes the scale of the weight profile; see
  Details for what the regression coefficient estimates. Default is
  `FALSE`.

## Value

An HRF object that can be used with
[`regressor()`](https://bbuchsbaum.github.io/fmrihrf/reference/regressor.md)
and other fmrihrf functions.

## Details

This is useful for summarising the signal in chosen post-stimulus
windows with a chosen temporal profile. In a least-squares GLM, an
isolated event's coefficient is the amplitude of the weight profile
\\w(t)\\ that best matches the data, \\\sum_t w(t) y(t) / \sum_t
w(t)^2\\. This equals the mean signal in the window only when all
non-zero weights are 1 (a boxcar); in general it is not a weighted mean.
Normalizing rescales the coefficient but does not change this.

There are two ways to specify the temporal structure:

1.  `width + weights`: the window `[0, width)` is divided into
    `length(weights)` equal bins (constant method) or the weights are
    placed at evenly spaced points from 0 to `width` (linear method)

2.  `times + weights`: explicit time points for each weight (relative to
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
# Simple: 6 s window split into 4 bins of 1.5 s (starting at 0, 1.5, 3, 4.5 s)
hrf1 <- hrf_weighted(width = 6, weights = c(0.2, 0.5, 0.8, 0.3))
t <- seq(-1, 10, by = 0.1)
plot(t, evaluate(hrf1, t), type = "s", main = "Weighted HRF (width + weights)")


# Explicit times for precise control
hrf2 <- hrf_weighted(
  times = c(0, 1, 3, 5, 6),
  weights = c(0.1, 0.5, 0.8, 0.5, 0.1),
  method = "linear"
)
plot(t, evaluate(hrf2, t), type = "l", main = "Smooth Weighted HRF")


# Normalized weights: all four bin weights sum to 1
hrf3 <- hrf_weighted(
  width = 8,
  weights = c(1, 2, 2, 1),
  normalize = TRUE
)

# Trial-varying weighted HRFs
hrf_early <- hrf_weighted(width = 6, weights = c(1, 1, 0, 0), normalize = TRUE)
hrf_late <- hrf_weighted(width = 6, weights = c(0, 0, 1, 1), normalize = TRUE)
reg <- regressor(onsets = c(0, 20), hrf = list(hrf_early, hrf_late))

# For delayed windows, use lag_hrf
hrf_delayed <- lag_hrf(hrf_weighted(width = 5, weights = c(1, 2, 1)), lag = 10)
```
