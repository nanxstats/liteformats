#' Create a resume or cover letter from a starter
#'
#' Copy an editable R Markdown starter document to `path`. Static assets used by
#' the rendered formats remain inside the installed package and are referenced
#' from the copied source instead of being copied beside it.
#'
#' @param path Destination path.
#' @param overwrite Whether to replace an existing file.
#' @return The normalized destination path, invisibly.
#' @export
#' @examples
#' use_resume(tempfile(fileext = ".Rmd"))
#' use_cover_letter(tempfile(fileext = ".Rmd"))
use_resume <- function(path = "resume.Rmd", overwrite = FALSE) {
  use_liteformat_template("resume", path, overwrite)
}

#' @rdname use_resume
#' @export
use_cover_letter <- function(path = "cover-letter.Rmd", overwrite = FALSE) {
  use_liteformat_template("cover-letter", path, overwrite)
}

use_liteformat_template <- function(type, path, overwrite) {
  if (!is.character(path) || length(path) != 1L || is.na(path) ||
    !nzchar(path)) {
    stop("`path` must be one non-empty file path.", call. = FALSE)
  }
  if (!is.logical(overwrite) || length(overwrite) != 1L ||
    is.na(overwrite)) {
    stop("`overwrite` must be TRUE or FALSE.", call. = FALSE)
  }
  if (file.exists(path) && !overwrite) {
    stop(
      "File already exists: ", path,
      ". Use `overwrite = TRUE` to replace it.",
      call. = FALSE
    )
  }
  directory <- dirname(path)
  if (!dir.exists(directory) &&
    !dir.create(directory, recursive = TRUE, showWarnings = FALSE)) {
    stop("Cannot create destination directory: ", directory, call. = FALSE)
  }
  source <- liteformats_file("skeletons", paste0(type, ".Rmd"))
  if (!file.copy(source, path, overwrite = overwrite, copy.mode = FALSE)) {
    stop("Failed to copy template to: ", path, call. = FALSE)
  }
  invisible(normalizePath(path, mustWork = TRUE))
}
