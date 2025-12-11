# Derivative method for SPMG2 HRF

Returns derivatives for both the canonical HRF and its temporal
derivative. The first column contains the derivative of the canonical
HRF, and the second column contains the second derivative (derivative of
the temporal derivative).

## Usage

``` r
# S3 method for class 'SPMG2_HRF'
deriv(x, t, ...)
```

## Arguments

- x:

  An SPMG2_HRF object

- t:

  Numeric vector of time points at which to evaluate the derivative

- ...:

  Additional arguments (currently unused)

## Value

Matrix with 2 columns of derivative values
