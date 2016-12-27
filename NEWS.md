# CHANGES IN tufte VERSION 0.3 (unreleased)

## NEW FEATURES

- It is possible to select a subset of some features of the default Tufte style (`tufte-css`) via the `tufte_features` argument of `tufte_html()`. For example, you can disable the `et-book` fonts and the background color.

- A new variant of the Tufte style, `envisioned`, is added to `tufte_html()`. You can use `tufte_html(tufte_variant = 'envisioned')` to enable this style. The major difference with the default Tufte style is: the font family is `Roboto Condensed`, the background color is `#fefefe`, and the text color is `#222` (thanks, @eddelbuettel, #21).

## BUG FIXES

- when `link-citations: no` in YAML, citations should not be moved into the page margin in the HTML output (http://stackoverflow.com/q/39053097/559676)

- horizontal lines could bisect margin notes and footnotes (thanks, @ajdamico, #32)

# CHANGES IN tufte VERSION 0.2

## NEW FEATURES

- it is possible to generate PDF output using the ctex package for R Markdown documents in Chinese; you just need to specify `ctex: yes` in the YAML metadata

## BUG FIXES

- the default LaTeX template for `tufte_handout()` may not work when the LaTeX
  package **soul** is installed, or **ifxetex**/**xltxtra** are not installed

- the `number_sections` option did not work for LaTeX output

# CHANGES IN tufte VERSION 0.1

## NEW FEATURES

- added three output formats for R Markdown: `tufte_html()`, `tufte_handout()`, 
and `tufte_book()`
