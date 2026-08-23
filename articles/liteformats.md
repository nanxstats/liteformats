# Get started with liteformats

liteformats provides lightweight document formats for
[litedown](https://github.com/yihui/litedown). Source documents use
Markdown with YAML metadata and can contain R code. The rendered output
is self-contained HTML or a PDF printed from that HTML.

## Choose a format

Each format has a starter, a renderer, and an options helper. Keep these
functions together when creating and rendering a document.

### Resume

Copy the resume starter, edit its YAML and Markdown, and render either
output:

``` r

liteformats::use_resume("resume.Rmd")
liteformats::resume("resume.Rmd", "resume.html")
liteformats::resume("resume.Rmd", "resume.pdf")
```

See
[`vignette("resume")`](https://nanx.me/liteformats/articles/resume.md)
for the format’s metadata and entry syntax.

### Cover letter

Use the cover letter starter with its matching renderer:

``` r

liteformats::use_cover_letter("cover-letter.Rmd")
liteformats::cover_letter("cover-letter.Rmd", "cover-letter.html")
liteformats::cover_letter("cover-letter.Rmd", "cover-letter.pdf")
```

See
[`vignette("cover-letter")`](https://nanx.me/liteformats/articles/cover-letter.md)
for its metadata and fixed two-column composition.

## Choose an output

The output extension selects the result. HTML output is self-contained
and does not need a browser. PDF output first creates the same HTML,
then prints it with
[`xfun::browser_print()`](https://rdrr.io/pkg/xfun/man/browser_print.html).
A local Chromium-based browser is therefore required for PDF output
only.

If `output` is omitted, the renderer writes an HTML file beside the
source. Both renderers return the normalized output path invisibly.

## Continue with the guides

- [`vignette("config")`](https://nanx.me/liteformats/articles/config.md)
  explains YAML, R options, and precedence.
- [`vignette("typography")`](https://nanx.me/liteformats/articles/typography.md)
  covers type, spacing, font sources, and reliable text extraction.
- [`vignette("workflows")`](https://nanx.me/liteformats/articles/workflows.md)
  shows a small `Make` workflow for repeatable HTML and PDF builds.
