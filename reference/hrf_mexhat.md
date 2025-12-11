# Mexican Hat HRF (hemodynamic response function)

The \`hrf_mexhat\` function computes the Mexican hat wavelet-based HRF
(hemodynamic response function) at given time points \`t\`.

## Usage

``` r
hrf_mexhat(t, mean = 6, sd = 2)
```

## Arguments

- t:

  A vector of time points.

- mean:

  A numeric value representing the mean of the Mexican hat wavelet.
  Default value is 6.

- sd:

  A numeric value representing the standard deviation of the Mexican hat
  wavelet. Default value is 2.

## Value

A numeric vector representing the Mexican hat wavelet-based HRF at the
given time points \`t\`.

## See also

Other hrf_functions:
[`hrf_basis_lwu()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_basis_lwu.md),
[`hrf_bspline()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_bspline.md),
[`hrf_gamma()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_gamma.md),
[`hrf_gaussian()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_gaussian.md),
[`hrf_inv_logit()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_inv_logit.md),
[`hrf_lwu()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_lwu.md),
[`hrf_sine()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_sine.md),
[`hrf_spmg1()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_spmg1.md),
[`hrf_time()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_time.md)

## Examples

``` r
# Compute the Mexican hat HRF representation for time points from 0 to 20 with 0.5 increments
hrf_mexhat_vals <- hrf_mexhat(seq(0, 20, by = .5), mean = 6, sd = 2)
```
