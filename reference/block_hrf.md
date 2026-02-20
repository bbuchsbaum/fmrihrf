# Create a Blocked HRF Object

Creates a new HRF object representing a response to a sustained
(blocked) stimulus by convolving the input HRF with a boxcar function of
a given width.

## Usage

``` r
block_hrf(
  hrf,
  width,
  precision = 0.1,
  half_life = Inf,
  summate = TRUE,
  normalize = FALSE
)
```

## Arguments

- hrf:

  The HRF object (of class \`HRF\`) to block.

- width:

  The width of the block in seconds.

- precision:

  The sampling precision in seconds used for the internal convolution
  (default: 0.1).

- half_life:

  The half-life of an optional exponential decay applied during the
  block (default: Inf, meaning no decay).

- summate:

  Logical; if TRUE (default), responses within the block are integrated
  (summed). If FALSE, the integrated response is divided by the total
  block weight so amplitude does not grow with block width.

- normalize:

  Logical; if TRUE, the resulting blocked HRF is scaled so that its peak
  value is 1 (default: FALSE).

## Value

A new HRF object representing the blocked function.

## See also

Other HRF_decorator_functions:
[`lag_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/lag_hrf.md),
[`normalise_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/normalise_hrf.md)

## Examples

``` r
blocked_spmg1 <- block_hrf(HRF_SPMG1, width = 5)
#> Warning: Parameters P1, P2, A1 are not arguments to function SPMG1_block(w=5) and will be ignored
t_vals <- seq(0, 30, by = 0.5)
plot(t_vals, HRF_SPMG1(t_vals), type = 'l', col = "blue", ylab = "Response", xlab = "Time")
lines(t_vals, blocked_spmg1(t_vals), col = "red")
legend("topright", legend = c("Original", "Blocked (width=5)"), col = c("blue", "red"), lty = 1)
```
