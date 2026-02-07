# hrf_spmg1

A hemodynamic response function based on the SPM canonical double gamma
parameterization.

## Usage

``` r
hrf_spmg1(t, P1 = 5, P2 = 15, A1 = 0.0833)
```

## Arguments

- t:

  A vector of time points.

- P1:

  The first exponent parameter (default: 5).

- P2:

  The second exponent parameter (default: 15).

- A1:

  Amplitude scaling factor for the positive gamma function component;
  normally fixed at .0833

## Value

A vector of HRF values at the given time points.

## Details

This function models the hemodynamic response using the canonical double
gamma parameterization in the SPM software. The HRF is defined by a
linear combination of two gamma functions with different exponents (P1
and P2) and amplitudes (A1 and A2). It is commonly used in fMRI data
analysis to estimate the BOLD (blood-oxygen-level-dependent) signal
changes associated with neural activity.

## See also

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
[`hrf_time()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_time.md),
[`hrf_weighted()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_weighted.md)

## Examples

``` r
# Generate a time vector
time_points <- seq(0, 30, by=0.1)
# Compute the HRF values using the SPM canonical double gamma parameterization
hrf_values <- hrf_spmg1(time_points)
# Plot the HRF values
plot(time_points, hrf_values, type='l', main='SPM Canonical Double Gamma HRF')
```
