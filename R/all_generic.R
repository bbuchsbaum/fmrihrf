
#' Evaluate a regressor object over a time grid
#' 
#' Generic function to evaluate a regressor object over a specified time grid.
#' Different types of regressors may have different evaluation methods.
#'
#' @param x The regressor object to evaluate
#' @param grid A numeric vector specifying the time points at which to evaluate the regressor
#' @param ... Additional arguments passed to specific methods
#' @return A numeric vector or matrix containing the evaluated regressor values
#' @examples
#' # Create a regressor
#' reg <- regressor(onsets = c(10, 30, 50), hrf = HRF_SPMG1)
#' 
#' # Evaluate at specific time points
#' times <- seq(0, 80, by = 0.1)
#' response <- evaluate(reg, times)
#' 
#' # Plot the response
#' plot(times, response, type = "l", xlab = "Time (s)", ylab = "Response")
#' @seealso [single_trial_regressor()], [regressor()]
#' @export
evaluate <- function(x, grid, ...) {
  UseMethod("evaluate")
}



#' Shift a time series object
#'
#' @description
#' Apply a temporal shift to a time series object. This function shifts the values in time 
#' while preserving the structure of the object. Common uses include:
#' \describe{
#'   \item{alignment}{Aligning regressors with different temporal offsets}
#'   \item{derivatives}{Applying temporal derivatives to time series}
#'   \item{correction}{Correcting for timing differences between signals}
#' }
#'
#' @param x An object representing a time series or a time-based data structure
#' @param shift_amount Numeric; amount to shift by (positive = forward, negative = backward)
#' @param ... Additional arguments passed to methods
#' @return An object of the same class as the input, with values shifted in time:
#'   \describe{
#'     \item{Values}{Values are moved by the specified offset}
#'     \item{Structure}{Object structure and dimensions are preserved}
#'     \item{Padding}{Empty regions are filled with padding value}
#'   }
#' @examples
#' # Create a simple time series with events
#' event_data <- data.frame(
#'   onsets = c(1, 10, 20, 30),
#'   run = c(1, 1, 1, 1)
#' )
#' 
#' # Create regressor from events
#' reg <- regressor(
#'   onsets = event_data$onsets,
#'   hrf = HRF_SPMG1,
#'   duration = 0,
#'   amplitude = 1
#' )
#' 
#' # Shift regressor forward by 2 seconds
#' reg_forward <- shift(reg, shift_amount = 2)
#' 
#' # Shift regressor backward by 1 second
#' reg_backward <- shift(reg, shift_amount = -1)
#' 
#' # Evaluate original and shifted regressors
#' times <- seq(0, 50, by = 2)
#' orig_values <- evaluate(reg, times)
#' shifted_values <- evaluate(reg_forward, times)
#' @export
#' @family time_series
#' @seealso [regressor()], [evaluate()]
shift <- function(x, ...) {
  UseMethod("shift")
}



#' Combine HRF Basis with Coefficients
#'
#' Create a new HRF by linearly weighting the basis functions of an existing HRF.
#' Useful when coefficients have been estimated for an FIR/bspline/SPMG3 basis
#' and one wants a single functional HRF.
#'
#' @param hrf  An object of class `HRF`.
#' @param h    Numeric vector of length `nbasis(hrf)` giving the weights.
#' @param name Optional name for the resulting HRF.
#' @param ...  Reserved for future extensions.
#'
#' @return A new `HRF` object with `nbasis = 1`.
#' @examples
#' # Create a custom HRF from SPMG3 basis coefficients
#' coeffs <- c(1, 0.2, -0.1)  # Main response + slight temporal shift - dispersion
#' custom_hrf <- hrf_from_coefficients(HRF_SPMG3, coeffs)
#' 
#' # Evaluate the custom HRF
#' t <- seq(0, 20, by = 0.1)
#' response <- evaluate(custom_hrf, t)
#' 
#' # Create from FIR basis
#' fir_coeffs <- c(0, 0.2, 0.5, 1, 0.8, 0.4, 0.1, 0, 0, 0, 0, 0)
#' custom_fir <- hrf_from_coefficients(HRF_FIR, fir_coeffs)
#' @export
hrf_from_coefficients <- function(hrf, h, ...) UseMethod("hrf_from_coefficients")




