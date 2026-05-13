# pkg_file() ---------------------------------------------------------------

test_that("pkg_file() resolves to inst/ when loaded via pkgload", {
  patches_dir <- pkg_file("rmarkdown", "templates", "tufte_handout", "patches")
  expect_true(dir.exists(patches_dir))
  expect_true(file.exists(file.path(patches_dir, "tufte-common.def")))
  if (devtools_loaded("tufte")) {
    expect_match(patches_dir, file.path("inst", "rmarkdown"), fixed = TRUE)
  }
})

# PDF rendering ------------------------------------------------------------

local_render_pdf <- function(input, .env = parent.frame()) {
  skip_if_not_pandoc()
  skip_if_not_tinytex()
  output_file <- withr::local_tempfile(.local_envir = .env, fileext = ".pdf")
  # clean = FALSE preserves the .log file for post-render inspection.
  # Muffle bibentry warnings: tufte-latex uses \nobibliography* which triggers
  # advisories when no \bibliography follows. This is inherent to the class
  # and unrelated to what these tests exercise.
  withCallingHandlers(
    rmarkdown::render(
      input,
      output_file = output_file,
      quiet = TRUE,
      clean = FALSE
    ),
    warning = function(w) {
      if (
        grepl(
          "bibentry|nobibliography",
          conditionMessage(w),
          ignore.case = TRUE
        )
      ) {
        invokeRestart("muffleWarning")
      }
    }
  )
}

test_that("tufte_handout renders a basic PDF without error (#127)", {
  skip_on_cran()
  rmd <- local_rmd_file(
    "---",
    "output: tufte::tufte_handout",
    "---",
    "",
    "Hello world.",
    .env = parent.frame()
  )
  output <- local_render_pdf(rmd)
  expect_true(file.exists(output))
})

# margin_fig_pos chunk option (#62) ----------------------------------------

local_render_tex <- function(rmd_lines, .env = parent.frame()) {
  skip_if_not_pandoc()
  skip_if_not_tinytex()
  rmd <- local_rmd_file(rmd_lines, .env = .env)
  output <- withr::local_tempfile(.local_envir = .env, fileext = ".pdf")
  withCallingHandlers(
    rmarkdown::render(rmd, output_file = output, quiet = TRUE, clean = FALSE),
    warning = function(w) {
      if (
        grepl(
          "bibentry|nobibliography|Marginpar",
          conditionMessage(w),
          ignore.case = TRUE
        )
      ) {
        invokeRestart("muffleWarning")
      }
    }
  )
  tex_file <- xfun::with_ext(output, "tex")
  if (!file.exists(tex_file)) {
    skip("keep_tex did not produce a .tex file")
  }
  xfun::read_utf8(tex_file)
}

test_that("margin_fig_pos via YAML sets the marginfigure offset (#62)", {
  skip_on_cran()
  tex <- local_render_tex(c(
    "---",
    "output:",
    "  tufte::tufte_handout:",
    "    keep_tex: true",
    "    margin_fig_pos: '0.5cm'",
    "---",
    "",
    "```{r fig.margin=TRUE, fig.cap='test', echo=FALSE}",
    "plot(1:5)",
    "```",
    "",
    "Text after."
  ))
  marginfig <- grep("\\\\begin\\{marginfigure\\}", tex, value = TRUE)
  expect_length(marginfig, 1)
  expect_match(marginfig, "[0.5cm]", fixed = TRUE)
})

test_that("margin_fig_pos via opts_chunk$set works (#62)", {
  skip_on_cran()
  tex <- local_render_tex(c(
    "---",
    "output:",
    "  tufte::tufte_handout:",
    "    keep_tex: true",
    "---",
    "",
    "```{r setup, include=FALSE}",
    "knitr::opts_chunk$set(margin_fig_pos = '0.5cm')",
    "```",
    "",
    "```{r fig.margin=TRUE, fig.cap='test', echo=FALSE}",
    "plot(1:5)",
    "```",
    "",
    "Text after."
  ))
  marginfig <- grep("\\\\begin\\{marginfigure\\}", tex, value = TRUE)
  expect_length(marginfig, 1)
  expect_match(marginfig, "[0.5cm]", fixed = TRUE)
})

