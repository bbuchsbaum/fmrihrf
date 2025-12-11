# Turn any function into an HRF object

This is the core constructor for creating HRF objects in the refactored
system. It takes a function \`f(t)\` and attaches standard HRF
attributes. If \`params\` are provided, \`as_hrf\` creates a closure
that captures these parameters, ensuring they are used during evaluation
rather than relying on the function's defaults.

## Usage

``` r
as_hrf(
  f,
  name = deparse(substitute(f)),
  nbasis = 1L,
  span = 24,
  params = list()
)
```

## Arguments

- f:

  The function to be turned into an HRF object. It must accept a single
  argument \`t\` (time).

- name:

  The name for the HRF object. Defaults to the deparsed name of \`f\`.

- nbasis:

  The number of basis functions represented by \`f\`. Must be `>= 1`.
  Defaults to 1L.

- span:

  The nominal time span (duration in seconds) of the HRF. Must be
  positive. Defaults to 24.

- params:

  A named list of parameters associated with the HRF function \`f\`.
  When provided, \`as_hrf\` creates a closure that captures these
  parameters. Defaults to an empty list.

## Value

A new HRF object.

## Examples

``` r
# Create a custom HRF from a function
custom_hrf <- as_hrf(function(t) exp(-t/5),
                     name = "exponential",
                     span = 20)
evaluate(custom_hrf, seq(0, 10, by = 1))
#>  [1] 1.0000000 0.8187308 0.6703200 0.5488116 0.4493290 0.3678794 0.3011942
#>  [8] 0.2465970 0.2018965 0.1652989 0.1353353

# Create HRF with specific parameters (closure captures them)
gamma_hrf <- as_hrf(hrf_gamma, params = list(shape = 8, rate = 1.2))
evaluate(gamma_hrf, seq(0, 20, by = 1))
#>  [1] 0.000000e+00 2.569603e-04 9.906555e-03 5.098097e-02 1.150339e-01
#>  [6] 1.652124e-01 1.783027e-01 1.579909e-01 1.211776e-01 8.324087e-02
#> [11] 5.241863e-02 3.076671e-02 1.703914e-02 8.987295e-03 4.547455e-03
#> [16] 2.220023e-03 1.050522e-03 4.836759e-04 2.173533e-04 9.558295e-05
#> [21] 4.122511e-05
```
