# Changelog

## liteformats (development version)

### Improvements

- Changed resume pagination to fill pages one rendered line at a time,
  even within multi-line and nested list items. Removed keep-together,
  widow, and orphan hints from the resume so authors retain direct
  control over breaks through content and page geometry
  ([\#47](https://github.com/nanxstats/liteformats/issues/47)).
- Refined resume list markers with explicit `U+2022` and `U+25E6`
  glyphs, with better indentation, spacing, optical sizing, and
  alignment matching similar LaTeX templates
  ([\#46](https://github.com/nanxstats/liteformats/issues/46)).
- Updated the cover letter signature name to upright text at the same
  size as the body copy, following standard letter formatting convention
  ([\#45](https://github.com/nanxstats/liteformats/issues/45)).

## liteformats 0.2.0

CRAN release: 2026-08-24

### New features

- Added
  [`liteformats::include_graphics()`](https://nanx.me/liteformats/reference/include_graphics.md)
  to embed local images as base64 data URIs in raw HTML that can be
  emitted directly from litedown code chunks. Added a bundled signature
  image to the cover letter starter
  ([\#20](https://github.com/nanxstats/liteformats/issues/20)).

### Bug fixes

- Fixed overly aggressive resume pagination that treated complete
  experiences and list-based sections as indivisible, leaving large gaps
  at page bottoms. Resume entries now fill the available page and
  continue across pages at normal paragraph and list boundaries while
  retaining compact list indentation
  ([\#8](https://github.com/nanxstats/liteformats/issues/8)).

### Improvements

- Simplified
  [`resume()`](https://nanx.me/liteformats/reference/resume.md) and
  [`cover_letter()`](https://nanx.me/liteformats/reference/cover_letter.md)
  to four primary arguments. Secondary metadata, typography, pagination,
  and PDF controls now live in classed
  [`resume_options()`](https://nanx.me/liteformats/reference/resume_options.md)
  and
  [`cover_letter_options()`](https://nanx.me/liteformats/reference/cover_letter_options.md)
  objects. The same internal option schema can be reused by future
  document formats, and the canonical YAML configuration is now checked
  for unknown names
  ([\#12](https://github.com/nanxstats/liteformats/issues/12)).
- Refactored opt-in Google Fonts loading to use bundled font metadata.
  Font family names now request the available weights and styles needed
  for regular, bold, italic, and bold-italic text, prefer variable
  weight and slant ranges, and omit unsupported combinations. Full CSS
  v2 URLs remain supported for custom axes and newer families. A
  maintainer script was added to refresh the catalog without Google API
  credentials
  ([\#10](https://github.com/nanxstats/liteformats/issues/10)).
- Matched resume section divider rules to LaTeX’s 0.4 TeX point rule
  thickness, using a scaled rule to avoid Chromium’s 1px minimum for CSS
  borders in PDF output
  ([\#21](https://github.com/nanxstats/liteformats/issues/21)).

### Documentation

- Qualified the namespaces in code examples of the README so they become
  self-contained. Removed configuration, typography, and automation
  details and redirect to the vignette to reduce duplication
  ([\#14](https://github.com/nanxstats/liteformats/issues/14)).

## liteformats 0.1.0

CRAN release: 2026-08-05

### New features

- Added [`resume()`](https://nanx.me/liteformats/reference/resume.md)
  and
  [`cover_letter()`](https://nanx.me/liteformats/reference/cover_letter.md)
  formats for self-contained HTML and direct PDF output through a
  Chromium-based browser
  ([\#1](https://github.com/nanxstats/liteformats/issues/1)).
- Added
  [`use_resume()`](https://nanx.me/liteformats/reference/use_resume.md)
  and
  [`use_cover_letter()`](https://nanx.me/liteformats/reference/use_resume.md)
  starter documents based on reusable Markdown content and packaged
  HTML, CSS, and pages.js assets.
- Added flexible controls for paper size, margins, spacing, link color,
  ligatures, font scaling, local font embedding, and opt-in Google
  Fonts.

### Testing

- Added testit coverage for starter creation, option handling, HTML
  rendering, font embedding, pagination, and PDF dispatch.

### Documentation

- Added a README quick start and a litedown-built vignette covering
  formats, typography, ATS considerations, semantic resume entries, and
  Makefile automation.
- Documented complete, matching HTML and PDF calls for both resume and
  cover letter starters.

### Maintenance

- Vendored the MIT-licensed pages.js runtime for offline builds and
  added a maintainer script that refreshes it from the upstream source
  archive.
- Credited the author and copyright holder of the bundled pages.js
  assets in `Authors@R`, and documented template styling lessons for
  maintainers.
