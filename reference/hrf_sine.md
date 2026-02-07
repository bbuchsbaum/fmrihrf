# hrf_sine

A hemodynamic response function using the Sine Basis Set.

## Usage

``` r
hrf_sine(t, span = 24, N = 5)
```

## Arguments

- t:

  A vector of times.

- span:

  The temporal window over which the basis sets span (default: 24).

- N:

  The number of basis functions (default: 5).

## Value

A matrix of sine basis functions.

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
[`hrf_spmg1()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_spmg1.md),
[`hrf_time()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_time.md),
[`hrf_weighted()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_weighted.md)

## Examples

``` r
hrf_sine_basis <- hrf_sine(seq(0, 20, by = 0.5), N = 4)
```
