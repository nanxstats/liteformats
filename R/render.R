#' Render a resume
#'
#' Render a Markdown or R Markdown resume to a self-contained HTML document or
#' to PDF through a headless Chromium-based browser. The output format is
#' inferred from the extension of `output`.
#'
#' Document metadata and typographic settings may be supplied in the YAML
#' header. Values in `options` take precedence over YAML. See [resume_options()]
#' for function-call configuration and [use_resume()] for a complete starter.
#'
#' @param input Path to a `.Rmd` or `.md` source document.
#' @param output Output path ending in `.html` or `.pdf`. If `NULL`, an HTML
#'   file is created beside `input`.
#' @param options A resume configuration created by [resume_options()].
#' @param envir Environment in which R code in `input` is evaluated.
#' @return The normalized output path, invisibly.
#' @export
#' @examples
#' source <- use_resume(tempfile(fileext = ".Rmd"))
#' resume(source, tempfile(fileext = ".html"))
#'
#' \dontrun{
#' # PDF output requires a local Chromium-based browser
#' resume(source, "resume.pdf")
#'
#' # Embed local font files
#' resume(
#'   source,
#'   options = resume_options(
#'     font_files = c(
#'       regular = "fonts/MySerif-Regular.woff2",
#'       italic = "fonts/MySerif-Italic.woff2",
#'       bold = "fonts/MySerif-Bold.woff2"
#'     ),
#'     font_scale = 0.96,
#'     ligatures = FALSE
#'   )
#' )
#' }
resume <- function(
  input,
  output = NULL,
  options = resume_options(),
  envir = parent.frame()
) {
  render_liteformat(
    type = "resume",
    input = input,
    output = output,
    options = options,
    envir = envir
  )
}

#' Render a cover letter
#'
#' Render a two-column cover letter to self-contained HTML or PDF. The narrow
#' left column holds the sender's details, while the letter remains the visual
#' foreground in the wider right column.
#'
#' @inheritParams resume
#' @param options A cover letter configuration created by
#'   [cover_letter_options()].
#' @return The normalized output path, invisibly.
#' @export
#' @examples
#' source <- use_cover_letter(tempfile(fileext = ".Rmd"))
#' cover_letter(source, tempfile(fileext = ".html"))
#'
#' \dontrun{
#' # PDF output requires a local Chromium-based browser
#' cover_letter(source, "cover-letter.pdf")
#' }
cover_letter <- function(
  input,
  output = NULL,
  options = cover_letter_options(),
  envir = parent.frame()
) {
  render_liteformat(
    type = "cover-letter",
    input = input,
    output = output,
    options = options,
    envir = envir
  )
}

render_liteformat <- function(type, input, output, options, envir) {
  options <- check_liteformat_options(options, type)
  input <- check_input(input)
  output <- document_output(input, output)
  format <- tolower(tools::file_ext(output))
  if (!format %in% c("html", "pdf")) {
    stop("`output` must end in '.html' or '.pdf'.", call. = FALSE)
  }

  output_dir <- dirname(output)
  if (!dir.exists(output_dir) &&
    !dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)) {
    stop("Cannot create output directory: ", output_dir, call. = FALSE)
  }

  # Fuse first so inline R in YAML metadata (notably dates) is resolved before
  # we construct the custom HTML front matter.
  markdown <- litedown::fuse(
    input = input,
    output = "markdown",
    envir = envir,
    quiet = TRUE
  )
  markdown <- as.character(markdown)
  yaml <- read_document_yaml(markdown)
  config <- document_config(yaml, type)

  settings <- document_settings(type, options$settings, config, input)
  metadata <- document_metadata(type, options$metadata, yaml)
  meta <- document_html_meta(type, metadata, settings)

  html_output <- if (format == "html") {
    output
  } else if (isTRUE(options$keep_html)) {
    replace_extension(output, "html")
  } else {
    tempfile("liteformats-", fileext = ".html")
  }
  if (format == "pdf" && !isTRUE(options$keep_html)) {
    on.exit(unlink(html_output), add = TRUE)
  }

  template <- liteformats_file("templates", paste0(type, ".html"))
  old_options <- base::options(
    litedown.html.template = template,
    litedown.html.options = list(
      embed_resources = "local",
      embed_cleanup = TRUE,
      auto_identifiers = TRUE,
      smart = TRUE
    )
  )
  on.exit(base::options(old_options), add = TRUE)

  litedown::mark(
    input = input,
    output = html_output,
    text = markdown,
    meta = meta
  )

  if (format == "pdf") {
    xfun::browser_print(
      input = normalizePath(html_output, mustWork = TRUE),
      output = output,
      args = c("default", "--no-pdf-header-footer"),
      browser = options$browser
    )
  }

  invisible(normalizePath(output, mustWork = TRUE))
}

