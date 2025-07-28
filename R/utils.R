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

#' @details `quote_footer()` formats text as the footer of a quote. It puts
#'   `text` in \samp{<footer></footer>} for HTML output, and
#'   after \samp{\\hfill} for LaTeX output (to right-align text).
#' @rdname tufte_handout
#' @export
quote_footer <- function(text) {
  if (is_html_output()) {
    sprintf("<footer>%s</footer>", text)
  } else if (is_latex_output()) {
    sprintf("\\hfill %s", text)
  } else {
    warning(
      "quote_footer() only works for HTML and LaTeX output",
      call. = FALSE
    )
    text
  }
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

template_resources <- function(name, ...) {
  system.file(
    "rmarkdown",
    "templates",
    name,
    "resources",
    ...,
    package = "tufte"
  )
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
