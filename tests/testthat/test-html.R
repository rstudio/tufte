test_that("add marginnote", {
  expect_snapshot(marginnote_html("text"))
  expect_snapshot(marginnote_html("text", "#"))
})

expect_refs_margin <- function(
  moved = FALSE,
  options = NULL,
  ...,
  variant = NULL
) {
  rmd <- test_path("resources/margins_references.Rmd")
  out <- withr::local_tempfile(fileext = ".html")
  rmd_temp <- withr::local_tempfile(fileext = ".Rmd")
  xfun::write_utf8(
    knitr::knit_expand(rmd, linked = if (moved) "yes" else "no"),
    rmd_temp
  )
  rmarkdown::pandoc_convert(
    basename(rmd_temp),
    "html4",
    "markdown",
    output = out,
    citeproc = TRUE,
    verbose = FALSE,
    wd = dirname(rmd_temp),
    options = c("--wrap", "preserve", options),
    ...
  )
  x <- xfun::read_utf8(out)
  expect_snapshot(margin_references(x), variant = variant)
}

citeproc_variant <- function() {
  if (!rmarkdown::pandoc_available("2.11")) {
    "pandoc-citeproc"
  } else if (!rmarkdown::pandoc_available("2.14.1")) {
    # new citeproc creates links on author
    "new-citeproc-post-2.14.0.2"
  } else if (!rmarkdown::pandoc_available("3.1.8")) {
    # Pandoc 2.14.1 fixed  that
    "new-citeproc-post-2.14.1"
  } else if (!rmarkdown::pandoc_available("3.8")) {
    "new-citeproc-post-3.1.8"
  } else {
    "new-citeproc-post-3.8"
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
  expect_refs_margin(
    moved = TRUE,
    variant = pandoc_variant,
    c("--csl", "https://www.zotero.org/styles/apa-6th-edition")
  )
  expect_refs_margin(
    moved = TRUE,
    variant = pandoc_variant,
    c("--csl", "https://www.zotero.org/styles/chicago-author-date-16th-edition")
  )
})

test_that("fig.margin=TRUE works with fig.align set (issue #54)", {
  skip_on_cran()
  skip_if_not_pandoc()
  rmd <- local_rmd_file(
    "---",
    "title: test",
    "output: tufte::tufte_html",
    "---",
    "",
    '```{r fig-margin-align, fig.margin=TRUE, fig.align="center", fig.cap="test cap"}',
    "plot(1)",
    "```"
  )
  html <- .render_and_read(rmd)
  # The margin figure wrapper must be present
  margin_lines <- grep("marginnote shownote", html, value = TRUE)
  expect_true(
    length(margin_lines) > 0,
    info = "fig.margin=TRUE with fig.align should still produce marginnote wrapper"
  )
  # The raw <div class="figure" style="text-align: ..."> should NOT appear
  # (it should be commented out inside the marginnote wrapper)
  raw_div <- grep(
    '<div class="figure" style=',
    html,
    fixed = TRUE,
    value = TRUE
  )
  expect_true(
    all(grepl("<!--", raw_div)),
    info = "fig div with style should be inside HTML comment when fig.margin=TRUE"
  )
})

test_that("fig.fullwidth=TRUE works with fig.align set", {
  skip_on_cran()
  skip_if_not_pandoc()
  rmd <- local_rmd_file(
    "---",
    "title: test",
    "output: tufte::tufte_html",
    "---",
    "",
    '```{r fig-full-align, fig.fullwidth=TRUE, fig.align="center", fig.cap="test cap"}',
    "plot(1)",
    "```"
  )
  html <- .render_and_read(rmd)
  fullwidth_lines <- grep("figure fullwidth", html, value = TRUE)
  expect_true(
    length(fullwidth_lines) > 0,
    info = "fig.fullwidth=TRUE with fig.align should produce fullwidth class"
  )
})

test_that("footnotes are correctly parsed", {
  skip_on_cran()
  skip_if_not_pandoc()
  pandoc_html <- local_pandoc_convert(
    "Here is some text^[This should be a sidenote].",
    to = "html4"
  )
  expect_identical(
    parse_footnotes(pandoc_html),
    list(items = "This should be a sidenote", range = 2:7)
  )
})
