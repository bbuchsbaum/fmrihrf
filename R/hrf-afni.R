#' @importFrom assertthat assert_that
#' @importFrom rlang enexpr
NULL

#' AFNI HRF Constructor Function
#'
#' @description
#' The `AFNI_HRF` function creates an object representing an AFNI-specific hemodynamic response function (HRF). It is a class constructor for AFNI HRFs.
#'
#' @param name A string specifying the name of the AFNI HRF.
#' @param nbasis An integer representing the number of basis functions for the AFNI HRF.
#' @param params A list containing the parameter values for the AFNI HRF.
#' @param span A numeric value representing the span in seconds of the HRF. Default is 24.
#'
#' @return An AFNI_HRF object with the specified properties.
#'
#' @seealso HRF
#'
#' @export
#' @rdname AFNI_HRF-class
AFNI_HRF <- function(name, nbasis, params, span = 24) {
  structure(name,
            nbasis = as.integer(nbasis),
            params = params,
            span = span,
            class = c("AFNI_HRF", "HRF"))
  
}


#' @export
as.character.AFNI_HRF <- function(x,...) {
  paste(x, "\\(", paste(attr(x, "params"), collapse=","), "\\)", sep="")
}

#' construct an native AFNI hrf specification for '3dDeconvolve' with the 'stim_times' argument.
#' 
#' @param ... Variables to include in the HRF specification
#' @param basis Character string specifying the basis function type
#' @param onsets Numeric vector of event onset times
#' @param durations Numeric vector of event durations
#' @param prefix Character string prefix for the term
#' @param subset Expression for subsetting events
#' @param nbasis Number of basis functions
#' @param contrasts Contrast specifications
#' @param id Character string identifier for the term
#' @param lag Numeric lag in seconds
#' @param precision Numeric precision for convolution
#' @param summate Logical whether to summate overlapping responses
#' @param start the start of the window for sin/poly/csplin models
#' @param stop the stop time for sin/poly/csplin models
#' @export
#' @return an \code{afni_hrfspec} instance
afni_hrf <- function(..., basis=c("spmg1", "block", "dmblock",
                                  "tent",   "csplin", "poly",  "sin", "sine",
                                  "gam", "gamma", "spmg2", "spmg3", "wav"),
                                  onsets=NULL, durations=NULL, prefix=NULL, subset=NULL,
                                  nbasis=1, contrasts=NULL, id=NULL,
                                  lag=0, precision = 0.3, summate = TRUE,
                                  start=NULL, stop=NULL) {
  
  ## TODO cryptic error message when argument is mispelled and is then added to ...
  basis <- tolower(basis)
  if (basis == "sin") basis <- "sine"
  if (basis == "gam") basis <- "gamma"
  basis <- match.arg(basis)
  
  vars <- as.list(base::substitute(list(...)))[-1]
  # Convert raw expressions to quosures for compatibility with construct_event_term
  vars_quos <- lapply(vars, function(expr) rlang::new_quosure(expr, env = rlang::caller_env()))
  # Requires parse_term (assuming it exists elsewhere now or is removed)
  # parsed <- parse_term(vars, "afni_hrf") 
  # term <- parsed$term
  # label <- parsed$label
  # --- Need to replace parse_term dependency --- 
  # Simplified naming based on input expressions/symbols for now
  var_labels <- sapply(vars, rlang::as_label)
  varnames <- sapply(vars, function(v) {
       if (rlang::is_symbol(v)) as.character(v) else make.names(rlang::as_label(v))
  })
  term <- vars_quos # Store quosures instead of raw expressions
  label <- paste0("afni_hrf(", paste0(var_labels, collapse=","), ")")
  # --- End replacement --- 
  
  hrf <- if (!is.null(durations)) {
    assert_that(length(durations) == 1, msg="afni_hrf does not currently accept variable durations")
    get_AFNI_HRF(basis, nbasis=nbasis, duration=durations[1], b=start, c=stop)
  } else {
    get_AFNI_HRF(basis, nbasis=nbasis, b=start, c=stop)
  }
  
  
  # varnames <- if (!is.null(prefix)) {
  #   paste0(prefix, "_", term)
  # } else {
  #   term
  # } 
  # Use the new varnames logic
  if (!is.null(prefix)) {
      varnames <- paste0(prefix, "_", varnames)
  }
  
  termname <- paste0(varnames, collapse="::")
  
  if (is.null(id)) {
    id <- termname
  }  
  
  # contrast_set function not yet implemented
  cset <- NULL
  # cset <- if (inherits(contrasts, "contrast_spec")) {
  #   contrast_set(con1=contrasts)
  # } else if (inherits(contrasts, "contrast_set")) {
  #   contrasts
  # } else { NULL } # Default to NULL if not correct type
  
  ret <- list(
    name=termname,
    id=id,
    varnames=varnames,
    vars=term, # Store original expressions/symbols
    label=label,
    hrf=hrf,
    onsets=onsets,
    durations=durations,
    prefix=prefix,
    subset=rlang::enexpr(subset), # Capture subset expression
    lag=lag,
    precision = precision,
    summate = summate,
    contrasts=cset)
  
  class(ret) <- c("afni_hrfspec", "hrfspec", "list")
  ret
  
}