check_input <- function(input) {
  if (!is.character(input) || length(input) != 1L || is.na(input) ||
    !nzchar(input)) {
    stop("`input` must be one file path.", call. = FALSE)
  }
  if (!file.exists(input)) {
    stop("Input file does not exist: ", input, call. = FALSE)
  }
  normalizePath(input, mustWork = TRUE)
}

document_output <- function(input, output) {
  if (is.null(output)) {
    return(replace_extension(input, "html"))
  }
  if (!is.character(output) || length(output) != 1L || is.na(output) ||
    !nzchar(output)) {
    stop("`output` must be NULL or one file path.", call. = FALSE)
  }
  if (output %in% c(".html", ".pdf")) {
    output <- replace_extension(input, substring(output, 2L))
  }
  normalizePath(output, mustWork = FALSE)
}

replace_extension <- function(path, extension) {
  sub("([.][^./\\\\]+)?$", paste0(".", extension), path)
}

read_document_yaml <- function(text) {
  lines <- unlist(strsplit(text, "\n", fixed = TRUE), use.names = FALSE)
  parsed <- xfun::yaml_body(lines, use_yaml = FALSE)
  if (is.list(parsed[["yaml"]])) parsed[["yaml"]] else list()
}

document_config <- function(yaml, type) {
  config <- yaml[["liteformats"]]
  if (is.null(config)) {
    return(list())
  }
  if (!is.list(config)) {
    stop("`liteformats` in YAML must be a mapping.", call. = FALSE)
  }
  if (length(config) && (is.null(names(config)) || any(!nzchar(names(config))))) {
    stop("Every `liteformats` YAML option must be named.", call. = FALSE)
  }
  allowed <- gsub("_", "-", names(document_defaults(type)), fixed = TRUE)
  unknown <- setdiff(names(config), allowed)
  if (length(unknown)) {
    stop(
      "Unknown `liteformats` YAML option",
      if (length(unknown) > 1L) "s" else "",
      ": ",
      paste0("`", unknown, "`", collapse = ", "),
      ".",
      call. = FALSE
    )
  }
  config
}

document_defaults <- function(type) {
  common <- list(
    font_family = 'Georgia, "Times New Roman", serif',
    google_font = NULL,
    font_files = NULL,
    font_size = "11pt",
    font_scale = 0.9,
    ligatures = FALSE,
    line_height = 1.15,
    paper = "letter",
    link_color = "#385898",
    paged = TRUE
  )
  specific <- switch(type,
    resume = list(
      paragraph_spacing = "0.05em",
      section_spacing = "1em",
      margins = c("0.65in", "0.8in")
    ),
    `cover-letter` = list(
      paragraph_spacing = "1em",
      section_spacing = "1em",
      margins = "1in"
    ),
    stop("Unknown liteformat type: ", type, call. = FALSE)
  )
  c(common, specific)
}

