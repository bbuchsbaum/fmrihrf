# Internal Constructor for Regressor Objects

Internal Constructor for Regressor Objects

## Usage

``` r
Reg(
  onsets,
  hrf = HRF_SPMG1,
  duration = 0,
  amplitude = 1,
  span = 40,
  summate = TRUE
)
```

## Value

An S3 object of class \`Reg\` (and \`list\`) with components: \*
\`onsets\`: Numeric vector of event onset times (seconds). \* \`hrf\`:
An object of class \`HRF\` used for convolution. \* \`duration\`:
Numeric vector of event durations (seconds). \* \`amplitude\`: Numeric
vector of event amplitudes/scaling factors. \* \`span\`: Numeric scalar
indicating the HRF span (seconds). \* \`summate\`: Logical indicating if
overlapping HRF responses should summate. \* \`filtered_all\`: Logical
attribute set to \`TRUE\` when all events were removed due to zero or
\`NA\` amplitudes.
