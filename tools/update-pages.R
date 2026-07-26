#!/usr/bin/env Rscript

# Refresh the exact pages.js sources from the upstream lite.js repository.
# This maintainer script requires internet access and is excluded from builds.

main <- function() {
  source_url <- "https://github.com/yihui/lite.js/archive/refs/heads/main.zip"
  archive <- tempfile("lite-js-", fileext = ".zip")
  unpack_root <- tempfile("lite-js-")
  on.exit(unlink(c(archive, unpack_root), recursive = TRUE), add = TRUE)

  status <- utils::download.file(source_url, archive, mode = "wb")
  if (!identical(status, 0L)) stop("Failed to download: ", source_url)

  archive_root <- "lite.js-main"
  source_root <- file.path(unpack_root, archive_root)
  target_root <- file.path("inst", "liteformats")
  files <- c(
    file.path("js", "pages.js"),
    file.path("css", "pages.css")
  )
  archive_files <- file.path(archive_root, c(files, "LICENSE"))
  dir.create(unpack_root)
  utils::unzip(archive, files = archive_files, exdir = unpack_root)

  for (file in files) {
    source <- file.path(source_root, file)
    target <- file.path(target_root, file)
    if (!file.exists(source)) stop("Missing source asset: ", source)
    dir.create(dirname(target), recursive = TRUE, showWarnings = FALSE)
    if (!file.copy(source, target, overwrite = TRUE, copy.mode = FALSE)) {
      stop("Failed to update: ", target)
    }
    message(target, "  ", unname(tools::md5sum(target)))
  }

  license <- file.path(source_root, "LICENSE")
  license_target <- file.path(
    target_root, "licenses", "lite.js-LICENSE.md"
  )
  dir.create(dirname(license_target), recursive = TRUE, showWarnings = FALSE)
  if (!file.copy(
    license, license_target,
    overwrite = TRUE, copy.mode = FALSE
  )) {
    stop("Failed to update: ", license_target)
  }
  message(license_target, "  ", unname(tools::md5sum(license_target)))
}

main()
