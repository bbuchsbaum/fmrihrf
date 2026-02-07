# Half-cosine HRF

Segments: 0-\>f1 (h1), f1-\>1 (h2), 1-\>f2 (h3), f2-\>0 (h4). Negative
f1 gives an initial dip; negative f2 gives an undershoot. Peak is at t =
h1 + h2 (amplitude 1 by construction).

## Usage

``` r
hrf_half_cosine(t, h1 = 1, h2 = 5, h3 = 7, h4 = 7, f1 = 0, f2 = 0)
```

## Arguments

- t:

  Numeric vector of times (s)

- h1, h2, h3, h4:

  Segment durations (s). Must be \> 0.

- f1:

  Initial dip level (default 0), typically in \[-0.2, 0\]

- f2:

  Undershoot level (default 0), typically in \[-0.3, 0\]

## Value

Numeric vector same length as t