document_settings <- function(type, args, config, input) {
  defaults <- document_defaults(type)
  cfg <- lapply(names(defaults), function(name) {
    config[[gsub("_", "-", name, fixed = TRUE)]]
  })
  names(cfg) <- names(defaults)
  settings <- lapply(names(defaults), function(name) {
    first_value(args[[name]], cfg[[name]], defaults[[name]])
  })
  names(settings) <- names(defaults)

  settings$font_scale <- positive_number(settings$font_scale, "font_scale")
  settings$font_size <- css_length(settings$font_size, "font_size")
  settings$font_size <- scale_css_length(
    settings$font_size, settings$font_scale
  )
  settings$line_height <- css_line_height(settings$line_height)
  settings$paragraph_spacing <- css_length(
    settings$paragraph_spacing, "paragraph_spacing",
    zero = TRUE
  )
  settings$section_spacing <- css_length(
    settings$section_spacing, "section_spacing",
    zero = TRUE
  )
  settings$margins <- css_margins(settings$margins)
  settings$paper <- css_paper(settings$paper)
  settings$link_color <- scalar_character(settings$link_color, "link_color")
  settings$ligatures <- scalar_logical(settings$ligatures, "ligatures")
  settings$paged <- scalar_logical(settings$paged, "paged")
  settings$font_family <- scalar_character(
    settings$font_family, "font_family"
  )
  settings$google_font <- google_font(settings$google_font)
  settings$font_faces <- local_font_faces(
    settings$font_files, dirname(input)
  )
  if (nzchar(settings$font_faces)) {
    settings$font_family <- paste(
      '"liteformats-local"', settings$font_family,
      sep = ", "
    )
  } else if (!is.null(settings$google_font$family)) {
    settings$font_family <- paste(
      css_font_name(settings$google_font$family),
      settings$font_family,
      sep = ", "
    )
  }
  settings
}

first_value <- function(x, y, z) {
  if (!is.null(x)) x else if (!is.null(y)) y else z
}

scalar_character <- function(x, name) {
  if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(x)) {
    stop("`", name, "` must be one non-empty string.", call. = FALSE)
  }
  x
}

scalar_logical <- function(x, name) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    stop("`", name, "` must be TRUE or FALSE.", call. = FALSE)
  }
  x
}

positive_number <- function(x, name) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) || !is.finite(x) ||
    x <= 0) {
    stop("`", name, "` must be one positive number.", call. = FALSE)
  }
  x
}

css_length <- function(x, name, zero = FALSE) {
  if (is.numeric(x) && length(x) == 1L && is.finite(x)) {
    x <- paste0(x, "in")
  }
  x <- scalar_character(x, name)
  pattern <- if (zero) {
    "^(0|[0-9]*[.]?[0-9]+(px|pt|pc|in|cm|mm|q|em|rem|ex|ch|%))$"
  } else {
    "^[0-9]*[.]?[0-9]+(px|pt|pc|in|cm|mm|q|em|rem|ex|ch|%)$"
  }
  if (!grepl(pattern, x, ignore.case = TRUE)) {
    stop("`", name, "` must be a non-negative CSS length.", call. = FALSE)
  }
  x
}

scale_css_length <- function(x, scale) {
  match <- regexec(
    "^([0-9]*[.]?[0-9]+)([[:alpha:]%]+)$", x,
    ignore.case = TRUE
  )
  parts <- regmatches(x, match)[[1L]]
  number <- as.numeric(parts[[2L]]) * scale
  paste0(
    format(number, digits = 8L, trim = TRUE, scientific = FALSE),
    parts[[3L]]
  )
}

css_line_height <- function(x) {
  if (is.numeric(x) && length(x) == 1L && is.finite(x) && x > 0) {
    return(format(x, trim = TRUE, scientific = FALSE))
  }
  x <- scalar_character(x, "line_height")
  if (grepl("^[0-9]*[.]?[0-9]+$", x) && as.numeric(x) > 0) {
    return(x)
  }
  css_length(x, "line_height")
}

css_margins <- function(x) {
  if (!is.atomic(x)) {
    stop("`margins` must contain one to four CSS lengths.", call. = FALSE)
  }
  x <- unlist(x, use.names = FALSE)
  if (!length(x) %in% 1:4) {
    stop("`margins` must contain one to four CSS lengths.", call. = FALSE)
  }
  x <- vapply(x, css_length, character(1), name = "margins", zero = TRUE)
  switch(as.character(length(x)),
    "1" = rep(x, 4L),
    "2" = x[c(1L, 2L, 1L, 2L)],
    "3" = x[c(1L, 2L, 3L, 2L)],
    "4" = x
  )
}

