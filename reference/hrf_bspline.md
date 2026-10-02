# B-spline HRF (hemodynamic response function)

The \`hrf_bspline\` function computes a B-spline basis for an HRF at
time points \`t\`. The \`N\` basis functions are the interior functions
of a clamped B-spline basis on `[0, span]` with evenly spaced knots: the
functions anchored at the two boundaries are dropped, so every basis
function (and therefore every fitted HRF) is zero at onset and at the
end of the span. Outside `[0, span]` the basis is zero.

## Usage

``` r
hrf_bspline(t, span = 24, N = 5, degree = 3, ...)
```

## Arguments

- t:

  A vector of time points.

- span:

  A numeric value representing the temporal window over which the basis
  set spans. Default value is 24.

- N:

  An integer representing the number of basis functions. Must be at
  least `degree - 1`. Default value is 5.

- degree:

  An integer representing the degree of the spline. Default value is 3.

- ...:

  Further arguments passed to [`bs`](https://rdrr.io/r/splines/bs.html)
  (`intercept`, `df` and `knots` are set internally and ignored if
  supplied).

## Value

A matrix representing the B-spline basis for the HRF at the given time
points \`t\`.

## See also

Other hrf_functions:
[`hrf_basis_lwu()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_basis_lwu.md),
[`hrf_boxcar()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_boxcar.md),
[`hrf_gamma()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_gamma.md),
[`hrf_gaussian()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_gaussian.md),
[`hrf_inv_logit()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_inv_logit.md),
[`hrf_lwu()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_lwu.md),
[`hrf_mexhat()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_mexhat.md),
[`hrf_sine()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_sine.md),
[`hrf_spmg1()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_spmg1.md),
[`hrf_time()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_time.md),
[`hrf_weighted()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_weighted.md)

## Examples

``` r
# Compute the B-spline HRF representation for time points from 0 to 20 with 0.5 increments
hrfb <- hrf_bspline(seq(0, 20, by = .5), N = 4, degree = 2)
```
