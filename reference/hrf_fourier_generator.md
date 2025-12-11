# Create Fourier HRF Basis Set

Generates an HRF object using Fourier basis functions (sine and cosine
pairs) with custom parameters.

## Usage

``` r
hrf_fourier_generator(nbasis = 5, span = 24)
```

## Arguments

- nbasis:

  Number of basis functions (default: 5). Should be even for complete
  sine-cosine pairs.

- span:

  Temporal window in seconds (default: 24)

## Value

An HRF object of class `c("Fourier_HRF", "HRF", "function")`

## Details

The Fourier basis uses alternating sine and cosine functions with
increasing frequencies. This provides a smooth, periodic basis set that
can capture oscillatory components in the HRF.

## See also

[`HRF_objects`](https://bbuchsbaum.github.io/fmrihrf/reference/HRF_objects.md)
for pre-defined HRF objects,
[`getHRF`](https://bbuchsbaum.github.io/fmrihrf/reference/getHRF.md) for
a unified interface to create HRFs

## Examples

``` r
# Create Fourier basis with 8 functions
custom_fourier <- hrf_fourier_generator(nbasis = 8)
#> Warning: Parameters nbasis, span are not arguments to function fourier and will be ignored
t <- seq(0, 24, by = 0.1)
response <- evaluate(custom_fourier, t)
matplot(t, response, type = "l", main = "Fourier HRF with 8 basis functions")
```
