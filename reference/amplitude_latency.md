# Amplitude and latency from the coefficients of a multi-basis HRF

Summarises the fitted coefficients of a multi-basis HRF (canonical plus
temporal derivative, \[HRF_SPMG2\], or the quadrature pair
\[HRF_SPMGQ\]) as a response amplitude and a latency. The coefficients
of a unit-amplitude response delayed by \`s\` seconds trace a known
curve (\[hrf_shift_curve()\]); each coefficient vector is matched to the
point of the curve it is most nearly proportional to. That point's shift
is the latency, and the proportionality constant is the amplitude.

With \`method = "boost"\` the amplitude is instead the derivative-boost
estimate of Calhoun et al. (2004), \`sign(b1) \* sqrt(b' G b / G\[1,
1\])\`, which needs no curve but is biased low for shifts beyond about a
second.

## Usage

``` r
amplitude_latency(
  beta,
  hrf,
  shifts = seq(-4, 4, by = 0.05),
  method = c("curve", "boost"),
  metric = NULL,
  reference = NULL,
  min_fit = 0,
  dt = 0.05
)
```

## Arguments

- beta:

  Numeric vector of length \`nbasis(hrf)\`, or a matrix with one row per
  response (voxel, condition, ...) and \`nbasis(hrf)\` columns, in the
  order of the basis functions.

- hrf:

  The multi-basis \`HRF\` object the coefficients were fitted with.

- shifts:

  Candidate latencies in seconds. Estimates are limited to this range;
  estimates at either end mean the response lies outside it.

- method:

  \`"curve"\` (default) or \`"boost"\`.

- metric:

  Optional positive-definite \`nbasis\` x \`nbasis\` matrix that defines
  proportionality: the inverse covariance of the coefficients, up to
  scale. Defaults to the Gram matrix of the basis, which is appropriate
  for well-separated events and white noise.

- reference:

  An \`HRF\` object or function of time giving the response shape whose
  shifts are fitted. Defaults to the first basis function of \`hrf\`.

- min_fit:

  Responses whose coefficients match the curve with a cosine below this
  value get \`NA\` latency and amplitude (default 0, i.e. only responses
  pointing away from every candidate are dropped).

- dt:

  Time step in seconds of the grid used for the projection.

## Value

A data frame with one row per response and columns \`amplitude\`,
\`latency\` (seconds, positive = later than the reference; \`NA\` for
\`method = "boost"\`) and \`fit\` (cosine between the coefficients and
the matched curve point; 1 is a perfect match).

## Details

Amplitude is signed: a negative response at the reference latency has a
negative amplitude rather than a half-cycle shift. Latency is poorly
determined when the amplitude is close to zero; mask such responses (for
example by a test on the amplitude) before interpreting it.

## References

Calhoun, V. D., Stevens, M. C., Pearlson, G. D., & Kiehl, K. A. (2004).
fMRI analysis with the general linear model: removal of latency-induced
amplitude bias by incorporation of hemodynamic derivative terms.
\*NeuroImage\*, 22(1), 252-257.
[doi:10.1016/j.neuroimage.2003.12.029](https://doi.org/10.1016/j.neuroimage.2003.12.029)

Henson, R. N. A., Price, C. J., Rugg, M. D., Turner, R., & Friston, K.
J. (2002). Detecting latency differences in event-related BOLD
responses: application to words versus nonwords and initial versus
repeated face presentations. \*NeuroImage\*, 15(1), 83-97.
[doi:10.1006/nimg.2001.0940](https://doi.org/10.1006/nimg.2001.0940)

Liao, C. H., Worsley, K. J., Poline, J.-B., Aston, J. A. D., Duncan, G.
H., & Evans, A. C. (2002). Estimating the delay of the fMRI response.
\*NeuroImage\*, 16(3), 593-606.
[doi:10.1006/nimg.2002.1096](https://doi.org/10.1006/nimg.2002.1096)

Saad, Z. S., Ropella, K. M., Cox, R. W., & DeYoe, E. A. (2001). Analysis
and use of FMRI response delays. \*Human Brain Mapping\*, 13(2), 74-93.
[doi:10.1002/hbm.1026](https://doi.org/10.1002/hbm.1026)

## See also

\[hrf_shift_curve()\], \[HRF_SPMGQ\]

## Examples

``` r
# Coefficients of a canonical response of amplitude 2, delayed by 1.5 s
t <- seq(0, 40, by = 0.05)
y <- 2 * hrf_spmg1(t - 1.5)
beta <- qr.solve(HRF_SPMG2(t), y)
beta                                   # the canonical coefficient is not 2
#> [1]  1.757090 -2.583261
amplitude_latency(beta, HRF_SPMG2)
#>   amplitude latency fit
#> 1  2.000003     1.5   1
amplitude_latency(beta, HRF_SPMG2, method = "boost")
#>   amplitude latency fit
#> 1  1.965606      NA  NA
```
