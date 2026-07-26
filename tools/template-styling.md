# Template styling notes

These notes record implementation details for maintainers of the HTML templates.
They are not user-facing format documentation.

## Why compact lists require iteration

Resume lists combine several variables that are visually coupled: marker
position, text indent, wrapped-line alignment, line height, item spacing,
list spacing, and the space before the next section. A small change to one
value can alter both the apparent rhythm and the page break.

There are three additional sources of variability:

1. `litedown` emits CommonMark HTML. A tight list contains text directly in
   `<li>`, while a loose list contains `<p>` elements inside `<li>`.
   Blank lines in Markdown can therefore change which margins participate
   in the layout.
2. The templates supply their own stylesheets instead of litedown's
   default CSS. Browser defaults remain relevant unless `margin`, `padding`,
   `list-style-type`, and nested-list spacing are set explicitly for both
   `ul` and `ol`.
3. pages.js can split a top-level list across page boxes. It shallow-clones
   list wrappers, adds `pagesjs-fragmented`, `fragment-first`, and
   `fragment-last` classes, and adjusts `start` for continued ordered lists.
   Styles that depend on fragile sibling or first/last-child assumptions may
   behave differently after pagination.

The same list also appears in different semantic contexts: directly under
`.resume-body`, inside `.resume-entry`, and nested inside another list.
Selectors must cover these contexts without affecting metadata lists such as
contact information.

## Reliable workflow

1. Render with `paged = FALSE` and inspect the exact generated elements before
   changing CSS. Do not assume Pandoc-style HTML structure.
2. Define the outer `ul` and `ol` geometry explicitly, then define `li` rhythm
   and nested-list overrides separately.
3. Test tight, loose, nested unordered, and ordered lists. Include a wrapped
   item so marker-to-text alignment is visible.
4. Render with pagination enabled and force a list across a page boundary.
   Confirm that indentation, spacing, markers, and ordered numbering survive
   pages.js fragmentation.
5. Inspect the PDF as well as browser HTML. Repeat with the supported paper
   sizes and at least one font with noticeably different metrics.

Prefer element/class selectors that remain true after pages.js moves or clones
nodes. Keep list values in relative units so they scale with user-selected font
size and font scaling.
