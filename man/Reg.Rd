% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/reg-constructor.R
\name{Reg}
\alias{Reg}
\title{Internal Constructor for Regressor Objects}
\usage{
Reg(
  onsets,
  hrf = HRF_SPMG1,
  duration = 0,
  amplitude = 1,
  span = 40,
  summate = TRUE
)
}
\value{
An S3 object of class `Reg` (and `list`) with components:
  * `onsets`: Numeric vector of event onset times (seconds).
  * `hrf`: An object of class `HRF` used for convolution.
  * `duration`: Numeric vector of event durations (seconds).
  * `amplitude`: Numeric vector of event amplitudes/scaling factors.
  * `span`: Numeric scalar indicating the HRF span (seconds).
  * `summate`: Logical indicating if overlapping HRF responses should summate.
  * `filtered_all`: Logical attribute set to `TRUE` when all events were
    removed due to zero or `NA` amplitudes.
}
\description{
Internal Constructor for Regressor Objects
}
\keyword{internal}
