
#' Evaluate a regressor object over a time grid
#' 
#' Generic function to evaluate a regressor object over a specified time grid.
#' Different types of regressors may have different evaluation methods.
#'
#' @param x The regressor object to evaluate
#' @param grid A numeric vector specifying the time points at which to evaluate the regressor
#' @param ... Additional arguments passed to specific methods
#' @return A numeric vector or matrix containing the evaluated regressor values
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
#' # Create sampling frame
#' sframe <- sampling_frame(blocklens = 50, TR = 2)
#' 
#' # Create regressor from events
#' reg <- regressor(
#'   onsets = event_data$onsets,
#'   sampling_frame = sframe
#' )
#' 
#' # Shift regressor forward by 2 seconds
#' reg_forward <- shift(reg, offset = 2)
#' 
#' # Shift regressor backward by 1 second
#' reg_backward <- shift(reg, offset = -1)
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
#' @export
hrf_from_coefficients <- function(hrf, h, ...) UseMethod("hrf_from_coefficients")




#' Number of basis functions
#' 
#' @description
#' Get the number of basis functions for an HRF object. This is useful for:
#' \itemize{
#'   \item Understanding the complexity of an HRF model
#'   \item Creating penalty matrices for regularization
nbasis <- function(x, ...) UseMethod("nbasis")


#' Generate penalty matrix for regularization
#'
#' @description
#' Generate a penalty matrix for regularizing HRF basis coefficients. The penalty matrix
#' encodes shape priors that discourage implausible or overly wiggly HRF estimates.
#' Different HRF types use different penalty structures:
#' 
#' \itemize{
#'   \item{FIR/B-spline bases: Roughness penalties based on discrete derivatives}
#'   \item{SPM canonical + derivatives: Differential shrinkage of derivative terms}
#'   \item{Fourier bases: Penalties on high-frequency components}
#'   \item{Default: Identity matrix (ridge penalty)}
#' }
#'
#' @param x The HRF object or basis specification
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
#' @param hrf An object of class `HRF`.
#' @param h   Numeric vector of length `nbasis(hrf)` giving the weights.
#' @param name Optional name for the resulting HRF.
#' @param ... Additional arguments passed to methods.
#'
#' @return A new `HRF` object with `nbasis = 1`.
#' @export
hrf_from_coefficients <- function(hrf, h, ...) { UseMethod("hrf_from_coefficients") }


#' Reconstruction matrix for an HRF basis
#'
#' Returns a matrix \eqn{\Phi} that converts basis coefficients into a
#' sampled HRF shape.
#'
#' @param hrf An object of class `HRF`.
#' @param sframe A `sampling_frame` object or numeric vector of times.
#' @param precision Optional sampling interval in seconds when `sframe`
#'   is a `sampling_frame`. Defaults to the TR of `sframe`.
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




amplitudes <- function(x) UseMethod("amplitudes")



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
#' @param ... Additional arguments passed to methods. Common arguments include:
#' \describe{
#'     \item{start}{Numeric; start time of the input function}
#'     \item{end}{Numeric; end time of the input function} 
#'     \item{resolution}{Numeric; temporal resolution in seconds (default: 0.33)}
#' }
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

