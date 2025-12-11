# Bind HRFs into a Basis Set

Combines multiple HRF objects into a single multi-basis HRF object. The
resulting function evaluates each input HRF at time \`t\` and returns
the results column-bound together.

## Usage

``` r
bind_basis(...)
```

## Arguments

- ...:

  One or more HRF objects created by \`as_hrf\` or other HRF
  constructors/decorators.

## Value

A new HRF object representing the combined basis set.

## Examples

``` r
# Combine multiple HRF basis functions
hrf1 <- as_hrf(hrf_gaussian, params = list(mean = 5))
hrf2 <- as_hrf(hrf_gaussian, params = list(mean = 10))
basis <- bind_basis(hrf1, hrf2)
nbasis(basis)  # Returns 2
#> [1] 2
```
