# Cover letters

Create a complete editable starter, then render it to self-contained
HTML or PDF with the cover letter renderer:

``` r

liteformats::use_cover_letter("cover-letter.Rmd")
liteformats::cover_letter("cover-letter.Rmd", "cover-letter.html")
liteformats::cover_letter("cover-letter.Rmd", "cover-letter.pdf")
```

## Supply letter metadata

The letterhead and salutation come from top-level YAML fields: `title`,
`author`, `address`, `phone`, `email`, `website`, `date`, and
`greeting`. The letter itself remains plain Markdown.

Use a YAML list for a multiline address:

``` yaml
address: ["123 Example Street", "Example City, EX 00000"]
```

litedown’s intentionally small YAML parser does not implement block
scalars. Inline R is supported in metadata, so the date can be evaluated
when the document is rendered:

``` yaml
date: "`{r} format(Sys.Date(), '%B %e, %Y')`"
```

The starter also demonstrates variables evaluated in the letter body and
an embedded signature image.

## Preserve the composition

The cover letter template places the letterhead and body in two columns
at every viewport width. This fixed page composition also appears in
narrow IDE or browser preview panes; it does not switch to a
single-column responsive layout.

Put appearance settings under the `liteformats` YAML key or override
them with
[`cover_letter_options()`](https://nanx.me/liteformats/reference/cover_letter_options.md).
See
[`vignette("config")`](https://nanx.me/liteformats/articles/config.md)
for the configuration model and
[`vignette("typography")`](https://nanx.me/liteformats/articles/typography.md)
for font and spacing controls.
