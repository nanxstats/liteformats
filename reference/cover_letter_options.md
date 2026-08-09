# Configure a cover letter

Create a classed options object for
[`cover_letter()`](https://nanx.me/liteformats/reference/cover_letter.md).
Settings work in the same way as
[`resume_options()`](https://nanx.me/liteformats/reference/resume_options.md),
with letter-specific metadata replacing the resume-specific fields.

## Usage

``` r
cover_letter_options(
  author = NULL,
  address = NULL,
  phone = NULL,
  email = NULL,
  website = NULL,
  date = NULL,
  greeting = NULL,
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

- date, greeting:

  Letter date and salutation.

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

A `liteformats_cover_letter_options` object for the `options` argument
of
[`cover_letter()`](https://nanx.me/liteformats/reference/cover_letter.md).

## YAML configuration

Use the same flat, kebab-case `liteformats` mapping documented in
[`resume_options()`](https://nanx.me/liteformats/reference/resume_options.md).
Place cover-letter metadata such as `author`, `address`, `date`, and
`greeting` at the top level of the YAML header. Unknown `liteformats`
YAML names are rejected.

## Examples

``` r
cover_letter_options(
  greeting = "Dear Search Committee:",
  paragraph_spacing = "0.9em"
)
#> $type
#> [1] "cover-letter"
#> 
#> $metadata
#> $metadata$author
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
#> $metadata$date
#> NULL
#> 
#> $metadata$greeting
#> [1] "Dear Search Committee:"
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
#> NULL
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
#> [1] "0.9em"
#> 
#> $settings$section_spacing
#> NULL
#> 
#> $settings$margins
#> NULL
#> 
#> $settings$paper
#> NULL
#> 
#> $settings$link_color
#> NULL
#> 
#> $settings$paged
#> NULL
#> 
#> 
#> $keep_html
#> [1] FALSE
#> 
#> $browser
#> NULL
#> 
#> attr(,"class")
#> [1] "liteformats_cover_letter_options" "liteformats_options"             
```