css_paper <- function(x) {
  if (is.character(x) && length(x) == 1L) {
    named <- list(
      letter = c("8.5in", "11in"),
      a4 = c("210mm", "297mm"),
      legal = c("8.5in", "14in")
    )
    value <- named[[tolower(x)]]
    if (!is.null(value)) {
      return(value)
    }
  }
  x <- unlist(x, use.names = FALSE)
  if (length(x) != 2L) {
    stop(
      "`paper` must be 'letter', 'a4', 'legal', or c(width, height).",
      call. = FALSE
    )
  }
  vapply(x, css_length, character(1), name = "paper")
}

google_font <- function(x) {
  if (is.null(x) || identical(x, FALSE) || identical(x, "")) {
    return(list(url = NULL, family = NULL))
  }
  x <- scalar_character(x, "google_font")
  if (grepl("^https://fonts[.]googleapis[.]com/css2[?]", x)) {
    return(list(url = x, family = google_font_url_family(x)))
  }
  if (grepl("^https?://", x)) {
    stop(
      "`google_font` URLs must use the Google Fonts CSS v2 API.",
      call. = FALSE
    )
  }

  catalog <- google_font_catalog()
  index <- match(tolower(trimws(x)), tolower(catalog$family))
  if (is.na(index)) {
    stop(
      "Google font family `", x, "` is not in the bundled catalog. ",
      "Supply a full Google Fonts CSS v2 URL for a newer family.",
      call. = FALSE
    )
  }
  font <- catalog[index, , drop = FALSE]
  family <- font$family[[1L]]
  spec <- if (is.na(font$variable_weight_min[[1L]])) {
    google_static_font_spec(font)
  } else {
    google_variable_font_spec(font)
  }
  query <- gsub(
    "%20", "+", utils::URLencode(family, reserved = TRUE),
    fixed = TRUE
  )
  list(
    url = paste0(
      "https://fonts.googleapis.com/css2?family=", query, spec,
      "&display=swap"
    ),
    family = family
  )
}

#' Load and cache the bundled Google Fonts catalog
#'
#' A private closure avoids reparsing the immutable TSV on every render.
#' @noRd
google_font_catalog <- local({
  catalog <- NULL
  function() {
    if (!is.null(catalog)) {
      return(catalog)
    }
    path <- liteformats_file("data", "google-fonts.tsv")
    catalog <<- utils::read.delim(
      path,
      sep = "\t",
      quote = '"',
      na.strings = "",
      colClasses = c(
        "character", "character", "character", "numeric", "numeric",
        "character", "numeric", "numeric"
      ),
      stringsAsFactors = FALSE,
      check.names = FALSE,
      fileEncoding = "UTF-8"
    )
    catalog
  }
})

google_static_font_spec <- function(font) {
  normal <- essential_font_weights(font$normal_weights[[1L]])
  italic <- essential_font_weights(font$italic_weights[[1L]])
  styles <- c(rep.int(0, length(normal)), rep.int(1, length(italic)))
  weights <- c(normal, italic)
  google_font_face_spec(styles, weights)
}

google_variable_font_spec <- function(font) {
  weight_min <- font$variable_weight_min[[1L]]
  weight_max <- font$variable_weight_max[[1L]]
  weights <- unique(pmax(weight_min, pmin(weight_max, c(400, 700))))
  weight <- if (length(weights) == 1L) {
    font_number(weights)
  } else {
    paste0(font_number(min(weights)), "..", font_number(max(weights)))
  }
  use_weight <- length(weights) > 1L || weights[[1L]] != 400

  slant_min <- font$slant_min[[1L]]
  slant_max <- font$slant_max[[1L]]
  if (!is.na(slant_min) && !is.na(slant_max) && slant_min != slant_max) {
    axes <- c("slnt", if (use_weight) "wght")
    values <- c(
      paste0(font_number(slant_min), "..", font_number(slant_max)),
      if (use_weight) weight
    )
    return(paste0(
      ":", paste(axes, collapse = ","), "@",
      paste(values, collapse = ",")
    ))
  }

  styles <- catalog_values(font$variable_styles[[1L]])
  styles <- c(if ("normal" %in% styles) 0, if ("italic" %in% styles) 1)
  if (!length(styles)) {
    styles <- 0
  }
  if (!use_weight) {
    return(google_font_face_spec(styles, rep.int(400, length(styles))))
  }
  if (identical(styles, 0)) {
    return(paste0(":wght@", weight))
  }
  tuples <- paste(styles, weight, sep = ",")
  paste0(":ital,wght@", paste(tuples, collapse = ";"))
}

