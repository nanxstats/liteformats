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
can split by rendered line, and top-level `ul`, `ol`, `table`, and `blockquote`
elements can fragment. A multi-child `div` is not one of its breakable
containers: if the whole element overflows, pages.js moves it to the next page.
CSS declarations such as `break-after: avoid` do not change this JavaScript
placement decision.

CommonMark renders each `::: resume-entry` as a multi-child `div`, normally
containing two metadata paragraphs followed by a list. The resume script
therefore listens for `pagesjs:before` and replaces each direct entry wrapper
with its children just before pagination. Marker classes on the first, second,
and last children preserve the entry header and bottom-spacing styles. The
unpaged document retains the original semantic wrapper.

Do not wrap a heading and its complete list merely to keep them together.
That makes the entire section atomic and can move many lines that would
otherwise fit. Let the heading and list remain direct body children, and let
pages.js fragment lists at list-item boundaries. Some unused space can still
occur when the next individual list item does not fit; nested lists are part of
their parent item. This bounded underfill is preferable to moving an entire
job or section.

When the last child of an entry is a fragmented list, pages.js shallow-clones
its wrapper and classes. Apply entry-ending space only to the final fragment;
otherwise the cloned margin consumes usable space at every page boundary.

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
