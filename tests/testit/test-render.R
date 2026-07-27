assert("resume starter renders to offline, self-contained HTML", {
  directory <- tempfile("liteformats-resume-")
  dir.create(directory)
  on.exit(unlink(directory, recursive = TRUE), add = TRUE)
  input <- use_resume(file.path(directory, "resume.Rmd"))
  output <- resume(input, paged = FALSE)
  html <- paste(readLines(output, warn = FALSE), collapse = "\n")

  (file.exists(output))
  (grepl('class="liteformats-document liteformats-resume"', html, fixed = TRUE))
  (grepl("pagesjs:after", html, fixed = TRUE))
  (grepl('addEventListener("pagesjs:before"', html, fixed = TRUE))
  (grepl("entry.replaceWith(...parts)", html, fixed = TRUE))
  (!grepl("resume-section-group", html, fixed = TRUE))
  (grepl(".liteformats-resume ul,", html, fixed = TRUE))
  (!grepl("cdn.jsdelivr.net", html, fixed = TRUE))
  (!grepl("fonts.googleapis.com", html, fixed = TRUE))
  (grepl("Example City, EX", html, fixed = TRUE))
  (grepl("(000) 000-0000", html, fixed = TRUE))
})

assert("cover-letter starter renders its semantic columns", {
  directory <- tempfile("liteformats-cover-")
  dir.create(directory)
  on.exit(unlink(directory, recursive = TRUE), add = TRUE)
  input <- use_cover_letter(file.path(directory, "letter.Rmd"))
  output <- cover_letter(input, paged = FALSE)
  html <- paste(readLines(output, warn = FALSE), collapse = "\n")

  (file.exists(output))
  (grepl('class="cover-layout"', html, fixed = TRUE))
  (grepl('class="cover-sidebar"', html, fixed = TRUE))
  (grepl(".cover-layout {\n  display: grid;", html, fixed = TRUE))
  (!grepl(".cover-layout {\n    display: block;", html, fixed = TRUE))
  (grepl("Acme Corporation", html, fixed = TRUE))
  (grepl("123 Example Street", html, fixed = TRUE))
  (grepl("Example City, EX 00000", html, fixed = TRUE))
  (grepl("(000) 000-0000", html, fixed = TRUE))
  (grepl("Dear Hiring Committee:", html, fixed = TRUE))
})

assert("page dimensions and shorthand margins are normalized", {
  (css_paper("letter") == c("8.5in", "11in"))
  (css_paper("a4") == c("210mm", "297mm"))
  (css_margins(c("0.5in", "0.75in")) ==
    c("0.5in", "0.75in", "0.5in", "0.75in"))
  (scale_css_length("11pt", 0.9) == "9.9pt")
})

assert("Google Fonts requests use the available essential faces", {
  lato <- google_font("Lato")
  inter <- google_font("Inter")
  linden <- google_font("Linden Hill")
  cardo <- google_font("Cardo")
  recursive <- google_font("Recursive")
  custom <- google_font(paste0(
    "https://fonts.googleapis.com/css2?",
    "family=Inter:ital,opsz,wght@0,14..32,100..900;",
    "1,14..32,100..900&display=swap"
  ))
  unknown <- try(google_font("A Font From The Future"), silent = TRUE)

  (lato$url == paste0(
    "https://fonts.googleapis.com/css2?",
    "family=Lato:ital,wght@0,400;0,700;1,400;1,700&display=swap"
  ))
  (inter$url == paste0(
    "https://fonts.googleapis.com/css2?",
    "family=Inter:ital,wght@0,400..700;1,400..700&display=swap"
  ))
  (linden$url == paste0(
    "https://fonts.googleapis.com/css2?",
    "family=Linden+Hill:ital@0;1&display=swap"
  ))
  (cardo$url == paste0(
    "https://fonts.googleapis.com/css2?",
    "family=Cardo:ital,wght@0,400;0,700;1,400&display=swap"
  ))
  (recursive$url == paste0(
    "https://fonts.googleapis.com/css2?",
    "family=Recursive:slnt,wght@-15..0,400..700&display=swap"
  ))
  (custom$family == "Inter")
  (inherits(unknown, "try-error"))
  (grepl("not in the bundled catalog", as.character(unknown), fixed = TRUE))
})

assert("Google Fonts are applied to rendered documents", {
  directory <- tempfile("liteformats-google-font-")
  dir.create(directory)
  on.exit(unlink(directory, recursive = TRUE), add = TRUE)
  input <- use_cover_letter(file.path(directory, "letter.Rmd"))
  output <- cover_letter(input, google_font = "Lato", paged = FALSE)
  html <- paste(readLines(output, warn = FALSE), collapse = "\n")

  (grepl(
    paste0(
      "family=Lato:ital,wght@0,400;0,700;1,400;1,700",
      "&amp;display=swap"
    ),
    html,
    fixed = TRUE
  ))
  (grepl('--lf-font-family:"Lato", Georgia,', html, fixed = TRUE))
})

assert("starter creation protects existing files", {
  directory <- tempfile("liteformats-copy-")
  dir.create(directory)
  on.exit(unlink(directory, recursive = TRUE), add = TRUE)
  path <- file.path(directory, "resume.Rmd")
  use_resume(path)
  error <- try(use_resume(path), silent = TRUE)

  (inherits(error, "try-error"))
  (grepl("File already exists", as.character(error), fixed = TRUE))
})
