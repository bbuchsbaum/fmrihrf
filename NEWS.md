# fmrihrf 0.4.0

## Improvements

* Factored the duplicated single-basis / multi-basis branching in
  `block_hrf()`, `evaluate.HRF()`, and `normalise_hrf()` into three internal
  helpers (`.weighted_combine`, `.normalise_result`, `.get_peaks`). No
  user-visible behavior change.

## Convolution engine consolidation

The package carried four convolution engines. Benchmarking them against
numerical integration of the same designs showed no configuration in which the
alternatives beat `conv` on either axis, so there is now one engine.

* `method = "conv"` remains the default and is the only convolution engine.
  It was 3-10x faster than `fft` and 10-100x faster than `loop` across every
  case measured (single run to 1000 volumes x 500 events, 1 to 5 basis
  functions, `precision` from 0.33 down to 0.01), at equal accuracy.

* `method = "fft"` and `method = "Rconv"` are deprecated. They now evaluate via
  `conv` and warn. The FFT engine never repaid its zero-padding, because the
  HRF is short relative to the sampled design, and it was the only method that
  could fail outright (on an internal FFT size above ~1e7). `Rconv` was an R
  reimplementation of `conv` that silently fell back to `loop` whenever the
  grid was irregular or durations varied. Both implementations have been
  removed.

* `method = "loop"` is retained. It is roughly twice as accurate as `conv`
  because event onsets are never quantised, and it remains the automatic
  fallback for regressors built from a list of per-event HRFs.

* Event onsets and block edges are no longer snapped to the internal grid.
  Each is placed at its exact sub-bin position, which at the default
  `precision = 0.33` cut the error of an off-grid onset from ~12% of peak to
  ~0.3%. Blocks are projected onto the linear hat basis, preserving trapezoid
  accuracy while keeping the exact edge placement.

* `method = "loop"` no longer truncates blocked events at `hrf_span`. It now
  extends to `hrf_span + duration`, removing a residual error that did not
  shrink as `precision` decreased.

## Bug Fixes

Addresses the defects reported in issue #45.

* **Breaking:** epoch (`duration > 0`) regressors are no longer scaled by
  `1/precision`. `evaluate()` on a `Reg` object summed microtime samples of a
  unit-height boxcar without a step-size factor, so the amplitude of every
  epoch regressor grew as the `precision` argument shrank -- at the default
  `precision = 0.33` an epoch column was inflated roughly 3.2x relative to the
  integral it was meant to approximate. The compiled engines now apply the same
  trapezoid quadrature `evaluate.HRF()` uses, so a block response is
  `amplitude * integral h(t - onset - u) du` over the block and converges as
  `precision` decreases. Point events (`duration = 0`) are unaffected.
  Fitted betas from epoch designs will change scale; model fit and t-statistics
  will not.

* **Breaking:** `summate = FALSE` now takes effect on every evaluation method.
  It was silently ignored by the `conv` (the default), `fft`, and `Rconv`
  engines, which never received the flag; only `method = "loop"` honoured it.

* **Breaking:** `evaluate.HRF()` selects its impulse and block branches on
  `duration` alone rather than on `duration < precision`. A numerical setting
  could previously decide which model was evaluated: at `precision = 0.2` a
  duration of 0.19 was treated as an impulse and 0.20 as a block, a five-fold
  amplitude jump. Durations smaller than `precision` are now integrated as
  blocks.

* All four evaluation methods (`conv`, `fft`, `Rconv`, `loop`) now agree to
  within quadrature error on block regressors.

* `hrf_sine()` and `hrf_fourier()` no longer error on a scalar `t`. `vapply()`
  dropped the result to a plain vector when `length(t) == 1`, so the support
  mask failed with "incorrect number of subscripts on matrix". This was
  reachable from public API via `lag_hrf()`, `block_hrf()`, and
  `getHRF("fourier")`.

* `HRF_BSPLINE` and `hrf_bspline_generator()` now place interior knots from
  `span`, fixed when the object is constructed. `splines::bs()` was called
  without `knots=` and fell back to quantiles of whatever `t` was supplied, so
  the basis depended on the evaluation grid and disagreed with `hrf_bspline()`.
  Evaluating on a single time point produced a degenerate basis.

* The internal Daguerre basis normalizes each column against a fixed reference
  grid rather than against the caller's `t`. Including negative lags inflated
  the divisor and shrank every returned value.

* `hrf_gaussian()`, `hrf_mexhat()`, `hrf_inv_logit()`, and `hrf_lwu()` return 0
  for `t < 0`, as the other kernels already did. The regressor path masked
  negative lags itself, but `block_hrf()` and `lag_hrf()` sample the shape
  function directly and mixed in pre-onset values -- up to 2% of peak for a
  blocked Mexican hat. Note that `hrf_mexhat()` is discontinuous at `t = 0` as
  a result, since its formula is non-zero there.

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
