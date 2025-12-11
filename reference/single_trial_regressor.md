# Create a single trial regressor

Creates a regressor object for modeling a single trial event in an fMRI
experiment. This is particularly useful for trial-wise analyses where
each trial needs to be modeled separately. The regressor represents the
predicted BOLD response for a single event using a specified hemodynamic
response function (HRF).

## Usage

``` r
single_trial_regressor(
  onsets,
  hrf = HRF_SPMG1,
  duration = 0,
  amplitude = 1,
  span = 24
)
```

## Arguments

- onsets:

  the event onset in seconds, must be of length 1.

- hrf:

  a hemodynamic response function, e.g. `HRF_SPMG1`

- duration:

  duration of the event (default is 0), must be length 1.

- amplitude:

  scaling vector (default is 1), must be length 1.

- span:

  the temporal window of the impulse response function (default is 24).

## Value

A \`Reg\` object (inheriting from \`regressor\` and \`list\`).

## Details

This is a convenience wrapper around \`regressor\` that ensures inputs
have length 1.

## See also

[`regressor`](https://bbuchsbaum.github.io/fmrihrf/reference/regressor.md)

## Examples

``` r
# Create single trial regressor at 10 seconds
str1 <- single_trial_regressor(onsets = 10, hrf = HRF_SPMG1)

# Single trial with duration and custom amplitude
str2 <- single_trial_regressor(
  onsets = 15,
  duration = 3,
  amplitude = 2,
  hrf = HRF_SPMG1
)

# Evaluate the response
times <- seq(0, 40, by = 0.1)
response <- evaluate(str1, times)
```
