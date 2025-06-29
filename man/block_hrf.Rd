% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/hrf_decorators.R
\name{block_hrf}
\alias{block_hrf}
\title{Create a Blocked HRF Object}
\usage{
block_hrf(
  hrf,
  width,
  precision = 0.1,
  half_life = Inf,
  summate = TRUE,
  normalize = FALSE
)
}
\arguments{
\item{hrf}{The HRF object (of class `HRF`) to block.}

\item{width}{The width of the block in seconds.}

\item{precision}{The sampling precision in seconds used for the internal convolution (default: 0.1).}

\item{half_life}{The half-life of an optional exponential decay applied during the block (default: Inf, meaning no decay).}

\item{summate}{Logical; if TRUE (default), the responses from each time point within the block are summed. If FALSE, the maximum response at each time point is taken.}

\item{normalize}{Logical; if TRUE, the resulting blocked HRF is scaled so that its peak value is 1 (default: FALSE).}
}
\value{
A new HRF object representing the blocked function.
}
\description{
Creates a new HRF object representing a response to a sustained (blocked)
stimulus by convolving the input HRF with a boxcar function of a given width.
}
\examples{
blocked_spmg1 <- block_hrf(HRF_SPMG1, width = 5)
t_vals <- seq(0, 30, by = 0.5)
plot(t_vals, HRF_SPMG1(t_vals), type = 'l', col = "blue", ylab = "Response", xlab = "Time")
lines(t_vals, blocked_spmg1(t_vals), col = "red")
legend("topright", legend = c("Original", "Blocked (width=5)"), col = c("blue", "red"), lty = 1)
}
\seealso{
Other HRF_decorator_functions: 
\code{\link{lag_hrf}()},
\code{\link{normalise_hrf}()}
}
\concept{HRF_decorator_functions}
