# CHANGES IN tufte VERSION 0.4

## BUG FIXES

- Should use the Pandoc argument `--top-level-division=chapter` instead of `--chapters` for `tufte_book()` (thanks, @jtth, #52).

- Processing of multi-line footnotes fails with the Pandoc option `--wrap preserve` (thanks, @aoles, #57 #58).

# CHANGES IN tufte VERSION 0.3

## NEW FEATURES

- It is possible to select a subset of some features of the default Tufte style (`tufte-css`) via the `tufte_features` argument of `tufte_html()`:

    - Disable the `et-book` fonts.
    - Remove the default light-yellow background color.
    - Use italics for document headers or not.

- A new variant of the Tufte style, `envisioned`, is added to `tufte_html()`. You can use `tufte_html(tufte_variant = 'envisioned')` to enable this style. The major difference with the default Tufte style is: the font family is `Roboto Condensed`, the background color is `#fefefe`, and the text color is `#222` (thanks, @eddelbuettel, #21).

- You can choose whether references from citations should be placed in the document margins or at the bottom using the `margin_references` argument of `tufte_html()` (thanks, @stefanfritsch, #49).

## BUG FIXES

- When `link-citations: no` in YAML, citations should not be moved into the page margin in the HTML output (http://stackoverflow.com/q/39053097/559676).

- Horizontal lines could bisect margin notes and footnotes (thanks, @ajdamico, #32).

- Compatibility issues with Pandoc 2.0 (thanks, @peetCreative, #51).

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
