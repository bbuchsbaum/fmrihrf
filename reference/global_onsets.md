# Convert onsets to global timing

Generic accessor for converting block-wise onsets to global onsets.

## Usage

``` r
global_onsets(x, ...)

# S3 method for class 'sampling_frame'
global_onsets(x, onsets, blockids, ...)
```

## Arguments

- x:

  Object describing the sampling frame

- ...:

  Additional arguments passed to methods

- onsets:

  Numeric vector of onset times within blocks

- blockids:

  Integer vector identifying the block for each onset. Values must be
  whole numbers with no NAs.

## Value

Numeric vector of global onset times

## Examples

``` r
# Convert block-relative onsets to global timing
sframe <- sampling_frame(blocklens = c(100, 120), TR = 2)
global_onsets(sframe, onsets = c(10, 20), blockids = c(1, 2))
#> [1]  10 220
```
