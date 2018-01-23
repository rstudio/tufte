#' @details \code{tufte_html()} provides the HTML format based on the Tufte CSS:
#'   \url{https://edwardtufte.github.io/tufte-css/}.
#' @param tufte_features A character vector of style features to enable:
#'   \code{fonts} stands for the \code{et-book} fonts in the \code{tufte-css}
#'   project, \code{background} means the lightyellow background color of the
#'   page, and \code{italics} means whether to use italics for the headers. You
#'   can enable a subset of these features, or just disable all of them by
#'   \code{NULL}. When this argument is not used and the \code{tufte_variant}
#'   argument is not \code{default}, no features are enabled.
#' @param tufte_variant A variant of the Tufte style. Currently supported styles
#'   are \code{default} (from the \code{tufte-css} project), and
#'   \code{envisioned} (inspired by the project \code{Envisioned CSS}
#'   \url{http://nogginfuel.com/envisioned-css/} but essentially just sets the
#'   font family to \code{Roboto Condensed}, and changed the
#'   background/foregroudn colors).
#' @param margin_references Whether to place citations in margin notes.
#' @rdname tufte_handout
#' @export
tufte_html = function(
  ..., tufte_features = c('fonts', 'background', 'italics'),
  tufte_variant = c('default', 'envisioned'), margin_references = TRUE
) {

  tufte_variant = match.arg(tufte_variant)
  if (missing(tufte_features) && tufte_variant != 'default') tufte_features = character()
  html_document2 = function(..., extra_dependencies = list()) {
    rmarkdown::html_document(
      ..., extra_dependencies = c(
        extra_dependencies, tufte_html_dependency(tufte_features, tufte_variant)
      )
    )
  }
  format = html_document2(theme = NULL, ...)
  pandoc2 = pandoc2.0()

  # when fig.margin = TRUE, set fig.beforecode = TRUE so plots are moved before
  # code blocks, and they can be top-aligned
  ohooks = knitr::opts_hooks$set(fig.margin = function(options) {
    if (isTRUE(options$fig.margin)) options$fig.beforecode = TRUE
    options
  })

  # make sure the existing post processor is called first in our new processor
  post_processor = format$post_processor
  format$post_processor = function(metadata, input, output, clean, verbose) {

    if (is.function(post_processor))
      output = post_processor(metadata, input, output, clean, verbose)

    knitr::opts_hooks$restore(ohooks)

    x = xfun::read_utf8(output)
    fn_label = paste0(knitr::opts_knit$get('rmarkdown.pandoc.id_prefix'), 'fn')
    footnotes = parse_footnotes(x, fn_label)
    notes = footnotes$items
    # replace footnotes with sidenotes
    for (i in seq_along(notes)) {
      num = sprintf(
        '<a href="#%s%d" class="%s" id="%sref%d"><sup>%d</sup></a>',
        fn_label, i, if (pandoc2) 'footnote-ref' else 'footnoteRef', fn_label, i, i
      )
      con = sprintf(paste0(
        '<label for="tufte-sn-%d" class="margin-toggle sidenote-number">%d</label>',
        '<input type="checkbox" id="tufte-sn-%d" class="margin-toggle">',
        '<span class="sidenote"><span class="sidenote-number">%d</span> %s</span>'
      ), i, i, i, i, notes[i])
      x = gsub_fixed(num, con, x)
    }
    # remove footnotes at the bottom
    if (length(footnotes$range)) x = x[-footnotes$range]

    # replace citations with margin notes
    if (margin_references) x = margin_references(x)

    # place figure captions in margin notes
    x[x == '<p class="caption">'] = '<p class="caption marginnote shownote">'

    # move </caption> to the same line as <caption>; the previous line should
    # start with <table
    for (i in intersect(grep('^<caption>', x), grep('^<table', x) + 1)) {
      j = 0
      while (!grepl('</caption>$', x[i])) {
        j = j + 1
        x[i] = paste0(x[i], x[i + j])
        x[i + j] = ''
      }
    }
    # place table captions in the margin
    r = '^<caption>(.+)</caption>$'
    for (i in grep(r, x)) {
      # the previous line should be <table> or <table class=...>
      if (!grepl('^<table( class=.+)?>$', x[i - 1])) next
      cap = gsub(r, '\\1', x[i])
      x[i] = x[i - 1]
      x[i - 1] = paste0(
        '<p><!--\n<caption>-->', '<span class="marginnote shownote">',
        cap, '</span><!--</caption>--></p>'
      )
    }

    # add an incremental number to the id of <label> and <input> for margin notes
    r = '(<label|<input type="checkbox") (id|for)(="tufte-mn)-(" )'
    m = gregexpr(r, x)
    j = 1
    regmatches(x, m) = lapply(regmatches(x, m), function(z) {
      n = length(z)
      if (n == 0) return(z)
      if (n %% 2 != 0) warning('The number of labels is different with checkboxes')
      for (i in seq(1, n, 2)) {
        if (i + 1 > n) break
        z[i + (0:1)] =  gsub(r, paste0('\\1 \\2\\3-', j, '\\4'), z[i + (0:1)])
        j <<- j + 1
      }
      z
    })

    # restore blockquote footer from <span class="blockquote footer">
    r = '^<p><span class="blockquote footer">(.+)</span></p>$'
    i = grep(r, x)
    x[i] = gsub(r, '<footer>\\1</footer>', x[i])

    xfun::write_utf8(x, output)
    output
  }

  if (is.null(format$knitr$knit_hooks)) format$knitr$knit_hooks = list()
  format$knitr$knit_hooks$plot = function(x, options) {
    # make sure the plot hook always generates HTML code instead of ![]()
    if (is.null(options$out.extra)) options$out.extra = ''
    fig_margin = isTRUE(options$fig.margin)
    fig_fullwd = isTRUE(options$fig.fullwidth)
    if (fig_margin || fig_fullwd) {
      if (is.null(options$fig.cap)) options$fig.cap = ' ' # empty caption
    } else if (is.null(options$fig.topcaption)) {
      # for normal figures, place captions at the top of images
      options$fig.topcaption = TRUE
    }
    res = knitr::hook_plot_md(x, options)
    if (fig_margin) {
      res = gsub_fixed('<p class="caption">', '<!--\n<p class="caption marginnote">-->', res)
      res = gsub_fixed('</p>', '<!--</p>-->', res)
      res = gsub_fixed('</div>', '<!--</div>--></span></p>', res)
      res = gsub_fixed(
        '<div class="figure">', paste0(
          '<p>', '<span class="marginnote shownote">', '<!--\n<div class="figure">-->'
        ), res
      )
    } else if (fig_fullwd) {
      res = gsub_fixed('<div class="figure">', '<div class="figure fullwidth">', res)
      res = gsub_fixed(
        '<p class="caption">', '<p class="caption marginnote shownote">', res
      )
    }
    res
  }

  knitr::knit_engines$set(marginfigure = function(options) {
    options$type = 'marginnote'
    if (is.null(options$html.tag)) options$html.tag = 'span'
    options$html.before = marginnote_html()
    eng_block = knitr::knit_engines$get('block')
    eng_block(options)
  })

  format$inherits = 'html_document'

  format
}

