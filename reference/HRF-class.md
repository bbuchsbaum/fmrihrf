# HRF Constructor Function

The \`HRF\` function creates an object representing a hemodynamic
response function (HRF). It is a class constructor for HRFs.

## Usage

``` r
HRF(fun, name, nbasis = 1, span = 24, param_names = NULL)
```

## Arguments

- fun:

  A function representing the hemodynamic response, mapping from time to
  BOLD response.

- name:

  A string specifying the name of the function.

- nbasis:

  An integer representing the number of basis functions, e.g., the
  columnar dimension of the HRF. Default is 1.

- span:

  A numeric value representing the span in seconds of the HRF. Default
  is 24.

- param_names:

  A character vector containing the names of the parameters for the HRF
  function.

## Value

An HRF object with the specified properties.

## Details

The package provides several pre-defined HRF types that can be used in
modeling fMRI responses:

\*\*Canonical HRFs:\*\* \* \`"spmg1"\` or \`HRF_SPMG1\`: SPM's canonical
HRF (single basis function) \* \`"spmg2"\` or \`HRF_SPMG2\`: SPM
canonical + temporal derivative (2 basis functions) \* \`"spmg3"\` or
\`HRF_SPMG3\`: SPM canonical + temporal and dispersion derivatives (3
basis functions) \* \`"gaussian"\` or \`HRF_GAUSSIAN\`: Gaussian-shaped
HRF with peak around 5-6s \* \`"gamma"\` or \`HRF_GAMMA\`: Gamma
function-based HRF with longer tail

\*\*Flexible basis sets:\*\* \* \`"bspline"\` or \`"bs"\` or
\`HRF_BSPLINE\`: B-spline basis for flexible HRF modeling \* \`"tent"\`:
Tent (triangular) basis functions for flexible HRF modeling \*
\`"daguerre"\` or \`HRF_DAGUERRE\`: Daguerre basis functions

To see a complete list of available HRF types with details, use the
\`list_available_hrfs()\` function.

## Examples

``` r
hrf <- HRF(hrf_gamma, "gamma", nbasis=1, param_names=c("shape", "rate"))
resp <- evaluate(hrf, seq(0, 24, by=1))

# List all available HRF types
list_available_hrfs(details = TRUE)
#>        name      type nbasis_default is_alias                description
#> 1     spmg1    object              1    FALSE        spmg1 HRF (object) 
#> 2     spmg2    object              2    FALSE        spmg2 HRF (object) 
#> 3     spmg3    object              3    FALSE        spmg3 HRF (object) 
#> 4     gamma    object              1    FALSE        gamma HRF (object) 
#> 5  gaussian    object              1    FALSE     gaussian HRF (object) 
#> 6   bspline generator              5    FALSE   bspline HRF (generator) 
#> 7      tent generator              5    FALSE      tent HRF (generator) 
#> 8   fourier generator              5    FALSE   fourier HRF (generator) 
#> 9  daguerre generator              3    FALSE  daguerre HRF (generator) 
#> 10      fir generator             12    FALSE       fir HRF (generator) 
#> 11      lwu generator       variable    FALSE       lwu HRF (generator) 
#> 12      gam    object              1    FALSE          gam HRF (object) 
#> 13       bs generator              5     TRUE bs HRF (generator) (alias)
```
