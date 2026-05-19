## Package

R package `tufte` — R Markdown output formats apply Edward Tufte styling to HTML + PDF. CRAN releases live on `main`.

## Common commands

```r
devtools::load_all()
devtools::test()
devtools::test(filter = "utils")                   # one test file: tests/testthat/test-utils.R
testthat::test_file("tests/testthat/test-utils.R")
devtools::document()                               # regenerate Rd + NAMESPACE from roxygen
devtools::check()                                  # full R CMD check
urlchecker::url_check()                            # for CRAN URL hygiene
revdepcheck::revdep_check(num_workers = 4)         # revdep run; results in revdep/
```

Package use testthat 3 (`Config/testthat/edition: 3`).

## Refresh upstream assets

Two assets vendored from upstream, refreshed via scripts in `tools/`:

- **`tools/update-tufte-common-def.R`** — downloads `tufte-common.def` from `Tufte-LaTeX/tufte-latex`, re-applies package LaTeX patches (e.g., remove obsolete `usenames` xcolor option, #127). Run after upstream changes; review diff, add new patch entries inline.
- **`tools/copy-tufte-css.sh`** — copies CSS + `et-book` fonts from sibling `tufte-css/` checkout into `inst/rmarkdown/templates/tufte_html/resources/`. Requires `tufte-css/` cloned next to `tufte/`.

## Architecture

### Output formats (R/)

`R/handout.R` + `R/html.R` expose public output formats. Each builds on `rmarkdown::pdf_document()` / `rmarkdown::html_document()`, then overrides `knitr` hooks/engines + `pandoc$args` to inject Tufte behavior:

- `tufte_handout()` / `tufte_book()` — LaTeX path. Both delegate to internal `tufte_pdf()` selecting `tufte-handout` or `tufte-book` document class.
- `tufte_html()` — HTML path. Adds `tufte-css` `htmlDependency`, rewrites footnotes to sidenotes, turns citations + figure/table captions into margin notes via `post_processor`.
- `tufte_handout2()`, `tufte_book2()`, `tufte_html2()` — wrappers around `bookdown::pdf_book()` / `bookdown::html_document2()` enabling text references + cross-references. `bookdown` is `Suggests` dep; `check_bookdown()` enforces.

### Cross-format inline helpers (R/utils.R)

`newthought()`, `margin_note()`, `quote_footer()`, `sans_serif()` used inline in R Markdown, must work in HTML, LaTeX, degraded other outputs. Branch on `knitr::is_html_output()` / `knitr::is_latex_output()`.

`quote_footer()` also must distinguish *tufte* HTML from non-tufte HTML (Bootstrap-based `html_document` injects em-dash via `::before`, `tufte.css` does not). Detection use `tufte.format` entry registered in `knitr::opts_knit` by each tufte format (`"html"` for `tufte_html()`, `"handout"` for PDF formats). Tests mock via `local_knit_opts()` helper.

### LaTeX template patching

`inst/rmarkdown/templates/tufte_handout/patches/tufte-common.def` is patched copy of upstream. `tufte_pdf()` prepends `patches/` dir to `TEXINPUTS` in `pre_processor` so kpathsea finds it before system `tufte-common.def`. `format$on_exit` restores `TEXINPUTS` even if `render()` errors.

### HTML post-processing pipeline

`tufte_html()` `post_processor` rewrites HTML output line-by-line:

1. `parse_footnotes()` extracts footnote items; each rewritten in-place as `<label>` + checkbox + `<span class="sidenote">` triple, trailing footnotes `<div>` removed.
2. `margin_references()` (when `margin_references = TRUE`) lifts pandoc-citeproc reference list entries into `<span class="marginnote">` blocks at citation site, drops bottom reference list.
3. Figure/table captions get `class="caption marginnote shownote"` so they render in margin.
4. Tufte margin-note `<label>`/`<input>` IDs renumbered so multiple notes don't collide.

Figure plot hook (set on `knitr$knit_hooks$plot`) handles `fig.margin = TRUE` + `fig.fullwidth = TRUE` chunk options by wrapping figure HTML in `marginnote` / `fullwidth` containers. Regex must tolerate optional `style=` attribute knitr adds when `fig.align` set (#54). When `fig.margin = TRUE` detected, `fig.beforecode = TRUE` also set via `opts_hooks` callback so margin plots render before code block.

### Margin figures (PDF)

`tufte_handout()` accepts `margin_fig_pos` (LaTeX length like `"0cm"` or `"-5pt"`) applied as `fig.pos` only on chunks with `fig.margin = TRUE`. Setting `fig.pos` globally via `opts_chunk` would break regular figures since their `fig.pos` is placement specifier (`"htbp"`), not length (#62).

### Knitr engines

Both formats register `marginfigure` engine (overrides placeholder set in `.onLoad`):

- HTML: rewrites to `marginnote` block with `html.before` injecting toggle markup.
- PDF: rewrites to `marginfigure` LaTeX environment via knitr `block` engine.

## Testing patterns

`tests/testthat/helpers.R` defines standard fixtures used across all test files:

- `skip_if_not_pandoc(ver)` / `skip_if_pandoc(ver)` / `skip_if_not_tinytex()` — version- + tool-aware skips. Integration tests always skip when tool unavailable rather than fail.
- `local_rmd_file(...)` — write lines to tempfile `.Rmd` with `withr` cleanup.
- `local_render(input, ...)` — `rmarkdown::render()` to tempfile, quiet.
- `local_pandoc_convert(text, ...)` — direct `pandoc_convert()` for tests not needing rendering.
- `local_knit_opts(...)` — temporarily set entries in `knitr::opts_knit`, restored via `withr::defer`. Use when testing helpers branching on `knitr::opts_knit$get("tufte.format")`.

Unit tests mock `knitr::is_html_output` / `is_latex_output` via `local_mocked_bindings()` to exercise format-branching without spinning up pandoc.

## CI matrix

`.github/workflows/R-CMD-check.yaml` runs against unusually wide pandoc matrix. Several runtime regexes depend on pandoc HTML output shape, fixed for specific pandoc versions (e.g. `--wrap preserve` for pandoc 2.0+, citation rewriting for pandoc 2.11+). When changing post-processing regex, test against multiple pandoc versions if possible.

## CRAN release

`cran-comments.md` + `revdep/` are CRAN submission artifacts. `tufte` has CRAN reverse dependencies — run `revdepcheck` before submission.