#' Number of basis functions
#'
#' Return the number of basis functions represented by an object.
#'
#' This information is typically used when constructing penalty matrices
#' or understanding the complexity of an HRF model or regressor.
#'
#' @param x Object containing HRF or regressor information.
#' @param ... Additional arguments passed to methods.
#' @return Integer scalar giving the number of basis functions.
#' @examples
#' # Number of basis functions for different HRF types
#' nbasis(HRF_SPMG1)   # 1 basis function
#' nbasis(HRF_SPMG3)   # 3 basis functions (canonical + 2 derivatives)
#' nbasis(HRF_BSPLINE) # 5 basis functions (default)
#' 
#' # For a regressor
#' reg <- regressor(onsets = c(10, 30, 50), hrf = HRF_SPMG3)
#' nbasis(reg)  # 3 (inherits from the HRF)
#' @export
nbasis <- function(x, ...) UseMethod("nbasis")


#' Generate penalty matrix for regularization
#'
#' @description
#' Generate a penalty matrix for regularizing HRF basis coefficients. The penalty matrix
#' encodes shape priors that discourage implausible or overly wiggly HRF estimates.
#' Different HRF types use different penalty structures:
#' 
#' \itemize{
#'   \item{FIR/B-spline/Tent bases: Roughness penalties based on discrete derivatives}
#'   \item{SPM canonical + derivatives: Differential shrinkage of derivative terms}
#'   \item{Fourier bases: Penalties on high-frequency components}
#'   \item{Daguerre bases: Increasing weights on higher-order terms}
#'   \item{Default: Identity matrix (ridge penalty)}
#' }
#'
#' @param x The HRF object or basis specification
#' @param order Integer specifying the order of the penalty (default: 2)
#' @param ... Additional arguments passed to specific methods
#' @return A symmetric positive definite penalty matrix of dimension nbasis(x) × nbasis(x)
#' @details
#' The penalty matrix R is used in regularized estimation as λ * h^T R h, where h are
#' the basis coefficients and λ is the regularization parameter. Well-designed penalty
#' matrices can significantly improve HRF estimation by encoding smoothness or other
#' shape constraints.
#' 
#' @examples
#' # FIR basis with smoothness penalty
#' fir_hrf <- HRF_FIR
#' R_fir <- penalty_matrix(fir_hrf)
#' 
#' # B-spline basis with second-order smoothness
#' bspline_hrf <- HRF_BSPLINE  
#' R_bspline <- penalty_matrix(bspline_hrf, order = 2)
#' 
#' # SPM canonical with derivative shrinkage
#' spmg3_hrf <- HRF_SPMG3
#' R_spmg3 <- penalty_matrix(spmg3_hrf, shrink_deriv = 4)
#' 
#' @export
#' @family hrf
#' @seealso [nbasis()], [HRF_objects]
penalty_matrix <- function(x, ...) UseMethod("penalty_matrix")


#' Combine HRF Basis with Coefficients
#'
#' Create a new HRF by linearly weighting the basis functions of an existing HRF.
#' This is useful for turning estimated basis coefficients into a single
#' functional HRF.
#'


#' Reconstruction matrix for an HRF basis
#'
#' Returns a matrix \eqn{\Phi} that converts basis coefficients into a
#' sampled HRF shape.
#'
#' @param hrf An object of class `HRF`.
#' @param sframe A `sampling_frame` object or numeric vector of times.
#' @param ... Additional arguments passed to methods
#' @return A numeric matrix with one column per basis function.
#' @export
reconstruction_matrix <- function(hrf, sframe, ...) { UseMethod("reconstruction_matrix") }



#' Get durations of an object
#' 
#' @param x The object to get durations from
#' @param ... Additional arguments passed to methods
#' @return A numeric vector of durations
#' @export
durations <- function(x, ...) UseMethod("durations")

#' Get amplitudes from an object
#'
#' Generic accessor returning event amplitudes or scaling factors.
#'
#' @param x Object containing amplitude information
#' @param ... Additional arguments passed to methods
#' @return Numeric vector of amplitudes
#' @export
amplitudes <- function(x, ...) UseMethod("amplitudes")

