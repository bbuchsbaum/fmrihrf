# Gaussian HRF (hemodynamic response function)

The \`hrf_gaussian\` function computes the Gaussian density-based HRF
(hemodynamic response function) at given time points \`t\`.

## Usage

``` r
hrf_gaussian(t, mean = 6, sd = 2)
```

## Arguments

- t:

  A vector of time points.

- mean:

  A numeric value representing the mean of the Gaussian probability
  density function. Default value is 6.

- sd:

  A numeric value representing the standard deviation of the Gaussian
  probability density function. Default value is 2.

## Value

A numeric vector representing the Gaussian HRF at the given time points
\`t\`.

## See also

Other hrf_functions:
[`hrf_basis_lwu()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_basis_lwu.md),
[`hrf_bspline()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_bspline.md),
[`hrf_gamma()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_gamma.md),
[`hrf_inv_logit()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_inv_logit.md),
[`hrf_lwu()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_lwu.md),
[`hrf_mexhat()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_mexhat.md),
[`hrf_sine()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_sine.md),
[`hrf_spmg1()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_spmg1.md),
[`hrf_time()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_time.md)

## Examples

``` r
# Compute the Gaussian HRF representation for time points from 0 to 20 with 0.5 increments
hrf_gaussian_vals <- hrf_gaussian(seq(0, 20, by = .5), mean = 6, sd = 2)
```