test_that("fig.pos overrides margin_fig_pos on a specific chunk (#62)", {
  skip_on_cran()
  tex <- local_render_tex(c(
    "---",
    "output:",
    "  tufte::tufte_handout:",
    "    keep_tex: true",
    "    margin_fig_pos: '0.5cm'",
    "---",
    "",
    "```{r fig.margin=TRUE, fig.pos='2cm', fig.cap='test', echo=FALSE}",
    "plot(1:5)",
    "```",
    "",
    "Text after."
  ))
  marginfig <- grep("\\\\begin\\{marginfigure\\}", tex, value = TRUE)
  expect_length(marginfig, 1)
  # fig.pos takes precedence
  expect_match(marginfig, "[2cm]", fixed = TRUE)
})

test_that("margin_fig_pos does not affect regular figures (#62)", {
  skip_on_cran()
  tex <- local_render_tex(c(
    "---",
    "output:",
    "  tufte::tufte_handout:",
    "    keep_tex: true",
    "    margin_fig_pos: '0.5cm'",
    "---",
    "",
    "```{r fig.cap='regular figure', echo=FALSE}",
    "plot(1:5)",
    "```",
    "",
    "Text after."
  ))
  # Regular figure should NOT have the margin offset
  figure_lines <- grep("\\\\begin\\{figure\\}", tex, value = TRUE)
  expect_false(any(grepl("0.5cm", figure_lines, fixed = TRUE)))
})

# tufte_handout2 / tufte_book2 (bookdown wrappers, issue #60) ---------------

test_that("tufte_handout2() renders a basic PDF", {
  skip_on_cran()
  skip_if_not_installed("bookdown")
  rmd <- local_rmd_file(
    "---",
    "output: tufte::tufte_handout2",
    "---",
    "",
    "Hello world."
  )
  output <- local_render_pdf(rmd)
  expect_true(file.exists(output))
})

test_that("tufte_handout2() resolves text references in fig.cap (#60)", {
  skip_on_cran()
  skip_if_not_installed("bookdown")
  tex <- local_render_tex(c(
    "---",
    "output:",
    "  tufte::tufte_handout2:",
    "    keep_tex: true",
    "---",
    "",
    "(ref:cars-cap) A plot of the [cars data set](https://stat.ethz.ch/R-manual/R-devel/library/datasets/html/cars.html).",
    "",
    "```{r cars-plot, fig.cap='(ref:cars-cap)', echo=FALSE}",
    "plot(cars)",
    "```"
  ))
  cap_lines <- grep("\\\\caption", tex, value = TRUE)
  expect_true(
    any(grepl("\\\\href\\{", cap_lines)),
    info = "fig.cap should contain \\href from resolved text reference"
  )
  # Raw markdown link syntax should NOT appear
  expect_false(
    any(grepl("](https://", cap_lines, fixed = TRUE)),
    info = "Raw markdown link should not appear in \\caption"
  )
})

test_that("tufte_book2() renders a basic PDF", {
  skip_on_cran()
  skip_if_not_installed("bookdown")
  rmd <- local_rmd_file(
    "---",
    "output: tufte::tufte_book2",
    "---",
    "",
    "Hello world."
  )
  output <- local_render_pdf(rmd)
  expect_true(file.exists(output))
})

test_that("check_bookdown() errors when bookdown is not available", {
  skip_on_cran()
  local_mocked_bindings(
    pkg_available = function(...) FALSE,
    .package = "xfun"
  )
  expect_error(check_bookdown(), "bookdown.*required")
})

test_that("tufte_handout PDF log contains no xcolor usenames warning (#127)", {
  skip_on_cran()
  rmd <- local_rmd_file(
    "---",
    "output: tufte::tufte_handout",
    "---",
    "",
    "Hello world.",
    .env = parent.frame()
  )
  output <- local_render_pdf(rmd)
  log_file <- xfun::with_ext(output, "log")
  skip_if(!file.exists(log_file), "LaTeX log not found")
  log_lines <- xfun::read_utf8(log_file)
  expect_false(
    any(grepl("usenames.*obsolete", log_lines, ignore.case = TRUE)),
    label = "xcolor 'usenames' obsolete warning found in LaTeX log"
  )
})
