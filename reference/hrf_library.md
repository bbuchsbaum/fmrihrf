# Generate an HRF library from a parameter grid

\`hrf_library\` applies a base HRF generating function to each row of a
parameter grid.

## Usage

``` r
hrf_library(fun, pgrid, ...)

gen_hrf_library(...)
```

## Arguments

- fun:

  A function that generates an HRF, given a set of parameters.

- pgrid:

  A data frame where each row is a set of parameters.

- ...:

  Additional arguments passed to \`fun\`.

## Value

A combined HRF object representing the library.

## Examples

``` r
# Create library of gamma HRFs with varying parameters
param_grid <- expand.grid(
  shape = c(6, 8, 10),
  rate = c(0.9, 1, 1.1)
)
gamma_library <- hrf_library(
  function(shape, rate) as_hrf(hrf_gamma, params = list(shape = shape, rate = rate)),
  param_grid
)

# Create library with fixed and varying parameters
param_grid2 <- expand.grid(lag = c(0, 2, 4))
lagged_library <- hrf_library(
  function(lag) gen_hrf(HRF_SPMG1, lag = lag),
  param_grid2
)
#> Warning: Parameters P1, P2, A1 are not arguments to function SPMG1_lag(2) and will be ignored
#> Warning: Parameters P1, P2, A1 are not arguments to function SPMG1_lag(4) and will be ignored
```
