# Hemodynamic Response Function with Half-Cosine Basis

This function models a hemodynamic response function (HRF) using four
half-period cosine basis functions. The HRF consists of an initial dip,
a rise to peak, a fall and undershoot, and a recovery to the baseline.

## Usage

``` r
hrf_half_cosine(t, h1 = 1, h2 = 5, h3 = 7, h4 = 7, f1 = 0, f2 = 0)
```

## Arguments

- t:

  Time points at which to evaluate the HRF

- h1:

  Duration of initial fall from f1 to 0 (default: 1)

- h2:

  Duration of rise from 0 to 1 (default: 5)

- h3:

  Duration of fall from 1 to 0 (default: 7)

- h4:

  Duration of final rise from 0 to f2 (default: 7)

- f1:

  Initial baseline level (default: 0)

- f2:

  Final baseline level (default: 0)

## Value

A vector of HRF values corresponding to the input time values.

Numeric vector of HRF values at time points t

## References

Woolrich, M. W., Behrens, T. E., & Smith, S. M. (2004). Constrained
linear basis sets for HRF modelling using Variational Bayes. NeuroImage,
21(4), 1748-1761.

Half-cosine HRF

Creates a hemodynamic response function using half-cosine segments. The
function consists of four phases controlled by h1-h4 parameters, with
transitions between baseline (f1) and peak (1) and final (f2) levels.

## Examples

``` r
# Standard half-cosine HRF
t <- seq(0, 30, by = 0.1)
hrf <- hrf_half_cosine(t)
plot(t, hrf, type = "l", main = "Half-cosine HRF")

# Modified shape with undershoot
hrf_under <- hrf_half_cosine(t, h1 = 1, h2 = 4, h3 = 6, h4 = 8, f2 = -0.2)
lines(t, hrf_under, col = "red")
```
