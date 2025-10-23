#!/usr/bin/env Rscript

# Script to check for missing tags in Rd files
# Specifically checking for \value tags in exported functions

library(tools)

check_rd_files <- function(path = "man") {
  rd_files <- list.files(path, pattern = "\\.Rd$", full.names = TRUE)
  
  missing_value <- character()
  missing_examples <- character()
  
  cat("Checking", length(rd_files), "Rd files...\n\n")
  
  for (rd_file in rd_files) {
    # Parse the Rd file
    rd_content <- parse_Rd(rd_file)
    
    # Get the name of the function/object
    name_tag <- NULL
    for (i in seq_along(rd_content)) {
      if (attr(rd_content[[i]], "Rd_tag") == "\\name") {
        name_tag <- as.character(rd_content[[i]][[1]])
        break
      }
    }
    
    # Check for various tags
    tags <- sapply(rd_content, function(x) attr(x, "Rd_tag"))
    
    # Check if it's a documented function (has \usage tag)
    has_usage <- "\\usage" %in% tags
    
    # Check for \value tag
    has_value <- "\\value" %in% tags
    
    # Check for \examples tag (optional but good to know)
    has_examples <- "\\examples" %in% tags
    
    # For functions with usage, value tag is required
    if (has_usage && !has_value) {
      missing_value <- c(missing_value, basename(rd_file))
    }
    
    # Track files without examples (informational)
    if (has_usage && !has_examples) {
      missing_examples <- c(missing_examples, basename(rd_file))
    }
  }
  
  # Report findings
  cat(paste(rep("=", 60), collapse = ""), "\n")
  cat("REQUIRED FIXES FOR CRAN:\n")
  cat(paste(rep("=", 60), collapse = ""), "\n\n")
  
  if (length(missing_value) > 0) {
    cat("Files missing \\value tag (MUST FIX):\n")
    cat("----------------------------------------\n")
    for (file in missing_value) {
      cat("  -", file, "\n")
    }
    cat("\n")
  } else {
    cat("✓ All files have \\value tags\n\n")
  }
  
  cat(paste(rep("=", 60), collapse = ""), "\n")
  cat("OPTIONAL IMPROVEMENTS:\n")
  cat(paste(rep("=", 60), collapse = ""), "\n\n")
  
  if (length(missing_examples) > 0) {
    cat("Files without \\examples tag (optional):\n")
    cat("----------------------------------------\n")
    for (file in missing_examples) {
      cat("  -", file, "\n")
    }
    cat("\n")
  } else {
    cat("✓ All files have \\examples tags\n\n")
  }
  
  # Return list for programmatic use
  invisible(list(
    missing_value = missing_value,
    missing_examples = missing_examples,
    total_checked = length(rd_files)
  ))
}

# Run the check
results <- check_rd_files()

# Exit with error code if there are missing required tags
if (length(results$missing_value) > 0) {
  cat("\n❌ Found", length(results$missing_value), "files with missing \\value tags\n")
  quit(status = 1)
} else {
  cat("\n✅ All required tags are present\n")
  quit(status = 0)
}