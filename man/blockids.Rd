% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/all_generic.R, R/sampling_frame.R
\name{blockids}
\alias{blockids}
\alias{blockids.sampling_frame}
\title{Get block identifiers}
\usage{
blockids(x, ...)

\method{blockids}{sampling_frame}(x, ...)
}
\arguments{
\item{x}{Object containing block structure}

\item{...}{Additional arguments passed to methods}
}
\value{
Integer vector of block ids
}
\description{
Generic accessor returning block indices for each sample or onset.
}
