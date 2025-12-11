# HRF (hemodynamic response function) as a linear function of time

The \`hrf_time\` function computes the value of an HRF, which is a
simple linear function of time \`t\`, when \`t\` is greater than 0 and
less than \`maxt\`.

## Usage

``` r
hrf_time(t, maxt = 22)
```

## Arguments

- t:

  A numeric value representing time in seconds.

- maxt:

  A numeric value representing the maximum time point in the domain.
  Default value is 22.

## Value

A numeric value representing the value of the HRF at the given time
\`t\`.

## See also

Other hrf_functions:
[`hrf_basis_lwu()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_basis_lwu.md),
[`hrf_bspline()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_bspline.md),
[`hrf_gamma()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_gamma.md),
[`hrf_gaussian()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_gaussian.md),
[`hrf_inv_logit()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_inv_logit.md),
[`hrf_lwu()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_lwu.md),
[`hrf_mexhat()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_mexhat.md),
[`hrf_sine()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_sine.md),
[`hrf_spmg1()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_spmg1.md)

## Examples

``` r
# Compute the HRF value for t = 5 seconds with the default maximum time
hrf_val <- hrf_time(5)

# Compute the HRF value for t = 5 seconds with a custom maximum time of 30 seconds
hrf_val_custom_maxt <- hrf_time(5, maxt = 30)
```
