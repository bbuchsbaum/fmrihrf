# HRF Generators

## Why Generators?

Most pre-defined HRFs in `fmrihrf` (like `HRF_SPMG1` or `HRF_GAUSSIAN`)
are ready-to-use objects. However, some HRFs are actually *generators*.
A generator is a function that creates a new HRF object when you call
it. This allows you to specify the number of basis functions (`nbasis`)
and the time span (`span`) at creation time.

The library provides generators for flexible basis sets such as
B-splines and finite impulse response (FIR) models. They are available
through the internal `HRF_REGISTRY` and are also returned by
[`list_available_hrfs()`](https://bbuchsbaum.github.io/fmrihrf/reference/list_available_hrfs.md)
with type “generator”.

``` r
list_available_hrfs(details = TRUE) %>%
  dplyr::filter(type == "generator")
#>       name      type nbasis_default is_alias                description
#> 1  bspline generator              5    FALSE   bspline HRF (generator) 
#> 2     tent generator              5    FALSE      tent HRF (generator) 
#> 3  fourier generator              5    FALSE   fourier HRF (generator) 
#> 4 daguerre generator              3    FALSE  daguerre HRF (generator) 
#> 5      fir generator             12    FALSE       fir HRF (generator) 
#> 6      lwu generator       variable    FALSE       lwu HRF (generator) 
#> 7       bs generator              5     TRUE bs HRF (generator) (alias)
```

## Creating a Basis with a Generator

To obtain an actual HRF object from a generator, simply call the
generator function with your desired parameters. For example, to create
a B-spline basis with 8 functions spanning 32 seconds:

``` r
# Create a B-spline basis using gen_hrf
bs8 <- gen_hrf(hrf_bspline, N = 8, span = 32)
print(bs8)
#> -- HRF: hrf_bspline --------------------------------------- 
#>    Basis functions: 8 
#>    Span: 32 s
```

The returned value is a standard `HRF` object, so you can evaluate it or
use it in model formulas like any other HRF.

``` r
times <- seq(0, 32, by = 0.5)
mat <- bs8(times)
head(mat)
#>              1          2            3 4 5 6 7 8
#> [1,] 0.0000000 0.00000000 0.0000000000 0 0 0 0 0
#> [2,] 0.3081055 0.02164714 0.0003255208 0 0 0 0 0
#> [3,] 0.4960938 0.07942708 0.0026041667 0 0 0 0 0
#> [4,] 0.5844727 0.16259766 0.0087890625 0 0 0 0 0
#> [5,] 0.5937500 0.26041667 0.0208333333 0 0 0 0 0
#> [6,] 0.5444336 0.36214193 0.0406901042 0 0 0 0 0
```

## Visualising FIR Basis Functions

Here is a quick look at an FIR basis generated with 10 bins over a 20
second window:

``` r
# Use the pre-defined FIR basis or create one with gen_hrf
fir10 <- HRF_FIR  # Pre-defined FIR with 12 basis functions
resp <- fir10(times)

fir_df <- data.frame(Time = times, resp)
fir_long <- tidyr::pivot_longer(fir_df, -Time)

ggplot(fir_long, aes(Time, value, colour = name)) +
  geom_line(linewidth = 1) +
  labs(title = "Finite Impulse Response Basis",
       x = "Time (s)", y = "Response") +
  theme_minimal() +
  theme(legend.position = "none")
```

![](a_03_hrf_generators_files/figure-html/fir-basis-1.png)

## Summary

Generator functions are simple factories that let you customise flexible
HRF bases. They return normal `HRF` objects, which means you can
evaluate them, combine them with decorators, or insert them into
regressors just like the built-in HRFs. \`\`\`\`
