.with_pdf_device <- function(code) {
  path <- tempfile(fileext = ".pdf")
  grDevices::pdf(path)
  on.exit(grDevices::dev.off(), add = TRUE)
  value <- force(code)
  stopifnot(file.exists(path))
  value
}

test_that("plot.Reg returns the evaluated grid data", {
  reg <- regressor(onsets = c(2, 8), hrf = HRF_SPMG1)
  grid <- seq(0, 12, by = 0.5)

  plotted <- .with_pdf_device(
    plot(reg, grid = grid, show_onsets = FALSE)
  )

  expect_s3_class(plotted, "data.frame")
  expect_equal(names(plotted), c("time", "response"))
  expect_equal(plotted$time, grid)
  expect_equal(plotted$response, evaluate(reg, grid))
})

test_that("plot_regressors returns labelled long-form data", {
  reg1 <- regressor(onsets = c(2, 8), hrf = HRF_SPMG1)
  reg2 <- regressor(onsets = c(4, 10), hrf = HRF_GAMMA)
  grid <- seq(0, 12, by = 1)

  plotted <- .with_pdf_device(
    plot_regressors(reg1, reg2, grid = grid, labels = c("spm", "gamma"),
                    show_onsets = FALSE, use_ggplot = FALSE)
  )

  expect_s3_class(plotted, "data.frame")
  expect_equal(names(plotted), c("time", "Regressor", "response"))
  expect_equal(nrow(plotted), 2 * length(grid))
  expect_equal(levels(plotted$Regressor), c("spm", "gamma"))
})

test_that("plot_hrfs returns labelled long-form data", {
  time <- seq(0, 12, by = 1)

  plotted <- .with_pdf_device(
    plot_hrfs(HRF_SPMG1, HRF_GAMMA, time = time,
              labels = c("spm", "gamma"), use_ggplot = FALSE)
  )

  expect_s3_class(plotted, "data.frame")
  expect_equal(names(plotted), c("time", "HRF", "response"))
  expect_equal(nrow(plotted), 2 * length(time))
  expect_equal(levels(plotted$HRF), c("spm", "gamma"))
})

test_that("print.HRF reports its public summary and returns the object", {
  expect_output(
    returned <- print(HRF_SPMG3),
    "Basis functions: 3"
  )
  expect_identical(returned, HRF_SPMG3)
})
