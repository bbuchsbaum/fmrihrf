# Create Daguerre HRF Basis Set

Generates an HRF object using Daguerre spherical basis functions with
custom parameters. These are orthogonal polynomials that naturally decay
to zero.

## Usage

``` r
hrf_daguerre_generator(nbasis = 3, scale = 4)
```

## Arguments

- nbasis:

  Number of basis functions (default: 3)

- scale:

  Scale parameter for the time axis (default: 4)

## Value

An HRF object of class `c("Daguerre_HRF", "HRF", "function")`

## Details

Daguerre basis functions are orthogonal polynomials on \[0,Inf) with
respect to the weight function w(x) = x^2 \* exp(-x). They are
particularly useful for modeling hemodynamic responses as they naturally
decay to zero and can capture various response shapes with few
parameters.

## See also

[`HRF_objects`](https://bbuchsbaum.github.io/fmrihrf/reference/HRF_objects.md)
for pre-defined HRF objects,
[`getHRF`](https://bbuchsbaum.github.io/fmrihrf/reference/getHRF.md) for
a unified interface to create HRFs

## Examples

``` r
# Create Daguerre basis with 5 functions
custom_dag <- hrf_daguerre_generator(nbasis = 5, scale = 3)
#> Warning: Parameters n_basis, scale are not arguments to function daguerre and will be ignored
t <- seq(0, 24, by = 0.1)
response <- evaluate(custom_dag, t)
matplot(t, response, type = "l", main = "Daguerre HRF with 5 basis functions")
```