google_font_face_spec <- function(styles, weights) {
  order <- order(styles, weights)
  styles <- styles[order]
  weights <- weights[order]
  use_italic <- any(styles == 1)
  use_weight <- any(weights != 400)
  if (!use_italic && !use_weight) {
    return("")
  }
  axes <- c(if (use_italic) "ital", if (use_weight) "wght")
  tuples <- vapply(seq_along(styles), function(index) {
    values <- c(
      if (use_italic) styles[[index]],
      if (use_weight) weights[[index]]
    )
    paste(values, collapse = ",")
  }, character(1))
  paste0(
    ":", paste(axes, collapse = ","), "@",
    paste(tuples, collapse = ";")
  )
}

essential_font_weights <- function(x) {
  weights <- as.numeric(catalog_values(x))
  if (!length(weights)) {
    return(numeric())
  }
  unique(vapply(c(400, 700), function(target) {
    distance <- abs(weights - target)
    nearest <- weights[distance == min(distance)]
    if (target <= 500) max(nearest) else min(nearest)
  }, numeric(1)))
}

catalog_values <- function(x) {
  if (length(x) != 1L || is.na(x) || !nzchar(x)) {
    return(character())
  }
  strsplit(x, ",", fixed = TRUE)[[1L]]
}

font_number <- function(x) {
  format(x, digits = 15L, trim = TRUE, scientific = FALSE)
}

google_font_url_family <- function(url) {
  match <- regexpr("[?&]family=[^&]+", url)
  if (match[[1L]] < 0L) {
    stop(
      "A Google Fonts CSS v2 URL must contain a `family` parameter.",
      call. = FALSE
    )
  }
  value <- regmatches(url, match)
  value <- sub("^[?&]family=", "", value)
  value <- utils::URLdecode(gsub("+", " ", value, fixed = TRUE))
  family <- sub(":.*$", "", value)
  if (!nzchar(family)) {
    stop(
      "A Google Fonts CSS v2 URL must name a font family.",
      call. = FALSE
    )
  }
  family
}

css_font_name <- function(x) {
  paste0('"', gsub('(["\\\\])', "\\\\\\1", x), '"')
}

local_font_faces <- function(files, source_dir) {
  if (is.null(files) || identical(files, FALSE) || !length(files)) {
    return("")
  }
  files <- unlist(files, use.names = TRUE)
  if (is.null(names(files)) || any(!nzchar(names(files)))) {
    names(files) <- c("regular", "italic", "bold", "bold_italic")[
      seq_along(files)
    ]
  }
  names(files) <- gsub("-", "_", tolower(names(files)), fixed = TRUE)
  allowed <- c("regular", "italic", "bold", "bold_italic")
  if (any(!names(files) %in% allowed) || anyDuplicated(names(files))) {
    stop(
      "`font_files` names must be regular, italic, bold, or bold_italic.",
      call. = FALSE
    )
  }
  faces <- Map(
    function(file, face) {
      if (!is.character(file) || length(file) != 1L || is.na(file)) {
        stop("Every `font_files` value must be one path.", call. = FALSE)
      }
      path <- if (is_absolute_path(file)) file else file.path(source_dir, file)
      if (!file.exists(path)) {
        stop("Local font file does not exist: ", path, call. = FALSE)
      }
      extension <- tolower(tools::file_ext(path))
      formats <- c(
        otf = "opentype", ttf = "truetype", woff = "woff", woff2 = "woff2"
      )
      font_format <- formats[[extension]]
      if (is.null(font_format)) {
        stop(
          "Local fonts must use .otf, .ttf, .woff, or .woff2 files.",
          call. = FALSE
        )
      }
      properties <- list(
        regular = c("normal", "400"),
        italic = c("italic", "400"),
        bold = c("normal", "700"),
        bold_italic = c("italic", "700")
      )[[face]]
      paste0(
        "@font-face{font-family:\"liteformats-local\";",
        "src:url(\"", xfun::base64_uri(path), "\") format(\"", font_format,
        "\");font-style:", properties[[1L]], ";font-weight:", properties[[2L]],
        ";font-display:swap;}"
      )
    },
    as.list(files),
    as.list(names(files))
  )
  paste(unlist(faces, use.names = FALSE), collapse = "\n")
}

