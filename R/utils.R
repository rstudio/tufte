.onLoad <- function(lib, pkg) {
  # this engine will be overridden in tufte_html/tufte_handout formats
  knitr::knit_engines$set(marginfigure = function(options) {
    'Placeholder (you should not see this)'
  })
}

#' @details `newthought()` can be used in inline R expressions in R
#'   Markdown
#'   ```r
#'   `r newthought(Some text)`
#'   ```
#'   and it works for both
#'   HTML (\samp{<span class="newthought">text</span>}) and PDF
#'   (\samp{\\newthought{text}}) output.
#' @param text A character string to be presented as a \dQuote{new thought}
#'   (using small caps), or a margin note, or a footer of a quote
#' @rdname tufte_handout
#' @export
#' @examples newthought("In this section")
newthought <- function(text) {
  if (is_html_output()) {
    sprintf('<span class="newthought">%s</span>', text)
  } else if (is_latex_output()) {
    sprintf("\\newthought{%s}", text)
  } else {
    sprintf('<span style="font-variant:small-caps;">%s</span>', text)
  }
}

#' @details `margin_note()` can be used in inline R expressions to write a
#'   margin note (like a sidenote but not numbered).
#' @param icon A character string to indicate there is a hidden margin note when
#'   the page width is too narrow (by default it is a circled plus sign)
#' @rdname tufte_handout
#' @importFrom knitr is_html_output is_latex_output
#' @export
margin_note <- function(text, icon = "&#8853;") {
  if (is_html_output()) {
    marginnote_html(sprintf('<span class="marginnote">%s</span>', text), icon)
  } else if (is_latex_output()) {
    sprintf("\\marginnote{%s}", text)
  } else {
    warning("marginnote() only works for HTML and LaTeX output", call. = FALSE)
    text
  }
}

#' @details `quote_footer()` formats text as the footer of a quote. It works in
#'   any HTML or LaTeX output format, not only tufte formats, and tries to
#'   render `text` consistently across formats. If `text` starts with `"---"`
#'   (or an em-dash), an em-dash + non-breaking space is rendered before the
#'   rest of the text in every output; the leading `"---"` is stripped or
#'   re-inserted as the destination format requires.
#'
#'   The HTML emitted depends on the active output:
#'
#'   * For tufte HTML, `text` is wrapped in a `<footer>` element styled by
#'     `tufte.css`. An em-dash glyph is injected in the markup when the caller
#'     wrote a leading `"---"`, since `tufte.css` has no `::before` rule.
#'
#'   * For non-tufte HTML where a `bslib::bs_theme()` (Bootstrap 4 or 5) is
#'     active, `text` is wrapped in a `<footer class="blockquote-footer">` and
#'     the leading `"---"` is stripped, so Bootstrap's
#'     `.blockquote-footer::before` rule supplies the em-dash exactly once.
#'
#'   * For all other HTML (Bootstrap 3 default `html_document()`,
#'     `theme: null`, ioslides, slidy, custom HTML frameworks, ...), `text` is
#'     wrapped in a `<p>` with an em-dash glyph injected in the markup when
#'     requested. Using `<p>` rather than `<footer>` avoids Bootstrap 3's
#'     `blockquote footer::before` rule, which would otherwise double the
#'     em-dash for callers following the `quote_footer('--- Author')` pattern
#'     shown in the R Markdown documentation.
#'
#'   For LaTeX output (tufte or non-tufte), `text` is prepended with
#'   \samp{\\hfill} to right-align it. Pandoc's smart-punctuation extension
#'   converts a leading `"---"` to an em-dash glyph.
#'
#'   `quote_footer()` detects whether the active output is a tufte format via
#'   the `tufte.format` entry that the tufte output formats register in
#'   `knitr::opts_knit`, and whether a `bslib::bs_theme()` is active via
#'   `bslib::bs_current_theme()`.
#' @rdname tufte_handout
#' @export
quote_footer <- function(text) {
  dash_pattern <- "^\\s*(?:---|—)\\s*"
  has_dash <- grepl(dash_pattern, text)
  stripped <- sub(dash_pattern, "", text)
  in_tufte <- !is.null(knitr::opts_knit$get("tufte.format"))

  if (is_html_output()) {
    if (in_tufte) {
      # tufte.css has no ::before rule on `blockquote footer`, so insert the
      # em-dash glyph in markup when the caller requested it via "---".
      prefix <- if (has_dash) "— " else ""
      sprintf(
        '<footer style="text-align: right;">%s%s</footer>',
        prefix,
        stripped
      )
    } else if (has_bslib_theme()) {
      # bslib Bootstrap 4/5: `.blockquote-footer::before` injects an em-dash;
      # strip the caller's "---" to avoid doubling.
      sprintf(
        '<footer class="blockquote-footer" style="text-align: right;">%s</footer>',
        stripped
      )
    } else {
      # Unknown HTML framework (Bootstrap 3 default, `theme: null`, ioslides,
      # slidy, custom, ...). Inject the em-dash glyph in markup and use `<p>`
      # so Bootstrap 3's `blockquote footer::before` element rule does not
      # double the em-dash.
      prefix <- if (has_dash) "— " else ""
      sprintf(
        '<p style="text-align: right;">%s%s</p>',
        prefix,
        stripped
      )
    }
  } else if (is_latex_output()) {
    # Restore the caller-supplied "---" after \hfill so pandoc's smart-punct
    # extension converts it to an em-dash glyph, mirroring the HTML behaviour.
    prefix <- if (has_dash) "--- " else ""
    sprintf("\\hfill %s%s", prefix, stripped)
  } else {
    if (!is.null(knitr::pandoc_to())) {
      warning(
        "quote_footer() only works for HTML and LaTeX output",
        call. = FALSE
      )
    }
    text
  }
}

