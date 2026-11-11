## Submission

This is an update from version 0.4.0 to version 0.5.0.

### Changes in this release

* New quadrature basis `HRF_SPMGQ` (the SPM canonical HRF and its
  orthogonalised, equal-norm Hilbert transform, `hrf_spmg1_quadrature()`), and
  `amplitude_latency()` / `hrf_shift_curve()`, which turn the fitted
  coefficients of a multi-basis HRF into a response amplitude and latency.
* `feature_regressor()` gains `durations` for event-timed features.
* Numerical corrections that can change results, each documented under
  "Changes that affect results" in NEWS: `regressor_design()` convolves each
  run separately; `hrf_mexhat()` uses the standard normalising constant;
  `hrf_spmg1()` scales its undershoot correctly for non-default `P2`; and
  `neural_input()` returns the stimulus function that `evaluate()` convolves.
* Bug fixes and performance improvements listed in NEWS.

## R CMD check results

0 errors | 0 warnings | 1 note

* Ubuntu 24.04.5 LTS (x86_64-pc-linux-gnu), R 4.6.2, `R CMD check --as-cran`,
  including the PDF manual, examples (also `--run-donttest`) and vignette
  rebuilds.

The NOTE is specific to the check machine: "Compilation used the following
non-portable flag(s): '-mno-omit-leaf-frame-pointer'". The flag comes from the
Ubuntu build of R, not from the package, which sets no compiler flags.

## Reverse dependencies

fmrihrf has no reverse dependencies on CRAN.
