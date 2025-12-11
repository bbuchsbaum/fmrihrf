# Derivative method for SPMG3 HRF

Returns derivatives for the canonical HRF and its two derivatives. Since
SPMG3 already includes first and second derivatives as basis functions,
this method returns their derivatives (1st, 2nd, and 3rd derivatives of
the original HRF).

## Usage

``` r
# S3 method for class 'SPMG3_HRF'
deriv(x, t, ...)
```

## Arguments

- x:

  An SPMG3_HRF object

- t:

  Numeric vector of time points at which to evaluate the derivative

- ...:

  Additional arguments (currently unused)

## Value

Matrix with 3 columns of derivative values
