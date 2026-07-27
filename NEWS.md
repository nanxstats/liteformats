# liteformats (development version)

## Bug fixes

- Fixed overly aggressive resume pagination that treated complete experiences
  and list-based sections as indivisible, leaving large gaps at page bottoms.
  Resume entries now fill the available page and continue across pages at
  normal paragraph and list boundaries while retaining compact list
  indentation (#8).

## Improvements

- Refactored opt-in Google Fonts loading to use bundled font metadata.
  Font family names now request the available weights and styles needed for
  regular, bold, italic, and bold-italic text, prefer variable weight and
  slant ranges, and omit unsupported combinations. Full CSS v2 URLs remain
  supported for custom axes and newer families. A maintainer script was added
  to refresh the catalog without Google API credentials (#10).

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
