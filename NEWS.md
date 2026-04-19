# fmrihrf (development version)

## New Features

* `make_hrf()` is now the unified entry point for HRF construction. It
  accepts a character registry name, a plain function, or an existing HRF
  object, and exposes the full decorator pipeline (`width`, `precision`,
  `half_life`, `summate`, `lag`, `normalize`, `span`, `...`). Its previous
  `(basis, lag, nbasis)` signature is preserved positionally, so existing
  downstream calls continue to work unchanged.

## Deprecations

* `gen_hrf()` and `getHRF()` are deprecated in favor of `make_hrf()`. They
  remain exported as thin wrappers that forward to `make_hrf()` with a
  `.Deprecated()` notice. Migration: replace `gen_hrf(x, ...)` and
  `getHRF("name", ...)` with `make_hrf(x, ...)` / `make_hrf("name", ...)`.
* `gen_hrf_lagged()` is deprecated in favor of `lag_hrf()`. The wrapper
  now returns an HRF object (previously it returned a bare function); callers
  that treated the result as a plain function should either migrate to
  `lag_hrf()` (which has always returned an HRF) or invoke the HRF
  directly, which also returns numeric values.

## Improvements

* Factored the duplicated single-basis / multi-basis branching in
  `block_hrf()`, `evaluate.HRF()`, and `normalise_hrf()` into three internal
  helpers (`.weighted_combine`, `.normalise_result`, `.get_peaks`). No
  user-visible behavior change.
* Formalized the `"."`-prefixed metadata namespace used by decorators
  (`.lag`, `.width`, `.normalised`, etc.). Such keys are stored in the `params`
  attribute but are now excluded from `param_names`, so introspection no
  longer leaks decorator bookkeeping.

## Bug Fixes

* `lag_hrf()`, `block_hrf()`, and `normalise_hrf()` no longer emit a spurious
  "Parameters ... are not arguments to function" warning when decorating HRFs
  whose base function has named parameters (e.g. `HRF_SPMG1`'s `P1`, `P2`,
  `A1`). Decorators now forward only the base HRF's dotted metadata, so
  `as_hrf()`'s formals validation does not fire. Dotted bookkeeping
  (`.width`, `.summate`, `.normalize`, etc.) is correctly preserved on the
  decorated HRF's `params` attribute.

# fmrihrf 0.3.1

## New Features

* Added a package-owned command line interface with installed `fmrihrf` wrapper,
  `fmrihrf_cli()`, and `install_cli()`.

## Improvements

* Removed an unused suggested dependency and tightened build-ignore rules for
  local check artifacts.

# fmrihrf 0.3.0

## Improvements

* Consolidated derivative method Rd aliases into parent help pages, reducing documentation redundancy.
* Added explicit `importFrom(utils, tail)` to avoid R CMD check NOTEs.

## Bug Fixes

* Guarded `is.symbol()` before `as.character()` in internal eco atlas extraction to prevent errors on non-symbol inputs.

# fmrihrf 0.2.1

## Bug Fixes

* Fixed `hrf_bspline()` support handling so values for `t > span` (and `t < 0`) are zeroed instead of wrapping to onset-like values.
* Fixed `block_hrf()` block integration to include quadrature step-size scaling, making amplitudes stable across `precision`.
* Fixed `hrf_sine()` and `hrf_fourier()` to clamp support to `[0, span]` and return zero outside the modeled window.
* Fixed `normalise_hrf()` to use fixed normalization constants computed on the HRF support, avoiding data-dependent scaling across evaluation grids.
* Fixed `evaluate.HRF()` block-duration summation to use the same weighted integration scheme as `block_hrf()`.
* Fixed `evaluate.Reg(normalize = TRUE)` to normalize regressor outputs consistently across evaluation methods, including single-trial regressors with different durations.
* Fixed `block_hrf(summate = FALSE)` to return normalized block integration (for both single- and multi-basis HRFs) instead of the legacy pointwise-maximum behavior.

# fmrihrf 0.2.0

## New Features

* New `hrf_boxcar()` function for simple boxcar (step function) HRFs with optional normalization.
* New `hrf_weighted()` function for arbitrary weighted-window HRFs with constant or linear interpolation.
* `regressor()` now accepts a list of HRF objects for trial-varying HRF designs.
* New `plot.Reg()` method for visualizing regressor objects.
* New `plot_regressors()` for comparing multiple regressors on one plot (ggplot2 or base R).
* New `plot_hrfs()` for comparing multiple HRF shapes.
* New `print.HRF()` method for concise HRF summaries.

## Improvements

* Revised hemodynamic response and regressor vignettes.
* Expanded test suite for new HRF types and trial-varying regressors.

## Bug Fixes

* Fixed critical bug in `as_hrf()` where parameters stored in the `params` attribute were never used at evaluation time. The fix creates a closure that properly captures and applies parameters during evaluation.

# fmrihrf 0.1.0

* Initial CRAN release
