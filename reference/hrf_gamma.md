# Gamma HRF (hemodynamic response function)

The \`hrf_gamma\` function computes the gamma density-based HRF
(hemodynamic response function) at given time points \`t\`.

## Usage

``` r
hrf_gamma(t, shape = 6, rate = 1)
```

## Arguments

- t:

  A vector of time points.

- shape:

  A numeric value representing the shape parameter for the gamma
  probability density function. Default value is 6.

- rate:

  A numeric value representing the rate parameter for the gamma
  probability density function. Default value is 1.

## Value

A numeric vector representing the gamma HRF at the given time points
\`t\`.

## See also

Other hrf_functions:
[`hrf_basis_lwu()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_basis_lwu.md),
[`hrf_boxcar()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_boxcar.md),
[`hrf_bspline()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_bspline.md),
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
# Compute the gamma HRF representation for time points from 0 to 20 with 0.5 increments
hrf_gamma_vals <- hrf_gamma(seq(0, 20, by = .5), shape = 6, rate = 1)
```
