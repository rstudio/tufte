# Unit tests for quote_footer() ----

test_that("quote_footer() produces styled <footer> for HTML output", {
  local_mocked_bindings(
    is_html_output = function(...) TRUE,
    is_latex_output = function(...) FALSE
  )

  result <- quote_footer("Author Name")
  expect_match(result, "<footer")
  expect_match(result, 'class="blockquote-footer"')
  expect_match(result, "text-align: right")
  expect_match(result, "Author Name")
})

test_that("quote_footer() produces \\hfill for LaTeX output", {
  local_mocked_bindings(
    is_html_output = function(...) FALSE,
    is_latex_output = function(...) TRUE
  )
  result <- quote_footer("Author Name")
  expect_equal(result, "\\hfill Author Name")
})

test_that("quote_footer() warns for unsupported output", {
  local_mocked_bindings(
    is_html_output = function(...) FALSE,
    is_latex_output = function(...) FALSE
  )
  local_mocked_bindings(pandoc_to = function(...) "docx", .package = "knitr")
  expect_warning(
    result <- quote_footer("Author Name"),
    "only works for HTML and LaTeX"
  )
  expect_equal(result, "Author Name")
})

test_that("quote_footer() is silent outside a pandoc context", {
  local_mocked_bindings(
    is_html_output = function(...) FALSE,
    is_latex_output = function(...) FALSE
  )
  local_mocked_bindings(pandoc_to = function(...) NULL, .package = "knitr")
  expect_no_warning(result <- quote_footer("Author Name"))
  expect_equal(result, "Author Name")
})

# Integration tests: render quote_footer() in non-tufte formats ----

test_that("quote_footer() renders in html_document with inline styles", {
  skip_if_not_pandoc()
  skip_if_not_installed("xml2")
  rmd <- local_rmd_file(
    "---",
    "output: html_document",
    "---",
    "",
    "> A quote",
    ">",
    # Note: Bootstrap 3 (html_document) adds an em-dash via footer::before CSS,
    # so quote_footer text should not include its own em-dash prefix.
    "> `r tufte::quote_footer('Author')`"
  )
  html <- .render_and_read(rmd)
  doc <- xml2::read_html(paste(html, collapse = "\n"))
  footer <- xml2::xml_find_first(doc, "//blockquote//footer")
  expect_false(is.na(footer))
  expect_match(xml2::xml_attr(footer, "style"), "text-align: right")
  expect_match(xml2::xml_attr(footer, "class"), "blockquote-footer")
  expect_match(xml2::xml_text(footer), "Author")
})

test_that("quote_footer() renders in html_document with bslib BS4 theme", {
  skip_if_not_pandoc()
  skip_if_not_installed("xml2")
  skip_if_not_installed("bslib")
  rmd <- local_rmd_file(
    "---",
    "output:",
    "  html_document:",
    "    theme:",
    "      version: 4",
    "---",
    "",
    "> A quote",
    ">",
    "> `r tufte::quote_footer('Author')`"
  )
  html <- .render_and_read(rmd)
  doc <- xml2::read_html(paste(html, collapse = "\n"))
  footer <- xml2::xml_find_first(doc, "//blockquote//footer")
  expect_false(is.na(footer))
  expect_match(xml2::xml_attr(footer, "class"), "blockquote-footer")
  expect_match(xml2::xml_attr(footer, "style"), "text-align: right")
})

test_that("quote_footer() renders in pdf_document", {
  skip_if_not_pandoc()
  skip_if_not_tinytex()
  rmd <- local_rmd_file(
    "---",
    "output: pdf_document",
    "---",
    "",
    "> A quote",
    ">",
    "> `r tufte::quote_footer('Author')`"
  )
  expect_no_error(local_render(rmd))
})

test_that("quote_footer() renders in beamer_presentation", {
  skip_if_not_pandoc()
  skip_if_not_tinytex()
  rmd <- local_rmd_file(
    "---",
    "output: beamer_presentation",
    "---",
    "",
    "## Slide",
    "",
    "> A quote",
    ">",
    "> `r tufte::quote_footer('Author')`"
  )
  expect_no_error(local_render(rmd))
})

test_that("quote_footer() still works in tufte_html", {
  skip_if_not_pandoc()
  skip_if_not_installed("xml2")
  rmd <- local_rmd_file(
    "---",
    "output: tufte::tufte_html",
    "---",
    "",
    "> A quote",
    ">",
    "> `r tufte::quote_footer('Author')`"
  )
  html <- .render_and_read(rmd)
  doc <- xml2::read_html(paste(html, collapse = "\n"))
  footer <- xml2::xml_find_first(doc, "//blockquote//footer")
  expect_false(is.na(footer))
  expect_match(xml2::xml_text(footer), "Author")
})
