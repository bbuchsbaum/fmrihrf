# Generate a Blocked HRF Function (deprecated)

`gen_hrf_blocked()` and its alias `hrf_blocked()` are deprecated and
warn when called. Use
[`block_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/block_hrf.md)
to block an existing HRF object, or
[`gen_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/gen_hrf.md)
with `width` (e.g. `gen_hrf(hrf_gaussian, width = 5)`), which is exactly
what `gen_hrf_blocked()` calls.

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
  `hrf_gaussian`.

- width:

  A numeric value specifying the width of the block in seconds. Default
  is 5.

- precision:

  A numeric value specifying the sampling resolution in seconds. Default
  is 0.1.

- half_life:

  A numeric value specifying the half-life of the exponential decay
  function, used to model response attenuation. Default is `Inf`, which
  means no decay.

- summate:

  Logical; if TRUE (default), integrate responses over the block. If
  FALSE, divide by the block width to obtain a temporal average.
  Averaging does not fix the peak height: longer blocks can have smaller
  peaks. Use `normalize = TRUE` for unit-peak scaling.

- normalize:

  A logical value indicating whether to rescale the output so that the
  peak of the output is 1. Default is `FALSE`.

- ...:

  Extra arguments passed to the HRF function.

## Value

The blocked `HRF` object returned by
[`gen_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/gen_hrf.md).

## See also

[`block_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/block_hrf.md),
[`gen_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/gen_hrf.md)

## Examples

``` r
# Instead of gen_hrf_blocked(hrf_gaussian, width = 10), use
blocked <- gen_hrf(hrf_gaussian, width = 10)
# or, for an existing HRF object
blocked <- block_hrf(HRF_SPMG1, width = 10)
```
