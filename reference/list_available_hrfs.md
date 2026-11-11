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

A data frame with columns `name`, `type` (`"object"` or `"generator"`),
`nbasis_default` and `is_alias`, plus `description` when
`details = TRUE`.

## Examples

``` r
# List all available HRFs
hrfs <- list_available_hrfs()
print(hrfs)
#>          name      type nbasis_default is_alias
#> 1       spmg1    object              1    FALSE
#> 2       spmg2    object              2    FALSE
#> 3       spmg3    object              3    FALSE
#> 4       spmgq    object              2    FALSE
#> 5       gamma    object              1    FALSE
#> 6    gaussian    object              1    FALSE
#> 7     bspline generator              5    FALSE
#> 8        tent generator              5    FALSE
#> 9     fourier generator              5    FALSE
#> 10   daguerre generator              3    FALSE
#> 11        fir generator             12    FALSE
#> 12        lwu generator              1    FALSE
#> 13        gam    object              1     TRUE
#> 14         bs generator              5     TRUE
#> 15 quadrature    object              2     TRUE

# List with details
hrfs_detailed <- list_available_hrfs(details = TRUE)
print(hrfs_detailed)
#>          name      type nbasis_default is_alias                     description
#> 1       spmg1    object              1    FALSE             spmg1 HRF (object) 
#> 2       spmg2    object              2    FALSE             spmg2 HRF (object) 
#> 3       spmg3    object              3    FALSE             spmg3 HRF (object) 
#> 4       spmgq    object              2    FALSE             spmgq HRF (object) 
#> 5       gamma    object              1    FALSE             gamma HRF (object) 
#> 6    gaussian    object              1    FALSE          gaussian HRF (object) 
#> 7     bspline generator              5    FALSE        bspline HRF (generator) 
#> 8        tent generator              5    FALSE           tent HRF (generator) 
#> 9     fourier generator              5    FALSE        fourier HRF (generator) 
#> 10   daguerre generator              3    FALSE       daguerre HRF (generator) 
#> 11        fir generator             12    FALSE            fir HRF (generator) 
#> 12        lwu generator              1    FALSE            lwu HRF (generator) 
#> 13        gam    object              1     TRUE        gam HRF (object) (alias)
#> 14         bs generator              5     TRUE      bs HRF (generator) (alias)
#> 15 quadrature    object              2     TRUE quadrature HRF (object) (alias)
```
