# Generate an HRF Basis Set

\`hrf_set\` constructs an HRF basis set from one or more component HRF
objects.

## Usage

``` r
hrf_set(..., name = "hrf_set")

gen_hrf_set(...)
```

## Arguments

- ...:

  One or more HRF objects.

- name:

  The name for the combined HRF set.

## Value

A combined HRF object.

## Examples

``` r
# Combine multiple HRF types into a basis set
hrf_basis <- hrf_set(HRF_SPMG1, HRF_GAUSSIAN, HRF_GAMMA)

# Create custom basis with different parameters
hrf1 <- gen_hrf(hrf_gamma, alpha = 6, beta = 1)
#> Warning: Could not determine nbasis for function hrf_gamma - defaulting to 1. Evaluation failed.
hrf2 <- gen_hrf(hrf_gamma, alpha = 8, beta = 1)
#> Warning: Could not determine nbasis for function hrf_gamma - defaulting to 1. Evaluation failed.
custom_basis <- hrf_set(hrf1, hrf2, name = "custom_gamma_basis")

# Evaluate the basis set
t <- seq(0, 30, by = 0.1)
basis_response <- evaluate(hrf_basis, t)
```
