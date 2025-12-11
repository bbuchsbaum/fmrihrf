# Combine HRF Basis with Coefficients

Create a new HRF by linearly weighting the basis functions of an
existing HRF. This is useful for turning estimated basis coefficients
into a single functional HRF.

S3 method for \`HRF\` objects that returns a matrix mapping basis
coefficients to sampled HRF values at the provided time grid. For
single-basis HRFs, this returns a one-column matrix. For multi-basis
HRFs (e.g., SPMG2/SPMG3, FIR, B-spline), this returns a matrix with one
column per basis function.

## Usage

``` r
reconstruction_matrix(hrf, sframe, ...)

# S3 method for class 'HRF'
reconstruction_matrix(hrf, sframe, ...)
```

## Arguments

- hrf:

  An object of class \`HRF\`.

- sframe:

  A numeric vector of times, or a \`sampling_frame\` object from which
  times are extracted via \`samples()\`.

- ...:

  Additional arguments passed to \`samples()\` when \`sframe\` is a
  \`sampling_frame\`, and to \`evaluate()\` for HRF evaluation.

## Value

A numeric matrix with one column per basis function.

A numeric matrix of dimension \`length(times) x nbasis(hrf)\`.

## Details

Reconstruction matrix for an HRF basis

Returns a matrix \\\Phi\\ that converts basis coefficients into a
sampled HRF shape.

## Examples

``` r
# Create reconstruction matrix for basis functions
hrf <- HRF_SPMG2  # 2-basis HRF
times <- seq(0, 20, by = 0.5)
rmat <- reconstruction_matrix(hrf, times)
dim(rmat)  # Shows dimensions
#> [1] 41  2
```
