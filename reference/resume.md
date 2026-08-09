# Render a resume

Render a Markdown or R Markdown resume to a self-contained HTML document
or to PDF through a headless Chromium-based browser. The output format
is inferred from the extension of `output`.

## Usage

``` r
resume(
  input,
  output = NULL,
  options = resume_options(),
  envir = parent.frame()
)
```

## Arguments

- input:

  Path to a `.Rmd` or `.md` source document.

- output:

  Output path ending in `.html` or `.pdf`. If `NULL`, an HTML file is
  created beside `input`.

- options:

  A resume configuration created by
  [`resume_options()`](https://nanx.me/liteformats/reference/resume_options.md).

- envir:

  Environment in which R code in `input` is evaluated.

## Value

The normalized output path, invisibly.

## Details

Document metadata and typographic settings may be supplied in the YAML
header. Values in `options` take precedence over YAML. See
[`resume_options()`](https://nanx.me/liteformats/reference/resume_options.md)
for function-call configuration and
[`use_resume()`](https://nanx.me/liteformats/reference/use_resume.md)
for a complete starter.

## Examples

``` r
source <- use_resume(tempfile(fileext = ".Rmd"))
resume(source, tempfile(fileext = ".html"))

if (FALSE) { # \dontrun{
# PDF output requires a local Chromium-based browser
resume(source, "resume.pdf")

# Embed local font files
resume(
  source,
  options = resume_options(
    font_files = c(
      regular = "fonts/MySerif-Regular.woff2",
      italic = "fonts/MySerif-Italic.woff2",
      bold = "fonts/MySerif-Bold.woff2"
    ),
    font_scale = 0.96,
    ligatures = FALSE
  )
)
} # }
```
