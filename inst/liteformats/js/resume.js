// pages.js moves a multi-child <div> to the next page as one unbreakable
// element. Flatten resume entries immediately before pagination so their
// paragraphs and lists can fill the current page and fragment normally.
addEventListener("pagesjs:before", () => {
  document.querySelectorAll(".resume-body > .resume-entry").forEach((entry) => {
    const parts = [...entry.children];
    if (!parts.length) {
      entry.remove();
      return;
    }

    if (parts[0].tagName === "P") {
      parts[0].classList.add("resume-entry-primary");
    }
    if (parts[1]?.tagName === "P") {
      parts[1].classList.add("resume-entry-secondary");
    }
    parts.at(-1).classList.add("resume-entry-last");
    entry.replaceWith(...parts);
  });
});
