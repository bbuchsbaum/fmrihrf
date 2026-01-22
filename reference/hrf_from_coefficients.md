# Combine HRF Basis with Coefficients

Create a new HRF by linearly weighting the basis functions of an
existing HRF. Useful when coefficients have been estimated for an
FIR/bspline/SPMG3 basis and one wants a single functional HRF.

## Usage

``` r
hrf_from_coefficients(hrf, h, ...)

# S3 method for class 'HRF'
hrf_from_coefficients(hrf, h, name = NULL, ...)
```

## Arguments

- hrf:

  An object of class \`HRF\`.

- h:

  Numeric vector of length \`nbasis(hrf)\` giving the weights.

- ...:

  Reserved for future extensions.

- name:

  Optional name for the resulting HRF.

## Value

A new \`HRF\` object with \`nbasis = 1\`.

## Examples

``` r
# Create a custom HRF from SPMG3 basis coefficients
coeffs <- c(1, 0.2, -0.1)  # Main response + slight temporal shift - dispersion
custom_hrf <- hrf_from_coefficients(HRF_SPMG3, coeffs)
#> Warning: Parameters coefficients are not arguments to function SPMG3_from_coef and will be ignored

# Evaluate the custom HRF
t <- seq(0, 20, by = 0.1)
response <- evaluate(custom_hrf, t)

# Create from FIR basis
fir_coeffs <- c(0, 0.2, 0.5, 1, 0.8, 0.4, 0.1, 0, 0, 0, 0, 0)
custom_fir <- hrf_from_coefficients(HRF_FIR, fir_coeffs)
#> Warning: Parameters nbasis, span, bin_width, coefficients are not arguments to function fir_from_coef and will be ignored
```
