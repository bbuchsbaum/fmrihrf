# fmrihrf

Hemodynamic response functions and event-related regressors for fMRI
analysis in R.

**fmrihrf** provides a composable toolkit for constructing, modifying,
and convolving HRFs with experimental designs. It ships with standard
basis sets (SPM canonical, B-spline, Fourier, FIR, Gamma, Gaussian, and
more), decorators for time-shifting and blocking, and a fast C++
convolution backend.

## Installation

``` r
# From CRAN
install.packages("fmrihrf")

# Development version
remotes::install_github("bbuchsbaum/fmrihrf")
```

## Quick start

``` r
library(fmrihrf)

# Evaluate the SPM canonical HRF over 0-30 seconds
t <- seq(0, 30, by = 0.1)
y <- evaluate(HRF_SPMG1, t)
plot(t, y, type = "l", xlab = "Time (s)", ylab = "Response")

# Build a regressor from event onsets
reg <- regressor(onsets = c(2, 10, 18), hrf = HRF_SPMG1,
                 duration = 0, amplitude = 1,
                 span = 24, sampling_frame = sampling_frame(blocklens = 100, TR = 1))
plot(reg)
```

## Key features

**Multiple basis sets** — Use a single canonical HRF or a flexible basis
set to capture response variability.

``` r
HRF_SPMG1                                    # SPM canonical (double gamma)
HRF_SPMG3                                    # canonical + temporal & dispersion derivatives
hrf_bspline(t, N = 6)                        # B-spline basis
hrf_fourier(t, N = 5)                        # Fourier basis
```

**Decorators** — Modify any HRF through functional composition.

``` r
lag_hrf(HRF_SPMG1, lag = 2)                  # shift peak by 2 s
block_hrf(HRF_SPMG1, width = 15)             # sustained/blocked response
normalise_hrf(HRF_SPMG1)                     # unit peak-normalised
```

**Custom HRFs** — Wrap any `f(t)` into the HRF system.

``` r
my_hrf <- as_hrf(function(t) exp(-t / 5), name = "exponential", span = 20)
evaluate(my_hrf, seq(0, 20, by = 1))
```

**Regressor construction** — Convolve events with HRFs to produce
design-matrix columns, with support for variable durations, amplitudes,
and multi-basis expansion.

``` r
sf <- sampling_frame(blocklens = c(200, 200), TR = 2)
reg <- regressor(onsets = c(10, 30, 50), hrf = HRF_SPMG1,
                 duration = c(0, 5, 0), amplitude = c(1, 1.5, 1),
                 sampling_frame = sf)
evaluate(reg)
```

**Fast convolution** — Core routines are implemented in C++ (Rcpp /
RcppArmadillo) for efficient large-scale design matrix generation.

## Documentation

Full documentation is available at
<https://bbuchsbaum.github.io/fmrihrf/>.

Vignettes cover the main workflows:

- [Hemodynamic Response
  Functions](https://bbuchsbaum.github.io/fmrihrf/articles/a_01_hemodynamic_response.html)
  — overview of built-in HRFs and the basis-set system
- [Building
  Regressors](https://bbuchsbaum.github.io/fmrihrf/articles/a_02_regressor.html)
  — constructing design-matrix regressors from event timing
- [HRF
  Generators](https://bbuchsbaum.github.io/fmrihrf/articles/a_03_hrf_generators.html)
  — programmatically generating families of HRFs
- [Advanced Modeling and
  Design](https://bbuchsbaum.github.io/fmrihrf/articles/a_04_advanced_modeling.html)
  — multi-basis designs, trial-varying HRFs, and more

## Command Line

Install the package:

``` r
install.packages("fmrihrf")
```

Install the command wrapper:

``` r
fmrihrf::install_cli("~/.local/bin", overwrite = TRUE)
```

If needed, add the directory to `PATH`:

``` sh
export PATH="$HOME/.local/bin:$PATH"
```

Check the command:

``` sh
fmrihrf --help
```

List available HRFs:

``` sh
fmrihrf list --details
```

Evaluate a canonical HRF:

``` sh
fmrihrf eval --hrf spmg1 --from 0 --to 30 --by 0.5
```

Evaluate a flexible basis set as JSON:

``` sh
fmrihrf eval --hrf bspline --nbasis 6 --span 24 --json
```

Evaluate one event regressor on an acquisition grid:

``` sh
fmrihrf regressor \
  --onsets 0,12,24 \
  --blocklens 200 \
  --tr 2 \
  --hrf spmg1 \
  --output regressor.csv
```

Build a design matrix from an event table:

``` sh
fmrihrf design \
  --events events.csv \
  --blocklens 200,200 \
  --tr 2 \
  --hrf spmg1 \
  --output design.csv
```

The default event columns are `onset`, `condition`, `block`, `duration`,
and `amplitude`. Use `--onset`, `--condition`, `--block`, `--duration`,
and `--amplitude` when a table uses different column names.

## License

MIT

## Albers theme

This package uses the albersdown theme. Existing vignette theme hooks
are replaced so `albers.css` and local `albers.js` render consistently
on CRAN and GitHub Pages. The palette family is provided via
`params$family` (default ‘red’). The pkgdown site uses
`template: { package: albersdown }`.
