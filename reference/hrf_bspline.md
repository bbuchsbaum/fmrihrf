# B-spline HRF (hemodynamic response function)

The \`hrf_bspline\` function computes the B-spline representation of an
HRF (hemodynamic response function) at given time points \`t\`.

## Usage

``` r
hrf_bspline(t, span = 24, N = 5, degree = 3, ...)
```

## Arguments

- t:

  A vector of time points.

- span:

  A numeric value representing the temporal window over which the basis
  set spans. Default value is 20.

- N:

  An integer representing the number of basis functions. Default value
  is 5.

- degree:

  An integer representing the degree of the spline. Default value is 3.

- ...:

  Additional arguments passed to \`splines::bs\`.

## Value

A matrix representing the B-spline basis for the HRF at the given time
points \`t\`.

## See also

Other hrf_functions:
[`hrf_basis_lwu()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_basis_lwu.md),
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
# Compute the B-spline HRF representation for time points from 0 to 20 with 0.5 increments
hrfb <- hrf_bspline(seq(0, 20, by = .5), N = 4, degree = 2)
```
