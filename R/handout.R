#' Tufte handout formats (PDF and HTML)
#'
#' Templates for creating handouts according to the style of Edward R. Tufte and
#' Richard Feynman.
#'
#' \code{tufte_handout()} provides the PDF format based on the Tufte-LaTeX
#' class: \url{https://tufte-latex.github.io/tufte-latex/}.
#' @inheritParams rmarkdown::pdf_document
#' @param ... Other arguments to be passed to \code{\link{pdf_document}} or
#'   \code{\link{html_document}} (note you cannot use the \code{template}
#'   argument in \code{tufte_handout} or the \code{theme} argument in
#'   \code{tufte_html()}; these arguments have been set internally)
#'
#' @export
#' @examples library(tufte)
tufte_handout = function(
  fig_width = 4, fig_height = 2.5, fig_crop = TRUE, dev = 'pdf',
  highlight = 'default', ...
) {

  # resolve default highlight
  if (identical(highlight, 'default')) highlight = 'pygments'

  # get the tufte handlout template
  template =  template_resources('tufte_handout', 'tufte-handout.tex')

  # call the base pdf_document format with the appropriate options
  format = rmarkdown::pdf_document(
    fig_width = fig_width, fig_height = fig_height, fig_crop = fig_crop,
    dev = dev, highlight = highlight, template = template, ...
  )

  knitr::knit_engines$set(marginfigure = function(options) {
    options$type = 'marginfigure'
    eng_block = knitr::knit_engines$get('block')
    eng_block(options)
  })

  # create knitr options (ensure opts and hooks are non-null)
  knitr_options = rmarkdown::knitr_options_pdf(fig_width, fig_height, fig_crop, dev)
  if (is.null(knitr_options$opts_knit))  knitr_options$opts_knit = list()
  if (is.null(knitr_options$knit_hooks)) knitr_options$knit_hooks = list()

  # set options
  knitr_options$opts_chunk$tidy = TRUE
  knitr_options$opts_knit$width = 45

  # set hooks for special plot output
  knitr_options$knit_hooks$plot = function(x, options) {

    # determine figure type
    if (isTRUE(options$fig.margin)) {
      options$fig.env = 'marginfigure'
    } else if (isTRUE(options$fig.fullwidth)) {
      options$fig.env = 'figure*'
    }

    knitr::hook_plot_tex(x, options)
  }

  # override the knitr settings of the base format and return the format
  format$knitr = knitr_options
  format$inherits = 'pdf_document'
  format
}
