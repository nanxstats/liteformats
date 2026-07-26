# liteformats

<!-- badges: start -->
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

Load liteformats once per R session:

``` r
library(liteformats)
```

### Resume

Create the resume starter, then render it to self-contained HTML or PDF:

``` r
use_resume("resume.Rmd")
resume("resume.Rmd", "resume.html")
resume("resume.Rmd", "resume.pdf")
```

### Cover letter

Use the matching `cover_letter()` renderer for the cover-letter starter:

``` r
use_cover_letter("cover-letter.Rmd")
cover_letter("cover-letter.Rmd", "cover-letter.html")
cover_letter("cover-letter.Rmd", "cover-letter.pdf")
```

HTML output is self-contained. A `.pdf` output path prints the HTML through
headless Chrome.

## Automate builds with Make

Rendering from explicit R commands takes a little more setup than clicking a
Knit button, but it also makes the process easy to customize and combine with
other tools. Put repeatable commands in a `Makefile` to rebuild only documents
whose sources have changed:

``` make
.PHONY: all clean

all: resume.html resume.pdf cover-letter.html cover-letter.pdf

resume.html resume.pdf: resume.Rmd
	Rscript -e 'liteformats::resume("$<", "$@")'

cover-letter.html cover-letter.pdf: cover-letter.Rmd
	Rscript -e 'liteformats::cover_letter("$<", "$@")'

clean:
	$(RM) resume.html resume.pdf cover-letter.html cover-letter.pdf
```

Run `make` for all outputs or, for example, `make resume.pdf` for one. Extend
the recipes with any preprocessing, postprocessing, or project-specific options
needed to shape the documents into a particular look.

Core typography and fitting controls can live in the document's YAML:

``` yaml
liteformats:
  paper: letter
  margins: ["0.65in", "0.8in"]
  font-family: "Charter, Georgia, serif"
  font-size: 11pt
  font-scale: 0.94
  ligatures: false
  line-height: 1.15
  paragraph-spacing: 0.05em
  section-spacing: 1em
  link-color: "#385898"
```

They can also be supplied as renderer arguments. Local `.otf`, `.ttf`,
`.woff`, and `.woff2` files are embedded in the output:

``` r
resume(
  "resume.Rmd",
  "resume.pdf",
  font_files = c(
    regular = "fonts/MySerif-Regular.woff2",
    italic = "fonts/MySerif-Italic.woff2",
    bold = "fonts/MySerif-Bold.woff2"
  ),
  font_scale = 0.96,
  ligatures = FALSE
)
```

Set `google_font = "Source Serif 4"` to opt into a Google Fonts request at
render time. Package installation, checks, examples, and vignettes never need
network access.

Ligatures are disabled by default, but PDF text extraction can also depend on
the selected font's internal tables. When ATS parsing matters, inspect the
result with a tool such as `pdftotext resume.pdf -` before submitting it.
