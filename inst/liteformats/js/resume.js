// Keep compact, list-based sections together when they fit on a page. This
// prevents a section heading from being orphaned when pages.js paginates.
document.querySelectorAll(".resume-body > h2").forEach((heading) => {
  const content = heading.nextElementSibling;
  if (!content || !["UL", "OL"].includes(content.tagName)) return;
  const section = document.createElement("section");
  section.className = "resume-section-group resume-entry";
  heading.before(section);
  section.append(heading, content);
});
