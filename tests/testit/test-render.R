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
  (!grepl("cdn.jsdelivr.net", html, fixed = TRUE))
  (!grepl("fonts.googleapis.com", html, fixed = TRUE))
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
  (grepl("Dear Hiring Committee:", html, fixed = TRUE))
})

assert("page dimensions and shorthand margins are normalized", {
  (css_paper("letter") == c("8.5in", "11in"))
  (css_paper("a4") == c("210mm", "297mm"))
  (css_margins(c("0.5in", "0.75in")) ==
    c("0.5in", "0.75in", "0.5in", "0.75in"))
  (scale_css_length("11pt", 0.9) == "9.9pt")
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
