# Changelog

## fmrihrf 0.4.0

### Improvements

- Added fixed-scale HRF normalization with
  [`normalize_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/normalize_hrf.md)
  and the `hrf_norm` argument to
  [`gen_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/gen_hrf.md)
  and
  [`getHRF()`](https://bbuchsbaum.github.io/fmrihrf/reference/getHRF.md).
  Modes include Nilearn/SPM reference-grid scaling, unit peak, unit
  integral, and independent per-basis unit peaks. The existing
  [`normalise_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/normalise_hrf.md)
  and `normalize = TRUE` interfaces retain their per-basis unit-peak
  behavior.

- Factored the duplicated single-basis / multi-basis branching in
  [`block_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/block_hrf.md),
  [`evaluate.HRF()`](https://bbuchsbaum.github.io/fmrihrf/reference/evaluate.HRF.md),
  and
  [`normalise_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/normalise_hrf.md)
  into three internal helpers (`.weighted_combine`, `.normalise_result`,
  `.get_peaks`). No user-visible behavior change.

### Convolution engine consolidation

The package carried four evaluation engines. `conv` provided the best
speed/accuracy tradeoff in development benchmarks, so there is now one
compiled convolution engine.

- `method = "conv"` remains the default and is the only compiled
  convolution engine. It avoids FFT zero-padding overhead and is
  substantially faster than `loop` on large designs; exact speedups
  depend on design size, basis count, and `precision`.

- `method = "fft"` and `method = "Rconv"` are deprecated. They now
  evaluate via `conv` and warn. The FFT engine never repaid its
  zero-padding, because the HRF is short relative to the sampled design,
  and it was the only method that could fail outright (on an internal
  FFT size above ~1e7). `Rconv` was an R reimplementation of `conv` that
  silently fell back to `loop` whenever the grid was irregular or
  durations varied. Both implementations have been removed.

- `method = "loop"` is retained as the reference implementation. It can
  be more accurate at a given `precision` because event onsets are
  evaluated directly, and it remains the automatic fallback for
  regressors built from a list of per-event HRFs.

- Event onsets and block edges are no longer snapped to the internal
  grid. Each is placed at its exact sub-bin position, substantially
  reducing off-grid error at the default `precision = 0.33`. Blocks are
  projected onto the linear hat basis, preserving trapezoid accuracy
  while keeping the exact edge placement.

- `method = "loop"` no longer truncates blocked events at `hrf_span`. It
  now extends to `hrf_span + duration`, removing a residual error that
  did not shrink as `precision` decreased. Its support calculation no
  longer assumes a multi-point regular grid, so one-point and irregular
  grids work as well. Blocks whose onset precedes the requested grid are
  retained when their duration carries the response into it.

### Bug Fixes

Addresses the defects reported in issue
[\#45](https://github.com/bbuchsbaum/fmrihrf/issues/45).

- **Breaking:** epoch (`duration > 0`) regressors are no longer scaled
  by `1/precision`.
  [`evaluate()`](https://bbuchsbaum.github.io/fmrihrf/reference/evaluate.md)
  on a `Reg` object summed microtime samples of a unit-height boxcar
  without a step-size factor, so the amplitude of every epoch regressor
  grew as the `precision` argument shrank – at the default
  `precision = 0.33` an epoch column was inflated roughly 3.2x relative
  to the integral it was meant to approximate. The compiled engines now
  apply the same trapezoid quadrature
  [`evaluate.HRF()`](https://bbuchsbaum.github.io/fmrihrf/reference/evaluate.HRF.md)
  uses, so a block response is
  `amplitude * integral h(t - onset - u) du` over the block and
  converges as `precision` decreases. Point events (`duration = 0`) are
  unaffected. Fitted betas from epoch designs will change scale; model
  fit and t-statistics will not.

- **Breaking:** `summate = FALSE` now takes effect on every evaluation
  method. It was silently ignored by the `conv` (the default), `fft`,
  and `Rconv` engines, which never received the flag; only
  `method = "loop"` honoured it.

- **Breaking:**
  [`evaluate.HRF()`](https://bbuchsbaum.github.io/fmrihrf/reference/evaluate.HRF.md)
  selects its impulse and block branches on `duration` alone rather than
  on `duration < precision`. A numerical setting could previously decide
  which model was evaluated: at `precision = 0.2` a duration of 0.19 was
  treated as an impulse and 0.20 as a block, a five-fold amplitude jump.
  Durations smaller than `precision` are now integrated as blocks.

- The accepted evaluation methods (`conv`, `fft`, `Rconv`, `loop`) now
  agree to within quadrature error on block regressors; the deprecated
  names `fft` and `Rconv` route to `conv`.

- [`hrf_sine()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_sine.md)
  and
  [`hrf_fourier()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_fourier.md)
  no longer error on a scalar `t`.
  [`vapply()`](https://rdrr.io/r/base/lapply.html) dropped the result to
  a plain vector when `length(t) == 1`, so the support mask failed with
  “incorrect number of subscripts on matrix”. This was reachable from
  public API via
  [`lag_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/lag_hrf.md),
  [`block_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/block_hrf.md),
  and `getHRF("fourier")`.

- `HRF_BSPLINE` and
  [`hrf_bspline_generator()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_bspline_generator.md)
  now place interior knots from `span`, fixed when the object is
  constructed. [`splines::bs()`](https://rdrr.io/r/splines/bs.html) was
  called without `knots=` and fell back to quantiles of whatever `t` was
  supplied, so the basis depended on the evaluation grid and disagreed
  with
  [`hrf_bspline()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_bspline.md).
  Evaluating on a single time point produced a degenerate basis.

- The internal Daguerre basis normalizes each column against a fixed
  reference grid rather than against the caller’s `t`. Including
  negative lags inflated the divisor and shrank every returned value.

- [`hrf_gaussian()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_gaussian.md),
  [`hrf_mexhat()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_mexhat.md),
  [`hrf_inv_logit()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_inv_logit.md),
  and
  [`hrf_lwu()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_lwu.md)
  return 0 for `t < 0`, as the other kernels already did. The regressor
  path masked negative lags itself, but
  [`block_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/block_hrf.md)
  and
  [`lag_hrf()`](https://bbuchsbaum.github.io/fmrihrf/reference/lag_hrf.md)
  sample the shape function directly and mixed in pre-onset values – up
  to 2% of peak for a blocked Mexican hat. Note that
  [`hrf_mexhat()`](https://bbuchsbaum.github.io/fmrihrf/reference/hrf_mexhat.md)
  is discontinuous at `t = 0` as a result, since its formula is non-zero
  there.

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
