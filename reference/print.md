# Print method for Reg objects

Provides a concise summary of the regressor object using the cli
package.

## Usage

``` r
# S3 method for class 'Reg'
print(x, ...)

# S3 method for class 'sampling_frame'
print(x, ...)
```

## Arguments

- x:

  A \`Reg\` object.

- ...:

  Not used.

## Value

No return value, called for side effects (prints to console)

## Examples

``` r
r <- regressor(onsets = c(1, 10, 20), hrf = HRF_SPMG1,
               duration = 0, amplitude = 1,
               span = 40)
print(r)
#> 
#> ── fMRI Regressor Object ───────────────────────────────────────────────────────
#>   • Type: <Reg>
#>   • Events: 3
#>   • Onset Range: 1s to 20s
#>   • HRF: SPMG1 (1 basis function)
#>   • HRF Span: 24s
#>   • Summation: TRUE
```
