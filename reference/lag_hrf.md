# Lag an HRF Object

Creates a new HRF object by applying a temporal lag to an existing HRF
object.

## Usage

``` r
lag_hrf(hrf, lag)
```

## Arguments

- hrf:

  The HRF object (of class \`HRF\`) to lag.

- lag:

  The time lag in seconds to apply. Positive values shift the response
  later in time.

## Value

A new HRF object representing the lagged function.

## See also

Other HRF_decorator_functions:
[`block_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/block_hrf.md),
[`normalise_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/normalise_hrf.md)

## Examples

``` r
lagged_spmg1 <- lag_hrf(HRF_SPMG1, 5)
#> Warning: Parameters P1, P2, A1, .lag are not arguments to function SPMG1_lag(5) and will be ignored
# Evaluate at time 10; equivalent to HRF_SPMG1(10 - 5)
lagged_spmg1(10)
#> [1] 1.753946
HRF_SPMG1(5)
#> [1] 1.753946
```
