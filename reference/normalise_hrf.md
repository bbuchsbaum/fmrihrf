# Normalise Each Basis of an HRF to Unit Peak

Back-compatible spelling and behavior for independently peak-normalizing
every basis column. New code can use \`normalize_hrf(hrf,
"unit_peak_per_basis")\` explicitly.

## Usage

``` r
normalise_hrf(hrf)
```

## Arguments

- hrf:

  An object of class \`HRF\`.

## Value

A unit-peak \`HRF\` object.

## See also

Other HRF_decorator_functions:
[`block_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/block_hrf.md),
[`lag_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/lag_hrf.md),
[`normalize_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/normalize_hrf.md)

## Examples

``` r
gauss_unnorm <- as_hrf(function(t) 5 * dnorm(t, 6, 2), name = "unnorm_gauss")
gauss_norm <- normalise_hrf(gauss_unnorm)
max(gauss_norm(seq(0, 20, by = 0.1)))
#> [1] 1
```
