# Create FIR HRF Basis Set

Generates an HRF object using Finite Impulse Response (FIR) basis
functions with custom parameters. Each basis function represents a time
bin with a value of 1 in that bin and 0 elsewhere.

## Usage

``` r
hrf_fir_generator(nbasis = 12, span = 24)
```

## Arguments

- nbasis:

  Number of time bins (default: 12)

- span:

  Temporal window in seconds (default: 24)

## Value

An HRF object of class `c("FIR_HRF", "HRF", "function")`

## Details

The FIR basis divides the time window into `nbasis` equal bins. Each
basis function is an indicator function for its corresponding bin. This
provides maximum flexibility but requires more parameters than smoother
basis sets like B-splines.

## See also

[`HRF_objects`](https://bbuchsbaum.github.io/fmrihrf/reference/HRF_objects.md)
for pre-defined HRF objects,
[`getHRF`](https://bbuchsbaum.github.io/fmrihrf/reference/getHRF.md) for
a unified interface to create HRFs,
[`hrf_bspline_generator`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_bspline_generator.md)
for a smoother alternative

## Examples

``` r
# Create FIR basis with 20 bins over 30 seconds
custom_fir <- hrf_fir_generator(nbasis = 20, span = 30)
t <- seq(0, 30, by = 0.1)
response <- evaluate(custom_fir, t)
matplot(t, response, type = "l", main = "FIR HRF with 20 time bins")


# Compare to default FIR with 12 bins
default_fir <- HRF_FIR
response_default <- evaluate(default_fir, t[1:241])  # 24 seconds
matplot(t[1:241], response_default, type = "l", 
        main = "Default FIR HRF (12 bins over 24s)")
```
