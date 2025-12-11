# Get fMRI Acquisition Onset Times

Calculate the onset time in seconds for each fMRI volume acquisition
from the start of the experiment.

## Usage

``` r
acquisition_onsets(x, ...)

# S3 method for class 'sampling_frame'
acquisition_onsets(x, ...)
```

## Arguments

- x:

  A sampling_frame object

- ...:

  Additional arguments (for extensibility)

## Value

Numeric vector of acquisition onset times in seconds

## Details

Returns the temporal onset of each brain volume acquisition, accounting
for TR, start_time, and run structure. This is essentially a convenience
wrapper around `samples(x, global = TRUE)` that provides clearer
semantic meaning for the common use case of getting acquisition times.

Note: The onset times include the start_time offset (default TR/2), so
the first acquisition typically doesn't start at 0.

## See also

[`samples`](https://bbuchsbaum.github.io/fmrihrf/reference/samples.md)
for more flexible timing queries

## Examples

``` r
# Single block with default start_time (TR/2 = 1)
sf <- sampling_frame(blocklens = 100, TR = 2)
onsets <- acquisition_onsets(sf)
head(onsets)  # Returns: 1, 3, 5, 7, 9, 11, ...
#> [1]  1  3  5  7  9 11

# Multiple blocks with same TR
sf2 <- sampling_frame(blocklens = c(100, 120), TR = 2)
onsets2 <- acquisition_onsets(sf2)
# First block: 1, 3, 5, ..., 199
# Second block: 201, 203, 205, ..., 439

# Variable TR per block
sf3 <- sampling_frame(blocklens = c(100, 100), TR = c(2, 1.5))
onsets3 <- acquisition_onsets(sf3)
# First block: 1, 3, 5, ..., 199 (TR=2)
# Second block: 200.75, 202.25, 203.75, ... (TR=1.5, start_time=0.75)

# Custom start times
sf4 <- sampling_frame(blocklens = c(50, 50), TR = 2, start_time = 0)
onsets4 <- acquisition_onsets(sf4)
head(onsets4)  # Returns: 0, 2, 4, 6, 8, 10, ...
#> [1]  0  2  4  6  8 10
```
