# Get event onsets from an object

Generic accessor returning event onset times in seconds.

## Usage

``` r
onsets(x, ...)

# S3 method for class 'Reg'
onsets(x, ...)
```

## Arguments

- x:

  Object containing onset information

- ...:

  Additional arguments passed to methods

## Value

Numeric vector of onsets

## Examples

``` r
# Create a regressor with event onsets
reg <- regressor(onsets = c(1, 5, 10, 15), hrf = HRF_SPMG1, span = 20)
onsets(reg)
#> [1]  1  5 10 15
```
