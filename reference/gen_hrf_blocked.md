# Generate a Blocked HRF Function

The \`gen_hrf_blocked\` function creates a blocked HRF by convolving the
input HRF with a boxcar function. This can be used to model block
designs in fMRI analysis.

## Usage

``` r
gen_hrf_blocked(
  hrf = hrf_gaussian,
  width = 5,
  precision = 0.1,
  half_life = Inf,
  summate = TRUE,
  normalize = FALSE,
  ...
)

hrf_blocked(
  hrf = hrf_gaussian,
  width = 5,
  precision = 0.1,
  half_life = Inf,
  summate = TRUE,
  normalize = FALSE,
  ...
)
```

## Arguments

- hrf:

  A function representing the hemodynamic response function. Default is
  \`hrf_gaussian\`.

- width:

  A numeric value specifying the width of the block in seconds. Default
  is 5.

- precision:

  A numeric value specifying the sampling resolution in seconds. Default
  is 0.1.

- half_life:

  A numeric value specifying the half-life of the exponential decay
  function, used to model response attenuation. Default is \`Inf\`,
  which means no decay.

- summate:

  A logical value indicating whether to allow each impulse response
  function to "add" up. Default is \`TRUE\`.

- normalize:

  A logical value indicating whether to rescale the output so that the
  peak of the output is 1. Default is \`FALSE\`.

- ...:

  Extra arguments passed to the HRF function.

## Value

A `function` representing the blocked HRF.

A `function` representing the blocked HRF.

## Functions

- `hrf_blocked()`: alias for gen_hrf_blocked

## See also

Other gen_hrf:
[`gen_hrf_lagged()`](https://bbuchsbaum.github.io/fmrihrf/reference/gen_hrf_lagged.md)

## Examples

``` r
# Deprecated: use gen_hrf(..., width = 10) or block_hrf(HRF, width = 10)
```
