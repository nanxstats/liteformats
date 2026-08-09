# Render a cover letter

Render a two-column cover letter to self-contained HTML or PDF. The
narrow left column holds the sender's details, while the letter remains
the visual foreground in the wider right column.

## Usage

``` r
cover_letter(
  input,
  output = NULL,
  options = cover_letter_options(),
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

  A cover letter configuration created by
  [`cover_letter_options()`](https://nanx.me/liteformats/reference/cover_letter_options.md).

- envir:

  Environment in which R code in `input` is evaluated.

## Value

The normalized output path, invisibly.

## Examples

``` r
source <- use_cover_letter(tempfile(fileext = ".Rmd"))
cover_letter(source, tempfile(fileext = ".html"))

if (FALSE) { # \dontrun{
# PDF output requires a local Chromium-based browser
cover_letter(source, "cover-letter.pdf")
} # }
```
