test_that("add marginnote", {
  expect_snapshot(marginnote_html("text"))
  expect_snapshot(marginnote_html("text", "#"))
})

expect_refs_margin <- function(moved = FALSE, options = NULL, ..., variant = NULL) {
  rmd <- test_path("resources/margins_references.Rmd")
  out <- withr::local_tempfile(fileext = ".html")
  rmd_temp <- withr::local_tempfile(fileext = ".Rmd")
  xfun::write_utf8(
    knitr::knit_expand(rmd, linked = if (moved) "yes" else "no"),
    rmd_temp
  )
  rmarkdown::pandoc_convert(basename(rmd_temp), "html4", "markdown",
                            output = out, citeproc = TRUE, verbose = FALSE,
                            wd = dirname(rmd_temp),
                            options = c("--wrap", "none", options), ...)
  x <- xfun::read_utf8(out)
  expect_snapshot(margin_references(x), variant = variant)
}

citeproc_variant <- function() {
  if (!rmarkdown::pandoc_available("2.11")) {
    "pandoc-citeproc"
  } else if (!rmarkdown::pandoc_available("2.14.1")) { # new citeproc creates links on author
    "new-citeproc-post-2.14.0.2"
  } else { # Pandoc 2.14.1 fixed  that
    "new-citeproc-post-2.14.1"
  }
}

pandoc_variant <- citeproc_variant()

test_that("put references in margin when link-citations: yes", {
  skip_on_cran()
  skip_if_not_pandoc()
  expect_refs_margin(moved = TRUE, variant = pandoc_variant)
  expect_refs_margin(moved = FALSE, variant = pandoc_variant)
})

test_that("put references in margin when link-citations: yes using csl", {
  skip_on_cran() # requires recent Pandoc
  skip_if_not_pandoc("2.11")
  skip_if_offline("zotero.org")
  expect_refs_margin(moved = TRUE, variant = pandoc_variant, c("--csl", "https://www.zotero.org/styles/apa-6th-edition"))
  expect_refs_margin(moved = TRUE, variant = pandoc_variant, c("--csl", "https://www.zotero.org/styles/chicago-author-date-16th-edition"))
})