is_absolute_path <- function(path) {
  grepl("^(/|[A-Za-z]:[/\\\\]|\\\\\\\\)", path)
}

document_metadata <- function(type, args, yaml) {
  for (name in names(args)) {
    if (!is.null(args[[name]])) next
    value <- yaml[[gsub("_", "-", name, fixed = TRUE)]]
    if (!is.null(value)) {
      args[[name]] <- value
    }
  }
  if (is.null(args$author)) {
    stop("An `author` must be supplied as an argument or in YAML.", call. = FALSE)
  }
  args$author <- collapse_text(args$author)
  if (type == "cover-letter" && is.null(args$greeting)) {
    args$greeting <- "Dear Hiring Manager:"
  }
  args
}

collapse_text <- function(x, separator = " ") {
  paste(as.character(unlist(x, use.names = FALSE)), collapse = separator)
}

document_html_meta <- function(type, metadata, settings) {
  margin <- settings$margins
  css <- paste0(
    "<style>\n:root{",
    "--paper-width:", settings$paper[[1L]], ";",
    "--paper-height:", settings$paper[[2L]], ";",
    "--paper-margin-top:", margin[[1L]], ";",
    "--paper-margin-right:", margin[[2L]], ";",
    "--paper-margin-bottom:", margin[[3L]], ";",
    "--paper-margin-left:", margin[[4L]], ";",
    "--page-header-height:0px;--page-header-bottom:0px;",
    "--page-footer-height:0px;--page-footer-top:0px;",
    "--lf-font-family:", settings$font_family, ";",
    "--lf-font-size:", settings$font_size, ";",
    "--lf-line-height:", settings$line_height, ";",
    "--lf-paragraph-spacing:", settings$paragraph_spacing, ";",
    "--lf-section-spacing:", settings$section_spacing, ";",
    "--lf-link-color:", settings$link_color, ";",
    "}\n",
    settings$font_faces,
    if (settings$ligatures) {
      ""
    } else {
      paste0(
        "\n.liteformats-document{font-variant-ligatures:none;",
        "font-feature-settings:\"liga\" 0,\"clig\" 0,\"dlig\" 0;}"
      )
    },
    "\n</style>"
  )
  if (!is.null(settings$google_font$url)) {
    css <- paste0(
      '<link rel="preconnect" href="https://fonts.googleapis.com">\n',
      '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>\n',
      '<link rel="stylesheet" href="',
      html_escape(settings$google_font$url, attribute = TRUE), '">\n',
      css
    )
  }

  assets <- c(
    liteformats_file("css", "base.css"),
    liteformats_file("css", paste0(type, ".css")),
    liteformats_file("css", "pages.css")
  )
  paged_script <- if (settings$paged) {
    paste0(
      "<script>",
      "window.dispatchEvent(new KeyboardEvent('keypress',{key:'p'}));",
      "</script>"
    )
  } else {
    ""
  }

  meta <- list(
    css = assets,
    js = c(
      if (type == "resume") liteformats_file("js", "resume.js"),
      liteformats_file("js", "pages.js")
    ),
    header_includes = I(css),
    paged_script = I(paged_script),
    author = metadata$author,
    body_class = paste("body", type, "body", sep = "-")
  )

  if (type == "resume") {
    meta$job_title_html <- I(optional_div(
      metadata$job_title, "resume-job-title"
    ))
    meta$resume_contact_html <- I(resume_contact(metadata))
  } else {
    meta$cover_address_html <- I(address_html(metadata$address))
    meta$cover_contact_html <- I(cover_contact(metadata))
    meta$date_html <- I(optional_div(metadata$date, "cover-date"))
    meta$greeting_html <- I(optional_div(
      metadata$greeting, "cover-greeting"
    ))
  }
  meta
}

