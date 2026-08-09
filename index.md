# liteformats

liteformats provides lightweight, carefully typeset document formats for
[litedown](https://github.com/yihui/litedown). The first formats are a
professional resume and a two-column cover letter. They use HTML and
CSS, paginate with a packaged copy of Yihui Xie’s pages.js, and require
neither Pandoc nor LaTeX.

## Installation

You can install the development version of liteformats from GitHub with:

``` r

# install.packages("pak")
pak::pak("nanxstats/liteformats")
```

## Usage

### Resume

Create the resume starter, then render it to self-contained HTML or PDF:

``` r

liteformats::use_resume("resume.Rmd")
liteformats::resume("resume.Rmd", "resume.html")
liteformats::resume("resume.Rmd", "resume.pdf")
```

### Cover letter

Use the matching
[`cover_letter()`](https://nanx.me/liteformats/reference/cover_letter.md)
renderer for the cover letter starter:

``` r

liteformats::use_cover_letter("cover-letter.Rmd")
liteformats::cover_letter("cover-letter.Rmd", "cover-letter.html")
liteformats::cover_letter("cover-letter.Rmd", "cover-letter.pdf")
```

HTML output is self-contained. A `.pdf` output path prints the HTML
through headless Chrome, which must be installed to create PDFs but is
not needed for HTML output.

## Customize and automate

Typography, spacing, margins, paper size, and link color can be
configured in the document YAML or with
[`liteformats::resume_options()`](https://nanx.me/liteformats/reference/resume_options.md)
and
[`liteformats::cover_letter_options()`](https://nanx.me/liteformats/reference/cover_letter_options.md).
Local font files are embedded in the output; Google Fonts are available
as an explicit, network-dependent opt-in. Ligatures are disabled by
default to improve ATS text extraction.

For configuration examples, the resume entry syntax, cover letter
metadata, and a Makefile workflow for repeatable builds, see the
[resumes and cover letters
vignette](https://nanx.me/liteformats/doc/formats.html).
