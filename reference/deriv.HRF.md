# Default derivative method for HRF objects

Uses numerical differentiation via numDeriv::grad when analytic
derivatives are not available for a specific HRF type.

## Usage

``` r
# S3 method for class 'HRF'
deriv(x, t, ...)
```

## Arguments

- x:

  An HRF object

- t:

  Numeric vector of time points at which to evaluate the derivative

- ...:

  Additional arguments (currently unused)

## Value

Numeric vector or matrix of derivative values
