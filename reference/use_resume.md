# Create a resume or cover letter from a starter

Copy an editable R Markdown starter document to `path`. Static assets
used by the rendered formats remain inside the installed package and are
referenced from the copied source instead of being copied beside it.

## Usage

``` r
use_resume(path = "resume.Rmd", overwrite = FALSE)

use_cover_letter(path = "cover-letter.Rmd", overwrite = FALSE)
```

## Arguments

- path:

  Destination path.

- overwrite:

  Whether to replace an existing file.

## Value

The normalized destination path, invisibly.

## Examples

``` r
use_resume(tempfile(fileext = ".Rmd"))
use_cover_letter(tempfile(fileext = ".Rmd"))
```
