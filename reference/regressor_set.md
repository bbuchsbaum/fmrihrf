# Construct a Regressor Set

Creates a set of regressors, one for each level of a factor. Each
condition shares the same HRF and other parameters but has distinct
onsets, durations and amplitudes.

## Usage

``` r
regressor_set(
  onsets,
  fac,
  hrf = HRF_SPMG1,
  duration = 0,
  amplitude = 1,
  span = 40,
  summate = TRUE
)

# S3 method for class 'RegSet'
evaluate(
  x,
  grid,
  precision = 0.33,
  method = c("conv", "fft", "Rconv", "loop"),
  sparse = FALSE,
  ...
)
```

## Arguments

- onsets:

  Numeric vector of event onset times.

- fac:

  A factor (or object coercible to a factor) indicating the condition
  for each onset.

- hrf:

  Hemodynamic response function used for all conditions.

- duration:

  Numeric scalar or vector of event durations.

- amplitude:

  Numeric scalar or vector of event amplitudes.

- span:

  Numeric scalar giving the HRF span in seconds.

- summate:

  Logical; passed to \[regressor()\].

- x:

  A RegSet object

- grid:

  Numeric vector of time points at which to evaluate

- precision:

  Numeric precision for evaluation

- method:

  Evaluation method

- sparse:

  Logical whether to return sparse matrix

- ...:

  Additional arguments passed to evaluate

## Value

An object of class \`RegSet\` containing one \`Reg\` per factor level.

## Examples

``` r
# Create events for 3 conditions
onsets <- c(10, 20, 30, 40, 50, 60)
conditions <- factor(c("A", "B", "C", "A", "B", "C"))

# Create regressor set
rset <- regressor_set(onsets, conditions, hrf = HRF_SPMG1)

# With durations and amplitudes
rset2 <- regressor_set(
  onsets = onsets,
  fac = conditions,
  duration = 2,
  amplitude = c(1, 1.5, 0.8, 1, 1.5, 0.8),
  hrf = HRF_SPMG1
)

# Evaluate the regressor set
times <- seq(0, 80, by = 0.1)
design_matrix <- evaluate(rset, times)
```
