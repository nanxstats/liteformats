# liteformats

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/liteformats)](https://cran.r-project.org/package=liteformats)
[![R-CMD-check](https://github.com/nanxstats/liteformats/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/nanxstats/liteformats/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

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

## Learn more

Start with [Get started with liteformats](https://nanx.me/liteformats/articles/liteformats.html).
The shared guides cover [configuration](https://nanx.me/liteformats/articles/config.html),
[typography](https://nanx.me/liteformats/articles/typography.html),
and [automated builds](https://nanx.me/liteformats/articles/workflows.html).

For format-specific metadata and authoring, see
[resumes](https://nanx.me/liteformats/articles/resume.html) and
[cover letters](https://nanx.me/liteformats/articles/cover-letter.html).
