# ShareClaw Decision Log

This file is the episodic memory for the ShareClaw demo. It records high-value
decisions, user corrections, tradeoffs, and do-not-regress notes. Current UI
facts and selector maps belong in `SHARECLAW_UI_MEMORY.md`.

## Decision Log

### 2026-05-22 - Memory Is Split Into Semantic And Episodic Layers

- Decision: keep `SHARECLAW_UI_MEMORY.md` as semantic memory and add this file
  as episodic memory.
- Reason: semantic memory should map user language to current code structure;
  episodic memory should preserve why certain interaction rules exist and which
  mistakes should not repeat.
- Working memory remains in the active conversation by default. Use a temporary
  `SHARECLAW_CURRENT_HANDOFF.md` only for explicit cross-session handoff.

### 2026-05-22 - Generated Results Panel Uses Floating Card Form

- Decision: the generated-results sidebar is a floating card, not a full-height
  flush rail, in the current card-based UI.
- Reason: user moved the design from a continuous rail to a Figma card-style
  side panel.
- Do not regress: do not reintroduce an internal close icon in list mode when
  the external toggle is the collapse control.

### 2026-05-22 - Static And Dynamic Generated-Result Schemes Are Separate

- Decision: `支持动态页签` and `不支持动态页签` are second-level capabilities under
  the first-level `侧边栏交互方案`.
- Reason: user needs to compare interaction schemes without cross-contaminating
  their behavior.
- Do not regress: changes for static-tabs must not silently alter dynamic-tabs
  behavior unless explicitly requested.

### 2026-05-22 - Static Business Object Detail Is Detached From Sidebar

- Decision: in static-tabs mode, business object details open as a detached
  right-side drawer instead of as generated-results sidebar detail.
- Reason: user clarified that business data detail is outside the sidebar scene.
- Do not regress: document details may stay in the output card, but business
  object details should use the drawer in static-tabs mode.

### 2026-05-22 - Automation Task Chat Has No User Message

- Decision: automation task conversations render only the task-generated AI
  message, not a user message bubble.
- Reason: automation tasks are system-triggered jobs, not user-submitted chat
  prompts.
- Do not regress: task prompt text may appear as task context/title metadata,
  but should not render as a user bubble.

### 2026-05-22 - Automation Task Report Blue Dot Means Unread

- Decision: blue dots in automation task reporting mean unread report state,
  not active selection.
- Correction history: active selection was first mistaken as the blue-dot source;
  then merely opening a task was mistaken as reading the report. User clarified
  the correct model: the left automation task unread marker means at least one
  report inside is unread; the right report row dot identifies the specific
  unread report; only clicking a concrete report row marks it read.
- Do not regress: opening an automation task must not clear unread. Clicking
  `[data-automation-run-id]` is the read action.

### 2026-05-28 - Automation Business Outputs Are Task-Level

- Decision: in automation task conversations, the right `业务生成结果` card shows
  all generated business outputs for the current automation task, not only the
  selected task history run.
- Reason: user clarified that `任务历史` controls the central report content,
  while `业务生成结果` is the full output set under the automation entry.
- Do not regress: switching `[data-automation-run-id]` must not filter or replace
  the business generated-results card.

### 2026-05-28 - Checkpoints Are A Project Capability

- Decision: add `scripts/checkpoint.sh` as the standard way to create a local
  restore point.
- Reason: memory records product knowledge but cannot restore file snapshots.
  Local Git commits provide a reliable rollback node for the current machine or
  any collaborator's clone.
- Do not regress: checkpoint must remain local-only and must not push to GitHub.
  If a collaborator has no Git repository or no Git identity configured, the
  script should fail with instructions rather than invent configuration.
- Trigger words: user requests containing "checkpoint commit" or "保存" should
  also create a local checkpoint commit through the script, unless the user
  explicitly asks for a different save behavior.

### 2026-05-28 - Left Sidebar Uses Desktop HTML Mixed History Model

- Decision: the shared left secondary sidebar uses the newly provided Desktop
  HTML model: one `历史会话` group whose `#historyList` mixes automation tasks
  and normal conversations.
- Reason: user clarified that the latest screenshot and Desktop HTML left menu
  are the source of truth for the sidebar.
- Boundary: only the left menu DOM/CSS/render/click entry is taken from the
  Desktop HTML. Current project chat content, generated-results sidebar,
  automation task reports, and business-object drawer remain the source of
  truth.
- Do not regress: do not reintroduce the old standalone
  `#automationTaskList` group in the shared sidebar, and do not replace current
  right-panel behavior with Desktop HTML content.

## Correction Log

| Topic | Correction |
| --- | --- |
| Memory file display | Do not show Markdown file links/cards for project memory updates in final responses. State briefly that memory or guidelines were updated. |
| Generated-results reopening | In static-detail mode, reopening from the external generated-results icon should enter the list, not stale detail content. |
| Multiple chat card opens | Opening another static detail surface should replace the previous one instead of stacking details. |
| Automation unread state | Left unread count and right report blue dots must stay consistent. A left unread marker without a right unread report is inconsistent. |

## Do-Not-Regress Notes

- Keep UI memory semantic: current selectors, state, functions, and stable
  interaction contracts.
- Keep this decision log episodic: reasons, corrections, tradeoffs, and
  regression warnings.
- Avoid using long-term working memory files for normal tasks.
- For ShareClaw UI work, use user product language as the primary semantic key
  and map it to selectors/functions through semantic memory.
