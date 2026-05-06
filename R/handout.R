#' Tufte handout formats (PDF and HTML)
#'
#' Templates for creating handouts according to the style of Edward R. Tufte and
#' Richard Feynman.
#'
#' `tufte_handout()` provides the PDF format based on the Tufte-LaTeX
#' class: <https://tufte-latex.github.io/tufte-latex/>.
#' @inheritParams rmarkdown::pdf_document
#' @param ... Other arguments to be passed to [rmarkdown::pdf_document()] or
#'   [rmarkdown::html_document()] (note you cannot use the `template`
#'   argument in `tufte_handout` or the `theme` argument in
#'   `tufte_html()`; these arguments have been set internally)
#' @references See <https://rstudio.github.io/tufte/> for an example.
#' @export
#' @examples library(tufte)
tufte_handout <- function(
  fig_width = 4,
  fig_height = 2.5,
  fig_crop = "auto",
  dev = "pdf",
  highlight = "default",
  ...
) {
  tufte_pdf(
    "tufte-handout",
    fig_width,
    fig_height,
    fig_crop,
    dev,
    highlight,
    ...
  )
}

#' @rdname tufte_handout
#' @export
tufte_book <- function(
  fig_width = 4,
  fig_height = 2.5,
  fig_crop = "auto",
  dev = "pdf",
  highlight = "default",
  ...
) {
  tufte_pdf("tufte-book", fig_width, fig_height, fig_crop, dev, highlight, ...)
}

tufte_pdf <- function(
  documentclass = c("tufte-handout", "tufte-book"),
  fig_width = 4,
  fig_height = 2.5,
  fig_crop = "auto",
  dev = "pdf",
  highlight = "default",
  template = template_resources("tufte_handout", "tufte-handout.tex"),
  ...
) {
  # resolve default highlight
  if (identical(highlight, "default")) {
    highlight <- "pygments"
  }

  # call the base pdf_document format with the appropriate options
  format <- rmarkdown::pdf_document(
    fig_width = fig_width,
    fig_height = fig_height,
    fig_crop = fig_crop,
    dev = dev,
    highlight = highlight,
    template = template,
    ...
  )

  # LaTeX document class
  documentclass <- match.arg(documentclass)
  format$pandoc$args <- c(
    format$pandoc$args,
    "--variable",
    paste0("documentclass:", documentclass),
    if (documentclass == "tufte-book") {
      if (pandoc2.0()) "--top-level-division=chapter" else "--chapters"
    }
  )

  # Prepend our patched tufte-common.def to TEXINPUTS so kpathsea finds it
  # before the system version. Fixes the xcolor usenames warning (#127).
  patches_dir <- pkg_file("rmarkdown", "templates", "tufte_handout", "patches")
  old_texinputs <- NULL
  base_pre_processor <- format$pre_processor
  format$pre_processor <- function(metadata, input_file, ...) {
    old_texinputs <<- Sys.getenv("TEXINPUTS", unset = "")
    # Trailing path separator tells kpathsea to also search default paths
    Sys.setenv(
      TEXINPUTS = paste0(patches_dir, .Platform$path.sep, old_texinputs)
    )
    if (is.function(base_pre_processor)) {
      base_pre_processor(metadata, input_file, ...)
    } else {
      character(0)
    }
  }
  # on_exit runs even when render() errors, so TEXINPUTS is always restored.
  format$on_exit <- function() {
    if (!is.null(old_texinputs)) {
      Sys.setenv(TEXINPUTS = old_texinputs)
    }
  }

  knitr::knit_engines$set(marginfigure = function(options) {
    options$type <- "marginfigure"
    eng_block <- knitr::knit_engines$get("block")
    eng_block(options)
  })

  # create knitr options (ensure opts and hooks are non-null)
  knitr_options <- rmarkdown::knitr_options_pdf(
    fig_width,
    fig_height,
    fig_crop,
    dev
  )
  if (is.null(knitr_options$opts_knit)) {
    knitr_options$opts_knit <- list()
  }
  if (is.null(knitr_options$knit_hooks)) {
    knitr_options$knit_hooks <- list()
  }

  # set options
  knitr_options$opts_knit$width <- 45

  # set hooks for special plot output
  knitr_options$knit_hooks$plot <- function(x, options) {
    # determine figure type
    if (isTRUE(options$fig.margin)) {
      options$fig.env <- "marginfigure"
      if (is.null(options$fig.cap)) options$fig.cap <- ""
    } else if (isTRUE(options$fig.fullwidth)) {
      options$fig.env <- "figure*"
      if (is.null(options$fig.cap)) options$fig.cap <- ""
    }

    knitr::hook_plot_tex(x, options)
  }

  # override the knitr settings of the base format and return the format
  format$knitr <- knitr_options
  format$inherits <- "pdf_document"
  format
}
