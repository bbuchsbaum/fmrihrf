# Create an HRF from a basis specification

\`make_hrf\` resolves a basis specification to an \`HRF\` object and
applies an optional temporal lag. The basis may be given as the name of
a built-in HRF, as a generating function, or as an existing \`HRF\`
object.

## Usage

``` r
make_hrf(basis, lag, nbasis = 1)
```

## Arguments

- basis:

  Character name of a built-in HRF, a function that generates HRF
  values, or an object of class \`HRF\`.

- lag:

  Numeric scalar giving the shift in seconds applied to the HRF.

- nbasis:

  Integer specifying the number of basis functions when \`basis\` is
  provided as a name.

## Value

An object of class \`HRF\` representing the lagged basis.

## Examples

``` r
# Canonical SPM HRF delayed by 2 seconds
h <- make_hrf("spmg1", lag = 2)
#> Warning: Parameters P1, P2, A1 are not arguments to function spmg1_lag(2) and will be ignored
h(0:5)
#> [1] 0.00000000 0.00000000 0.00000000 0.03064436 0.36074973 1.00778477
```
