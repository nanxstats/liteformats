# AGENTS.md

## Package design

- Keep liteformats HTML-first. Do not add rmarkdown, Pandoc, or LaTeX to
  the rendering path.
- Public document APIs currently consist of
  [`resume()`](https://nanx.me/liteformats/reference/resume.md),
  [`cover_letter()`](https://nanx.me/liteformats/reference/cover_letter.md),
  [`use_resume()`](https://nanx.me/liteformats/reference/use_resume.md),
  and
  [`use_cover_letter()`](https://nanx.me/liteformats/reference/use_resume.md).
  The output extension selects HTML or PDF.
- Rendering is intentionally two-stage:
  `litedown::fuse(..., "markdown")` evaluates R and YAML, then
  [`litedown::mark()`](https://rdrr.io/pkg/litedown/man/mark.html)
  applies the package’s custom HTML template. Preserve this order so
  inline R dates and metadata work.
- PDF output is the self-contained HTML printed by
  [`xfun::browser_print()`](https://rdrr.io/pkg/xfun/man/browser_print.html).
  Chrome/Chromium is a runtime requirement only, never a build
  requirement.

## Assets

- Runtime assets belong under `inst/liteformats/`.
- `inst/liteformats/js/pages.js` and `css/pages.css` are exact
  MIT-licensed copies from the upstream lite.js repository. Refresh them
  and the bundled license with `Rscript tools/update-pages.R`; the
  maintainer script downloads the main-branch source archive and
  therefore requires internet access.
- Never replace local pages.js with the CDN shorthand `@pages`. CRAN
  builds and the default formats must work without network access.

## Typography

- Local OTF, TTF, WOFF, and WOFF2 user fonts are embedded as data URIs.
  Google Fonts support is explicit opt-in and may use the network at
  render time.
- Keep ligatures disabled by default for reliable ATS text extraction.
  Expose font scale, line height, paragraph and section spacing,
  margins, paper size, and link color as both YAML settings and R
  arguments.
- Keep the cover letter’s letterhead and body in two columns at every
  viewport width. It is a fixed-page composition, and narrow IDE preview
  panes must not trigger a single-column responsive layout.
- Read `tools/template-styling.md` before changing resume list CSS. Test
  the actual CommonMark HTML in unpaged HTML, pages.js output, and PDF
  because list structure, browser defaults, and pagination all affect
  spacing and markers.
- Preserve the resume’s `pagesjs:before` entry flattening. pages.js
  treats a multi-child `<div>` as indivisible and does not use CSS
  `break-*` rules for its element-placement decisions, so keep-together
  wrappers around entries or heading/list sections can leave large page
  gaps.
- Do not redistribute any local fonts: no redistributable license was
  found. They may be used locally for visual comparison only.

## Documentation and checks

- Use roxygen2 and run `devtools::document()` after public API changes.
- Use testit, not testthat. The test entry point is `tests/test-all.R`.
- Build vignettes with litedown. Vignettes must not render PDFs or
  request web fonts, because those would add browser or network
  requirements to checks.
- Show Makefile-based workflows when documenting repeatable or
  customized document builds; keep examples small and expose the
  underlying R commands.
- Give every document format its own complete, copyable starter, HTML,
  and PDF example. Keep function names explicit so examples cannot imply
  that [`resume()`](https://nanx.me/liteformats/reference/resume.md)
  also renders cover letters.
- Run `devtools::check()` before handoff. Do not commit or push.
