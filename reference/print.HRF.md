# Print an HRF Object

Displays a concise summary of an HRF object including its name, number
of basis functions, temporal span, and parameters (if any).

## Usage

``` r
# S3 method for class 'HRF'
print(x, ...)
```

## Arguments

- x:

  An HRF object

- ...:

  Additional arguments (unused)

## Value

Invisibly returns the HRF object

## Examples

``` r
# Print canonical HRF
print(HRF_SPMG1)
#> -- HRF: SPMG1 --------------------------------------------- 
#>    Basis functions: 1 
#>    Span: 24 s
#>    Parameters: P1 = 5, P2 = 15, A1 = 0.0833 

# Print multi-basis HRF
print(HRF_SPMG3)
#> -- HRF: SPMG3 --------------------------------------------- 
#>    Basis functions: 3 
#>    Span: 24 s

# Print Gaussian HRF
print(HRF_GAUSSIAN)
#> -- HRF: gaussian ------------------------------------------ 
#>    Basis functions: 1 
#>    Span: 24 s
#>    Parameters: mean = 6, sd = 2 
```
