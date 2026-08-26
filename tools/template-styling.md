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
During pagination, pages.js moves direct content into `.pagesjs-body` and
removes the empty `.resume-body`; flattened entry lists also lose their
`.resume-entry` ancestor. Scope shared content-list geometry to the persistent
`.liteformats-resume` document class so it survives both transformations.
Avoid selectors that would affect metadata such as contact information.

## How resume pagination works

pages.js fills a page from the direct element children of `.body`. Paragraphs
can split by rendered line, but `ul` and `ol` elements normally fragment only
between complete top-level `li` elements. A parent item that contains a nested
list is therefore atomic with all of its descendants. A multi-child `div` is
also not one of its breakable containers. CSS declarations such as
`break-after: avoid` do not change these JavaScript placement decisions.

CommonMark renders each `::: resume-entry` as a multi-child `div`, normally
containing two metadata paragraphs followed by a list. The resume script
therefore listens for `pagesjs:before` and replaces each direct entry wrapper
with its children just before pagination. Marker classes on the first, second,
and last children preserve the entry header and bottom-spacing styles. The
unpaged document retains the original semantic wrapper.

After flattening entries, the same event handler replaces each direct resume
list with styled paragraph items. This transformation is limited to the paged
DOM: the unpaged HTML keeps semantic `ul`, `ol`, and `li` markup. pages.js can
then use its paragraph splitter to fill every page through the last rendered
line that fits, including lines within a single item or its nested items.
Continuation fragments suppress duplicate markers. Unordered items retain the
template's positioned text glyphs; ordered items use native list-item markers.

Do not add `break-*`, `orphans`, or `widows` constraints to the resume. Resume
pagination is intentionally natural rather than keep-together or orphan-aware:
the author controls undesirable visual breaks by adjusting content and page
geometry.

When pages.js splits the final paragraph item in a list, it shallow-clones the
paragraph and its classes. Suppress list-opening, list-ending, and entry-ending
margins on nonterminal fragments; otherwise cloned margins consume usable
space at the page boundary.

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
5. Include a long `resume-entry` that must cross a page boundary. Confirm that
   earlier pages fill through the entry instead of moving the whole job.
6. Inspect the PDF as well as browser HTML. Repeat with the supported paper
   sizes and at least one font with noticeably different metrics.

Prefer element/class selectors that remain true after pages.js moves or clones
nodes. Keep list values in relative units so they scale with user-selected font
size and font scaling.
