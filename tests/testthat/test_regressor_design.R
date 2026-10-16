box_hrf_fun <- function(t) ifelse(t >= 0 & t <= 1, 1, 0)
BOX_HRF <- as_hrf(box_hrf_fun, name = "box", span = 1)

# Basic construction and evaluation with sampling frame

test_that("regressor_design produces expected design", {
  ons <- c(0, 1, 0, 2)
  fac <- factor(c("a", "b", "a", "b"))
  blk <- c(1L, 1L, 2L, 2L)
  sf  <- sampling_frame(blocklens = c(3, 3), TR = 1)
  dmat <- regressor_design(ons, fac, blk, sf, hrf = BOX_HRF, precision = 1)
  expect_true(is.matrix(dmat))
  expect_equal(nrow(dmat), length(samples(sf)))
  expect_equal(ncol(dmat), nbasis(BOX_HRF) * length(levels(fac)))
})

# Sparse output

test_that("regressor_design returns sparse matrix", {
  ons <- c(0, 2)
  fac <- factor(c("a", "b"))
  blk <- c(1L, 2L)
  sf  <- sampling_frame(blocklens = c(3, 3), TR = 1)
  dmat <- regressor_design(ons, fac, blk, sf, hrf = BOX_HRF,
                           precision = 1, sparse = TRUE)
  expect_true(inherits(dmat, "dgCMatrix"))
})


# Run boundaries (#62)

test_that("regressor_design does not carry responses across runs (#62)", {
  sf <- sampling_frame(blocklens = c(120, 120), TR = 2)
  # Event 10 s before the end of run 1; its undershoot would reach run 2
  # if the session were convolved as one time series.
  rd <- regressor_design(onsets = 230, fac = factor("a"), block = 1,
                         sframe = sf, hrf = HRF_SPMG1)
  run1 <- seq_len(120)
  run2 <- 120 + seq_len(120)
  expect_true(any(rd[run1, 1] != 0))
  expect_identical(unname(rd[run2, 1]), rep(0, 120))
})

test_that("regressor_design equals per-run convolution stacked by run (#62)", {
  sf <- sampling_frame(blocklens = c(60, 80), TR = c(2, 1.5))
  ons <- c(10, 105, 115, 5, 50, 110)
  fac <- factor(c("a", "b", "a", "b", "a", "b"))
  blk <- c(1, 1, 1, 2, 2, 2)
  amp <- c(1, 2, 0.5, 1.5, 1, 0.7)
  rd <- regressor_design(ons, fac, blk, sf, hrf = HRF_SPMG3,
                         amplitude = amp, duration = 1)

  per_run <- lapply(1:2, function(b) {
    idx <- blk == b
    rs <- regressor_set(ons[idx], factor(as.character(fac[idx]),
                                         levels = levels(fac)),
                        hrf = HRF_SPMG3, amplitude = amp[idx], duration = 1)
    evaluate(rs, samples(sf, blockids = b, global = FALSE))
  })
  expected <- do.call(rbind, per_run)

  expect_equal(dim(rd), c(140L, 6L))
  expect_equal(unname(rd), unname(expected))
  # Run 1 events close to its end leave run 2's first scans untouched
  # except for run 2's own events (first run-2 event at 5 s, condition "b").
  expect_true(all(rd[61, c("a_basis1", "a_basis2", "a_basis3")] == 0))
})

test_that("regressor_design handles runs without events and validates block", {
  sf <- sampling_frame(blocklens = c(20, 20, 20), TR = 2)
  rd <- regressor_design(c(5, 10), factor(c("a", "b")), c(1, 3), sf)
  expect_equal(dim(rd), c(60L, 2L))
  expect_true(all(rd[21:40, ] == 0))
  expect_error(regressor_design(5, "a", 4, sf), "valid block")
})

# Column names (#63)

test_that("regressor_design names its columns after factor levels (#63)", {
  sf <- sampling_frame(blocklens = c(50, 50), TR = 2)
  rd <- regressor_design(onsets = c(10, 20, 30),
                         fac = factor(c("a", "b", "a")),
                         block = c(1, 2, 2), sframe = sf)
  expect_identical(colnames(rd), c("a", "b"))

  rd3 <- regressor_design(c(10, 20), factor(c("b", "a")), c(1, 2), sf,
                          hrf = HRF_SPMG3, sparse = TRUE)
  expect_identical(colnames(rd3),
                   c(paste0("a_basis", 1:3), paste0("b_basis", 1:3)))
})
