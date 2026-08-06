# liteformats

<!-- badges: start -->
[![R-CMD-check](https://github.com/nanxstats/liteformats/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/nanxstats/liteformats/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/liteformats)](https://cran.r-project.org/package=liteformats)
<!-- badges: end -->

``` text
.__  .__  __          _____                            __
|  | |__|/  |_  _____/ ____\___________  _____ _____ _/  |_  ______
|  | |  \   __\/ __ \   __\/  _ \_  __ \/     \\__  \\   __\/  ___/
|  |_|  ||  | \  ___/|  | (  <_> )  | \/  Y Y  \/ __ \|  |  \___ \
|____/__||__|  \___  >__|  \____/|__|  |__|_|  (____  /__| /____  >
                   \/                        \/     \/          \/
```

liteformats provides lightweight, carefully typeset document formats for
[litedown](https://github.com/yihui/litedown). The first formats are a
professional resume and a two-column cover letter. They use HTML and CSS,
paginate with a packaged copy of Yihui Xie's pages.js, and require neither
Pandoc nor LaTeX.

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

Use the matching `cover_letter()` renderer for the cover letter starter:

``` r
liteformats::use_cover_letter("cover-letter.Rmd")
liteformats::cover_letter("cover-letter.Rmd", "cover-letter.html")
liteformats::cover_letter("cover-letter.Rmd", "cover-letter.pdf")
```

HTML output is self-contained. A `.pdf` output path prints the HTML through
headless Chrome, which must be installed to create PDFs but is not needed for
HTML output.

## Customize and automate

Typography, spacing, margins, paper size, and link color can be configured in
the document YAML or with `liteformats::resume_options()` and
`liteformats::cover_letter_options()`. Local font files are embedded in the
output; Google Fonts are available as an explicit, network-dependent opt-in.
Ligatures are disabled by default to improve ATS text extraction.

For configuration examples, the resume entry syntax, cover letter metadata,
and a Makefile workflow for repeatable builds, see the
[resumes and cover letters vignette](https://nanx.me/liteformats/doc/formats.html).
