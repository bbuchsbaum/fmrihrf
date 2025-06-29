% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/hrf.R
\name{hrf_fir_generator}
\alias{hrf_fir_generator}
\title{Create FIR HRF Basis Set}
\usage{
hrf_fir_generator(nbasis = 12, span = 24)
}
\arguments{
\item{nbasis}{Number of time bins (default: 12)}

\item{span}{Temporal window in seconds (default: 24)}
}
\value{
An HRF object of class \code{c("FIR_HRF", "HRF", "function")}
}
\description{
Generates an HRF object using Finite Impulse Response (FIR) basis functions
with custom parameters. Each basis function represents a time bin with a
value of 1 in that bin and 0 elsewhere.
}
\details{
The FIR basis divides the time window into \code{nbasis} equal bins.
Each basis function is an indicator function for its corresponding bin.
This provides maximum flexibility but requires more parameters than
smoother basis sets like B-splines.
}
\examples{
# Create FIR basis with 20 bins over 30 seconds
custom_fir <- hrf_fir_generator(nbasis = 20, span = 30)
t <- seq(0, 30, by = 0.1)
response <- evaluate(custom_fir, t)
matplot(t, response, type = "l", main = "FIR HRF with 20 time bins")

# Compare to default FIR with 12 bins
default_fir <- HRF_FIR
response_default <- evaluate(default_fir, t[1:241])  # 24 seconds
matplot(t[1:241], response_default, type = "l", 
        main = "Default FIR HRF (12 bins over 24s)")
}
\seealso{
\code{\link{HRF_objects}} for pre-defined HRF objects,
  \code{\link{getHRF}} for a unified interface to create HRFs,
  \code{\link{hrf_bspline_generator}} for a smoother alternative
}
