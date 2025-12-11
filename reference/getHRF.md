# Get HRF by Name

Retrieves an HRF by name from the registry and optionally applies
decorators. This provides a unified interface for creating both
pre-defined HRF objects and custom basis sets with specified parameters.

## Usage

``` r
getHRF(
  name = "spmg1",
  nbasis = 5,
  span = 24,
  lag = 0,
  width = 0,
  summate = TRUE,
  normalize = FALSE,
  ...
)
```

## Arguments

- name:

  Character string specifying the HRF type. Options include:

  - `"spmg1"`, `"spmg2"`, `"spmg3"` - SPM canonical HRFs

  - `"gamma"`, `"gaussian"` - Simple parametric HRFs

  - `"fir"` - Finite Impulse Response basis

  - `"bspline"` or `"bs"` - B-spline basis

  - `"fourier"` - Fourier basis

  - `"daguerre"` - Daguerre spherical basis

  - `"tent"` - Tent (linear spline) basis

- nbasis:

  Number of basis functions (for basis set types)

- span:

  Temporal window in seconds (default: 24)

- lag:

  Time lag in seconds to apply (default: 0)

- width:

  Block width for block designs (default: 0)

- summate:

  Whether to sum responses in block designs (default: TRUE)

- normalize:

  Whether to normalize the HRF (default: FALSE)

- ...:

  Additional arguments passed to generator functions (e.g., `scale` for
  daguerre)

## Value

An HRF object

## Details

For single HRF types (spmg1, gamma, gaussian), the function returns
pre-defined objects. For basis set types (fir, bspline, fourier,
daguerre), it calls the appropriate generator function with the
specified parameters.

## Examples

``` r
# Get pre-defined canonical HRF
canonical <- getHRF("spmg1")

# Create custom FIR basis with 20 bins
fir20 <- getHRF("fir", nbasis = 20, span = 30)
#> Warning: Parameters nbasis, span, bin_width are not arguments to function fir and will be ignored

# Create B-spline basis with lag
bs_lag <- getHRF("bspline", nbasis = 8, lag = 2)
#> Warning: Parameters nbasis, degree, span are not arguments to function bspline and will be ignored
#> Warning: Parameters .lag are not arguments to function bspline_lag(2) and will be ignored

# Create blocked Gaussian HRF
block_gauss <- getHRF("gaussian", width = 5)
#> Warning: Parameters mean, sd, .width, .precision, .half_life, .summate, .normalize are not arguments to function gaussian_block(w=5) and will be ignored
```
