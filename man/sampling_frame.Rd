% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sampling_frame.R
\name{sampling_frame}
\alias{sampling_frame}
\title{A \code{sampling_frame} describes the block structure and temporal sampling of an fMRI paradigm.}
\usage{
sampling_frame(blocklens, TR, start_time = TR/2, precision = 0.1)
}
\arguments{
\item{blocklens}{A numeric vector representing the number of scans in each block.}

\item{TR}{A numeric value or vector representing the repetition time in seconds
(i.e., the spacing between consecutive image acquisitions). When a vector is
provided, its length must be 1 or equal to the number of blocks.}

\item{start_time}{A numeric value or vector representing the offset of the first
scan of each block (default is \code{TR/2}). When a vector is provided, its
length must be 1 or equal to the number of blocks.}

\item{precision}{A numeric value representing the discrete sampling interval used for convolution with the hemodynamic response function (default is 0.1).}
}
\value{
A list with class "sampling_frame" describing the block structure and temporal sampling of an fMRI paradigm.
}
\description{
A \code{sampling_frame} describes the block structure and temporal sampling of an fMRI paradigm.
}
\examples{
frame <- sampling_frame(blocklens = c(100, 100, 100), TR = 2, precision = 0.5)

# The relative time (with respect to the last block) in seconds of each sample/acquisition
sam <- samples(frame)
# The global time (with respect to the first block) of each sample/acquisition
gsam <- samples(frame, global = TRUE)

# Block identifiers for each acquisition can be retrieved using
# blockids(frame)

}
