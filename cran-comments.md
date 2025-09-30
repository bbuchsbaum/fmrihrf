## CRAN Release

Version 0.1.0 was accepted and published on CRAN on 2025-09-29.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

* we have added a package referennce

* we have reduced length of title

* we have added missing \value tags for print and plot

* In response to recent RcppArmadillo guidance, we added `-DARMA_USE_CURRENT` to `PKG_CXXFLAGS` in `src/Makevars` and `src/Makevars.win` so the package builds against the current Armadillo API. This should avoid legacy-mode use and related warnings.
