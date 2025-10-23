# fmrihrf (development version)

## Bug Fixes

* Fixed critical bug in `as_hrf()` where parameters stored in the `params` attribute were never used at evaluation time (#). Previously, calling `as_hrf(hrf_gamma, params = list(shape = 8, rate = 1.2))` would create an HRF that used the default parameter values instead of the specified ones. This caused `hrf_library()` to produce perfectly collinear basis functions when different parameters were provided. The fix creates a closure that properly captures and applies parameters during evaluation.

# fmrihrf 0.1.0

* Initial CRAN release