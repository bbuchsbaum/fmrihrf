# Get amplitudes from an object

Generic accessor returning event amplitudes or scaling factors.

## Usage

``` r
amplitudes(x, ...)

# S3 method for class 'Reg'
amplitudes(x, ...)
```

## Arguments

- x:

  Object containing amplitude information

- ...:

  Additional arguments passed to methods

## Value

Numeric vector of amplitudes

## Examples

``` r
# Create a regressor with varying amplitudes
reg <- regressor(onsets = c(1, 5, 10), hrf = HRF_SPMG1,
                 amplitude = c(1, 0.5, 2), 
                 span = 20)
amplitudes(reg)
#> [1] 1.0 0.5 2.0
```
