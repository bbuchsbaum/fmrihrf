# Construct an HRF Instance using Decorators

\`gen_hrf\` takes a base HRF function or object and applies optional
lag, blocking, and normalization decorators based on arguments.

## Usage

``` r
gen_hrf(
  hrf,
  lag = 0,
  width = 0,
  precision = 0.1,
  half_life = Inf,
  summate = TRUE,
  normalize = FALSE,
  name = NULL,
  span = NULL,
  ...
)
```

## Arguments

- hrf:

  A function \`f(t)\` or an existing \`HRF\` object.

- lag:

  Optional lag in seconds. If non-zero, applies \`lag_hrf\`.

- width:

  Optional block width in seconds. If non-zero, applies \`block_hrf\`.

- precision:

  Sampling precision for block convolution (passed to \`block_hrf\`).
  Default is 0.1.

- half_life:

  Half-life decay parameter for exponential decay in seconds (passed to
  \`block_hrf\`). Default is Inf (no decay).

- summate:

  Whether to summate within blocks (passed to \`block_hrf\`). Default is
  TRUE.

- normalize:

  If TRUE, applies \`normalise_hrf\` at the end. Default is FALSE.

- name:

  Optional name for the \*final\* HRF object. If NULL (default), a name
  is generated based on the base HRF and applied decorators.

- span:

  Optional span for the \*final\* HRF object. If NULL (default), the
  span is determined by the base HRF and decorators.

- ...:

  Extra arguments passed to the \*base\* HRF function if \`hrf\` is a
  function.

## Value

A final \`HRF\` object, potentially modified by decorators.

## Examples

``` r
# Lagged SPMG1
grf_lag <- gen_hrf(HRF_SPMG1, lag=3)
#> Warning: Parameters P1, P2, A1 are not arguments to function SPMG1_lag(3) and will be ignored
# Blocked Gaussian
grf_block <- gen_hrf(hrf_gaussian, width=5, precision=0.2)
# Lagged and Blocked, then Normalized
grf_both_norm <- gen_hrf(HRF_SPMG1, lag=2, width=4, normalize=TRUE)
#> Warning: Parameters P1, P2, A1 are not arguments to function SPMG1_block(w=4) and will be ignored
```
