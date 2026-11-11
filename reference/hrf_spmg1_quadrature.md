# Quadrature partner of the SPM canonical HRF

The Hilbert transform of the SPM canonical HRF (\[hrf_spmg1()\]) on
\`\[0, span\]\`, made orthogonal to the canonical HRF and scaled to the
same L2 norm. Together the two functions form a quadrature pair: a small
shift of the response in time acts, to a good approximation, as a
rotation of the two coefficients, so their length carries amplitude and
their angle carries latency. The temporal derivative in \[HRF_SPMG2\]
plays the same role but only for shifts of about a second.

## Usage

``` r
hrf_spmg1_quadrature(t, P1 = 5, P2 = 15, A1 = 1/120, span = 32)
```

## Arguments

- t:

  A vector of time points.

- P1:

  The first exponent parameter (default: 5).

- P2:

  The second exponent parameter (default: 15). The undershoot is
  `t^P2 * exp(-t) / (6 * factorial(P2))`, one sixth of a gamma density
  with shape `P2 + 1` and unit rate.

- A1:

  Amplitude scaling factor for the positive gamma function component;
  normally fixed at 1/120

- span:

  Length in seconds of the window on which the function is defined
  (default 32). It is zero outside \`\[0, span\]\`.

## Value

A numeric vector the same length as \`t\`.

## Details

The function is tabulated once per parameter set on a 0.01 s grid (the
Hilbert transform is computed with a zero-padded FFT) and interpolated
linearly. Unlike the canonical HRF, the Hilbert transform of a causal
function is not causal, so the quadrature partner does not start at
zero: restricted to \`\[0, span\]\` it begins at about -0.37 of the
canonical peak. Treat it as a companion regressor for estimating
latency, not as a response shape.

## References

Saad, Z. S., Ropella, K. M., Cox, R. W., & DeYoe, E. A. (2001). Analysis
and use of FMRI response delays. \*Human Brain Mapping\*, 13(2), 74-93.
[doi:10.1002/hbm.1026](https://doi.org/10.1002/hbm.1026)

## See also

\[HRF_SPMGQ\], \[amplitude_latency()\]

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
[`hrf_time()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_time.md),
[`hrf_weighted()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_weighted.md)

## Examples

``` r
t <- seq(0, 32, by = 0.1)
h <- hrf_spmg1(t)
q <- hrf_spmg1_quadrature(t)
matplot(t, cbind(h, q), type = "l", lty = 1, ylab = "response")

sum(h * q)              # orthogonal
#> [1] -2.729261e-07
sum(h^2) / sum(q^2)     # equal norm
#> [1] 0.9984316
```
