#!/usr/bin/env Rscript

# Refresh the compact Google Fonts capability index used at render time.
# This maintainer script requires internet access and is excluded from builds.
#
# By default, the script downloads the main branch of
# fontsource/google-font-metadata. Pass a local checkout as the first argument
# to generate the index without downloading it:
#
#   Rscript tools/update-google-fonts.R vendor/google-font-metadata

main <- function() {
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("Package 'jsonlite' is required to update Google Fonts metadata.")
  }

  args <- commandArgs(trailingOnly = TRUE)
  cleanup <- character()
  on.exit(unlink(cleanup, recursive = TRUE), add = TRUE)

  if (length(args)) {
    if (length(args) != 1L) {
      stop("Supply at most one local google-font-metadata checkout.")
    }
    source_root <- normalizePath(args[[1L]], mustWork = TRUE)
  } else {
    source_url <- paste0(
      "https://github.com/fontsource/google-font-metadata/",
      "archive/refs/heads/main.zip"
    )
    archive <- tempfile("google-font-metadata-", fileext = ".zip")
    unpack_root <- tempfile("google-font-metadata-")
    cleanup <- c(archive, unpack_root)

    status <- utils::download.file(source_url, archive, mode = "wb")
    if (!identical(status, 0L)) stop("Failed to download: ", source_url)
    dir.create(unpack_root)
    archive_root <- "google-font-metadata-main"
    archive_files <- file.path(
      archive_root,
      c("data/google-fonts-v2.json", "data/variable.json", "LICENSE")
    )
    utils::unzip(archive, files = archive_files, exdir = unpack_root)
    source_root <- file.path(unpack_root, archive_root)
  }

  data_root <- file.path(source_root, "data")
  static <- read_json(file.path(data_root, "google-fonts-v2.json"))
  variable <- read_json(file.path(data_root, "variable.json"))

  rows <- lapply(static, function(font) {
    variants <- font[["variants"]]
    weights_for <- function(style) {
      weights <- names(variants)[vapply(
        variants,
        function(weight) !is.null(weight[[style]]),
        logical(1)
      )]
      paste(as.integer(weights), collapse = ",")
    }

    variable_font <- variable[[font[["id"]]]]
    has_variable_weight <- !is.null(variable_font[["axes"]][["wght"]])
    variable_styles <- ""
    weight_min <- weight_max <- slant_min <- slant_max <- NA_real_
    if (has_variable_weight) {
      weight_axis <- variable_font[["axes"]][["wght"]]
      weight_min <- as.numeric(weight_axis[["min"]])
      weight_max <- as.numeric(weight_axis[["max"]])
      styles <- names(variable_font[["variants"]][["wght"]])
      variable_styles <- paste(
        intersect(c("normal", "italic"), styles),
        collapse = ","
      )

      slant_axis <- variable_font[["axes"]][["slnt"]]
      if (!is.null(slant_axis)) {
        slant_min <- as.numeric(slant_axis[["min"]])
        slant_max <- as.numeric(slant_axis[["max"]])
      }
    }

    data.frame(
      family = font[["family"]],
      normal_weights = weights_for("normal"),
      italic_weights = weights_for("italic"),
      variable_weight_min = weight_min,
      variable_weight_max = weight_max,
      variable_styles = variable_styles,
      slant_min = slant_min,
      slant_max = slant_max,
      stringsAsFactors = FALSE
    )
  })
  catalog <- do.call(rbind, rows)
  catalog <- catalog[order(tolower(catalog$family)), , drop = FALSE]

  if (anyDuplicated(tolower(catalog$family))) {
    stop("Google Fonts metadata contains duplicate family names.")
  }
  if (any(!nzchar(catalog$normal_weights) &
    !nzchar(catalog$italic_weights))) {
    stop("A Google Fonts family has no static face metadata.")
  }

  target_root <- file.path("inst", "liteformats")
  data_target <- file.path(target_root, "data", "google-fonts.tsv")
  dir.create(dirname(data_target), recursive = TRUE, showWarnings = FALSE)
  utils::write.table(
    catalog,
    data_target,
    sep = "\t",
    row.names = FALSE,
    quote = TRUE,
    na = "",
    fileEncoding = "UTF-8"
  )
  message(data_target, "  ", unname(tools::md5sum(data_target)))

  license <- file.path(source_root, "LICENSE")
  license_target <- file.path(
    target_root, "licenses", "google-font-metadata-LICENSE.md"
  )
  if (!file.exists(license)) stop("Missing source license: ", license)
  dir.create(dirname(license_target), recursive = TRUE, showWarnings = FALSE)
  if (!file.copy(
    license, license_target,
    overwrite = TRUE, copy.mode = FALSE
  )) {
    stop("Failed to update: ", license_target)
  }
  message(license_target, "  ", unname(tools::md5sum(license_target)))
}

read_json <- function(path) {
  if (!file.exists(path)) stop("Missing metadata file: ", path)
  jsonlite::fromJSON(path, simplifyVector = FALSE)
}

main()
