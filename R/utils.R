#' @details \code{newthought()} can be used in inline R expressions in R
#'   Markdown (e.g. \samp{`r newthought(Some text)`}), and it works for both
#'   HTML (\samp{<span class="newthought">text</span>}) and PDF
#'   (\samp{\\newthought{text}}) output.
#' @param text A character string to be presented as a \dQuote{new thought}
#'   (using small caps), or a margin note, or a footer of a quote
#' @rdname tufte_handout
#' @export
#' @examples newthought('In this section')
newthought = function(text) {
  sprintf('\\newthought<span class="newthought">%s</span>', text)
}

#' @details \code{margin_note()} can be used in inline R expressions to write a
#'   margin note (like a sidenote but not numbered).
#' @param icon A character string to indicate there is a hidden margin note when
#'   the page width is too narrow (by default it is a circled plus sign)
#' @rdname tufte_handout
#' @export
margin_note = function(text, icon = '&#8853;') {
  if (is_html_output()) {
    marginnote_html(sprintf('<span class="marginnote">%s</span>', text), icon)
  } else if (is_latex_output()) {
    sprintf('\\marginnote{%s}', text)
  } else {
    warning('marginnote() only works for HTML and LaTeX output', call. = FALSE)
    text
  }
}

#' @details \code{quote_footer()} formats text as the footer of a quote. It puts
#'   \code{text} in \samp{<footer></footer>} for HTML output, and
#'   after \samp{\\hfill} for LaTeX output (to right-align text).
#' @rdname tufte_handout
#' @export
quote_footer = function(text) {
  sprintf('\\hfill<span class="blockquote footer">%s</span>', text)
}

#' @details \code{sans_serif()} applies sans-serif fonts to \code{text}.
#' @rdname tufte_handout
#' @export
sans_serif = function(text) {
  sprintf('\\textsf<span class="sans">%s</span>', text)
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
