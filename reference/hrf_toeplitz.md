# HRF Toeplitz Matrix

Create a Toeplitz matrix for hemodynamic response function (HRF)
convolution.

## Usage

``` r
hrf_toeplitz(hrf, time, len, sparse = FALSE)
```

## Arguments

- hrf:

  The hemodynamic response function.

- time:

  A numeric vector representing the time points.

- len:

  The length of the output Toeplitz matrix.

- sparse:

  Logical, if TRUE, the output Toeplitz matrix is returned as a sparse
  matrix (default: FALSE).

## Value

A Toeplitz matrix for HRF convolution.

## Examples

``` r
# Create HRF and time points
hrf_fun <- function(t) hrf_spmg1(t)
times <- seq(0, 30, by = 1)

# Create Toeplitz matrix
H <- hrf_toeplitz(hrf_fun, times, len = 50)

# Create sparse version
H_sparse <- hrf_toeplitz(hrf_fun, times, len = 50, sparse = TRUE)
```
