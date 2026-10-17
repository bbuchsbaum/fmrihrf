#define ARMA_DONT_USE_WRAPPER
#include <RcppArmadillo.h>

// [[Rcpp::depends(RcppArmadillo)]]
// Single-threaded by design (no OpenMP in src/Makevars*); C++17.

using arma::uword;


/*  Accumulate coef * A_j(x) into a difference array, where A_j is the running
 *  integral of the linear hat (tent) basis function centred on bin j.
 *
 *  A block over [s, e] projected onto the hat basis has bin weights
 *  A_j(e) - A_j(s), which is trapezoid quadrature with the two endpoints
 *  placed at their exact sub-bin positions. Both properties matter: bin-aligned
 *  trapezoid weights quantised the block edges, and exact edges with plain
 *  rectangle weights dropped the quadrature to first order.
 */
static inline void addHatStep(arma::vec& diff, double pos, double coef,
                              double dt, uword nBins)
{
    if (pos <= 0.0) return;                        // nothing accumulated yet
    const double maxPos = (double) (nBins - 1);
    if (pos > maxPos) pos = maxPos;

    const uword a = (uword) std::floor(pos);
    const double f = pos - (double) a;
    const double v = coef * dt;

    // Full weight on every bin strictly left of a.
    if (a > 0) { diff[0] += v; diff[a] -= v; }

    // Partial weight on the two bins bracketing pos.
    const double wa  = v * (0.5 + f - 0.5 * f * f);
    const double wa1 = v * (0.5 * f * f);
    diff[a]     += wa;   diff[a + 1] -= wa;
    diff[a + 1] += wa1;  diff[a + 2] -= wa1;
}

/*──────────────────────────────────────────────────────────────────────
  Fine-grid neural input, built in O(E + N) with a difference array.

  Point events (duration <= 0) contribute a unit-mass impulse, so that
  convolution with the sampled HRF reproduces amp * h(t - onset)
  independently of `dt`.

  Block events (duration > 0) contribute the hat-basis projection of the
  boxcar, so that convolution approximates
  amp * \int_0^duration h(t - onset - u) du and converges as dt -> 0.
  Previously the boxcar had unit height and no dt factor at all, so a block
  response was a bare sample count that grew as ~1/dt: the amplitude of
  every epoch regressor was a function of the `precision` argument.

  Neither onsets nor block edges are snapped to the grid; both are placed at
  their exact sub-bin positions.

  With `summate = false` each block is divided by its total mass
  (`duration`), giving the duration-averaged response rather than the
  accumulated one.
──────────────────────────────────────────────────────────────────────*/
static arma::vec buildImpulseTrain(const arma::vec& on,
                                   const arma::vec& dur,
                                   const arma::vec& amp,
                                   double t0, double t1,
                                   double dt,
                                   bool summate)
{
    if (dt <= 0.0) Rcpp::stop("dt must be > 0 in buildImpulseTrain");

    const uword nBins = (uword) std::floor((t1 - t0) / dt) + 1;
    arma::vec diff(nBins + 2, arma::fill::zeros);      // 2 guard slots
    const double maxPos = (double) (nBins - 1);

    for (uword i = 0; i < on.n_elem; ++i) {
        const double d = dur[i];
        double pos_s = (on[i] - t0) / dt;
        if (pos_s > maxPos) continue;                  // starts past the window

        if (!(d > 0.0)) {
            // Impulse of unit mass, split linearly across the two bracketing
            // bins. Snapping it to the nearest bin instead cost up to dt/2 of
            // onset error, which at the default precision of 0.33 s was ~12%
            // of peak for an onset that fell between bins.
            if (pos_s < 0.0) pos_s = 0.0;
            const uword a = (uword) std::floor(pos_s);
            const double f = pos_s - (double) a;
            const double w0 = amp[i] * (1.0 - f);
            const double w1 = amp[i] * f;
            diff[a]     += w0;  diff[a + 1] -= w0;
            diff[a + 1] += w1;  diff[a + 2] -= w1;
            continue;
        }

        const double pos_e = (on[i] + d - t0) / dt;
        if (pos_e <= 0.0) continue;                    // ends before the window

        // Block weights are the difference of the two running hat integrals,
        // so the block carries mass amp * duration for any sub-bin alignment.
        const double c = amp[i] * (summate ? 1.0 : 1.0 / d);
        addHatStep(diff, pos_e,  c, dt, nBins);
        addHatStep(diff, pos_s, -c, dt, nBins);
    }
    // head(nBins) drops the guard slots.
    return arma::cumsum(diff.head(nBins));
}

