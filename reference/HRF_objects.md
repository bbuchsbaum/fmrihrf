# Pre-defined Hemodynamic Response Function Objects

A collection of pre-defined HRF objects for common fMRI analysis
scenarios. These objects can be used directly in model specifications or
as templates for creating custom HRFs.

## Usage

``` r
HRF_GAMMA(t)

HRF_GAUSSIAN(t)

HRF_SPMG1(t)

HRF_SPMG2(t)

HRF_SPMG3(t)

HRF_BSPLINE(t)

HRF_FIR(t)
```

## Arguments

- t:

  Numeric vector of time points (in seconds) at which to evaluate the
  HRF

- P1, P2:

  Shape parameters for SPM canonical HRF (default: P1=5, P2=15)

- A1:

  Amplitude parameter for SPM canonical HRF (default: 0.0833)

- shape, rate:

  Parameters for gamma distribution HRF (default: shape=6, rate=1)

- mean, sd:

  Parameters for Gaussian HRF (default: mean=6, sd=2)

## Value

When called as functions, return numeric vectors or matrices of HRF
values. When used as objects, they are HRF objects with class
`c("HRF", "function")`.

## Canonical HRFs

- `HRF_SPMG1`:

  SPM canonical HRF (single basis function)

- `HRF_SPMG2`:

  SPM canonical HRF with temporal derivative (2 basis functions)

- `HRF_SPMG3`:

  SPM canonical HRF with temporal and dispersion derivatives (3 basis
  functions)

- `HRF_GAMMA`:

  Gamma function-based HRF

- `HRF_GAUSSIAN`:

  Gaussian function-based HRF

## Flexible Basis Sets

- `HRF_BSPLINE`:

  B-spline basis HRF (5 basis functions)

- `HRF_FIR`:

  Finite Impulse Response (FIR) basis HRF (12 basis functions)

## Creating Custom Basis Sets

The pre-defined objects above have fixed numbers of basis functions. To
create basis sets with custom parameters (e.g., different numbers of
basis functions), use one of these approaches:

**Using getHRF():**

- `getHRF("fir", nbasis = 20)` - FIR basis with 20 functions

- `getHRF("bspline", nbasis = 10, span = 30)` - B-spline with 10
  functions

- `getHRF("fourier", nbasis = 7)` - Fourier basis with 7 functions

- `getHRF("daguerre", nbasis = 5, scale = 3)` - Daguerre basis

**Using generator functions directly:**

- `hrf_fir_generator(nbasis = 20, span = 30)`

- `hrf_bspline_generator(nbasis = 10, span = 30)`

- `hrf_fourier_generator(nbasis = 7, span = 24)`

- `hrf_daguerre_generator(nbasis = 5, scale = 3)`

## Usage

All HRF objects can be:

- Called as functions with time argument: `HRF_SPMG1(t)`

- Used in model specifications: `hrf(condition, basis = HRF_SPMG1)`

- Evaluated with
  [`evaluate()`](https://bbuchsbaum.github.io/fmrihrf/reference/evaluate.md)
  method

- Combined with decorators like
  [`lag_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/lag_hrf.md)
  or
  [`block_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/block_hrf.md)

## See also

[`evaluate.HRF`](https://bbuchsbaum.github.io/fmrihrf/reference/evaluate.HRF.md)
for evaluating HRF objects,
[`gen_hrf`](https://bbuchsbaum.github.io/fmrihrf/reference/gen_hrf.md)
for creating HRFs with decorators,
[`list_available_hrfs`](https://bbuchsbaum.github.io/fmrihrf/reference/list_available_hrfs.md)
for listing all HRF types,
[`getHRF`](https://bbuchsbaum.github.io/fmrihrf/reference/getHRF.md) for
creating HRFs by name with custom parameters,
[`hrf_fir_generator`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_fir_generator.md),
[`hrf_bspline_generator`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_bspline_generator.md),
[`hrf_fourier_generator`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_fourier_generator.md),
[`hrf_daguerre_generator`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_daguerre_generator.md)
for creating custom basis sets directly

Other hrf:
[`deriv()`](https://bbuchsbaum.github.io/fmrihrf/reference/deriv.md),
[`penalty_matrix()`](https://bbuchsbaum.github.io/fmrihrf/reference/penalty_matrix.md)

## Examples

``` r
# Evaluate HRFs at specific time points
times <- seq(0, 20, by = 0.5)

# Single basis canonical HRF
canonical_response <- HRF_SPMG1(times)
plot(times, canonical_response, type = "l", main = "SPM Canonical HRF")


# Multi-basis HRF with derivatives
multi_response <- HRF_SPMG3(times)  # Returns 3-column matrix
matplot(times, multi_response, type = "l", main = "SPM HRF with Derivatives")


# Gamma and Gaussian HRFs
gamma_response <- HRF_GAMMA(times)
gaussian_response <- HRF_GAUSSIAN(times)

# Compare different HRF shapes
plot(times, canonical_response, type = "l", col = "blue", 
     main = "HRF Comparison", ylab = "Response")
lines(times, gamma_response, col = "red")
lines(times, gaussian_response, col = "green")
legend("topright", c("SPM Canonical", "Gamma", "Gaussian"), 
       col = c("blue", "red", "green"), lty = 1)


# Create custom FIR basis with 20 bins
custom_fir <- getHRF("fir", nbasis = 20, span = 30)
#> Warning: Parameters nbasis, span, bin_width are not arguments to function fir and will be ignored
fir_response <- evaluate(custom_fir, times)
matplot(times, fir_response, type = "l", main = "Custom FIR with 20 bins")


# Create custom B-spline basis  
custom_bspline <- hrf_bspline_generator(nbasis = 8, span = 25)
#> Warning: Parameters nbasis, degree, span are not arguments to function bspline and will be ignored
bspline_response <- evaluate(custom_bspline, times)
matplot(times, bspline_response, type = "l", main = "Custom B-spline with 8 basis functions")

```
