# Create Tent HRF Basis Set

Generates an HRF object using tent (piecewise linear) basis functions
with custom parameters. This generator mirrors `HRF_TENT` but allows
callers to control the number of basis elements and temporal span.

## Usage

``` r
hrf_tent_generator(nbasis = 5, span = 24)
```

## Arguments

- nbasis:

  Number of tent basis functions (default: 5)

- span:

  Temporal window in seconds (default: 24)

## Value

An HRF object of class `c("Tent_HRF", "HRF", "function")`

## See also

[`HRF_objects`](https://bbuchsbaum.github.io/fmrihrf/reference/HRF_objects.md)
for pre-defined HRF objects,
[`getHRF`](https://bbuchsbaum.github.io/fmrihrf/reference/getHRF.md) for
a unified interface to create HRFs,
[`hrf_bspline_generator`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_bspline_generator.md)
for a smoother alternative

## Examples

``` r
# Create a tent basis with 6 functions over a 20 second window
custom_tent <- hrf_tent_generator(nbasis = 6, span = 20)
#> Warning: Parameters N, degree, span are not arguments to function tent and will be ignored
t <- seq(0, 20, by = 0.1)
response <- evaluate(custom_tent, t)
matplot(t, response, type = "l", main = "Tent HRF with 6 basis functions")
```
