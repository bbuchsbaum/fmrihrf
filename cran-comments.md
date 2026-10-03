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

Checked on October 3, 2026, using the same source tarball on every platform:

| Environment | Errors | Warnings | Notes | Full check step | Vignette rebuild |
| --- | ---: | ---: | ---: | ---: | ---: |
| Ubuntu 24.04, R 4.6.1 | 0 | 0 | 0 | 140 s | 26 s |
| Ubuntu 24.04, R-devel (2026-10-02 r90631) | 0 | 0 | 0 | 99 s | 17 s |
| Windows, R 4.6.1 (ucrt) | 0 | 0 | 0 | 192 s | 29 s |
| macOS, R 4.6.1 | 0 | 0 | 1 | 147 s | 24 s |

All checks used `R CMD check --as-cran`, including the indexed PDF manual,
examples (also `--run-donttest`), and vignette rebuilds. `NOT_CRAN=false`;
the system-clock check was not disabled. CRAN incoming feasibility passed
on every platform. There were no test failures, warnings, or skips: 1,013
expectations passed on Linux and macOS, and 1,012 on Windows.

The macOS NOTE reports that the runner's system HTML Tidy is too old to validate
the HTML manual. HTML validation and math rendering passed on both Linux checks
and Windows. The PDF manual and vignette rebuilds passed on every platform.

Full check timings are conservative wall-clock durations of the checksum/check
step, including check setup and result capture. Vignette times are elapsed times
reported in `00check.log`. All are below the preparation gates of 600 seconds
for the full check and 180 seconds for vignette rebuilds. No tests or vignette
computation were disabled to achieve those times.

## Source artifact

Built with R 4.6.1 from commit
`6edcd1c897007b98c309f9ffea27022becf2d937`.

* File: `fmrihrf_0.4.0.tar.gz` (3,438,017 bytes)
* SHA-256: `51cb90a54318cca05bcd40d1b8990f9f6b0e0ac7f4029c3e231c83bcdf95cad0`
* Validation and retained logs:
  https://github.com/bbuchsbaum/fmrihrf/actions/runs/37154021156

Every platform verified this checksum before checking. Subsequent edits to this
file do not enter the source archive (`cran-comments.md` is build-ignored).

Independent scientific review identified query-dependent block normalization
and impulse substitution for positive durations below the quadrature step.
Both are corrected: normalization uses fixed per-basis absolute peaks over the
full blocked support; every positive duration is integrated. Sixty-eight new
expectations cover analytic integrals, signed/multiple bases, query invariance,
and method agreement. The implementation was independently re-reviewed before
these final checks. Linux BLAS summation order required a 64-machine-epsilon
tolerance for query-shape comparisons; analytic tolerances are unchanged.

## Additional pre-submission gates — upload held

The exact artifact has been uploaded to win-builder R-devel for checking;
results and elapsed time are pending. R-hub checks of the same source commit completed at:
https://github.com/bbuchsbaum/fmrihrf/actions/runs/37154495928

* ubuntu-clang: 0 errors, 0 warnings, 1 NOTE. All 1,013 expectations pass;
  the NOTE is test CPU time 3.2 times elapsed time (28s/9s), on a threaded
  OpenBLAS runner. Vignette rebuild elapsed time is 18 seconds.
* clang-asan: Status OK, all 1,013 expectations pass, no sanitizer failure.
* rchk: failed on Rcpp header protection diagnostics. Analysis-limit messages
  in R internals and incomplete-analysis notices in generated wrappers also
  appear. The concrete Rcpp findings remain under review and are not waived.

R-hub creates supplemental archives from the verified source commit and does
not check the byte-identical submission archive. Its defaults omit manuals;
the full manual evidence is supplied by the four exact-artifact checks.
Twenty local named-list/error-recovery/evaluation cycles under gctorture2(10)
pass against the exact installed archive, supporting but not replacing review
of the static findings.

CRAN upload remains held until all service diagnostics and runtime notes are
reviewed and the exact artifact is explicitly authorized.

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
