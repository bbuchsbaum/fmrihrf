# Coefficients of a time-shifted response in an HRF basis

For each shift \`s\`, the least-squares coefficients of the reference
response delayed by \`s\` seconds, \`reference(t - s)\`, in the basis
\`hrf\`. As \`s\` varies the coefficients trace a curve in coefficient
space; \[amplitude_latency()\] locates fitted coefficients on that
curve.

## Usage

``` r
hrf_shift_curve(
  hrf,
  shifts = seq(-4, 4, by = 0.05),
  reference = NULL,
  dt = 0.05
)
```

## Arguments

- hrf:

  A multi-basis \`HRF\` object, e.g. \[HRF_SPMG2\] or \[HRF_SPMGQ\].

- shifts:

  Numeric vector of delays in seconds (positive = later).

- reference:

  An \`HRF\` object or function of time giving the response shape whose
  shifts are fitted. Defaults to the first basis function of \`hrf\`.

- dt:

  Time step in seconds of the grid used for the projection.

## Value

A matrix with one row per shift and one column per basis function, with
attributes \`shifts\` and \`gram\` (the Gram matrix of the basis on the
projection grid).

## See also

\[amplitude_latency()\]

## Examples

``` r
cc <- hrf_shift_curve(HRF_SPMG2, shifts = c(-2, -1, 0, 1, 2))
cc   # an unshifted response is (1, 0); the derivative picks up the shift
#>             b1            b2
#> [1,] 0.7956050  1.541767e+00
#> [2,] 0.9437691  9.346378e-01
#> [3,] 1.0000000 -7.682642e-16
#> [4,] 0.9437682 -9.346258e-01
#> [5,] 0.7955989 -1.541720e+00
#> attr(,"shifts")
#> [1] -2 -1  0  1  2
#> attr(,"gram")
#>              [,1]        [,2]
#> [1,] 1.225877e-01 5.83356e-07
#> [2,] 5.833560e-07 1.42596e-02
```
