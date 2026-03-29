## Resubmission

This is a resubmission of version 0.3.0 addressing CRAN pretest feedback.

### Changes since previous submission

* Fixed vignette building so prebuilt vignettes are included in the tarball
  (resolves WARNING about missing `inst/doc` and NOTE about missing vignette index).
* Aligned VignetteIndexEntry title with YAML title in `a_02_regressor.Rmd`.
* Consolidated derivative method Rd aliases into parent help pages.
* Added explicit `importFrom(utils, tail)` to avoid R CMD check NOTEs.
* Fixed `is.symbol()` guard before `as.character()` in internal helper.

## R CMD check results

0 errors | 0 warnings | 0 notes

## Test environments

* local macOS (aarch64-apple-darwin), R 4.5.1
* GitHub Actions: ubuntu-latest (R release, R devel), macOS-latest (R release), windows-latest (R release)
