# Generate penalty matrix for regularization

Generate a penalty matrix for regularizing HRF basis coefficients. The
penalty matrix encodes shape priors that discourage implausible or
overly wiggly HRF estimates. Different HRF types use different penalty
structures:

- FIR/B-spline/Tent bases: Roughness penalties based on discrete
  derivatives

- SPM canonical + derivatives: Differential shrinkage of derivative
  terms

- Fourier bases: Penalties on high-frequency components

- Daguerre bases: Increasing weights on higher-order terms

- Default: Identity matrix (ridge penalty)

## Usage

``` r
penalty_matrix(x, ...)

# S3 method for class 'HRF'
penalty_matrix(x, order = 2, ...)

# S3 method for class 'BSpline_HRF'
penalty_matrix(x, order = 2, ...)

# S3 method for class 'Tent_HRF'
penalty_matrix(x, order = 2, ...)

# S3 method for class 'FIR_HRF'
penalty_matrix(x, order = 2, ...)

# S3 method for class 'SPMG2_HRF'
penalty_matrix(x, order = 2, shrink_deriv = 2, ...)

# S3 method for class 'SPMG3_HRF'
penalty_matrix(x, order = 2, shrink_deriv = 2, ...)

# S3 method for class 'Fourier_HRF'
penalty_matrix(x, order = 2, ...)

# S3 method for class 'Daguerre_HRF'
penalty_matrix(x, order = 2, ...)
```

## Arguments

- x:

  The HRF object or basis specification

- ...:

  Additional arguments passed to specific methods

- order:

  Integer specifying the order of the penalty (default: 2)

- shrink_deriv:

  Numeric; penalty weight for derivative terms in SPMG2/SPMG3 bases
  (default: 2)

## Value

A symmetric positive definite penalty matrix of dimension nbasis(x) ×
nbasis(x)

## Details

The penalty matrix R is used in regularized estimation as lambda \* h^T
R h, where h are the basis coefficients and lambda is the regularization
parameter. Well-designed penalty matrices can significantly improve HRF
estimation by encoding smoothness or other shape constraints.

## See also

\[nbasis()\], \[HRF_objects\]

Other hrf:
[`HRF_objects`](https://bbuchsbaum.github.io/fmrihrf/reference/HRF_objects.md),
[`deriv()`](https://bbuchsbaum.github.io/fmrihrf/reference/deriv.md)

## Examples

``` r
# FIR basis with smoothness penalty
fir_hrf <- HRF_FIR
R_fir <- penalty_matrix(fir_hrf)

# B-spline basis with second-order smoothness
bspline_hrf <- HRF_BSPLINE  
R_bspline <- penalty_matrix(bspline_hrf, order = 2)

# SPM canonical with derivative shrinkage
spmg3_hrf <- HRF_SPMG3
R_spmg3 <- penalty_matrix(spmg3_hrf, shrink_deriv = 4)
```
