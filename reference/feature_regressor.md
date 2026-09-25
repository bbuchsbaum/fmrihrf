# Construct a Feature Regressor from a Sampled Time Series

Creates a regressor from a continuously sampled feature (for example RMS
energy of an acoustic stimulus) by treating each sample as a
zero-order-hold bin of width \\\Delta t\\. The result is the Riemann-sum
/ ZOH approximation of convolving the feature with an HRF, not a train
of unit-mass impulses.

## Usage

``` r
feature_regressor(
  values,
  hrf = HRF_SPMG1,
  times = NULL,
  dt = NULL,
  start = 0,
  center = TRUE,
  scale = c("none", "sd"),
  mask = NULL,
  span = NULL
)
```

## Arguments

- values:

  Numeric vector of feature samples. Matrix and array inputs are
  rejected; construct one feature regressor per column instead.

- hrf:

  The hemodynamic response function to convolve with the feature. Same
  types as
  [`regressor()`](https://bbuchsbaum.github.io/fmrihrf/reference/regressor.md),
  except a list of per-event HRFs is not allowed. Defaults to
  `HRF_SPMG1`.

- times:

  Numeric vector of sample times in seconds, same length as `values`.
  Mutually exclusive with `dt`. Times must be strictly increasing and
  non-negative. The last bin width is the last inter-sample gap.

- dt:

  Positive sampling interval in seconds. Mutually exclusive with
  `times`. Sample times are
  `start + seq(0, by = dt, length.out = length(values))`.

- start:

  Start time in seconds used only when `dt` is supplied. Defaults to 0.

- center:

  Logical; if `TRUE` (default), subtract the mean of the (masked)
  samples before convolution. For an all-sample series this removes
  \\\mu H\mathbf{1}\\, including the HRF-length run-boundary ramp.

- scale:

  Character; `"none"` (default) leaves native units, `"sd"` divides by
  the standard deviation of the (masked) samples after centering. This
  z-scores the feature, not the convolved design column.

- mask:

  Optional logical vector the same length as `values`. Center and scale
  statistics are computed on `mask == TRUE` samples only; off-mask
  samples are set to 0. This is not equivalent to global all-sample
  centering.

- span:

  Temporal window in seconds for the HRF, passed to
  [`regressor()`](https://bbuchsbaum.github.io/fmrihrf/reference/regressor.md).
  If `NULL`, the HRF's own span is used.

## Value

An S3 object of class `c("FeatureReg", "Reg", "list")`. Evaluation uses
the same convolution path as
[`regressor()`](https://bbuchsbaum.github.io/fmrihrf/reference/regressor.md).

## Details

Amplitude modulation on this sampling grid is the same linear model as
convolving the sampled series: if \\x\\ is the (possibly centered)
feature and \\H\\ is the convolution operator, the regressor is \\Hx\\.
Zeros are kept, so an all-TR / all-sample series stays an all-sample
series. No unmodulated companion regressor is added.

Centering and scaling are applied to the feature **before** convolution.
For a whole-run series (`mask = NULL`), \$\$H(x-\mu\mathbf{1}) = Hx -
\mu H\mathbf{1}.\$\$ Away from the run edges, \\H\mathbf{1}\\ is nearly
constant (overlapping HRFs sum to a plateau), so with a GLM intercept
the centered and raw columns are affinely equivalent. They differ by the
HRF-length ramp of \\H\mathbf{1}\\ at the start and end of the run.
Default `center = TRUE` removes that boundary term; `center = FALSE`
keeps it. `scale = "sd"` only changes the feature's units (still
pre-convolution). It is not standardization of the final BOLD-space
column after filtering.

Use `mask` when the feature should be centered only during an on-period
(stimulus present, task on, and so on). Center and scale then use only
the on-samples, and off-mask samples stay 0:
\$\$H\[m(x-\mu\_{\mathrm{on}})\] = H(mx) - \mu\_{\mathrm{on}} Hm.\$\$
That is **not** an affine transform of the all-sample series. Pair it
with a separate boxcar for the on-period if you want presence and
intensity as two questions.

Each sample is a zero-order-hold bin of width \\\Delta t\\, not a
unit-mass impulse. Evaluate with `precision` less than or equal to the
feature sampling interval. Compared with
`regressor(times, amplitude = values, duration = 0)`, the predicted BOLD
is smaller by about \\\Delta t\\.

## See also

[`regressor()`](https://bbuchsbaum.github.io/fmrihrf/reference/regressor.md),
[`evaluate()`](https://bbuchsbaum.github.io/fmrihrf/reference/evaluate.md)

## Examples

``` r
# 10 Hz envelope over 8 seconds, demeaned
dt <- 0.1
t <- seq(0, 8, by = dt)
rms <- abs(sin(2 * pi * t / 4))
feat <- feature_regressor(rms, dt = dt, hrf = HRF_SPMG1)

grid <- seq(0, 12, by = 1)
y <- evaluate(feat, grid, precision = dt)

# Same ZOH encoding as a duration-dt event regressor (no centering)
feat_raw <- feature_regressor(rms, dt = dt, center = FALSE, scale = "none")
ev <- regressor(t, HRF_SPMG1, duration = dt, amplitude = rms)
all.equal(evaluate(feat_raw, grid, precision = dt),
          evaluate(ev, grid, precision = dt))
#> [1] TRUE
```
