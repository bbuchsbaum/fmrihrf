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

  The duration of the event (seconds). A duration of 0 is an impulse of
  unit mass and returns the HRF itself; a duration \> 0 is a unit-height
  boxcar and returns its integral against the HRF (default: 0).

- precision:

  The quadrature step used to integrate over the block when duration \>
  0 (default: 0.2). It controls numerical accuracy only: the result
  converges as \`precision\` decreases and does not otherwise depend on
  it.

- summate:

  Logical; if TRUE (default), integrate the HRF over a unit-height
  block. If FALSE, divide by the duration to obtain a temporal average.
  The peak still varies with duration and can decrease for longer
  blocks. The average approaches the impulse response as duration
  approaches zero. Use \`normalize = TRUE\` for unit-peak scaling on the
  evaluated grid.

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
