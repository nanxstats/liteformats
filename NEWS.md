# liteformats 0.1.0

## New features

- Added `resume()` and `cover_letter()` formats for self-contained HTML and
  direct PDF output through a Chromium-based browser (#1).
- Added `use_resume()` and `use_cover_letter()` starter documents based on
  reusable Markdown content and packaged HTML, CSS, and pages.js assets.
- Added flexible controls for paper size, margins, spacing, link color,
  ligatures, font scaling, local font embedding, and opt-in Google Fonts.

## Testing

- Added testit coverage for starter creation, option handling, HTML rendering,
  font embedding, pagination, and PDF dispatch.

## Documentation

- Added a README quick start and a litedown-built vignette covering formats,
  typography, ATS considerations, semantic resume entries, and Makefile
  automation.
- Documented complete, matching HTML and PDF calls for both resume and cover
  letter starters.

## Maintenance

- Vendored the MIT-licensed pages.js runtime for offline builds and added a
  maintainer script that refreshes it from the upstream source archive.
- Credited the author and copyright holder of the bundled pages.js assets in
  `Authors@R`, and documented template styling lessons for maintainers.
