# Build a Design Matrix from Block-wise Onsets

\`regressor_design\` extends \[regressor_set()\] by allowing onsets to
be specified relative to individual blocks and by directly returning the
evaluated design matrix.

## Usage

``` r
regressor_design(
  onsets,
  fac,
  block,
  sframe,
  hrf = HRF_SPMG1,
  duration = 0,
  amplitude = 1,
  span = 40,
  precision = 0.33,
  method = c("conv", "fft", "Rconv", "loop"),
  sparse = FALSE,
  summate = TRUE
)
```

## Arguments

- onsets:

  Numeric vector of event onset times, expressed relative to the start
  of their corresponding block.

- fac:

  A factor (or object coercible to a factor) indicating the condition
  for each onset.

- block:

  Integer vector identifying the block for each onset. Values must be
  valid block indices for \`sframe\`.

- sframe:

  A \[sampling_frame\] describing the temporal structure of the
  experiment.

- hrf:

  Hemodynamic response function shared by all conditions.

- duration:

  Numeric scalar or vector of event durations.

- amplitude:

  Numeric scalar or vector of event amplitudes.

- span:

  Numeric scalar giving the HRF span in seconds.

- precision:

  Numeric precision used during convolution.

- method:

  Evaluation method passed to \[evaluate()\].

- sparse:

  Logical; if \`TRUE\` a sparse design matrix is returned.

- summate:

  Logical; passed to \[regressor()\].

## Value

A numeric matrix (or sparse matrix) with one column per factor level and
one row per sample defined by \`sframe\`.

## Examples

``` r
# Create a sampling frame for 2 blocks, 100 scans each, TR=2
sframe <- sampling_frame(blocklens = c(100, 100), TR = 2)

# Events in block-relative time
onsets <- c(10, 30, 50, 20, 40, 60)
conditions <- factor(c("A", "B", "A", "B", "A", "B"))
blocks <- c(1, 1, 1, 2, 2, 2)

# Build design matrix
design <- regressor_design(
  onsets = onsets,
  fac = conditions,
  block = blocks,
  sframe = sframe,
  hrf = HRF_SPMG1
)

# Design matrix has 200 rows (total scans) and 2 columns (conditions)
dim(design)
#> [1] 200   2
```
