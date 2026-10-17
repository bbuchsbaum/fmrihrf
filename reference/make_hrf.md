# Create an HRF from a basis specification

\`make_hrf\` resolves a basis specification to an \`HRF\` object and
applies an optional temporal lag. The basis may be given as the name of
a built-in HRF, as a generating function, or as an existing \`HRF\`
object.

## Usage

``` r
make_hrf(basis, lag, nbasis = NULL)
```

## Arguments

- basis:

  Character name of a built-in HRF, a function that generates HRF
  values, or an object of class \`HRF\`.

- lag:

  Numeric scalar giving the shift in seconds applied to the HRF.

- nbasis:

  Number of basis functions. \`NULL\` (the default) gives a basis-set
  name such as \`"bspline"\` or \`"fir"\` the default size used by
  \[getHRF()\], and a plain function as many basis functions as the
  columns it returns. Ignored for fixed HRFs such as \`"spmg1"\` or an
  \`HRF\` object.

## Value

An object of class \`HRF\` representing the lagged basis.

## Examples

``` r
# Canonical SPM HRF delayed by 2 seconds
h <- make_hrf("spmg1", lag = 2)
h(0:5)
#> [1] 0.000000000 0.000000000 0.000000000 0.003065662 0.036089408 0.100818722
```
