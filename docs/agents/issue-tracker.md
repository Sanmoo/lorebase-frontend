# Issue tracker: GitHub

Issues and specs live in GitHub Issues for `Sanmoo/lorebase-frontend`.
Use the `gh` CLI from this repository.

## Conventions

- Create: `gh issue create --title "..." --body-file <file>`
- Read: `gh issue view <number> --comments`
- List: `gh issue list --state open`
- Comment: `gh issue comment <number> --body-file <file>`
- Add/remove labels: `gh issue edit <number> --add-label "..."`
  or `--remove-label "..."`
- Close: `gh issue close <number> --comment "..."`

Use the label mappings in `triage-labels.md`.

## Pull requests as a triage surface

PRs as a request surface: no.

## Publishing and fetching tickets

When a skill says to publish to the issue tracker, create a GitHub issue.
When it says to fetch a ticket, read the GitHub issue and its comments.

## Wayfinding operations

- Map: one issue labelled `wayfinder:map`.
- Children: GitHub sub-issues; if unavailable, use a task list in the map
  and a `Part of #<map>` reference in each child.
- Types: `wayfinder:research`, `wayfinder:prototype`,
  `wayfinder:grilling`, or `wayfinder:task`.
- Blocking: use native GitHub issue dependencies; if unavailable,
  record `Blocked by: #<number>` in the child body.
- Frontier: open, unassigned children with no open blockers,
  in map order.
- Claim: assign the issue to the driving developer before working.
- Resolve: comment with the answer, close the child, and update
  the map with a summary and link.

## Legacy local files

Existing `.scratch/` files remain available as historical references.
Do not migrate them automatically or create new issue/spec files there.
