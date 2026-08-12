# Normalize an HRF Object with a Fixed Scale

Creates an HRF whose evaluations are divided by constants computed once
on a fixed reference grid. The resulting scale therefore does not depend
on the time points supplied in later calls.

## Usage

``` r
normalize_hrf(hrf, mode)
```

## Arguments

- hrf:

  An object of class \`HRF\`.

- mode:

  Normalization convention: \`"spm"\` divides by the sum of the
  canonical basis on the 1,600-point 0–32 second Nilearn reference grid;
  \`"unit_peak"\` divides every basis by the canonical basis peak;
  \`"unit_integral"\` divides every basis by the canonical basis
  trapezoidal integral; \`"unit_peak_per_basis"\` scales each basis
  independently; and \`"none"\` returns \`hrf\` unchanged.

## Value

An \`HRF\` object with fixed normalization.

## Details

For multi-basis HRFs, \`"spm"\`, \`"unit_peak"\`, and
\`"unit_integral"\` use one scalar computed from the first (canonical)
column and apply it uniformly. This preserves the relative scale of
derivative bases. Only \`"unit_peak_per_basis"\` rescales columns
independently.

## See also

Other HRF_decorator_functions:
[`block_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/block_hrf.md),
[`lag_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/lag_hrf.md),
[`normalise_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/normalise_hrf.md)

## Examples

``` r
spm_scaled <- normalize_hrf(HRF_SPMG1, "spm")
reference_grid <- seq(0, 32, length.out = 1600)
sum(spm_scaled(reference_grid))
#> [1] 1

peak_scaled <- normalize_hrf(HRF_SPMG2, "unit_peak")
max(abs(peak_scaled(seq(0, 24, by = 0.01))[, 1]))
#> [1] 1
```
