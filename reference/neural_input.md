# Generate Neural Input Function from Event Timing

Converts event timing information into a neural input function
representing the underlying neural activity before HRF convolution. This
function is useful for:

## Usage

``` r
neural_input(x, ...)

# S3 method for class 'Reg'
neural_input(x, start = 0, end = NULL, resolution = 0.33, ...)
```

## Arguments

- x:

  A regressor object containing event timing information

- ...:

  Additional arguments passed to methods

- start:

  Numeric; start time of the input function

- end:

  Numeric; end time of the input function

- resolution:

  Numeric; temporal resolution in seconds (default: 0.33)

## Value

A list containing:

- time:

  Numeric vector of time points

- neural_input:

  Numeric vector of the stimulus density at each time point (see method
  details)

## Details

- stimulus:

  Creating stimulus functions for fMRI analysis

- modeling:

  Modeling sustained vs. transient neural activity

- inputs:

  Generating inputs for HRF convolution

- visualization:

  Visualizing the temporal structure of experimental designs

For a `Reg` object the input is built exactly as the default `"conv"`
engine of
[`evaluate`](https://bbuchsbaum.github.io/fmrihrf/reference/evaluate.md)
builds it, on the time grid `seq(start, end, by = resolution)`. A point
event (duration 0) is an impulse of mass `amplitude`, split linearly
between the two samples bracketing its onset. A block is projected onto
linear (hat) basis functions centred on the samples, with both edges at
their exact positions, so it carries mass `amplitude * duration`
(divided by `duration` when the regressor has `summate = FALSE`),
however short it is. The values are a density, mass per second: a block
is `amplitude` high away from its edges, a point event is a spike of
area `amplitude`, and `sum(neural_input) * resolution` is the input mass
inside the window. Convolving `neural_input * resolution` with the HRF
sampled every `resolution` seconds is the convolution that
`evaluate(x, grid, precision = resolution)` computes.

## See also

[`regressor`](https://bbuchsbaum.github.io/fmrihrf/reference/regressor.md),
[`evaluate.Reg`](https://bbuchsbaum.github.io/fmrihrf/reference/evaluate.md),
[`HRF_SPMG1`](https://bbuchsbaum.github.io/fmrihrf/reference/HRF_objects.md)

## Examples

``` r
# Create a regressor with multiple events
reg <- regressor(
  onsets = c(10, 30, 50),
  duration = c(2, 2, 2),
  amplitude = c(1, 1.5, 0.8),
  hrf = HRF_SPMG1
)

# Generate neural input function
input <- neural_input(reg, start = 0, end = 60, resolution = 0.5)

# Plot the neural input function
plot(input$time, input$neural_input, type = "l",
     xlab = "Time (s)", ylab = "Neural Input",
     main = "Neural Input Function")


# Create regressor with varying durations
reg_sustained <- regressor(
  onsets = c(10, 30),
  duration = c(5, 10),  # sustained activity
  amplitude = c(1, 1),
  hrf = HRF_SPMG1
)

# Generate and compare neural inputs
input_sustained <- neural_input(
  reg_sustained,
  start = 0,
  end = 60,
  resolution = 0.5
)
```
