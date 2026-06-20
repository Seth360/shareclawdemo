# ShareClaw Project Guidelines

This file defines project-level working rules for agents maintaining the
ShareClaw demo. It is the first file to read before any project work.

## Memory Model

ShareClaw uses three memory layers:

| Layer | File / location | Purpose |
| --- | --- | --- |
| Project guideline | `SHARECLAW_PROJECT_GUIDELINES.md` | Operating rules for agents: what to read, when to update memory, and how to respond. |
| Semantic memory | `SHARECLAW_UI_MEMORY.md` | Current UI facts: page ownership, semantic module map, selectors, state fields, render/event functions, and stable interaction contracts. |
| Episodic memory | `SHARECLAW_DECISION_LOG.md` | High-value decision history: why a rule exists, user corrections, tradeoffs, and do-not-regress notes. |

Working memory is not stored as a long-term project file by default. Keep
current task context in the active conversation. Create a temporary
`SHARECLAW_CURRENT_HANDOFF.md` only when a long or interrupted task must be
handed off across sessions; delete or archive it after the handoff is resolved.

## Local Checkpoints

When the user asks to "checkpoint", "做 checkpoint", "checkpoint commit",
"保存", or "记录一个节点", create a local Git checkpoint commit. Prefer the
project script:

```bash
./scripts/checkpoint.sh "short description"
```

Checkpoint rules:

- A checkpoint is a local Git commit only; it must not push to GitHub.
- The trigger words "checkpoint commit" and "保存" mean the same local
  checkpoint behavior unless the user explicitly asks to push or publish.
- The script commits all current worktree changes with `git add -A`.
- If the worktree is clean, the script creates an empty commit.
- If Git identity is missing, ask the user to configure `user.name` and
  `user.email`; do not invent identity values.
- Before checkpointing, inspect `git status --short` and flag clearly unrelated
  or risky files instead of silently committing them.

## Required Startup Reading

- Always read this file before starting work in this project.
- For UI or interaction work, read `SHARECLAW_UI_MEMORY.md` once at project
  start or when context has been compacted/lost.
- Read `SHARECLAW_DECISION_LOG.md` when a request touches a previously debated
  interaction, user-corrected behavior, or design tradeoff.
- Do not reread semantic or episodic memory before every small operation if the
  relevant content is already reliable in current context.

## Memory Update Rules

Update `SHARECLAW_UI_MEMORY.md` in the same task when a change modifies:

- page ownership or canonical file responsibility,
- core layout selectors,
- state fields controlling navigation, active session, panels, or unread/read
  behavior,
- render functions or event delegation selectors,
- right-panel behavior,
- cross-page navigation,
- major customer/deal/task/messenger/market semantic mappings.

Update `SHARECLAW_DECISION_LOG.md` when the task establishes or changes:

- a product/design decision and its reason,
- a user correction that prevents a likely future regression,
- a tradeoff between multiple plausible interaction models,
- a do-not-regress rule caused by prior implementation mistakes.

Pure visual changes do not require semantic or episodic memory updates unless
they redefine a reusable UI contract.

## Response Rule

- When updating memory or guidelines, do not show Markdown links to memory files
  in the final response because the client may render them as file cards.
- In final responses, state briefly that memory, decision log, or guidelines
  were updated.
- Do not expand or quote memory/guideline contents unless the user explicitly
  asks to see them.

## Current Maintenance Expectations

- Keep UI/interaction edits scoped to the relevant HTML file unless shared shell
  behavior requires cross-page updates.
- Preserve existing static-demo patterns: inline CSS, inline markup, and inline
  JavaScript inside each HTML page.
- Prefer existing selectors, state objects, and render functions over parallel
  abstractions.
- Treat `conversation.html` as the source of truth for advanced generated-result
  sidebar behavior unless the task explicitly targets `task-conversation.html`
  automation behavior.