#' construct a native AFNI hrf specification for '3dDeconvolve' and individually modulated events using the 'stim_times_IM' argument.
#' 
#' @param label name of regressor
#' @param basis Character string specifying the basis function type
#' @param onsets Numeric vector of event onset times
#' @param durations Numeric vector of event durations (default 0)
#' @param subset Expression for subsetting events
#' @param id Character string identifier for the term
#' @param precision Numeric precision for convolution (default 0.3)
#' @param summate Logical whether to summate overlapping responses (default TRUE)
#' @param start start of hrf (for multiple basis hrfs)
#' @param stop end of hrf (for multiple basis hrfs)
#' 
#' @examples
#' 
#' tw <- afni_trialwise("trialwise", basis="gamma", onsets=seq(1,100,by=5))
#' 
#' @export
#' @return an \code{afni_trialwise_hrfspec} instance
afni_trialwise <- function(label, basis=c("spmg1", "block", "dmblock", "gamma", "wav"),
                     onsets=NULL, durations=0, subset=NULL,
                      id=NULL, start=0, stop=22,
                      precision = 0.3, summate = TRUE) {
  
  ## TODO cryptic error message when argument is mispelled and is then added to ...
  basis <- match.arg(basis)
  basis <- tolower(basis)
  if (basis == "gam") basis <- "gamma"
  
  hrf <- if (!is.null(durations)) {
    assert_that(length(durations) == 1, msg="afni_trialwise does not currently accept variable durations")
    get_AFNI_HRF(basis, nbasis=1, duration=durations[1], b=start, c=stop)
  } else {
    get_AFNI_HRF(basis, nbasis=1, b=start, c=stop)
  }
  
  
  if (is.null(id)) {
    id <- label
  }  
  
  ret <- list(
    name=label,
    varname=label,
    id=id,
    hrf=hrf,
    onsets=onsets,
    durations=durations,
    subset=rlang::enexpr(subset),
    precision = precision,
    summate = summate)
  
  class(ret) <- c("afni_trialwise_hrfspec", "hrfspec", "list")
  ret
  
}

#' Construct AFNI HRF specification
#' 
#' Internal method for constructing AFNI HRF specifications.
#' 
#' @param x An afni_hrfspec object
#' @param model_spec Model specification
#' @param ... Additional arguments
#' @keywords internal
#' @export
construct.afni_hrfspec <- function(x, model_spec, ...) {
  # This function requires construct_event_term which is not yet implemented
  stop("construct_event_term is not yet implemented")
}


#' Construct AFNI trialwise HRF specification
#' 
#' Internal method for constructing AFNI trialwise HRF specifications.
#' 
#' @param x An afni_trialwise_hrfspec object
#' @param model_spec Model specification
#' @param ... Additional arguments
#' @keywords internal
#' @export
construct.afni_trialwise_hrfspec <- function(x, model_spec, ...) {
  # This function requires event_term and other event modeling functions
  # which are not yet implemented
  stop("construct.afni_trialwise_hrfspec requires event modeling functions that are not yet implemented")
}


#' @keywords internal
#' @noRd
AFNI_SPMG1 <- function(d=1) AFNI_HRF(name="SPMG1", nbasis=as.integer(1), params=list(d=d)) 

#' @keywords internal
#' @noRd
AFNI_SPMG2 <- function(d=1) AFNI_HRF(name="SPMG2", nbasis=as.integer(2), params=list(d=d))

#' @keywords internal
#' @noRd
AFNI_SPMG3 <- function(d=1) AFNI_HRF(name="SPMG3", nbasis=as.integer(3), params=list(d=d))

#' @keywords internal
#' @noRd
AFNI_BLOCK <- function(d=1,p=1) AFNI_HRF(name="BLOCK", nbasis=as.integer(1), params=list(d=d,p=p))

#' @keywords internal
#' @noRd
AFNI_dmBLOCK <- function(d=1,p=1) AFNI_HRF(name="dmBLOCK", nbasis=as.integer(1), params=list(d=d,p=p))

#' @keywords internal
#' @noRd
AFNI_TENT <- function(b=0,c=18, n=10) AFNI_HRF(name="TENT", nbasis=as.integer(n), params=list(b=b,c=c,n=n))

#' @keywords internal
#' @noRd
AFNI_CSPLIN <- function(b=0,c=18, n=6) AFNI_HRF(name="CSPLIN", nbasis=as.integer(n), params=list(b=b,c=c,n=n))

#' @keywords internal
#' @noRd
AFNI_POLY <- function(b=0,c=18, n=10) AFNI_HRF(name="POLY", nbasis=as.integer(n), params=list(b=b,c=c,n=n))

#' @keywords internal
#' @noRd
AFNI_SIN <- function(b=0,c=18, n=10) AFNI_HRF(name="SIN", nbasis=as.integer(n), params=list(b=b,c=c,n=n))

#' @keywords internal
#' @noRd
AFNI_GAM <- function(p=8.6,q=.547) AFNI_HRF(name="GAM", nbasis=as.integer(1), params=list(p=p,q=q))

#' @keywords internal
#' @noRd
AFNI_WAV <- function(d=1) AFNI_HRF(name="WAV", nbasis=as.integer(1), params=list(d=1))


#' @keywords internal
#' @noRd
get_AFNI_HRF <- function(name, nbasis=1, duration=1, b=0, c=18) {
  name <- tolower(name)
  if (name == "sin") name <- "sine"
  if (name == "gam") name <- "gamma"
  hrf <- switch(name,
                gamma=AFNI_GAM(),
                spmg1=AFNI_SPMG1(d=duration),
                spmg2=AFNI_SPMG2(d=duration),
                spmg3=AFNI_SPMG3(d=duration),
                csplin=AFNI_CSPLIN(b=b,c=c, n=nbasis),
                poly=AFNI_POLY(b=b,c=c, n=nbasis),
                sine=AFNI_SIN(b=b,c=c,n=nbasis),
                wav=AFNI_WAV(),
                block=AFNI_BLOCK(d=duration),
                dmblock=AFNI_dmBLOCK(),
                # Add tent as an alias or explicit entry
                tent=AFNI_TENT(b=b, c=c, n=nbasis))
  
  if (is.null(hrf)) {
    stop("could not find afni hrf named: ", name)
  }
  
  hrf
  
} 