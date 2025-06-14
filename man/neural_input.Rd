% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/all_generic.R, R/neural_input_methods.R
\name{neural_input}
\alias{neural_input}
\alias{neural_input.Reg}
\title{Generate Neural Input Function from Event Timing}
\usage{
neural_input(x, ...)

\method{neural_input}{Reg}(x, start = 0, end = NULL, resolution = 0.33, ...)
}
\arguments{
\item{x}{A regressor object containing event timing information}

\item{...}{Additional arguments passed to methods}

\item{start}{Numeric; start time of the input function}

\item{end}{Numeric; end time of the input function}

\item{resolution}{Numeric; temporal resolution in seconds (default: 0.33)}
}
\value{
A list containing:
\describe{
    \item{time}{Numeric vector of time points}
    \item{neural_input}{Numeric vector of input amplitudes at each time point}
}
}
\description{
Converts event timing information into a neural input function representing the underlying
neural activity before HRF convolution. This function is useful for:
}
\details{
\describe{
  \item{stimulus}{Creating stimulus functions for fMRI analysis}
  \item{modeling}{Modeling sustained vs. transient neural activity}
  \item{inputs}{Generating inputs for HRF convolution}
  \item{visualization}{Visualizing the temporal structure of experimental designs}
}
}
\examples{
# Create a regressor with multiple events
reg <- regressor(
  onsets = c(10, 30, 50),
  duration = c(2, 2, 2),
  amplitude = c(1, 1.5, 0.8),
  hrf = HRF_SPMG1
)

# Generate neural input function
input <- neural_input(reg, start = 0, end = 60, resolution = 0.5)

# Plot the neural input function
plot(input$time, input$neural_input, type = "l",
     xlab = "Time (s)", ylab = "Neural Input",
     main = "Neural Input Function")

# Create regressor with varying durations
reg_sustained <- regressor(
  onsets = c(10, 30),
  duration = c(5, 10),  # sustained activity
  amplitude = c(1, 1),
  hrf = HRF_SPMG1
)

# Generate and compare neural inputs
input_sustained <- neural_input(
  reg_sustained,
  start = 0,
  end = 60,
  resolution = 0.5
)

}
\seealso{
\code{\link{regressor}}, \code{\link{evaluate.Reg}}, \code{\link{HRF_SPMG1}}
}
\concept{regressor_functions}