#' Get event onsets from an object
#'
#' Generic accessor returning event onset times in seconds.
#'
#' @param x Object containing onset information
#' @param ... Additional arguments passed to methods
#' @return Numeric vector of onsets
#' @export
onsets <- function(x, ...) UseMethod("onsets")

#' Get sample acquisition times
#'
#' Generic function retrieving sampling times from a sampling frame or
#' related object.
#'
#' @param x Object describing the sampling grid
#' @param blockids Integer vector of block identifiers to include (default: all blocks)
#' @param global Logical indicating whether to return global times (default: FALSE)
#' @param ... Additional arguments passed to methods
#' @return Numeric vector of sample times
#' @export
samples <- function(x, ...) UseMethod("samples")

#' Convert onsets to global timing
#'
#' Generic accessor for converting block-wise onsets to global onsets.
#'
#' @param x Object describing the sampling frame
#' @param onsets Numeric vector of onset times within blocks
#' @param ... Additional arguments passed to methods
#' @return Numeric vector of global onset times
#' @export
global_onsets <- function(x, ...) UseMethod("global_onsets")

#' Get block identifiers
#'
#' Generic accessor returning block indices for each sample or onset.
#'
#' @param x Object containing block structure
#' @param ... Additional arguments passed to methods
#' @return Integer vector of block ids
#' @export
blockids <- function(x, ...) UseMethod("blockids")

#' Get block lengths
#'
#' Generic accessor returning the number of scans in each block of a
#' sampling frame or similar object.
#'
#' @param x Object containing block length information
#' @param ... Additional arguments passed to methods
#' @return Numeric vector of block lengths
#' @export
blocklens <- function(x, ...) UseMethod("blocklens")






#' Generate Neural Input Function from Event Timing
#'
#' Converts event timing information into a neural input function representing the underlying
#' neural activity before HRF convolution. This function is useful for:
#' 
#' \describe{
#'   \item{stimulus}{Creating stimulus functions for fMRI analysis}
#'   \item{modeling}{Modeling sustained vs. transient neural activity}
#'   \item{inputs}{Generating inputs for HRF convolution}
#'   \item{visualization}{Visualizing the temporal structure of experimental designs}
#' }
#'
#' @param x A regressor object containing event timing information
#' @param start Numeric; start time of the input function
#' @param end Numeric; end time of the input function
#' @param resolution Numeric; temporal resolution in seconds (default: 0.33)
#' @param ... Additional arguments passed to methods
#'
#' @return A list containing:
#' \describe{
#'     \item{time}{Numeric vector of time points}
#'     \item{neural_input}{Numeric vector of input amplitudes at each time point}
#' }
#'
#' @examples
#' # Create a regressor with multiple events
#' reg <- regressor(
#'   onsets = c(10, 30, 50),
#'   duration = c(2, 2, 2),
#'   amplitude = c(1, 1.5, 0.8),
#'   hrf = HRF_SPMG1
#' )
#' 
#' # Generate neural input function
#' input <- neural_input(reg, start = 0, end = 60, resolution = 0.5)
#' 
#' # Plot the neural input function
#' plot(input$time, input$neural_input, type = "l",
#'      xlab = "Time (s)", ylab = "Neural Input",
#'      main = "Neural Input Function")
#' 
#' # Create regressor with varying durations
#' reg_sustained <- regressor(
#'   onsets = c(10, 30),
#'   duration = c(5, 10),  # sustained activity
#'   amplitude = c(1, 1),
#'   hrf = HRF_SPMG1
#' )
#' 
#' # Generate and compare neural inputs
#' input_sustained <- neural_input(
#'   reg_sustained,
#'   start = 0,
#'   end = 60,
#'   resolution = 0.5
#' )
#'
#' @family regressor_functions
#' @seealso 
#' \code{\link{regressor}}, \code{\link{evaluate.Reg}}, \code{\link{HRF_SPMG1}}
#' @export
neural_input <- function(x, ...) UseMethod("neural_input")

