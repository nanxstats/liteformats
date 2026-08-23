# Automate document builds

The rendering functions make document builds explicit and repeatable. A
small `Makefile` can express the same commands used interactively while
rebuilding an output only after its source changes:

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

Run `make` to build every target, or name one target such as
`make cover-letter.pdf`. Each recipe exposes the underlying R command,
so it can include project-specific options, preprocessing,
postprocessing, or other dependencies.

## Rendering model

Each render has two stages. First, `litedown::fuse(..., "markdown")`
evaluates R code and YAML. Then
[`litedown::mark()`](https://rdrr.io/pkg/litedown/man/mark.html) applies
the format’s HTML template. This order means inline R values work in
metadata as well as in the document body.

PDF uses that self-contained HTML as its input and prints it with
[`xfun::browser_print()`](https://rdrr.io/pkg/xfun/man/browser_print.html).
As a result, the source and R dependencies are the same for HTML and
PDF; PDF additionally requires a local Chromium-based browser. Vignette
and automated check workflows can build HTML without adding that browser
requirement.

For render time overrides, pass the matching options helper in the
recipe as shown in
[`vignette("config")`](https://nanx.me/liteformats/articles/config.md).
