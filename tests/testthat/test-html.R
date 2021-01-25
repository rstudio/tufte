test_that("add marginnote", {
  expect_snapshot(marginnote_html("text"))
  expect_snapshot(marginnote_html("text", "#"))
})


expect_refs_margin <- function(moved = FALSE) {
  rmd <- test_path("resources/margins_references.Rmd")
  out <- withr::local_tempfile(fileext = ".html")
  rmd_temp <- withr::local_tempfile(fileext = ".Rmd")
  xfun::write_utf8(
    knitr::knit_expand(rmd, linked = if (moved) "yes" else "no"),
    rmd_temp
  )
  rmarkdown::pandoc_convert(basename(rmd_temp), "html4", "markdown",
                                   output = out, citeproc = TRUE, verbose = FALSE,
                                   wd = dirname(rmd_temp))
  x <- xfun::read_utf8(out)
  expect_snapshot(margin_references(x))
}

test_that("put references in margin when link-citations: yes using Pandoc 2.11+", {
  skip_on_cran() # requires recent Pandoc
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  expect_refs_margin(moved = TRUE)
  expect_refs_margin(moved = FALSE)
})

test_that("put references in margin when link-citations: yes before Pandoc 2.11+", {
  skip_on_cran() # requires recent Pandoc
  skip_if(rmarkdown::pandoc_available("2.11"))
  expect_refs_margin(moved = TRUE)
  expect_refs_margin(moved = FALSE)
})
