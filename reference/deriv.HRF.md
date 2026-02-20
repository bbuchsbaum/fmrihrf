# Default derivative method for HRF objects

Uses numerical differentiation via numDeriv::grad when analytic
derivatives are not available for a specific HRF type.

Uses the analytic derivative formula for the SPM canonical HRF.

Returns derivatives for both the canonical HRF and its temporal
derivative. The first column contains the derivative of the canonical
HRF, and the second column contains the second derivative (derivative of
the temporal derivative).

Returns derivatives for the canonical HRF and its two derivatives. Since
SPMG3 already includes first and second derivatives as basis functions,
this method returns their derivatives (1st, 2nd, and 3rd derivatives of
the original HRF).

## Usage

``` r
# S3 method for class 'HRF'
deriv(x, t, ...)

# S3 method for class 'SPMG1_HRF'
deriv(x, t, ...)

# S3 method for class 'SPMG2_HRF'
deriv(x, t, ...)

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

Numeric vector or matrix of derivative values

Numeric vector of derivative values

Matrix with 2 columns of derivative values

Matrix with 3 columns of derivative values

## Examples

``` r
t <- seq(0, 30, by = 0.5)
d <- deriv(HRF_SPMG1, t)
```
