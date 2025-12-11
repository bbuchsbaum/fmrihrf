# A `sampling_frame` describes the block structure and temporal sampling of an fMRI paradigm.

A `sampling_frame` describes the block structure and temporal sampling
of an fMRI paradigm.

## Usage

``` r
sampling_frame(blocklens, TR, start_time = TR/2, precision = 0.1)
```

## Arguments

- blocklens:

  A numeric vector representing the number of scans in each block.

- TR:

  A numeric value or vector representing the repetition time in seconds
  (i.e., the spacing between consecutive image acquisitions). When a
  vector is provided, its length must be 1 or equal to the number of
  blocks.

- start_time:

  A numeric value or vector representing the offset of the first scan of
  each block (default is `TR/2`). When a vector is provided, its length
  must be 1 or equal to the number of blocks.

- precision:

  A numeric value representing the discrete sampling interval used for
  convolution with the hemodynamic response function (default is 0.1).

## Value

A list with class "sampling_frame" describing the block structure and
temporal sampling of an fMRI paradigm.

## Examples

``` r
frame <- sampling_frame(blocklens = c(100, 100, 100), TR = 2, precision = 0.5)

# The relative time (with respect to the last block) in seconds of each sample/acquisition
sam <- samples(frame)
# The global time (with respect to the first block) of each sample/acquisition
gsam <- samples(frame, global = TRUE)

# Block identifiers for each acquisition can be retrieved using
# blockids(frame)
```