has_bslib_theme <- function() {
  tryCatch(
    !is.null(bslib::bs_current_theme()),
    error = function(e) FALSE
  )
}

#' @details `sans_serif()` applies sans-serif fonts to `text`.
#' @rdname tufte_handout
#' @export
sans_serif <- function(text) {
  if (is_html_output()) {
    sprintf('<span class="sans">%s</span>', text)
  } else if (is_latex_output()) {
    sprintf("\\textsf{%s}", text)
  } else {
    warning("sans_serif() only works for HTML and LaTeX output", call. = FALSE)
    text
  }
}

check_bookdown <- function() {
  if (!xfun::pkg_available("bookdown")) {
    stop(
      "The 'bookdown' package is required for tufte_handout2()/tufte_book2(). ",
      "Install it with install.packages('bookdown').",
      call. = FALSE
    )
  }
}

devtools_loaded <- function(x) {
  if (!x %in% loadedNamespaces()) {
    return(FALSE)
  }
  ns <- .getNamespace(x)
  !is.null(ns$.__DEVTOOLS__)
}

pkg_file <- function(..., package = "tufte", mustWork = FALSE) {
  if (devtools_loaded(package)) {
    file.path(find.package(package), "inst", ...)
  } else {
    system.file(..., package = package, mustWork = mustWork)
  }
}

template_resources <- function(name, ...) {
  pkg_file("rmarkdown", "templates", name, "resources", ...)
}

gsub_fixed <- function(...) gsub(..., fixed = TRUE)

pandoc2.0 <- function() rmarkdown::pandoc_available("2.0")

# add --wrap=preserve to pandoc args for pandoc 2.0:
# https://github.com/rstudio/bookdown/issues/504
# https://github.com/rstudio/tufte/issues/115
add_wrap_preserve <- function(args, pandoc2 = pandoc2.0) {
  if (pandoc2 && !length(grep("--wrap", args))) {
    c("--wrap", "preserve", args)
  } else {
    args
  }
}
