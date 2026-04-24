test_that("tufte_handout() does not warn about crop tools", {
  expect_no_warning(tufte_handout())
})

test_that("tufte_book() does not warn about crop tools", {
  expect_no_warning(tufte_book())
})

test_that("fig_crop = 'auto' is passed through to pdf_document", {
  fmt <- tufte_handout()
  # When crop tools are missing, the knitr options should not include crop hook
  if (!nzchar(Sys.which("pdfcrop")) || !nzchar(Sys.which("gs"))) {
    expect_null(fmt$knitr$knit_hooks$crop)
  }
})

test_that("tufte_handout renders without pdfcrop warnings", {
  skip_on_cran()
  skip_if_not_pandoc()
  rmd <- local_rmd_file(c(
    "---",
    "title: test",
    "output: tufte::tufte_handout",
    "---",
    "",
    "Hello world."
  ))
  # Suppress unrelated LaTeX warnings, but fail on any crop-related ones
  withCallingHandlers(
    local_render(rmd),
    warning = function(w) {
      msg <- conditionMessage(w)
      if (grepl("pdfcrop|crop_tools|ghostscript", msg)) {
        fail(paste("Unexpected crop tool warning:", msg))
      }
      invokeRestart("muffleWarning")
    }
  )
  succeed()
})
