# Get block lengths

Generic accessor returning the number of scans in each block of a
sampling frame or similar object.

## Usage

``` r
blocklens(x, ...)

# S3 method for class 'sampling_frame'
blocklens(x, ...)
```

## Arguments

- x:

  Object containing block length information

- ...:

  Additional arguments passed to methods

## Value

Numeric vector of block lengths

## Examples

``` r
# Get block lengths from a sampling frame
sframe <- sampling_frame(blocklens = c(100, 120, 80), TR = 2)
blocklens(sframe)
#> [1] 100 120  80
```
