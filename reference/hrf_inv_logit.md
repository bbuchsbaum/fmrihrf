# hrf_inv_logit

A hemodynamic response function using the difference of two Inverse
Logit functions.

## Usage

``` r
hrf_inv_logit(t, mu1 = 6, s1 = 1, mu2 = 16, s2 = 1, lag = 0)
```

## Arguments

- t:

  A vector of times.

- mu1:

  The time-to-peak for the rising phase (mean of the first logistic
  function).

- s1:

  The width (slope) of the first logistic function.

- mu2:

  The time-to-peak for the falling phase (mean of the second logistic
  function).

- s2:

  The width (slope) of the second logistic function.

- lag:

  The time delay (default: 0).

## Value

A vector of the difference of two Inverse Logit HRF values.

## See also

Other hrf_functions:
[`hrf_basis_lwu()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_basis_lwu.md),
[`hrf_bspline()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_bspline.md),
[`hrf_gamma()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_gamma.md),
[`hrf_gaussian()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_gaussian.md),
[`hrf_lwu()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_lwu.md),
[`hrf_mexhat()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_mexhat.md),
[`hrf_sine()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_sine.md),
[`hrf_spmg1()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_spmg1.md),
[`hrf_time()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_time.md)

## Examples

``` r
hrf_inv_logit_basis <- hrf_inv_logit(seq(0, 20, by = 0.5), mu1 = 6, s1 = 1, mu2 = 16, s2 = 1)
```
