box_hrf_fun <- function(t) ifelse(t >= 0 & t <= 1, 1, 0)
BOX_HRF <- as_hrf(box_hrf_fun, name = "box", span = 1)

# Basic construction and evaluation

test_that("regressor_set constructs and evaluates", {
  ons <- c(0, 1, 2, 3)
  fac <- factor(c("a", "a", "b", "b"))
  rs <- regressor_set(ons, fac, hrf = BOX_HRF)
  expect_s3_class(rs, "RegSet")
  grid <- 0:4
  mat <- evaluate(rs, grid, method = "conv", precision = 1)
  expect_true(is.matrix(mat))
  expect_equal(nrow(mat), length(grid))
  expect_equal(ncol(mat), nbasis(BOX_HRF) * length(levels(fac)))
})

# Sparse output

test_that("regressor_set produces sparse matrix", {
  ons <- c(0, 2)
  fac <- factor(c("a", "b"))
  rs <- regressor_set(ons, fac, hrf = BOX_HRF)
  grid <- 0:4
  mat <- evaluate(rs, grid, method = "conv", precision = 1, sparse = TRUE)
  expect_true(inherits(mat, "dgCMatrix"))
})

test_that("evaluate.RegSet returns named columns (#63)", {
  rs <- regressor_set(c(10, 20), factor(c("a", "b")))
  m <- evaluate(rs, 0:30)
  expect_identical(colnames(m), c("a", "b"))
  ms <- evaluate(rs, 0:30, sparse = TRUE)
  expect_identical(colnames(ms), c("a", "b"))

  rs3 <- regressor_set(c(10, 20), factor(c("x", "y")), hrf = HRF_SPMG2)
  expect_identical(colnames(evaluate(rs3, 0:30)),
                   c("x_basis1", "x_basis2", "y_basis1", "y_basis2"))
})