#' @importFrom htmltools htmlDependency
tufte_html_dependency = function(features, variant) {
  list(htmlDependency(
    'tufte-css', '2015.12.29',
    src = template_resources('tufte_html'), stylesheet = c(
      sprintf('tufte-%s.css', features), 'tufte.css',
      if (variant != 'default') sprintf('%s.css', variant)
    )
  ))
}

# we assume one footnote only contains one paragraph here, although it is
# possible to write multiple paragraphs in a footnote with Pandoc's Markdown
parse_footnotes = function(x, fn_label = 'fn') {
  i = which(x == '<div class="footnotes">')
  if (length(i) == 0) return(list(items = character(), range = integer()))
  j = which(x == '</div>')
  j = min(j[j > i])
  n = length(x)
  r = sprintf(
    '<li id="%s([0-9]+)"><p>(.+)<a href="#%sref\\1"([^>]*)>.</a></p></li>',
    fn_label, fn_label
  )
  list(
    items = gsub(r, '\\2', grep(r, x[i:n], value = TRUE)),
    range = i:j
  )
}

# move reference items from the bottom to the margin (as margin notes)
margin_references = function(x) {
  i = which(x == '<div id="refs" class="references">')
  if (length(i) != 1) return(x)
  # link-citations: no
  if (length(grep('<a href="#ref-[^"]+">([^<]+)</a>', x)) == 0) return(x)
  r = '^<div id="(ref-[^"]+)">$'
  k = grep(r, x)
  k = k[k > i]
  n = length(k)
  if (n == 0) return(x)
  # pandoc-citeproc may generate a link on both the year and the alphabetic
  # suffix, e.g. <a href="#cite-key">2016</a><a href="#cite-key">a</a>; we need
  # to merge the two links
  x = gsub('(<a href="#[^"]+">)([^<]+)</a>\\1([^<]+)</a>', '\\1\\2\\3</a>', x)
  ids = gsub(r, '\\1', x[k])
  ids = sprintf('<a href="#%s">([^<]+)</a>', ids)
  ref = gsub('^<p>|</p>$', '', x[k + 1])
  # replace 3 em-dashes with author names
  dashes = paste0('^', intToUtf8(rep(8212, 3)), '[.]')
  for (j in grep(dashes, ref)) {
    ref[j] = sub(dashes, sub('^([^.]+[.])( .+)$', '\\1', ref[j - 1]), ref[j])
  }
  ref = marginnote_html(paste0('\\1<span class="marginnote">', ref, '</span>'))
  for (j in seq_len(n)) {
    x = gsub(ids[j], ref[j], x)
  }
  x[-(i:(max(k) + 3))]  # remove references at the bottom
}

marginnote_html = function(text = '', icon = '&#8853;') {
  sprintf(paste0(
    '<label for="tufte-mn-" class="margin-toggle">%s</label>',
    '<input type="checkbox" id="tufte-mn-" class="margin-toggle">%s'
  ), icon, text)
}
