# List all available hemodynamic response functions (HRFs)

Reads the internal HRF registry to list available HRF types.

## Usage

``` r
list_available_hrfs(details = FALSE)
```

## Arguments

- details:

  Logical; if TRUE, attempt to add descriptions (basic for now).

## Value

A data frame with columns: name, type (object/generator),
nbasis_default.

## Examples

``` r
# List all available HRFs
hrfs <- list_available_hrfs()
print(hrfs)
#>        name      type nbasis_default is_alias
#> 1     spmg1    object              1    FALSE
#> 2     spmg2    object              2    FALSE
#> 3     spmg3    object              3    FALSE
#> 4     gamma    object              1    FALSE
#> 5  gaussian    object              1    FALSE
#> 6   bspline generator              5    FALSE
#> 7      tent generator              5    FALSE
#> 8   fourier generator              5    FALSE
#> 9  daguerre generator              3    FALSE
#> 10      fir generator             12    FALSE
#> 11      lwu generator       variable    FALSE
#> 12      gam    object              1    FALSE
#> 13       bs generator              5     TRUE

# List with details
hrfs_detailed <- list_available_hrfs(details = TRUE)
print(hrfs_detailed)
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
