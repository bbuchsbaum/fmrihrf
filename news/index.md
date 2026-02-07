# Changelog

## fmrihrf 0.2.0

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
