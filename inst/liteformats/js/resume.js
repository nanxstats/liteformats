// pages.js moves a multi-child <div> to the next page as one unbreakable
// element and fragments lists only between whole <li> elements. Flatten
// resume entries and list items immediately before pagination so paragraphs
// can fill the current page one rendered line at a time.
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

  const blockTags = new Set([
    "ADDRESS", "BLOCKQUOTE", "DIV", "DL", "FIGURE", "P", "PRE", "TABLE"
  ]);

  function meaningful(element) {
    return element.textContent.trim() ||
      element.querySelector("br, img, svg, canvas, video, audio");
  }

  function decorate(element, item, marker, indent, markerLeft) {
    element.classList.add("resume-list-item");
    element.style.setProperty("--resume-list-indent", `${indent}em`);

    if (!marker) {
      element.classList.add("resume-list-continuation");
      return;
    }

    element.classList.add("resume-list-marker");
    element.setAttribute("role", "listitem");
    element.setAttribute("aria-level", item.depth);
    if (item.ordered) {
      element.classList.add("resume-list-ordered");
      element.style.setProperty("--resume-list-marker-left", `${markerLeft}em`);
      element.style.listStyleType = item.listStyleType;
      element.style.counterSet = `list-item ${item.number}`;
      element.style.counterIncrement = "none";
    } else {
      element.classList.add("resume-list-unordered");
      if (item.depth > 1) element.classList.add("resume-list-nested");
      element.style.setProperty("--resume-list-marker-left", `${markerLeft}em`);
    }
  }

  function flattenList(list, parentIndent = 0, depth = 1, root = true) {
    const ordered = list.tagName === "OL";
    const reversed = ordered && list.reversed;
    const listStyleType = ordered ? getComputedStyle(list).listStyleType : "";
    let number = ordered ? (
      list.hasAttribute("start") ? list.start : (reversed ? list.children.length : 1)
    ) : 0;
    const markerLeft = parentIndent + (ordered ? 1.15 : 0);
    const indent = parentIndent + (ordered ? 1.23 : (depth === 1 ? 0.96 : 1.1));
    const output = [];

    [...list.children].forEach((li) => {
      if (li.tagName !== "LI") return;
      if (ordered && li.hasAttribute("value")) number = li.value;

      const item = { depth, listStyleType, number, ordered };
      let inline = null;
      let marker = true;

      function append(element) {
        if (!meaningful(element)) return;
        decorate(element, item, marker, indent, markerLeft);
        output.push(element);
        marker = false;
      }

      function flushInline() {
        if (!inline) return;
        append(inline);
        inline = null;
      }

      [...li.childNodes].forEach((node) => {
        const tag = node.tagName;
        if (tag === "UL" || tag === "OL") {
          flushInline();
          output.push(...flattenList(node, indent, depth + 1, false));
        } else if (tag && blockTags.has(tag)) {
          flushInline();
          append(node);
        } else {
          if (!inline) inline = document.createElement("p");
          inline.append(node);
        }
      });
      flushInline();
      number += reversed ? -1 : 1;
    });

    if (output.length) {
      output[0].classList.add(root ? "resume-list-root-first" : "resume-list-nested-first");
      output.at(-1).classList.add(root ? "resume-list-root-last" : "resume-list-nested-last");
      ["resume-entry-last", "resume-compact"].forEach((name) => {
        if (list.classList.contains(name)) output.at(-1).classList.add(name);
      });
    }
    return output;
  }

  document.querySelectorAll(".resume-body > ul, .resume-body > ol").forEach((list) => {
    const parts = flattenList(list);
    parts.length ? list.replaceWith(...parts) : list.remove();
  });
});