/*──────────────────────────────────────────────────────────────────────
  Regressor evaluation: the neural input on a fine grid of step
  `precision`, convolved with each sampled HRF basis column and linearly
  interpolated onto `grid`.

  The fine grid starts one HRF span before the first grid point, so events
  preceding the grid still contribute, and runs one span past the end of
  the last block so its tail fits.

  Only the convolution samples that bracket a grid point are computed. The
  fine grid is usually several times denser than the scan grid, so a full
  convolution spent most of its time on samples that were never read.
──────────────────────────────────────────────────────────────────────*/
// [[Rcpp::export]]
Rcpp::NumericMatrix evaluate_regressor_cpp(const arma::vec& grid,
                                           const arma::vec& onsets,
                                           const arma::vec& durations,
                                           const arma::vec& amplitudes,
                                           const arma::mat& hrf_matrix,
                                           double hrf_span,
                                           double precision,
                                           std::string method = "conv",
                                           bool summate = true) {
    // The generated Rcpp export wrapper translates exceptions after C++
    // stack unwinding; do not longjmp through live C++ objects here.
    if (method != "conv") {
        Rcpp::stop("Invalid method for evaluate_regressor_cpp; only 'conv' is supported.");
    }
    if (hrf_matrix.n_rows == 0) {
        Rcpp::stop("hrf_matrix must have at least one row.");
    }
    const double start = grid.min() - hrf_span;
    const double max_dur = (durations.n_elem > 0) ? durations.max() : 0.0;
    const double last_onset = (onsets.n_elem > 0) ? onsets.max() : grid.max();
    const double end = std::max(grid.max(), last_onset + max_dur) + hrf_span;

    const arma::vec neural = buildImpulseTrain(onsets, durations, amplitudes,
                                               start, end, precision, summate);
    const uword nfine = neural.n_elem;
    const uword ntaps = hrf_matrix.n_rows;
    const uword ngrid = grid.n_elem;
    const uword nbasis = hrf_matrix.n_cols;

    // Fine-grid samples bracketing each grid point (lo == hi past either end
    // of the fine grid, which then contributes its end value).
    const double fine_last = start + (double) (nfine - 1) * precision;
    std::vector<uword> lo(ngrid), hi(ngrid);
    std::vector<double> alpha(ngrid, 0.0);
    for (uword i = 0; i < ngrid; ++i) {
        const double t = grid[i];
        if (t <= start) {
            lo[i] = hi[i] = 0;
        } else if (t >= fine_last) {
            lo[i] = hi[i] = nfine - 1;
        } else {
            uword idx = (uword) ((t - start) / precision);
            if (idx >= nfine - 1) idx = nfine - 2;
            const double t1 = start + (double) idx * precision;
            const double t2 = start + (double) (idx + 1) * precision;
            lo[i] = idx;
            hi[i] = idx + 1;
            alpha[i] = (t - t1) / (t2 - t1);
        }
    }

    Rcpp::NumericMatrix out(ngrid, nbasis);
    std::vector<double> conv(nfine);
    std::vector<char> have(nfine);
    for (uword b = 0; b < nbasis; ++b) {
        const double* h = hrf_matrix.colptr(b);
        std::fill(have.begin(), have.end(), 0);
        // (neural * h)[n], summed from the longest lag down as arma::conv() did.
        auto conv_at = [&](uword n) {
            if (!have[n]) {
                double s = 0.0;
                for (uword k = std::min(n, ntaps - 1) + 1; k-- > 0; ) {
                    s += h[k] * neural[n - k];
                }
                conv[n] = s;
                have[n] = 1;
            }
            return conv[n];
        };
        for (uword i = 0; i < ngrid; ++i) {
            const double y1 = conv_at(lo[i]);
            out(i, b) = (hi[i] == lo[i]) ? y1 : y1 + alpha[i] * (conv_at(hi[i]) - y1);
        }
    }
    return out;
}
