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

## R CMD check results

0 errors | 0 warnings | 0 notes

Checked on 2026-09-27. All 776 test expectations passed with no test warnings or
skips. Examples, vignette rebuilds, and PDF and HTML manual checks passed.

No checks were disabled. The source tarball is 4.88 MB; incoming feasibility
passed without a size note.

## Test environment

* macOS Sonoma 14.3 (aarch64-apple-darwin20), R 4.5.1
  (`R CMD check --as-cran` on the source tarball, including the PDF manual;
  `LANG=en_US.UTF-8`, `LC_ALL=en_US.UTF-8`)
* HTML Tidy 5.8.0, selected with `R_TIDYCMD` for HTML manual validation.
* albersdown 2.1.0, installed from CRAN source into an isolated library.
