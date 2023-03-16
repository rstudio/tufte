
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tufte

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/tufte)](https://CRAN.R-project.org/package=tufte)
[![Downloads from the RStudio CRAN
mirror](https://cranlogs.r-pkg.org/badges/tufte)](https://cran.r-project.org/package=tufte)
[![R-CMD-check](https://github.com/rstudio/tufte/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rstudio/tufte/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/rstudio/tufte/branch/main/graph/badge.svg)](https://app.codecov.io/gh/rstudio/tufte?branch=main)
<!-- badges: end -->

This R package provides a few R Markdown output formats that use the
Tufte style. See <https://rstudio.github.io/tufte/> for a comprehensive
example.

## Books

<a href="https://bookdown.org/yihui/rmarkdown/tufte-handouts.html"><img src="https://bookdown.org/yihui/rmarkdown/images/cover.png" alt="R Markdown: The Definitive Guide" class="book" height="400"/></a>

See about the Tufte Handouts format in R Markdown Definitive Guide

## Installation

You can install the last available released version from
[CRAN](https://cran.r-project.org/package=tufte)

``` r
install.packages('tufte')
```

You can also install the development version of **tufte** from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("rstudio/tufte")
```

## Usage

The easiest way to make a new R Markdown document using Tufte style is
from within RStudio. Go to *File \> New File \> R Markdown \> From
template \> Tufte Handout*.

This can also be created from the command line using

``` r
rmarkdown::draft("tufte.Rmd", "tufte_html", "tufte")
```

## Getting help

There are two main places to get help:

1.  The [RStudio
    community](https://community.rstudio.com/c/r-markdown/10) is a
    friendly place to ask any questions about rmarkdown and the R
    Markdown family of packages. Use tag **tufte** in your post.

2.  [Stack
    Overflow](https://stackoverflow.com/questions/tagged/r-markdown+tufte)
    is a great source of answers to common rmarkdown questions. It is
    also a great place to get help, once you have created a reproducible
    example that illustrates your problem.
