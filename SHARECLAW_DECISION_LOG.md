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

### 2026-05-28 - Trigger Words Enter Scenes Through Routes

- Decision: AI composer trigger words on shared pages route to
  `conversation.html` instead of starting special scenes locally.
- Reason: one canonical route entry keeps cross-page behavior consistent and
  makes the active scene visible in the URL.
- Do not regress: trigger words such as `信息收集`, `信息补全`, `删除客户`, `新建对象`,
  `编辑对象`, `更新对象`, `复杂查询`, and `新建定时任务` should reach their target
  scenes through `conversation.html?launch=...` routes.

### 2026-05-29 - Created Customer Uses Output Artifact Loop

- Decision: after the info-collection customer intake creates a customer, the
  result is rendered as a compact CRM output artifact and is also added to the
  right `业务生成结果` list.
- Reason: the created customer is a generated business object, so it must be
  traceable from both the chat feed and the generated-result panel.
- Do not regress: the created-customer success state should not fall back to a
  large in-chat field-detail card or leave the right generated-result list
  empty.
- Update: `md-info-demo` customer creation also uses the same CRM object
  artifact loop, and the legacy `.chat-customer-card` style is retired. Query
  scenes keep isolated query-specific classes only.
- Update: `agent-action-create-object` uses the same minimal object artifact
  after create success and appends the dynamic customer to the right
  `业务生成结果` list.

### 2026-06-01 - Mobile Prototype Files Removed From Runtime

- Decision: remove the old mobile prototype files from the current project
  runtime surface: `Mobile.html`, `ShareClaw-Demo.html`, `image/frame*.png`,
  and `image/1`.
- Reason: the active product work is the desktop ShareAgent shell and the
  deleted mobile files were stale prototype surfaces.
- Boundary correction: deleting mobile files does not imply changing Web
  desktop HTML. Shared desktop pages must not be modified during mobile-file
  cleanup unless the user explicitly asks for a Web-side UI/navigation change.

### 2026-06-01 - Standalone Object Detail HTML Is Not Current

- Decision: `object-detail-overlay.html` is not a current project module.
- Reason: the file is absent from the working tree and not referenced by runtime
  HTML. The current business detail surface is embedded in `conversation.html`
  and `task-conversation.html` through `#businessObjectOverlay` and
  `.embedded-object-detail`.
- Do not regress: do not treat `object-detail-overlay.html` as a page ownership
  target unless the user explicitly reintroduces that standalone file.
- Update: clicking `创建` in `agent-action-create-object` shows a 1-second
  thinking state before the CRM object artifact is produced.
- Update: clicking `更新` in `agent-action-update-object` also shows a
  1-second thinking state, then produces the CRM object artifact and appends the
  customer to the right `业务生成结果` list.
- Update: `agent-action-create-scheduled-task` also produces a generated
  artifact after success: a scheduled-task card in the chat feed and a dynamic
  task source in the right `业务生成结果` list. Scheduled-task artifacts use the
  orange clock icon and display the task name directly without a type prefix.
- Update: complex-query results follow ShareClaw Figma node `3295:26112`: a
  CRM object-list layout without the old summary/count copy. Related
  opportunity/order sections default collapsed and expand downward on click.
  The completion state hides the ShareAgent identity row, renders two summary
  text lines before the cards, exposes three customer cards by default, and
  shows `查看全部（共X个客户）` when more customers exist. That button is a
  placeholder for a future list page and only toasts `待接入列表页`.

### 2026-06-11 - Generated-Results Toggle Follows The Panel

- Decision: in `conversation.html` and `task-conversation.html`, the
  generated-results toggle button moves together with the output panel's
  expand/collapse animation instead of staying fixed in the centered titlebar.
- Reason: user pointed out the toggle sat in dead space far from the open
  panel on wide screens; the icon should track the panel edge.
- Implementation: `.chat-output-entry` moved out of `#chatSessionTitlebar` to
  be a direct child of `#chatFlowShell`, absolutely anchored `right: 0` so the
  shrinking chat column carries it along the panel's width transition. The
  legacy half-wired `--chat-output-entry-offset` / `output-open` JS (never
  consumed by CSS) was removed.
- Do not regress: do not re-nest the toggle inside the titlebar flow and do
  not reintroduce JS-computed offsets for it; visibility must keep mirroring
  the titlebar via `syncChatSessionTitlebar()`.

### 2026-06-11 - Session Titlebar Hosts A Sidebar Collapse Toggle

- Decision: `conversation.html` and `task-conversation.html` get a sidebar
  collapse toggle at the left of the session title — a mirrored twin of the
  generated-results toggle — that collapses/expands the secondary `.sidebar`
  while the primary channel rail stays (Figma `ShareClaw` node `4630:34893`).
- Decision: the leading icon inside the session title trigger is removed; the
  title row is now toggle + divider + title text.
- Reason: user request following the Figma interaction spec.
- Do not regress: collapsing must hide only the secondary sidebar, never the
  channel rail; do not reintroduce a leading icon in the session title.

### 2026-06-11 - Chat Pages Lock To Static-Tabs; Scheme Switcher Removed

- Decision: remove the `侧边栏交互方案` two-level scheme switcher from the
  `conversation.html` and `task-conversation.html` topbars and keep only the
  `不支持动态页签` (static-tabs / static-detail) behavior.
- History: this was applied, rolled back together with the collapse-toggle
  red badge during a revert to an earlier checkpoint, then both were
  explicitly re-confirmed and re-applied by the user the same day.

### 2026-06-11 - Collapsed Sidebar Toggle Shows Unread Red Badge

- Decision: the left sidebar collapse toggle mirrors the generated-results
  toggle's badge logic — a red dot appears on `#chatSidebarToggleBtn` only
  while the sidebar is collapsed AND the history list contains at least one
  unread blue dot.
- Implementation: `syncSidebarToggleBadge()` reads the rendered
  `#historyList` for `.history-status-dot.is-unread`; synced at the end of
  `renderHistoryList()` and on collapse toggle. Reuses the existing
  `.chat-output-toggle-btn.has-badge` style.
- Do not regress: expanding the sidebar must clear the badge; reading reports
  while collapsed must update the badge through the normal
  `markAutomationRunRead()` → `renderHistoryList()` path — do not add a
  separate unread bookkeeping source.
- Implementation: topbar anchor markup and its listeners removed;
  `renderSchemeSwitch()` keeps a null guard for remaining render-cycle calls;
  scheme state machinery stays (default `static-tabs`, never persisted).
- Do not regress: do not reintroduce dynamic-tab UI paths on these pages; the
  `方案1/方案2` switcher on other pages is a separate system and was not
  touched.

## Correction Log

### 2026-06-04 - ShareAgent Title Menu Is Shared Across Desktop Pages

- Decision: the ShareAgent title dropdown, remaining-usage expansion, and
  settings modal are shared navigation behavior and must remain identical on
  all eight desktop HTML pages.
- Reason: the user explicitly requested that the completed dropdown and modal
  adjustments apply to every page navigation.
- Do not regress: do not update only `index.html` when changing
  `#sidebarTitleMenu`, `#sidebarUsageDetail`, or `#generalSettingsOverlay`.

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