resume_contact <- function(metadata) {
  values <- list(
    plain_item(metadata$address),
    phone_item(metadata$phone),
    email_item(metadata$email),
    website_item(metadata$website),
    linkedin_item(metadata$linkedin)
  )
  values <- Filter(nzchar, values)
  if (!length(values)) {
    return("")
  }
  paste0(
    '<div class="resume-contact" role="list" ',
    'aria-label="Contact information">',
    paste0('<span role="listitem">', values, "</span>", collapse = ""),
    "</div>"
  )
}

cover_contact <- function(metadata) {
  values <- c(
    phone_item(metadata$phone),
    email_item(metadata$email),
    website_item(metadata$website)
  )
  values <- values[nzchar(values)]
  if (!length(values)) {
    return("")
  }
  paste0(
    '<ul class="cover-contact" aria-label="Contact information">',
    paste0("<li>", values, "</li>", collapse = ""),
    "</ul>"
  )
}

plain_item <- function(x) {
  if (is.null(x) || !length(x)) {
    return("")
  }
  html_escape(collapse_text(x, ", "))
}

phone_item <- function(x) {
  if (is.null(x) || !length(x)) {
    return("")
  }
  label <- collapse_text(x)
  href <- gsub("[^0-9+]", "", label)
  html_anchor(paste0("tel:", href), label)
}

email_item <- function(x) {
  if (is.null(x) || !length(x)) {
    return("")
  }
  label <- collapse_text(x)
  html_anchor(paste0("mailto:", label), label)
}

website_item <- function(x) {
  if (is.null(x) || !length(x)) {
    return("")
  }
  label <- collapse_text(x)
  href <- if (grepl("^https?://", label, ignore.case = TRUE)) {
    label
  } else {
    paste0("https://", label)
  }
  display <- sub("^https?://", "", label, ignore.case = TRUE)
  html_anchor(href, display)
}

linkedin_item <- function(x) {
  if (is.null(x) || !length(x)) {
    return("")
  }
  label <- collapse_text(x)
  href <- if (grepl("^https?://", label, ignore.case = TRUE)) {
    label
  } else {
    paste0("https://www.linkedin.com/in/", label, "/")
  }
  display <- if (grepl("^https?://", label, ignore.case = TRUE)) {
    sub("^https?://(www[.])?", "", label, ignore.case = TRUE)
  } else {
    paste0("linkedin.com/in/", label)
  }
  html_anchor(href, display)
}

html_anchor <- function(href, label) {
  paste0(
    '<a href="', html_escape(href, attribute = TRUE), '">',
    html_escape(label), "</a>"
  )
}

address_html <- function(x) {
  if (is.null(x) || !length(x)) {
    return("")
  }
  lines <- unlist(strsplit(collapse_text(x, "\n"), "\n", fixed = TRUE))
  lines <- trimws(lines)
  lines <- lines[nzchar(lines)]
  if (!length(lines)) {
    return("")
  }
  paste0(
    '<address class="cover-address">',
    paste(html_escape(lines), collapse = "<br>"),
    "</address>"
  )
}

optional_div <- function(x, class) {
  if (is.null(x) || !length(x) || !nzchar(collapse_text(x))) {
    return("")
  }
  paste0('<div class="', class, '">', html_escape(collapse_text(x)), "</div>")
}

html_escape <- function(x, attribute = FALSE) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  if (attribute) {
    x <- gsub('"', "&quot;", x, fixed = TRUE)
    x <- gsub("'", "&#39;", x, fixed = TRUE)
  }
  x
}

liteformats_file <- function(...) {
  system.file("liteformats", ..., package = "liteformats", mustWork = TRUE)
}
