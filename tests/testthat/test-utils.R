# Unit tests for quote_footer() ----

test_that("quote_footer() emits <p> with em-dash in markup for unknown non-tufte HTML", {
  local_mocked_bindings(
    is_html_output = function(...) TRUE,
    is_latex_output = function(...) FALSE,
    has_bslib_theme = function() FALSE
  )

  result <- quote_footer("Author Name")
  expect_match(result, "<p")
  expect_no_match(result, 'class="blockquote-footer"', fixed = TRUE)
  expect_match(result, "text-align: right")
  expect_match(result, "Author Name")
})

test_that("quote_footer() injects em-dash glyph in unknown non-tufte HTML when caller wrote ---", {
  local_mocked_bindings(
    is_html_output = function(...) TRUE,
    is_latex_output = function(...) FALSE,
    has_bslib_theme = function() FALSE
  )
  result <- quote_footer("--- Author Name")
  # --- is stripped and replaced by an em-dash glyph in markup, since we
  # cannot rely on Bootstrap's ::before rule to be present.
  expect_no_match(result, "---", fixed = TRUE)
  expect_match(result, "—")
  expect_match(result, "Author Name")
  expect_match(result, "<p")
})

test_that("quote_footer() emits <footer class='blockquote-footer'> when bslib theme is active", {
  local_mocked_bindings(
    is_html_output = function(...) TRUE,
    is_latex_output = function(...) FALSE,
    has_bslib_theme = function() TRUE
  )
  result <- quote_footer("--- Author Name")
  # Bootstrap 4/5 ::before injects em-dash, so caller's --- is dropped.
  expect_no_match(result, "---", fixed = TRUE)
  expect_match(result, 'class="blockquote-footer"')
  expect_match(result, "Author Name")
})

test_that("quote_footer() inserts em-dash glyph in tufte HTML when caller wrote ---", {
  local_mocked_bindings(
    is_html_output = function(...) TRUE,
    is_latex_output = function(...) FALSE
  )
  local_knit_opts(tufte.format = "html")
  result <- quote_footer("--- Author Name")
  # tufte.css has no ::before; the glyph + nbsp is injected in markup.
  expect_match(result, "—")
  expect_match(result, "Author Name")
  expect_no_match(result, 'class="blockquote-footer"', fixed = TRUE)
  expect_match(result, "text-align: right")
})

test_that("quote_footer() in tufte HTML without --- preserves text as-is", {
  local_mocked_bindings(
    is_html_output = function(...) TRUE,
    is_latex_output = function(...) FALSE
  )
  local_knit_opts(tufte.format = "html")
  result <- quote_footer("Author Name")
  expect_no_match(result, "—", fixed = TRUE)
  expect_no_match(result, 'class="blockquote-footer"', fixed = TRUE)
  expect_match(result, "Author Name")
})

test_that("quote_footer() produces \\hfill for LaTeX output", {
  local_mocked_bindings(
    is_html_output = function(...) FALSE,
    is_latex_output = function(...) TRUE
  )
  expect_equal(quote_footer("Author Name"), "\\hfill Author Name")
  # Leading --- is preserved so pandoc smart-punct converts to em-dash.
  expect_equal(quote_footer("--- Author Name"), "\\hfill --- Author Name")
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

test_that("quote_footer() renders <p> with em-dash in html_document (Bootstrap 3 default)", {
  skip_if_not_pandoc()
  skip_if_not_installed("xml2")
  rmd <- local_rmd_file(
    "---",
    "output: html_document",
    "---",
    "",
    "> A quote",
    ">",
    # bslib::bs_current_theme() returns NULL for legacy BS3 default theme,
    # so quote_footer() injects the em-dash glyph in markup via <p>.
    "> `r tufte::quote_footer('--- Author')`"
  )
  html <- .render_and_read(rmd)
  doc <- xml2::read_html(paste(html, collapse = "\n"))
  p <- xml2::xml_find_first(doc, "//blockquote//p[contains(@style,'text-align: right')]")
  expect_false(is.na(p))
  txt <- xml2::xml_text(p)
  expect_match(txt, "—")
  expect_match(txt, "Author")
  expect_no_match(txt, "---", fixed = TRUE)
})

test_that("quote_footer() renders <p> with em-dash in html_document(theme = NULL)", {
  skip_if_not_pandoc()
  skip_if_not_installed("xml2")
  rmd <- local_rmd_file(
    "---",
    "output:",
    "  html_document:",
    "    theme: null",
    "---",
    "",
    "> A quote",
    ">",
    "> `r tufte::quote_footer('--- Author')`"
  )
  html <- .render_and_read(rmd)
  doc <- xml2::read_html(paste(html, collapse = "\n"))
  p <- xml2::xml_find_first(doc, "//blockquote//p[contains(@style,'text-align: right')]")
  expect_false(is.na(p))
  txt <- xml2::xml_text(p)
  expect_match(txt, "—")
  expect_match(txt, "Author")
  expect_no_match(txt, "---", fixed = TRUE)
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
    "> `r tufte::quote_footer('--- Author')`"
  )
  html <- .render_and_read(rmd)
  doc <- xml2::read_html(paste(html, collapse = "\n"))
  footer <- xml2::xml_find_first(doc, "//blockquote//footer")
  expect_false(is.na(footer))
  expect_match(xml2::xml_attr(footer, "class"), "blockquote-footer")
  expect_match(xml2::xml_attr(footer, "style"), "text-align: right")
  # --- stripped because Bootstrap 4 CSS supplies the em-dash via ::before.
  expect_no_match(xml2::xml_text(footer), "---", fixed = TRUE)
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
    # Leading "---" should render as an em-dash glyph in tufte HTML too,
    # since tufte.css does not inject one via ::before.
    "> `r tufte::quote_footer('--- Author')`"
  )
  html <- .render_and_read(rmd)
  doc <- xml2::read_html(paste(html, collapse = "\n"))
  footer <- xml2::xml_find_first(doc, "//blockquote//footer")
  expect_false(is.na(footer))
  txt <- xml2::xml_text(footer)
  expect_match(txt, "—")
  expect_match(txt, "Author")
  expect_no_match(txt, "---", fixed = TRUE)
})
