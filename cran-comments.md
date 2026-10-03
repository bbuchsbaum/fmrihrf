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

## Validation status

Release-candidate validation is in progress. The previous September 27 check
predates the B-spline and weighted-window corrections and is not evidence for
this candidate. The CRAN candidate workflow builds once on current R release,
records the source commit and SHA-256, and checks that same tarball with
`R CMD check --as-cran` on Linux R release/devel and macOS/Windows R release,
including vignette rebuilds and the PDF manual.

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
