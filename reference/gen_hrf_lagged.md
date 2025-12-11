# Generate a Lagged HRF Function

The \`gen_hrf_lagged\` function takes an HRF function and applies a
specified lag to it. This can be useful for modeling time-delayed
hemodynamic responses.

## Usage

``` r
gen_hrf_lagged(hrf, lag = 2, normalize = FALSE, ...)

hrf_lagged(hrf, lag = 2, normalize = FALSE, ...)
```

## Arguments

- hrf:

  A function representing the underlying HRF to be shifted.

- lag:

  A numeric value specifying the lag or delay in seconds to apply to the
  HRF. This can also be a vector of lags, in which case the function
  returns an HRF set.

- normalize:

  A logical value indicating whether to rescale the output so that the
  maximum absolute value is 1. Defaults to \`FALSE\`.

- ...:

  Extra arguments supplied to the \`hrf\` function.

## Value

A function representing the lagged HRF. If \`lag\` is a vector of lags,
the function returns an HRF set.

an lagged hrf function

## Functions

- `hrf_lagged()`: alias for gen_hrf_lagged

## See also

Other gen_hrf:
[`gen_hrf_blocked()`](https://bbuchsbaum.github.io/fmrihrf/reference/gen_hrf_blocked.md)

Other gen_hrf:
[`gen_hrf_blocked()`](https://bbuchsbaum.github.io/fmrihrf/reference/gen_hrf_blocked.md)

## Examples

``` r
# \donttest{
hrf_lag5 <- gen_hrf_lagged(HRF_SPMG1, lag=5)
hrf_lag5(0:20)
#>  [1] 0.000000000 0.000000000 0.000000000 0.000000000 0.000000000 0.000000000
#>  [7] 0.030644357 0.360749730 1.007784768 1.562306838 1.753945621 1.605440375
#> [13] 1.276104046 0.914165872 0.603787442 0.372395071 0.215170462 0.115290241
#> [19] 0.055163173 0.020765904 0.002277497
# }
```
