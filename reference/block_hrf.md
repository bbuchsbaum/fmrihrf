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

  The width of the block in seconds. Every positive width is integrated,
  including widths smaller than \`precision\`. Zero retains the original
  impulse response.

- precision:

  The sampling precision in seconds used for the internal convolution
  (default: 0.1).

- half_life:

  The half-life of an optional exponential decay applied during the
  block (default: Inf, meaning no decay).

- summate:

  Logical; if TRUE (default), responses within the block are integrated
  (summed). If FALSE, the integrated response is divided by the block
  width to obtain a temporal average. With finite \`half_life\`, decay
  attenuates the integrand but does not change this divisor. This does
  not fix peak height: longer blocks can have smaller peaks. Use
  \`normalize = TRUE\` for unit-peak scaling.

- normalize:

  Logical; if TRUE, scale each basis independently by its peak absolute
  value on a fixed reference grid over the full blocked span (the
  original span plus \`width\`). Uses the same approximately 0.02-second
  reference spacing as \[normalize_hrf()\] with
  \`"unit_peak_per_basis"\`. The factors are computed once at
  construction, so scalar, vector, and chunked queries have the same
  scale. Signs are preserved and zero bases remain zero. Default: FALSE.

## Value

A new HRF object representing the blocked function.

## See also

Other HRF_decorator_functions:
[`lag_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/lag_hrf.md),
[`normalise_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/normalise_hrf.md),
[`normalize_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/normalize_hrf.md)

## Examples

``` r
blocked_spmg1 <- block_hrf(HRF_SPMG1, width = 5)
t_vals <- seq(0, 30, by = 0.5)
plot(t_vals, HRF_SPMG1(t_vals), type = 'l', col = "blue", ylab = "Response", xlab = "Time")
lines(t_vals, blocked_spmg1(t_vals), col = "red")
legend("topright", legend = c("Original", "Blocked (width=5)"), col = c("blue", "red"), lty = 1)
```
