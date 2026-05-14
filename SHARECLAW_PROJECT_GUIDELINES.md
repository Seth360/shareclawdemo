# ShareClaw Project Guidelines

This file defines project-level working rules for agents maintaining the
ShareClaw demo. It is separate from `SHARECLAW_UI_MEMORY.md`, which documents
the UI framework, semantic module map, and interaction logic.

## Required Startup Reading

- `SHARECLAW_PROJECT_GUIDELINES.md` is required reading before starting work on
  this project.
- After reading this file, load `SHARECLAW_UI_MEMORY.md` only when beginning a
  ShareClaw UI/interaction task or when the current context no longer contains
  reliable UI memory.
- Treat this file as the project operating guideline and
  `SHARECLAW_UI_MEMORY.md` as the UI semantic memory.

## UI Memory Rule

- `SHARECLAW_UI_MEMORY.md` is project memory, not app runtime memory.
- Read `SHARECLAW_UI_MEMORY.md` once when starting work on this project, or
  when context has been compacted/lost and the UI memory is no longer reliable.
- Do not reread `SHARECLAW_UI_MEMORY.md` before every small operation if its
  content is already present in the current working context.
- Use the injected memory to map user language to HTML modules, selectors,
  state fields, and render/event functions.
- Update `SHARECLAW_UI_MEMORY.md` in the same task whenever a change modifies
  layout structure, selector names, state fields, navigation flow, or major
  interaction logic.
- If a change is purely visual and does not alter module semantics or
  interaction logic, updating `SHARECLAW_UI_MEMORY.md` is not required.

## Response Rule

- When updating project memory or guidelines, do not show Markdown links to
  `SHARECLAW_UI_MEMORY.md` or `SHARECLAW_PROJECT_GUIDELINES.md` in the final
  response because the client renders them as file cards.
- In final responses, only state briefly that memory or guidelines were updated.
- Do not expand or quote memory/guideline contents unless the user explicitly
  asks to see them.

## Current Maintenance Expectations

- Keep UI/interaction edits scoped to the relevant HTML file unless shared
  shell behavior requires cross-page updates.
- Preserve existing static-demo patterns: inline CSS, inline markup, and inline
  JavaScript inside each HTML page.
- Prefer existing selectors, state objects, and render functions over inventing
  parallel structures.
- When changing the right-side generated results panel in `conversation.html`,
  treat it as the source of truth for advanced chat output behavior.
