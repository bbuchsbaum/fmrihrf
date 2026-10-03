## Submission

This is an update from version 0.3.0 to version 0.4.0.

### Changes in this release

* Corrected the quadrature and scaling of block-event regressors. Block
  responses now converge as temporal precision increases, and all supported
  evaluation methods agree within quadrature error. These numerical corrections
  can affect fitted coefficients and results; existing analyses should be refitted.
* Corrected the SPMG canonical response shape and replaced the third SPMG3
  column with a response-dispersion derivative. These are breaking scientific
  corrections, documented in NEWS. The bases remain raw continuous kernels;
  exact sampled SPM/Nilearn design compatibility is not claimed.
* Added `feature_regressor()` for continuously sampled features, with explicit
  pre-convolution centering, scaling, and masking. Matrix and array inputs are
  rejected to avoid silently combining separate features.
* Consolidated the compiled convolution implementation. The deprecated `fft`
  and `Rconv` method names now route to `conv`; the direct `loop` reference
  implementation remains available.
* Added fixed-scale HRF normalization modes while retaining the existing
  per-basis unit-peak behavior for compatibility.
* Added a package-owned command-line interface and improved its Windows
  portability.
* Corrected scalar Fourier evaluation, fixed-grid B-spline and Daguerre basis
  behavior, negative-lag support, and loop evaluation on irregular grids.
* Updated all vignettes to the CRAN release of albersdown 2.1.0, declared in
  Suggests. The new output format embeds the theme assets; figure resolution
  is limited to keep the source tarball compact.
* Improved narrow-screen plot layouts, peak annotations and onset transparency.
  Website figures use Retina resolution; CRAN vignette figures remain compact.

## Release review hold

The candidate and checks recorded below are superseded. Independent review
identified query-dependent normalization and incorrect impulse substitution for
positive blocks shorter than the quadrature step. Fixes are in preparation;
this archive must not be submitted. New exact-artifact checks will replace these
results before submission.

## Previous R CMD check results

Checked on October 3, 2026, using the same source tarball on every platform:

| Environment | Errors | Warnings | Notes |
| --- | ---: | ---: | ---: |
| Ubuntu 24.04, R 4.6.1 | 0 | 0 | 0 |
| Ubuntu 24.04, R-devel (2026-10-02 r90631) | 0 | 0 | 0 |
| Windows, R 4.6.1 (ucrt) | 0 | 0 | 0 |
| macOS, R 4.6.1 | 0 | 0 | 1 |

All checks used `R CMD check --as-cran`, including the indexed PDF manual,
examples, and vignette rebuilds. `NOT_CRAN=false`; the system-clock check was
not disabled. There were no test failures, warnings, or skips: 945 expectations
passed on Linux and macOS, and 944 on Windows.

The macOS NOTE reports that the runner's system HTML Tidy is too old to validate
the HTML manual. HTML validation and math rendering passed on both Linux checks
and Windows. The PDF manual and vignette rebuilds passed on every platform.

Minimal CI TeX installations initially lacked Courier and/or `makeindex`.
Installing those tools resolved the PDF failures; no manual check was disabled.

## Source artifact

Built with R 4.6.1 from commit
`4e8ccb6e665d1738becb1db9d2d34e5ec2694cfd`.

* File: `fmrihrf_0.4.0.tar.gz` (3,435,052 bytes)
* SHA-256: `1fa5f66a19ded2e0cedcf9de952c1f64c3e382ecb252aec7f1749461716f8f44`
* Validation and retained logs:
  https://github.com/bbuchsbaum/fmrihrf/actions/runs/37151994419

Every platform verified this checksum before checking. Subsequent edits to this
file do not enter the source archive (`cran-comments.md` is build-ignored).

## Compatibility and reverse dependencies

The B-spline and tent bases now vanish at both endpoints, and constant weighted
windows use all weights. Together with the SPMG and block-convolution changes,
these require rebuilding design matrices and refitting analyses. Old coefficients
and inferential results must not be assumed interchangeable. README and NEWS
provide migration guidance. The default 24-second support is retained; users who
need more of the SPMG undershoot can explicitly choose a longer span.

CRAN's source package metadata, retrieved October 3, 2026, lists no reverse
Depends, Imports, LinkingTo, or Suggests dependencies for fmrihrf.

This preparation also removes a direct `Rf_error()` call from the C++ wrapper
(issue #42) and clarifies temporal averaging versus peak normalization (issue
#49). Version 0.4.0 has not been submitted by this release-preparation task.
