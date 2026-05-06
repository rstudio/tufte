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
