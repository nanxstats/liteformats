#' Include local graphics in a liteformat
#'
#' Embed one or more local graphic files as base64 data URIs and return raw
#' HTML that [litedown::fuse()] can include directly in a document. This keeps
#' the rendered document self-contained without copying image files beside the
#' source or output.
#'
#' @param path A character vector of paths to local graphic files.
#' @param alt Alternative text. Supply one string for all graphics or one
#'   string per path.
#' @param class An optional CSS class string added to every image.
#'
#' @return Raw HTML output for use in a litedown code chunk.
#'
#' @export
#'
#' @examples
#' signature <- system.file(
#'   "liteformats/skeletons/signature.png",
#'   package = "liteformats"
#' )
#' include_graphics(
#'   signature,
#'   alt = "Handwritten signature",
#'   class = "signature"
#' )
include_graphics <- function(path, alt = "", class = NULL) {
  if (!is.character(path) || !length(path) || anyNA(path) ||
    any(!nzchar(path))) {
    stop("`path` must contain one or more non-empty file paths.", call. = FALSE)
  }
  path <- path.expand(path)
  info <- file.info(path)
  missing <- !file.exists(path) | is.na(info$isdir) | info$isdir
  if (any(missing)) {
    stop("Graphic file does not exist: ", path[[which(missing)[[1L]]]],
      call. = FALSE
    )
  }
  path <- normalizePath(path, mustWork = TRUE)

  if (!is.character(alt) || !length(alt) || anyNA(alt) ||
    !length(alt) %in% c(1L, length(path))) {
    stop(
      "`alt` must be one string or one string per graphic.",
      call. = FALSE
    )
  }
  alt <- rep(alt, length.out = length(path))
  if (!is.null(class)) {
    class <- scalar_character(class, "class")
  }

  tags <- vapply(seq_along(path), function(i) {
    attributes <- list(
      src = xfun::base64_uri(path[[i]]),
      alt = alt[[i]]
    )
    if (!is.null(class)) {
      attributes$class <- class
    }
    as.character(xfun::html_tag("img", .attrs = attributes))
  }, character(1))

  litedown::raw_text(tags, "html")
}
