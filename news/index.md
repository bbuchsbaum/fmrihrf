# Changelog

## fmrihrf (development version)

### Improvements

- Factored the duplicated single-basis / multi-basis branching in
  [`block_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/block_hrf.md),
  [`evaluate.HRF()`](https://bbuchsbaum.github.io/fmrihrf/reference/evaluate.HRF.md),
  and
  [`normalise_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/normalise_hrf.md)
  into three internal helpers (`.weighted_combine`, `.normalise_result`,
  `.get_peaks`). No user-visible behavior change.

## fmrihrf 0.3.1

### New Features

- Added a package-owned command line interface with installed `fmrihrf`
  wrapper,
  [`fmrihrf_cli()`](https://bbuchsbaum.github.io/fmrihrf/reference/fmrihrf_cli.md),
  and
  [`install_cli()`](https://bbuchsbaum.github.io/fmrihrf/reference/install_cli.md).

### Improvements

- Removed an unused suggested dependency and tightened build-ignore
  rules for local check artifacts.

## fmrihrf 0.3.0

CRAN release: 2026-03-28

### Improvements

- Consolidated derivative method Rd aliases into parent help pages,
  reducing documentation redundancy.
- Added explicit `importFrom(utils, tail)` to avoid R CMD check NOTEs.

### Bug Fixes

- Guarded [`is.symbol()`](https://rdrr.io/r/base/name.html) before
  [`as.character()`](https://rdrr.io/r/base/character.html) in internal
  eco atlas extraction to prevent errors on non-symbol inputs.

## fmrihrf 0.2.1

### Bug Fixes

- Fixed
  [`hrf_bspline()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_bspline.md)
  support handling so values for `t > span` (and `t < 0`) are zeroed
  instead of wrapping to onset-like values.
- Fixed
  [`block_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/block_hrf.md)
  block integration to include quadrature step-size scaling, making
  amplitudes stable across `precision`.
- Fixed
  [`hrf_sine()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_sine.md)
  and
  [`hrf_fourier()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_fourier.md)
  to clamp support to `[0, span]` and return zero outside the modeled
  window.
- Fixed
  [`normalise_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/normalise_hrf.md)
  to use fixed normalization constants computed on the HRF support,
  avoiding data-dependent scaling across evaluation grids.
- Fixed
  [`evaluate.HRF()`](https://bbuchsbaum.github.io/fmrihrf/reference/evaluate.HRF.md)
  block-duration summation to use the same weighted integration scheme
  as
  [`block_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/block_hrf.md).
- Fixed `evaluate.Reg(normalize = TRUE)` to normalize regressor outputs
  consistently across evaluation methods, including single-trial
  regressors with different durations.
- Fixed `block_hrf(summate = FALSE)` to return normalized block
  integration (for both single- and multi-basis HRFs) instead of the
  legacy pointwise-maximum behavior.

## fmrihrf 0.2.0

CRAN release: 2026-02-09

### New Features

- New
  [`hrf_boxcar()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_boxcar.md)
  function for simple boxcar (step function) HRFs with optional
  normalization.
- New
  [`hrf_weighted()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_weighted.md)
  function for arbitrary weighted-window HRFs with constant or linear
  interpolation.
- [`regressor()`](https://bbuchsbaum.github.io/fmrihrf/reference/regressor.md)
  now accepts a list of HRF objects for trial-varying HRF designs.
- New
  [`plot.Reg()`](https://bbuchsbaum.github.io/fmrihrf/reference/plot.Reg.md)
  method for visualizing regressor objects.
- New
  [`plot_regressors()`](https://bbuchsbaum.github.io/fmrihrf/reference/plot_regressors.md)
  for comparing multiple regressors on one plot (ggplot2 or base R).
- New
  [`plot_hrfs()`](https://bbuchsbaum.github.io/fmrihrf/reference/plot_hrfs.md)
  for comparing multiple HRF shapes.
- New
  [`print.HRF()`](https://bbuchsbaum.github.io/fmrihrf/reference/print.HRF.md)
  method for concise HRF summaries.

### Improvements

- Revised hemodynamic response and regressor vignettes.
- Expanded test suite for new HRF types and trial-varying regressors.

### Bug Fixes

- Fixed critical bug in
  [`as_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/as_hrf.md)
  where parameters stored in the `params` attribute were never used at
  evaluation time. The fix creates a closure that properly captures and
  applies parameters during evaluation.

## fmrihrf 0.1.0

CRAN release: 2025-09-16

- Initial CRAN release
