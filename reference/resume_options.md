# Configure a resume

Create a classed options object for
[`resume()`](https://nanx.me/liteformats/reference/resume.md). The
helper keeps secondary metadata, typography, page, and PDF controls out
of the main rendering function while retaining argument-name checking
and autocomplete.

## Usage

``` r
resume_options(
  author = NULL,
  job_title = NULL,
  address = NULL,
  phone = NULL,
  email = NULL,
  website = NULL,
  linkedin = NULL,
  font_family = NULL,
  google_font = NULL,
  font_files = NULL,
  font_size = NULL,
  font_scale = NULL,
  ligatures = NULL,
  line_height = NULL,
  paragraph_spacing = NULL,
  section_spacing = NULL,
  margins = NULL,
  paper = NULL,
  link_color = NULL,
  paged = NULL,
  keep_html = FALSE,
  browser = NULL
)
```

## Arguments

- author, address, phone, email, website:

  Contact metadata.

- job_title, linkedin:

  Resume-specific professional and contact metadata.

- font_family:

  A CSS `font-family` value. For example, `"Charter, Georgia, serif"`.

- google_font:

  A Google Fonts family name or a full Google Fonts CSS v2 URL. This is
  an explicit online resource and is never used by default. A family
  name loads the available weights and styles needed for regular, bold,
  italic, and bold italic text, preferring a variable weight range.
  Supply a full URL to select other weights, axes, or options.

- font_files:

  A named character vector or list of local font files. Names may be
  `regular`, `italic`, `bold`, and `bold_italic`. Relative paths are
  resolved from the source document. Fonts are embedded in the HTML.

- font_size:

  A CSS length such as `"11pt"`.

- font_scale:

  A positive number used to scale `font_size`. This is useful when
  replacing a font with different metrics.

- ligatures:

  Whether to enable common and discretionary ligatures. The template
  default is `FALSE` for more predictable text extraction from PDFs.

- line_height:

  A positive unitless CSS line height or CSS length.

- paragraph_spacing, section_spacing:

  CSS lengths controlling vertical rhythm.

- margins:

  Page margins. Supply one to four CSS lengths using standard CSS
  shorthand order, or numeric values interpreted as inches.

- paper:

  A paper name (`"letter"`, `"a4"`, or `"legal"`) or a two-element
  vector containing width and height as CSS lengths.

- link_color:

  Any valid CSS color.

- paged:

  Whether the HTML preview should open in a paginated layout. Printing
  always invokes the packaged pages.js pagination.

- keep_html:

  For PDF output, whether to retain the intermediate HTML beside the
  PDF. Defaults to `FALSE`.

- browser:

  Path to Chromium, Google Chrome, or Microsoft Edge. `NULL` lets
  [`xfun::browser_print()`](https://rdrr.io/pkg/xfun/man/browser_print.html)
  discover it.

## Value

A `liteformats_resume_options` object for the `options` argument of
[`resume()`](https://nanx.me/liteformats/reference/resume.md).

## Details

Every argument defaults to `NULL` unless stated otherwise. A `NULL`
metadata or appearance value falls back to the source document's YAML
header and then to the template default. Values supplied here take
precedence over YAML.

## YAML configuration

In a source document, place metadata at the top level of the YAML header
and appearance controls in one flat `liteformats` mapping. YAML setting
names are the kebab-case equivalents of the helper arguments:

    author: "Jane Doe"
    job-title: "Research Scientist"
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
      paged: true

Unknown `liteformats` YAML names are rejected to catch misspellings.

## Examples

``` r
resume_options(
  font_size = "10.5pt",
  margins = c("0.6in", "0.75in"),
  paged = FALSE
)
#> $type
#> [1] "resume"
#> 
#> $metadata
#> $metadata$author
#> NULL
#> 
#> $metadata$job_title
#> NULL
#> 
#> $metadata$address
#> NULL
#> 
#> $metadata$phone
#> NULL
#> 
#> $metadata$email
#> NULL
#> 
#> $metadata$website
#> NULL
#> 
#> $metadata$linkedin
#> NULL
#> 
#> 
#> $settings
#> $settings$font_family
#> NULL
#> 
#> $settings$google_font
#> NULL
#> 
#> $settings$font_files
#> NULL
#> 
#> $settings$font_size
#> [1] "10.5pt"
#> 
#> $settings$font_scale
#> NULL
#> 
#> $settings$ligatures
#> NULL
#> 
#> $settings$line_height
#> NULL
#> 
#> $settings$paragraph_spacing
#> NULL
#> 
#> $settings$section_spacing
#> NULL
#> 
#> $settings$margins
#> [1] "0.6in"  "0.75in"
#> 
#> $settings$paper
#> NULL
#> 
#> $settings$link_color
#> NULL
#> 
#> $settings$paged
#> [1] FALSE
#> 
#> 
#> $keep_html
#> [1] FALSE
#> 
#> $browser
#> NULL
#> 
#> attr(,"class")
#> [1] "liteformats_resume_options" "liteformats_options"       
```
