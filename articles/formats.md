# Resumes and cover letters

## Start from Markdown

The resume and cover letter starters keep content in ordinary Markdown.
Copy one into a project, edit its YAML and prose, and render it:

``` r

liteformats::use_resume("resume.Rmd")
liteformats::resume("resume.Rmd", "resume.html")
liteformats::resume("resume.Rmd", "resume.pdf")
```

For a cover letter, use the cover letter starter and its matching
renderer:

``` r

liteformats::use_cover_letter("cover-letter.Rmd")
liteformats::cover_letter("cover-letter.Rmd", "cover-letter.html")
liteformats::cover_letter("cover-letter.Rmd", "cover-letter.pdf")
```

The PDF path uses
[`xfun::browser_print()`](https://rdrr.io/pkg/xfun/man/browser_print.html)
and therefore needs a local Chromium-based browser. The HTML renderer
does not.

## Automate builds with Make

Calling the renderer is more explicit than clicking a Knit button, which
makes it straightforward to add project-specific options and other build
steps. A small `Makefile` turns those commands into a repeatable,
one-command workflow:

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

Run `make` to build everything, or name one target such as
`make cover-letter.pdf`. Make rebuilds a target only when its `.Rmd`
source has changed. The recipes can also include preprocessing,
postprocessing, or any other commands needed for a specific design.

## Typography and fitting

The main controls can be set under the `liteformats` YAML key:

``` yaml
liteformats:
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

This flat, kebab-case `liteformats` mapping is the canonical YAML
configuration. Metadata such as `author`, `job-title`, `address`,
`date`, and `greeting` remains at the top level of the header.

For function-call configuration, use the options helper matching the
renderer. Its non-`NULL` values override YAML. A local font family can
provide regular, italic, bold, and bold-italic files. These files are
embedded into the output, which keeps HTML portable and lets PDF
rendering work offline.

``` r

liteformats::resume(
  "resume.Rmd",
  options = liteformats::resume_options(
    font_files = c(
      regular = "fonts/MySerif-Regular.otf",
      italic = "fonts/MySerif-Italic.otf",
      bold = "fonts/MySerif-Bold.otf"
    ),
    font_scale = 0.9,
    ligatures = FALSE
  )
)
```

Alternatively, `google_font = "Source Serif 4"` in the helper (or
`google-font: "Source Serif 4"` in YAML) adds a Google Fonts stylesheet.
liteformats consults its bundled catalog and requests the available
weights and styles needed for regular, bold, italic, and bold-italic
text. It uses a variable weight range when the family provides one and
omits unsupported combinations, so the CSS API request remains valid.
This option is deliberately opt-in because it requires internet access
when the document is rendered.

A full Google Fonts CSS v2 URL overrides the catalog-derived request and
can select explicit weights or variable axes:

``` r

liteformats::resume(
  "resume.Rmd",
  options = liteformats::resume_options(
    google_font = paste0(
      "https://fonts.googleapis.com/css2?",
      "family=Inter:ital,opsz,wght@0,14..32,100..900;",
      "1,14..32,100..900&display=swap"
    )
  )
)
```

The full-URL form also supports families newer than the bundled catalog.

Disabling ligatures prevents a common text-extraction problem, but an
embedded font’s own tables can also affect PDF extraction. For
ATS-sensitive documents, check the final result with a tool such as
`pdftotext resume.pdf -`.

## Semantic resume entries

The starter uses fenced divisions and inline spans to align dates and
locations without LaTeX:

``` markdown
::: resume-entry
**Example Corporation** [Seattle, WA · 2022--Present](){.resume-meta}

**Principal Data Scientist** [Evidence Systems](){.resume-meta}

- Led a cross-functional analytical program.
- Built reusable, documented research software.
:::
```

The cover letter starter needs no layout markup. Its author, address,
contact details, date, and greeting come from YAML, while the letter
itself remains plain Markdown. The template keeps the letterhead and
body in two columns, including in narrow browser or IDE preview panes.
Use a YAML list for a multiline address, for example
`address: ["123 Example Street", "Example City, EX 00000"]`; litedown’s
intentionally small YAML parser does not implement block scalars.
