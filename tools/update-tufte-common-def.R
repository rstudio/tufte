#!/usr/bin/env Rscript

# update-tufte-common-def.R
#
# Downloads the latest tufte-common.def from upstream (Tufte-LaTeX/tufte-latex)
# and re-applies the patches maintained by this package.
#
# Usage:
#   Rscript tools/update-tufte-common-def.R
#
# After running, review the diff and run tests:
#   git diff inst/rmarkdown/templates/tufte_handout/patches/tufte-common.def
#   devtools::test()

upstream_url <- "https://raw.githubusercontent.com/Tufte-LaTeX/tufte-latex/master/tufte-common.def"
target <- file.path(
  "inst",
  "rmarkdown",
  "templates",
  "tufte_handout",
  "patches",
  "tufte-common.def"
)

# --- Download upstream ---
message("Downloading upstream tufte-common.def ...")
tmp <- tempfile(fileext = ".def")
invisible(xfun::download_file(upstream_url, tmp, quiet = TRUE))
upstream <- xfun::read_utf8(tmp)
message(sprintf("  Downloaded %d lines.", length(upstream)))

# Extract version from \ProvidesFile line
provides <- grep(
  "\\\\ProvidesFile\\{tufte-common.def\\}",
  upstream,
  value = TRUE
)
if (length(provides)) {
  message("  Upstream version: ", trimws(provides))
}

# --- Apply patches ---
patched <- upstream
patches_applied <- character()

# Patch 1: Remove obsolete 'usenames' from xcolor options (GitHub #127)
xcolor_pat <- "\\\\RequirePackage\\[usenames,dvipsnames,svgnames\\]\\{xcolor\\}"
idx <- grep(xcolor_pat, patched)
if (length(idx) == 1) {
  patched[idx] <- sub("usenames,", "", patched[idx])
  patches_applied <- c(
    patches_applied,
    paste0(
      "%%   1. Line ~",
      idx,
      ": Removed obsolete 'usenames' option from \\RequirePackage{xcolor}",
      "\n%%      to suppress warning in xcolor >= 2.12 (TeX Live 2022+). (GitHub #127)"
    )
  )
  message(sprintf("  Patch 1 applied at line %d (xcolor usenames).", idx))
} else if (length(idx) == 0) {
  if (
    any(grepl(
      "\\\\RequirePackage\\[dvipsnames,svgnames\\]\\{xcolor\\}",
      patched
    ))
  ) {
    message("  Patch 1 skipped: usenames already removed upstream.")
  } else {
    warning(
      "  Patch 1: could not find xcolor RequirePackage line. Manual review needed."
    )
  }
}

# Patch 2: Route natbib's \citep and \citet through the margin sidenote
# machinery, so pandoc-generated citations (citation_package: natbib) land
# in the margin like native \cite does. (GitHub #48)
# Anchor to the top-level redirect (\let with no trailing comment), not the
# nested swaps inside \sidenote / \marginnote which carry the same \let line.
cite_pat <- "^  \\\\let\\\\cite\\\\@tufte@normal@cite$"
cite_idx <- grep(cite_pat, patched)
if (length(cite_idx) == 1) {
  # Find the closing }{} of the surrounding \ifthenelse block (next line
  # starting with `}{}`).
  block_end <- cite_idx +
    which(grepl("^\\}\\{\\}", patched[(cite_idx + 1):length(patched)]))[1]
  if (!is.na(block_end)) {
    insertion <- c(
      "",
      "%%",
      "% Route pandoc's natbib output to the margin (rstudio/tufte#48). Pandoc with",
      "% citation_package: natbib emits \\citep / \\citet for [@key] / @key, neither",
      "% of which tufte-latex normally redirects. Without these redefinitions",
      "% citations render inline as natbib's defaults, missing the margin entirely.",
      "% \\citeyearpar (emitted for [-@key]) is left inline by design. Optional",
      "% prefix/locator arguments are dropped: \\citep[p.~5]{key} still places the",
      "% full bibentry in the margin but does not echo the locator.",
      "",
      "\\ifthenelse{\\boolean{@tufte@loadnatbib}}{%",
      "  \\RenewDocumentCommand{\\citep}{o o m}{\\cite{#3}}%",
      "  \\RenewDocumentCommand{\\citet}{o o m}{\\citeauthor{#3}~(\\citeyear{#3})\\cite{#3}}%",
      "}{}"
    )
    patched <- c(
      patched[seq_len(block_end)],
      insertion,
      patched[(block_end + 1):length(patched)]
    )
    patches_applied <- c(
      patches_applied,
      paste0(
        "%%   2. After line ~",
        block_end,
        ": Redefined \\citep / \\citet to route through tufte's margin\n",
        "%%      sidenote machinery so pandoc natbib citations land in the margin. (GitHub #48)"
      )
    )
    message(sprintf(
      "  Patch 2 applied after line %d (\\citep / \\citet redirect).",
      block_end
    ))
  } else {
    warning(
      "  Patch 2: could not find end of \\let\\cite block. Manual review needed."
    )
  }
} else {
  warning(
    "  Patch 2: could not find \\let\\cite\\@tufte@normal@cite. Manual review needed."
  )
}

# --- Build header ---
header <- c(
  "%%",
  "%% This file contains the code that is common to the Tufte-LaTeX document classes.",
  "%%",
  "%% PATCHED by the tufte R package (https://github.com/rstudio/tufte).",
  "%%",
  "%% Upstream source:",
  "%%   Repo:    https://github.com/Tufte-LaTeX/tufte-latex",
  "%%   File:    tufte-common.def",
  paste0("%%   Updated: ", Sys.Date()),
  "%%",
  "%% To refresh from upstream, run:",
  "%%   Rscript tools/update-tufte-common-def.R",
  "%%",
  if (length(patches_applied)) {
    c(
      "%% Patches applied:",
      patches_applied
    )
  } else {
    "%% No patches needed (all fixes already present upstream)."
  },
  "%%"
)

# Insert header before \ProvidesFile
provides_idx <- grep("\\\\ProvidesFile\\{tufte-common.def\\}", patched)
if (length(provides_idx) == 1) {
  # Replace upstream's own header (lines before \ProvidesFile) with ours
  patched <- c(header, "", patched[provides_idx:length(patched)])
}

# --- Write ---
dir.create(dirname(target), recursive = TRUE, showWarnings = FALSE)
xfun::write_utf8(patched, target)
message(sprintf("\nWritten to %s (%d lines).", target, length(patched)))
message("Review the diff:  git diff ", target)
