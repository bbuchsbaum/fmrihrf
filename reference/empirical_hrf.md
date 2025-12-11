# Generate an Empirical Hemodynamic Response Function

\`empirical_hrf\` generates an empirical HRF using provided time points
and values.

## Usage

``` r
empirical_hrf(t, y, name = "empirical_hrf")

gen_empirical_hrf(...)
```

## Arguments

- t:

  Time points.

- y:

  Values of HRF at time \`t\[i\]\`.

- name:

  Name of the generated HRF.

## Value

An instance of type \`HRF\`.

## Examples

``` r
# Create empirical HRF from data points
t_points <- seq(0, 20, by = 1)
y_values <- c(0, 0.1, 0.5, 0.9, 1.0, 0.8, 0.5, 0.2, 0, -0.1, -0.1, 
              0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
emp_hrf <- empirical_hrf(t_points, y_values)

# Evaluate at new time points
new_times <- seq(0, 25, by = 0.1)
response <- evaluate(emp_hrf, new_times)
```
