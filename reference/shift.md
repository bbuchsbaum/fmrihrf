# Shift a time series object

Apply a temporal shift to a time series object. This function shifts the
values in time while preserving the structure of the object. Common uses
include:

- alignment:

  Aligning regressors with different temporal offsets

- derivatives:

  Applying temporal derivatives to time series

- correction:

  Correcting for timing differences between signals

## Usage

``` r
shift(x, ...)

# S3 method for class 'Reg'
shift(x, shift_amount, ...)
```

## Arguments

- x:

  An object representing a time series or a time-based data structure

- ...:

  Additional arguments passed to methods

- shift_amount:

  Numeric; amount to shift by (positive = forward, negative = backward)

## Value

An object of the same class as the input, with values shifted in time:

- Values:

  Values are moved by the specified offset

- Structure:

  Object structure and dimensions are preserved

- Padding:

  Empty regions are filled with padding value

## See also

\[regressor()\], \[evaluate()\]

## Examples

``` r
# Create a simple time series with events
event_data <- data.frame(
  onsets = c(1, 10, 20, 30),
  run = c(1, 1, 1, 1)
)

# Create regressor from events
reg <- regressor(
  onsets = event_data$onsets,
  hrf = HRF_SPMG1,
  duration = 0,
  amplitude = 1
)

# Shift regressor forward by 2 seconds
reg_forward <- shift(reg, shift_amount = 2)

# Shift regressor backward by 1 second
reg_backward <- shift(reg, shift_amount = -1)

# Evaluate original and shifted regressors
times <- seq(0, 50, by = 2)
orig_values <- evaluate(reg, times)
shifted_values <- evaluate(reg_forward, times)
```
