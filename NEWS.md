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
