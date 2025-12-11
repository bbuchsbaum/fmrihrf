# Number of basis functions

Return the number of basis functions represented by an object.

## Usage

``` r
nbasis(x, ...)

# S3 method for class 'HRF'
nbasis(x, ...)

# S3 method for class 'Reg'
nbasis(x, ...)
```

## Arguments

- x:

  Object containing HRF or regressor information.

- ...:

  Additional arguments passed to methods.

## Value

Integer scalar giving the number of basis functions.

## Details

This information is typically used when constructing penalty matrices or
understanding the complexity of an HRF model or regressor.

## Examples

``` r
# Number of basis functions for different HRF types
nbasis(HRF_SPMG1)   # 1 basis function
#> [1] 1
nbasis(HRF_SPMG3)   # 3 basis functions (canonical + 2 derivatives)
#> [1] 3
nbasis(HRF_BSPLINE) # 5 basis functions (default)
#> [1] 5

# For a regressor
reg <- regressor(onsets = c(10, 30, 50), hrf = HRF_SPMG3)
nbasis(reg)  # 3 (inherits from the HRF)
#> [1] 3
```
