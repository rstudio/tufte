#' @details \code{newthought()} can be used in inline R expressions in R
#'   Markdown (e.g. \samp{`r newthought(Some text)`}), and it works for both
#'   HTML (\samp{<span class="newthought">text</span>}) and PDF
#'   (\samp{\\newthought{text}}) output.
#' @param text A character string to be presented as a \dQuote{new thought}
#'   (using small caps), or a margin note, or a footer of a quote
#' @param escape Whether to escape special HTML/LaTeX characters in \code{text}
#' @rdname tufte_handout
#' @export
#' @examples newthought('In this section')
newthought = function(text, escape = TRUE) cond_text(
  text, escape, '<span class="newthought">%s</span>', '\\newthought{%s}',
  sprintf('<span style="font-variant:small-caps;">%s</span>', text)
)

#' @details \code{margin_note()} can be used in inline R expressions to write a
#'   margin note (like a sidenote but not numbered).
#' @param icon A character string to indicate there is a hidden margin note when
#'   the page width is too narrow (by default it is a circled plus sign)
#' @rdname tufte_handout
#' @export
margin_note = function(text, icon = '&#8853;', escape = TRUE) cond_text(
  text, escape,
  sprintf('%s<span class="marginnote">%%s</span>', marginnote_html('', icon)),
  '\\marginnote{%s}', {
    warning('marginnote() only works for HTML and LaTeX output', call. = FALSE)
    text
  }
)

#' @details \code{quote_footer()} formats text as the footer of a quote. It puts
#'   \code{text} in \samp{<footer></footer>} for HTML output, and
#'   after \samp{\\hfill} for LaTeX output (to right-align text).
#' @rdname tufte_handout
#' @export
quote_footer = function(text, escape = TRUE) cond_text(
  text, escape, '<footer>%s</footer>', '\\hfill %s', {
    warning('quote_footer() only works for HTML and LaTeX output', call. = FALSE)
    text
  }
)

#' @details \code{sans_serif()} applies sans-serif fonts to \code{text}.
#' @rdname tufte_handout
#' @export
sans_serif = function(text, escape = TRUE) cond_text(
  text, escape, '<span class="sans">%s</span>', '\\textsf{%s}', {
    warning('sans_serif() only works for HTML and LaTeX output', call. = FALSE)
    text
  }
)

cond_text = function(text, escape = TRUE, html, latex, other) {
  if (is_html_output()) {
    if (escape) text = knitr:::escape_html(text)
    sprintf(html, text)
  } else if (is_latex_output()) {
    if (escape) text = knitr:::escape_latex(text)
    sprintf(latex, text)
  } else other
}

template_resources = function(name, ...) {
  system.file('rmarkdown', 'templates', name, 'resources', ..., package = 'tufte')
}

# import two helper functions from knitr
is_html_output = function(...) knitr:::is_html_output(...)
is_latex_output = function(...) knitr:::is_latex_output(...)

gsub_fixed = function(...) gsub(..., fixed = TRUE)

readUTF8 = function(file, ...) readLines(file, encoding = 'UTF-8', warn = FALSE, ...)
writeUTF8 = function(text, ...) writeLines(enc2utf8(text), ..., useBytes = TRUE)
