# Normalise an HRF Object

Creates a new HRF object whose output is scaled such that the maximum
absolute value of the response is 1.

## Usage

``` r
normalise_hrf(hrf)
```

## Arguments

- hrf:

  The HRF object (of class \`HRF\`) to normalise.

## Value

A new HRF object representing the normalised function.

## Details

For multi-basis HRFs, each basis function (column) is normalised
independently.

## See also

Other HRF_decorator_functions:
[`block_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/block_hrf.md),
[`lag_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/lag_hrf.md)

## Examples

``` r
# Create a gaussian HRF with a peak value != 1
gauss_unnorm <- as_hrf(function(t) 5 * dnorm(t, 6, 2), name="unnorm_gauss")
# Normalise it
gauss_norm <- normalise_hrf(gauss_unnorm)
#> Warning: Parameters .normalised are not arguments to function unnorm_gauss_norm and will be ignored
t_vals <- seq(0, 20, by = 0.1)
max(gauss_unnorm(t_vals)) # Peak is > 1
#> [1] 0.9973557
max(gauss_norm(t_vals))   # Peak is 1
#> [1] 1
```
