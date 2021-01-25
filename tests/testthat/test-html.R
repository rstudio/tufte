test_that("add marginnote", {
  expect_snapshot(marginnote_html("text"))
  expect_snapshot(marginnote_html("text", "#"))
})


test_that("put references in margin when link-citations: yes using Pandoc 2.11+", {
  skip_on_cran() # requires recent Pandoc
  skip_if_not(rmarkdown::pandoc_available("2.11"))
  rmd <- test_path("resources/margins_references.Rmd")
  out <- withr::local_tempfile(fileext = ".html")
  res <- rmarkdown::pandoc_convert(basename(rmd), "html4", "markdown",
                                   output = out, citeproc = TRUE, verbose = FALSE,
                                   wd = dirname(rmd))
  x <- xfun::read_utf8(out)
  expect_snapshot(margin_references(x))
  xfun::gsub_file(rmd, pattern = "^link-citations: yes$", replacement = "link-citations: no")
  res <- rmarkdown::pandoc_convert(basename(rmd), "html4", "markdown",
                                   output = out, citeproc = TRUE, verbose = FALSE,
                                   wd = dirname(rmd))
  x <- xfun::read_utf8(out)
  expect_snapshot(margin_references(x))
  xfun::gsub_file(rmd, pattern = "^link-citations: no$", replacement = "link-citations: yes")
})

test_that("put references in margin when link-citations: yes before Pandoc 2.11+", {
  skip_on_cran() # requires recent Pandoc
  skip_if(rmarkdown::pandoc_available("2.11"))
  rmd <- test_path("resources/margins_references.Rmd")
  out <- withr::local_tempfile(fileext = ".html")
  res <- rmarkdown::pandoc_convert(basename(rmd), "html4", "markdown",
                                   output = out, citeproc = TRUE, verbose = FALSE,
                                   wd = dirname(rmd))
  x <- xfun::read_utf8(out)
  expect_snapshot(margin_references(x))
  xfun::gsub_file(rmd, pattern = "^link-citations: yes$", replacement = "link-citations: no")
  res <- rmarkdown::pandoc_convert(basename(rmd), "html4", "markdown",
                                   output = out, citeproc = TRUE, verbose = FALSE,
                                   wd = dirname(rmd))
  x <- xfun::read_utf8(out)
  expect_snapshot(margin_references(x))
  xfun::gsub_file(rmd, pattern = "^link-citations: no$", replacement = "link-citations: yes")
})
