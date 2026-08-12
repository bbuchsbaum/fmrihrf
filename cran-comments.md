## Submission

This is an update from version 0.3.0 to version 0.4.0.

### Changes in this release

* Corrected the quadrature and scaling of block-event regressors. Block
  responses now converge as temporal precision increases, and all supported
  evaluation methods agree within quadrature error. This correction changes
  the scale of fitted coefficients for block designs but does not change model
  fits or test statistics.
* Consolidated the compiled convolution implementation. The deprecated `fft`
  and `Rconv` method names now route to `conv`; the direct `loop` reference
  implementation remains available.
* Added fixed-scale HRF normalization modes while retaining the existing
  per-basis unit-peak behavior for compatibility.
* Added a package-owned command-line interface and improved its Windows
  portability.
* Corrected scalar Fourier evaluation, fixed-grid B-spline and Daguerre basis
  behavior, negative-lag support, and loop evaluation on irregular grids.
* Updated and rebuilt all vignettes without undeclared runtime dependencies.

## R CMD check results

0 errors | 0 warnings | 0 notes

## Test environment

* macOS Sonoma 14.3 (aarch64-apple-darwin), R 4.5.1
  (`R CMD check --as-cran --no-manual` on the source tarball)
