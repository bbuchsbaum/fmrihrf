# Evaluate an HRF Object

This function evaluates a hemodynamic response function (HRF) object for
a given set of time points (grid) and other parameters. It handles both
point evaluation (duration=0) and block evaluation (duration \> 0).

## Usage

``` r
# S3 method for class 'HRF'
evaluate(
  x,
  grid,
  amplitude = 1,
  duration = 0,
  precision = 0.2,
  summate = TRUE,
  normalize = FALSE,
  ...
)
```

## Arguments

- x:

  The HRF object (inherits from \`HRF\` and \`function\`).

- grid:

  A numeric vector of time points at which to evaluate the HRF.

- amplitude:

  The scaling value for the event (default: 1).

- duration:

  The duration of the event (seconds). If \> 0, the HRF is evaluated
  over this duration (default: 0).

- precision:

  The temporal resolution for evaluating responses when duration \> 0
  (default: 0.2).

- summate:

  Logical; whether the HRF response should accumulate over the duration
  (default: TRUE). If FALSE, the maximum response within the duration
  window is taken (currently only supported for single-basis HRFs).

- normalize:

  Logical; scale output so that the peak absolute value is 1 (default:
  FALSE). Applied \*after\* amplitude scaling and duration processing.

- ...:

  Additional arguments (unused).

## Value

A numeric vector or matrix of HRF values at the specified time points.

## Examples

``` r
# Evaluate canonical HRF at specific times
times <- seq(0, 20, by = 0.5)
response <- evaluate(HRF_SPMG1, times)

# Evaluate with amplitude scaling
response_scaled <- evaluate(HRF_SPMG1, times, amplitude = 2)

# Evaluate with duration (block design)
response_block <- evaluate(HRF_SPMG1, times, duration = 5, summate = TRUE)

# Multi-basis HRF evaluation
response_multi <- evaluate(HRF_SPMG3, times)  # Returns 3-column matrix
```
