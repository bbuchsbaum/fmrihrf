# Get durations of an object

Get durations of an object

## Usage

``` r
durations(x, ...)

# S3 method for class 'Reg'
durations(x, ...)
```

## Arguments

- x:

  The object to get durations from

- ...:

  Additional arguments passed to methods

## Value

A numeric vector of durations

## Examples

``` r
# Create a regressor with event durations
reg <- regressor(onsets = c(1, 5, 10), hrf = HRF_SPMG1,
                 duration = c(2, 3, 1), span = 20)
durations(reg)
#> [1] 2 3 1
```
