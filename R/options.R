#' Configure a resume
#'
#' Create a classed options object for [resume()]. The helper keeps secondary
#' metadata, typography, page, and PDF controls out of the main rendering
#' function while retaining argument-name checking and autocomplete.
#'
#' Every argument defaults to `NULL` unless stated otherwise. A `NULL` metadata
#' or appearance value falls back to the source document's YAML header and then
#' to the template default. Values supplied here take precedence over YAML.
#'
#' @param author,address,phone,email,website Contact metadata.
#' @param job_title,linkedin Resume-specific professional and contact metadata.
#' @param font_family A CSS `font-family` value. For example,
#'   `"Charter, Georgia, serif"`.
#' @param google_font A Google Fonts family name or a full Google Fonts CSS v2
#'   URL. This is an explicit online resource and is never used by default.
#'   A family name loads the available weights and styles needed for regular,
#'   bold, italic, and bold italic text, preferring a variable weight range.
#'   Supply a full URL to select other weights, axes, or options.
#' @param font_files A named character vector or list of local font files. Names
#'   may be `regular`, `italic`, `bold`, and `bold_italic`. Relative paths are
#'   resolved from the source document. Fonts are embedded in the HTML.
#' @param font_size A CSS length such as `"11pt"`.
#' @param font_scale A positive number used to scale `font_size`. This is useful
#'   when replacing a font with different metrics.
#' @param ligatures Whether to enable common and discretionary ligatures.
#'   The template default is `FALSE` for more predictable text extraction from
#'   PDFs.
#' @param line_height A positive unitless CSS line height or CSS length.
#' @param paragraph_spacing,section_spacing CSS lengths controlling vertical
#'   rhythm.
#' @param margins Page margins. Supply one to four CSS lengths using standard
#'   CSS shorthand order, or numeric values interpreted as inches.
#' @param paper A paper name (`"letter"`, `"a4"`, or `"legal"`) or a
#'   two-element vector containing width and height as CSS lengths.
#' @param link_color Any valid CSS color.
#' @param paged Whether the HTML preview should open in a paginated layout.
#'   Printing always invokes the packaged pages.js pagination.
#' @param keep_html For PDF output, whether to retain the intermediate HTML
#'   beside the PDF. Defaults to `FALSE`.
#' @param browser Path to Chromium, Google Chrome, or Microsoft Edge. `NULL`
#'   lets [xfun::browser_print()] discover it.
#' @return A `liteformats_resume_options` object for the `options` argument of
#'   [resume()].
#' @section YAML configuration:
#' In a source document, place metadata at the top level of the YAML header and
#' appearance controls in one flat `liteformats` mapping. YAML setting names
#' are the kebab-case equivalents of the helper arguments:
#'
#' ```yaml
#' author: "Jane Doe"
#' job-title: "Research Scientist"
#' liteformats:
#'   paper: letter
#'   margins: ["0.65in", "0.8in"]
#'   font-family: "Charter, Georgia, serif"
#'   font-size: 11pt
#'   font-scale: 0.94
#'   ligatures: false
#'   line-height: 1.15
#'   paragraph-spacing: 0.05em
#'   section-spacing: 1em
#'   link-color: "#385898"
#'   paged: true
#' ```
#'
#' Unknown `liteformats` YAML names are rejected to catch misspellings.
#' @export
#' @examples
#' resume_options(
#'   font_size = "10.5pt",
#'   margins = c("0.6in", "0.75in"),
#'   paged = FALSE
#' )
resume_options <- function(
  author = NULL,
  job_title = NULL,
  address = NULL,
  phone = NULL,
  email = NULL,
  website = NULL,
  linkedin = NULL,
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
) {
  new_liteformat_options(
    type = "resume",
    metadata = list(
      author = author,
      job_title = job_title,
      address = address,
      phone = phone,
      email = email,
      website = website,
      linkedin = linkedin
    ),
    settings = document_option_settings(
      font_family = font_family,
      google_font = google_font,
      font_files = font_files,
      font_size = font_size,
      font_scale = font_scale,
      ligatures = ligatures,
      line_height = line_height,
      paragraph_spacing = paragraph_spacing,
      section_spacing = section_spacing,
      margins = margins,
      paper = paper,
      link_color = link_color,
      paged = paged
    ),
    keep_html = keep_html,
    browser = browser
  )
}

#' Configure a cover letter
#'
#' Create a classed options object for [cover_letter()]. Settings work in the
#' same way as [resume_options()], with letter-specific metadata replacing the
#' resume-specific fields.
#'
#' @inheritParams resume_options
#' @param date,greeting Letter date and salutation.
#' @return A `liteformats_cover_letter_options` object for the `options`
#'   argument of [cover_letter()].
#' @section YAML configuration:
#' Use the same flat, kebab-case `liteformats` mapping documented in
#' [resume_options()]. Place cover-letter metadata such as `author`, `address`,
#' `date`, and `greeting` at the top level of the YAML header. Unknown
#' `liteformats` YAML names are rejected.
#' @export
#' @examples
#' cover_letter_options(
#'   greeting = "Dear Search Committee:",
#'   paragraph_spacing = "0.9em"
#' )
cover_letter_options <- function(
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
) {
  new_liteformat_options(
    type = "cover-letter",
    metadata = list(
      author = author,
      address = address,
      phone = phone,
      email = email,
      website = website,
      date = date,
      greeting = greeting
    ),
    settings = document_option_settings(
      font_family = font_family,
      google_font = google_font,
      font_files = font_files,
      font_size = font_size,
      font_scale = font_scale,
      ligatures = ligatures,
      line_height = line_height,
      paragraph_spacing = paragraph_spacing,
      section_spacing = section_spacing,
      margins = margins,
      paper = paper,
      link_color = link_color,
      paged = paged
    ),
    keep_html = keep_html,
    browser = browser
  )
}

document_option_settings <- function(
  font_family,
  google_font,
  font_files,
  font_size,
  font_scale,
  ligatures,
  line_height,
  paragraph_spacing,
  section_spacing,
  margins,
  paper,
  link_color,
  paged
) {
  list(
    font_family = font_family,
    google_font = google_font,
    font_files = font_files,
    font_size = font_size,
    font_scale = font_scale,
    ligatures = ligatures,
    line_height = line_height,
    paragraph_spacing = paragraph_spacing,
    section_spacing = section_spacing,
    margins = margins,
    paper = paper,
    link_color = link_color,
    paged = paged
  )
}

new_liteformat_options <- function(
  type, metadata, settings, keep_html = FALSE, browser = NULL
) {
  keep_html <- scalar_logical(keep_html, "keep_html")
  if (!is.null(browser)) {
    browser <- scalar_character(browser, "browser")
  }
  structure(
    list(
      type = type,
      metadata = metadata,
      settings = settings,
      keep_html = keep_html,
      browser = browser
    ),
    class = c(liteformat_options_class(type), "liteformats_options")
  )
}

check_liteformat_options <- function(options, type) {
  helper <- paste0(gsub("-", "_", type, fixed = TRUE), "_options")
  if (!inherits(options, liteformat_options_class(type)) ||
    !identical(options$type, type)) {
    stop(
      "`options` must be created by `", helper, "()`.",
      call. = FALSE
    )
  }
  options
}

liteformat_options_class <- function(type) {
  paste0("liteformats_", gsub("-", "_", type, fixed = TRUE), "_options")
}
