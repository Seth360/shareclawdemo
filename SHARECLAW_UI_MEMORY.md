# ShareClaw UI Semantic Memory

This file is the semantic memory for the ShareClaw static HTML demo. It records
the current UI architecture, semantic module map, selectors, state fields, and
stable interaction contracts. It should describe what the system is now, not the
history of how it became that way. Decision history belongs in
`SHARECLAW_DECISION_LOG.md`.

Before project work, read `SHARECLAW_PROJECT_GUIDELINES.md`.

## Shared Shell

ShareClaw is a static multi-page HTML demo. The main pages inline CSS, markup,
and JavaScript. Several files duplicate the same shell, so shared UI changes may
need to be synchronized across multiple HTML files.

| Semantic area | Selector / state | Role |
| --- | --- | --- |
| Top bar | `.topbar` | Company name, search, top-right icons, scheme switch. |
| Left primary rail | `.channel-rail`, `.channel-item[data-channel]` | First-level navigation: Claw, 企信, 待办, CRM, 工作, 日程. |
| Left secondary sidebar | `.sidebar` | Second-level navigation. Switches between default, settings, config, and messenger thread views. |
| Default sidebar | `#defaultSidebarView` | ShareAgent title menu, shortcuts, and the mixed history list that contains automation tasks plus normal conversations. |
| ShareAgent title menu | `#sidebarTitleTrigger`, `#sidebarTitleMenu`, `#sidebarUsageDetail` | Shared dropdown in every desktop page. Opens the settings modal and expands remaining-usage details in place. |
| ShareAgent settings modal | `#generalSettingsOverlay`, `#generalSettingsNameInput`, `#generalSettingsPromptInput` | Shared name/prompt settings form. Save persists the AI profile and updates the sidebar title. |
| Settings sidebar | `#settingsSidebarView` | Settings tabs. |
| Config sidebar | `#configSidebarView` | Scheme/config tabs. |
| Messenger sidebar | `#messengerSidebarView`, `#messengerThreadList` | 企信 thread list. |
| Main shell | `.main-shell` | Center content container for home/chat/task/docs/settings/messenger/market pages. |
| Home/chat shell | `#homeDashboardShell`, `.home-center-shell` | Dashboard, chat feed, composer, and right panels. |
| Chat feed | `#chatFlowShell`, `#chatFeed` | Main conversation display area. |
| Composer | `.composer-stage`, `.composer-card`, `#composerEditor`, `#sendBtn` | Chat input, mode picker, skill/agent selection, send action. |
| Home insight rail | `#homeInsightRail`, `#homeInsightToggle` | Dashboard right insight panel. |
| Generated result panel | `#chatOutputPanelShell`, `#chatOutputPanel`, `#chatOutputToggleBtn` | Right-side generated output list/detail surface. |

Core shared state:

| State field | Meaning |
| --- | --- |
| `state.mainPanel` | Active main module: `home`, `task`, `docs`, `settings`, `messenger`, `market`. |
| `state.homeView` | Home sub-mode: `dashboard` or `chat`. |
| `state.currentChannel` | Active first-level rail channel. |
| `state.activeChatId` | Current conversation session id. |
| `state.activeHistoryId` | Active normal sidebar history row. Automation rows use `sidebarHistoryStatus.activeAutomationTaskId`. |
| `state.activeMessengerThread` | Current 企信 thread id. |
| `state.outputResultsPanelOpen` | Whether the generated results panel is open. |
| `state.outputResultsPanelMode` | Generated results mode: `list` or `detail`. |
| `state.outputOpenTabs`, `state.activeOutputTabId` | Dynamic generated-result detail tabs. |
| `state.activeOutputMenuId`, `state.activeOutputMenuPosition` | Active generated-result row menu and its fixed viewport anchor. |
| `state.activeSchemePlanId` | Active first-level interaction scheme. Default: `sidebar-interaction`. |
| `state.activeSchemeCapability` | Active second-level capability: `dynamic-tabs` or `static-tabs`. |
| `state.schemeCapabilityByPlan` | Per-scheme capability selection. |
| `state.marketMode`, `state.marketPage` | Market module mode and subpage. |

Core shared render/navigation functions:

| Function | Role |
| --- | --- |
| `renderMainPanels()` | Central refresh function for panel visibility, sidebar state, history, channel rail, and active page rendering. |
| `renderHomePanels()` | Toggles dashboard/chat, insight rail, chat feed, composer, and output panel. |
| `renderSidebarMode()` | Switches secondary sidebar view. |
| `renderChannelRail()` | Syncs active first-level channel. |
| `renderHistoryList()` | Renders the default sidebar mixed history list: automation task rows plus normal conversation rows in `#historyList`. |
| `navigateToPanel(panel, params)` | Cross-page module navigation. |
| `navigateToConversation(params)` | Cross-page navigation into `conversation.html`. |
| `openSidebarHome()` | Returns to home dashboard. |
| `openConversationSession(sessionId)` | Opens a conversation and switches to chat mode. |
| `openMessengerConversation(threadId)` | Opens a 企信 thread and switches sidebar/main content. |

## Page Ownership

| File | Primary ownership |
| --- | --- |
| `index.html` | Home dashboard, base shared shell, dashboard composer, and simple generated-results panel. |
| `conversation.html` | Advanced independent chat page: Haiyue flow, generated-result list/detail, dynamic tabs, static detail mode, business object drawer, customer/deal confirmation flows. |
| `task-conversation.html` | Automation task chat page: `?task=...` route, CRM task report content, current automation run, and automation generated-output cards. |
| `task.html` | Task list, filters, task status tabs, create-task dialog. |
| `messenger.html` | 企信 thread sidebar and message canvas. |
| `market.html` | Agent square, skill center, automation view, created/batch/share flows, skill import flow. |
| `docs.html` | Shared shell plus document library. Shallow semantic mapping only. |
| `settings.html` | Shared shell plus settings pages. Shallow semantic mapping only. |
| `copilot/list-page.html` | CRM 客户对象列表页（独立 `copilot/` 界面）。点行 `openDetail(rowData)` 写 localStorage `crmActiveCustomer` 后下钻。 |
| `copilot/object-detail-overlay.html` | CRM 客户对象详情页 + 右侧 Ask Agent（copilot）。详情与 copilot 通过 Ask Agent 联动。 |

### Copilot Surface (`copilot/`)

`copilot/` 是独立于 8 主页的新版 CRM 界面，仅「客户」对象通路打通。

- **客户身份契约**：`list-page.html` `openDetail(rowData)` 把客户记录写 localStorage
  `crmActiveCustomer`；详情页脚本顶 `getActiveCustomer()` 读出 `currentCustomer`
  （无则回退 `上海云驰智能制造有限公司`）。客户名锚点加 `.js-customer-name` 类，初始化灌入。
- **数据驱动脚本**：`buildCustomerScript(currentCustomer)` 由名字 hash（`seedFromName`，
  `num` 必用无符号 `>>>`）确定性派生全部变量，返回 `{greeting, instructions:[{id,title,tag,
  question,answer}]}`；`answer={summary(含<b>),exec,followups}`。**业务逻辑固定，仅变量随客户变**。
  当前 3 条指令：q2 诊断 / q3 风险情报 / q4 增购（**q1 速览已按用户要求删除**）。
- **欢迎区**：`renderWelcome()` 渲染 `.agent-prompt` 胶囊（`.agent-prompt-text` + `.agent-prompt-tag`
  白底#545861字 + 11px 箭头，无序号，Figma 5169-52026）；欢迎语精简
  `Hi Scott，这个客户我已读完，你可以让我:`。点击 → `startInstruction(id)`。
- **一问一答**：`startInstruction`/`appendFollowup` → `pushAgentTurn`（用户气泡 + 650ms thinking
  → `renderAgentAnswer`）。`renderAgentAnswer` **不渲染 agent 头像/ShareAgent 名**（不调
  `renderAgentAiMeta`），直接 `.agent-chat-copy` + `renderExecCard`。followup chip（带
  `data-followup`）点击追加子问答并隐藏该 chip。事件用 `.agent-prompts`/`#agentChatFeed` 委托。
- **执行卡片 `.agent-chat-exec`**：视觉对齐 `conversation.html` 的 `.agent-action-card`
  「新建·客户」卡（**这才是用户认定的 ask-user-question 样式**）——0.5px #dee1e8 边 / 16px 圆角 /
  无阴影；header 标题 + 可执行紫 pill（#f7f0ff/#7341de，对齐 `.agent-action-badge`）；
  行 k(#545861)·val·徽标(amber/red/green)；note；**动作按钮在底部 `.agent-chat-exec-footer`
  （flex-end，对齐 `.agent-action-footer`），黑色 `.agent-action-btn.primary`（#181c25 / h32 /
  border1px#181c25 / radius8 / 13px / 白字），不是紫色，不嵌行内**。布局宽松：16px 内边距、12px 行距、
  64px 标签列。`[data-exec-action]` → `emitBridge` toast。

## Semantic Lookup

| User wording | Primary file | Selector / state | Function / event |
| --- | --- | --- | --- |
| 左侧一级菜单 / 左侧 rail | shared | `.channel-rail`, `.channel-item[data-channel]`, `state.currentChannel` | `renderChannelRail()`, channel click listeners |
| 左侧二级菜单 | shared | `.sidebar`, `#defaultSidebarView` | `renderSidebarMode()`, `syncSidebarSelection()` |
| 新建会话按钮 | shared | `.sidebar-primary-entry[data-panel="home"]` | `openSidebarHome()` |
| 历史会话列表 / 左侧混排列表 | shared | `#historyList`, `.history-row`, `[data-automation-task]`, `[data-session-id]`, `[data-history-url]` | `renderHistoryList()`, `openAutomationTaskConversation()`, `openConversationSession()` |
| 中间 chat | `index.html`, `conversation.html`, `task-conversation.html` | `#chatFlowShell`, `#chatFeed`, `state.activeChatId` | `renderChatConversation()` |
| Chat 吸顶标题区 | `task-conversation.html` | `#chatSessionTitlebar`, `#chatSessionTitleText` | `syncChatSessionTitlebar()` |
| 左侧菜单收起/展开按钮 | `conversation.html`, `task-conversation.html` | `.chat-sidebar-entry`（标题栏首子节点：镜像图标 + 8px 竖分隔线）, `#chatSidebarToggleBtn`, `.sidebar.collapsed` | 点击切换 `.sidebar` 的 `collapsed`（width 264↔0, 0.24s）；一级 rail 不受影响 |
| 左侧收起按钮红点 | `conversation.html`, `task-conversation.html` | `#chatSidebarToggleBtn.has-badge`（复用产出物按钮红点样式） | `syncSidebarToggleBadge()`：仅在「菜单已收起 且 `#historyList` 存在 `.history-status-dot.is-unread`」时显示；`renderHistoryList()` 末尾与收起切换时同步 |
| 生成结果展开/收起按钮 | `conversation.html`, `task-conversation.html` | `.chat-output-entry`（`#chatFlowShell` 直接子节点，absolute 锚定 `.chat-flow-shell` 右缘）, `#chatOutputToggleBtn` | `syncChatSessionTitlebar()` 同步其 hidden；位置随聊天列宽度跟随面板展开/收起动画 |
| 输入框 / composer | shared | `#composerEditor`, `.composer-card`, `#sendBtn` | send button listener, `openMockAiConversation()` |
| 触发词路由 | shared input pages -> `conversation.html` | `routeSpecialConversationTrigger(text)`, `specialConversationRouteMap`, `routeAgentActionTrigger(text)` | `信息收集`, `信息补全`, `删除客户`, `新建对象`, `编辑对象`, `更新对象`, `复杂查询`, `新建定时任务` route into `conversation.html` launch URLs. |
| 模式选择 / 指定智能体 | shared | `#agentPickerBtn`, `#agentPickerMenu`, `state.composerMode`, `state.activeAgent` | `setComposerMode()`, `renderAgentPill()`, `renderExposedPicker()` |
| 右侧 Daily 洞察 | `index.html` | `#homeInsightRail`, `#homeInsightToggle`, `state.homeInsightRailCollapsed` | insight listeners, `openInsightConversation()` |
| 右侧生成结果栏 / 产出物侧边栏 | mostly `conversation.html` | `#chatOutputPanelShell`, `#chatOutputPanel`, `.chat-output-entry`, `#chatOutputToggleBtn`, `state.outputResultsPanelOpen`, `state.businessObjectOverlayOpen` | `renderChatOutputPanel()` |
| 右侧生成结果列表 | `conversation.html` | `[data-output-doc-id]`, `[data-output-business-id]` | `getCurrentOutputResults()`, `renderOutputListPanel()` |
| 右侧通用文档操作 | `conversation.html`, `docs.html` | `[data-output-doc-action]`, `[data-output-doc-menu-action]`, `.docs-row-inline-action` | Document row actions expose download and forward; remaining actions stay in more menu. |
| 右侧业务文档操作 | `conversation.html` | `[data-output-business-id]`, `[data-output-business-menu-action="forward"]` | Business source rows expose only forward icon in list. |
| 方案切换入口（已移除） | `conversation.html`, `task-conversation.html` | 入口已删；交互锁定 `static-tabs`（见 Scheme Lock 节） | `renderSchemeSwitch()` 现为空守卫 |
| 右侧文档详情 | `conversation.html` | `state.outputOpenTabs`, `state.activeOutputTabId` | `openOutputPanelTab("doc", id)`, `renderOutputDetailPanel()` |
| 右侧业务详情 / 客户详情 | `conversation.html` | `[data-output-business-id]`, `.embedded-object-detail`, `#businessObjectOverlay` | `openOutputPanelTab("business", id)` or `openBusinessObjectOverlay(id)` |
| 右侧详情宽度拖拽 | `conversation.html` | `[data-output-resize-handle]`, `state.outputDetailPanelWidth` | pointer listeners, `applyOutputDetailPanelWidth()` |
| 创建客户确认卡片 | `conversation.html` | `#customerCreateComposerCard`, session `source: "create-customer"` | `beginCreateCustomerConversation()`, `updateCustomerCreateComposer()` |
| 创建客户产出物 | `conversation.html` | `.created-customer-detail-card`, `[data-chat-card="open-created-customer"]`, dynamic source id `business-created-customer-${session.id}` | `renderCustomerObjectArtifactCard()`, `renderCreatedCustomerDetailCard()`, `getCreatedCustomerSource()`, `getCurrentBusinessSources()` |
| 创建定时任务产出物 | `conversation.html` | `.scheduled-task-detail-card`, `[data-chat-card="open-created-scheduled-task"]`, dynamic source id `business-created-scheduled-task-${session.id}` | `renderScheduledTaskArtifactCard()`, `getCreatedScheduledTaskSource()`, `getCurrentBusinessSources()` |
| 创建商机确认卡片 | `conversation.html` | `#dealCreateComposerCard`, session `stage: "deal-confirming"` | `beginCreateDealFromCustomer()` |
| 查询客户卡片 / 商机卡片 | `conversation.html` | `[data-chat-card]`, `.query-customer-card`, `.complex-query-card-icon` | chat feed click handler |
| 复杂查询客户列表 | `conversation.html` | `.complex-query-summary`, `.complex-query-card`, `.complex-query-object-card`, `[data-chat-card="open-complex-query-customer"]` | `renderComplexQueryResultBlock()`, `renderComplexQueryCustomerCard()`, `getComplexQueryCustomers()` |
| Agent Action 审核卡 | `conversation.html` | `.agent-action-card`, `[data-agent-action]`, session `source` starts with `agent-action-` | `startAgentActionCreateObjectConversation()`, `startAgentActionEditObjectConversation()`, `startAgentActionUpdateObjectConversation()`, `startAgentActionCreateTaskConversation()`, `renderAgentActionConversation()` |
| 海岳客户简报 | `index.html`, `conversation.html` | session `haiyue-brief`, doc `doc-haiyue-brief` | `shouldUseHaiyueBriefFlow()`, `openHaiyueBriefConversation()` |
| 企信线程列表 | `messenger.html` | `#messengerThreadList`, `[data-thread-id]`, `state.activeMessengerThread` | `renderMessengerSidebar()`, `openMessengerConversation()` |
| 企信消息内容 | `messenger.html` | `#messengerHeader`, `#messengerCanvas` | `renderMessengerShell()`, `renderMessengerCanvasContent()` |
| 任务页 | `task.html` | `#taskShell` | `openTaskPage()`, `renderTaskPage()` |
| 任务 tab | `task.html` | `[data-task-tab]`, `taskPageState.tab` | tab listeners |
| 任务搜索 / 状态筛选 | `task.html` | `#taskSearchInput`, `#taskStatusFilter`, `taskPageState.query/status` | `getVisibleTaskRecords()`, `renderTaskPage()` |
| 创建任务弹窗 | `task.html` | `#createTaskOverlay`, `#createTaskDialogBody`, `state.createTaskForm` | `openCreateTaskDialog()`, `renderCreateTaskDialog()`, `confirmCreateTaskDialog()` |
| 自动化任务对话 | `task-conversation.html` | `?task`, `state.activeAutomationTaskId`, `state.activeAutomationRunId`, `automationTaskCatalog` | `openAutomationTaskConversation()`, `renderAutomationTaskConversation()` |
| 自动化任务报告侧栏 | `task-conversation.html` | `#chatOutputPanelShell.automation-list`, `#chatOutputPanel`, `.automation-output-card`, `.automation-report-row.unread`, `[data-automation-run-id]`, `sidebarHistoryStatus.automationReadRunKeys` | `renderAutomationTaskReportCard()`, `renderOutputListPanel()`, `markAutomationRunRead()` |
| 自动化业务生成结果 | `task-conversation.html` | `#chatOutputPanelShell.automation-list`, `[data-output-doc-id]`, `[data-output-business-id]` | `renderBusinessOutputCard()`, `getAutomationTaskOutputRuns()`, `getAutomationOutputDocs()`, `getAutomationOutputBusinessSources()` |
| 智能体广场 | `market.html` | `#marketShell`, `#appSquarePage`, `state.marketMode` | `openMarketPage("square")`, `renderMarketSquare()` |
| 技能中心 / 已添加 | `market.html` | `#createdPage`, `#manageInstalledTab`, `#createdGrid`, `state.manageSource = "installed"` | `renderCreatedView()` |
| 我创建的技能 | `market.html` | `#manageCreatedTab`, `state.manageSource = "created"` | `renderCreatedView()` |
| 批量操作 | `market.html` | `#bulkEditBtn`, `[data-batch-id]`, `state.selectedCreatedIds`, `state.manageBatchMode` | created grid click handler |
| 共享给同事 | `market.html` | `#sharePage`, `#selectedShareList` | `renderShareView()`, share confirmation listener |
| 导入技能 | `market.html` | `#skillImportPage`, `#skillImportTableBody`, `state.skillImportStatus` | `renderSkillImportView()`, skill import listeners |
| 自动化任务页 | `market.html` | `#marketAutomationView`, `state.marketMode = "automation"` | `switchMarketMode("automation")`, `renderMarketSquare()` |

## Interaction Contracts

### Shared ShareAgent Title Menu

- Every desktop HTML page uses the same ShareAgent title dropdown in
  `#defaultSidebarView`; shared-shell changes to this dropdown must be applied
  to `index.html`, `conversation.html`, `task-conversation.html`, `task.html`,
  `docs.html`, `settings.html`, `market.html`, and `messenger.html`.
- The dropdown contains `设置` and `剩余用量`. Remaining usage expands inside
  the same dropdown: today's remaining percentage and reset time share one
  card, while monthly remaining percentage is a separate row below.
- `设置` opens `#generalSettingsOverlay` without navigating away. The modal
  contains name and prompt fields plus save/cancel actions. Saving updates and
  persists `state.aiProfile`; closing, canceling, overlay click, and Escape do
  not submit pending edits.

### Generated Results Panel

- In `conversation.html`, generated documents and business sources are merged
  into one current-session list sorted by `sortKey` descending.
- Generated output list rows use the compact list rhythm: 46px minimum row
  height, 10px internal item gap, and 4px left inset. The same rhythm applies to
  business generated-result rows and automation output-card rows.
- Generated output list areas show at most five rows before scrolling. With the
  compact row rhythm this is `max-height: calc(46px * 5)`.
- The generated-results list has no "当前 / 所有文档" tabs and no separate
  business-source section title.
- The list surface is a floating card. In list mode its title is
  `业务生成结果`, with no title icon and no internal close button; collapse is
  controlled by the external `#chatOutputToggleBtn`.
- In `conversation.html` and `task-conversation.html`, the external toggle
  `.chat-output-entry` is a direct child of `#chatFlowShell` (not inside the
  titlebar), absolutely anchored to the chat column's right edge
  (`top: -5px; right: 0` on `.chat-flow-shell`). Because the panel shell is a
  flex sibling animating `width 0 ↔ 372px`, the button follows the panel's
  expand/collapse motion automatically; no JS offset is involved. Its
  visibility mirrors the session titlebar through `syncChatSessionTitlebar()`.
  `index.html` keeps its own simpler model (button hidden while panel open).
- The session titlebar on those two pages spans the full chat column
  (`width: 100%`, not the centered 868px block — the centered width only
  applies to the chat feed column) and starts with `.chat-sidebar-entry`:
  a mirrored toggle icon (vertical bar on the left of the rect) plus an 8px
  `#dee1e8` divider, followed by the title text, all pinned to the column's
  left edge (Figma node `4630:34893`).
  Clicking `#chatSidebarToggleBtn` toggles `collapsed` on the shared
  `.sidebar` (secondary navigation), animating width 264px ↔ 0 over 0.24s;
  the primary channel rail stays. The title trigger has no leading icon —
  `.chat-session-title-icon` is retired on these pages.
- Generic document rows expose download and forward. Business source rows expose
  only forward in the list.
- Generated-result more menus use `.docs-row-menu-panel.output-floating-menu`
  with fixed viewport positioning so they are not clipped by card or scroll
  containers. Document-library menus keep the default in-row menu positioning.
- `source.actionLabel` may render row action tags such as `查询`, `更新`, or
  `创建`.
- Created-customer output is a business generated result, not only an in-chat
  detail card. After `create-customer`, `md-info-demo`, or
  `agent-action-create-object` reaches `stage: "created"`, or after
  `agent-action-update-object` reaches `stage: "updated"`,
  `getCurrentBusinessSources()` appends the dynamic
  `business-created-customer-${session.id}` source and the right
  `业务生成结果` list opens in list mode.
- For `agent-action-create-object`, clicking `创建` first moves the session to
  `stage: "creating"` and renders the standard thinking chip. After
  `AGENT_ACTION_THINKING_DELAY`, it enters `created` and renders the CRM object
  artifact.
- For `agent-action-update-object`, clicking `更新` first moves the session to
  `stage: "updating"` and renders the standard thinking chip. After
  `AGENT_ACTION_THINKING_DELAY`, it enters `updated`, renders the CRM object
  artifact with an `更新` action tag, and opens the right generated-results list.
- For `agent-action-create-scheduled-task`, successful creation renders a
  scheduled-task artifact card below the success copy and appends a dynamic
  `business-created-scheduled-task-${session.id}` source into the right
  `业务生成结果` list. The scheduled-task artifact uses an orange clock icon and
  displays the task name directly, without a `[定时任务]` title prefix.
- Ordinary customer object artifacts use `.created-customer-detail-card`. The
  legacy `.chat-customer-card` class is retired; query-only cards use
  `.query-customer-card`, and complex-query keeps only an isolated
  `.complex-query-card-icon` reuse.
- Complex-query results use the Figma object-list pattern from ShareClaw node
  `3295:26112`: completion uses compact `renderChatAiStatus()` without the
  ShareAgent identity row, then renders two summary text lines before the
  cards. The default list exposes three 380px CRM customer cards plus
  `查看全部（共X个客户）` when more exist; clicking that button only toasts
  `待接入列表页` and does not expand more cards. Related opportunity/order
  sections render as collapsed `details` rows that expand downward when clicked.
- In dynamic-tab mode, output details use `state.outputOpenTabs` and
  `state.activeOutputTabId`; the tab strip is visible only in detail mode and
  includes an add-tab menu for unopened current-session outputs.
- In static-detail mode, the dynamic tab strip is not rendered. Document details
  use a single right-panel detail page. Business object outputs open the
  detached drawer through `openBusinessObjectOverlay(id)`.
- In static-detail mode, document details and business object drawers are
  mutually exclusive. Opening one surface clears the previous surface instead of
  stacking details.
- Reopening generated results from the external icon in static-detail mode opens
  the list, not a stale detail.
- Detail width adapts to active output type and is capped to preserve chat area.
  Current-session drag switches to manual-width behavior.

### Business Object Drawer

- Static business object details are outside the generated-results sidebar.
- `#businessObjectOverlay` / `.business-object-drawer` start below the 48px top
  bar and keep the drawer left edge 200px from the viewport left edge.
- The drawer uses a soft right-drawer shadow and slide-in/slide-out transition.
- The drawer title area is rendered through `renderBusinessObjectTitleBar()`.
- Business object detail header actions show only the forward/share icon.
- There is no standalone `object-detail-overlay.html` module in the current
  project. Business object detail is embedded in `conversation.html` and
  `task-conversation.html`.

### Removed Mobile Prototype Files

- Removed mobile files: `Mobile.html`, `ShareClaw-Demo.html`, `image/1`, and
  `image/frame*.png`.
- Web desktop HTML files are `index.html`, `conversation.html`,
  `task-conversation.html`, `task.html`, `docs.html`, `settings.html`,
  `market.html`, and `messenger.html`.
- Mobile-file cleanup must not change Web desktop HTML behavior unless the user
  explicitly asks for a Web-side UI/navigation change.

### Scheme Lock (Switcher Removed)

- The chat-page scheme switcher (`#schemeSwitchBtn` / `#schemeSwitchMenu`,
  label `侧边栏交互方案`) is removed from the `conversation.html` and
  `task-conversation.html` topbars. Those pages run permanently in the
  `static-tabs` capability (runtime mode `static-detail`): no dynamic tab
  strip, document details as a single right-panel page, business objects in
  the detached drawer.
- The underlying scheme state machinery (`state.activeSchemeCapability`
  defaulting to `static-tabs`, `usesDynamicOutputTabs()`,
  `usesStaticOutputDetail()`, `SCHEME_CAPABILITIES`) is still in the code and
  consumed by `renderChatOutputPanel()`; `renderSchemeSwitch()` early-returns
  because its DOM is gone. Scheme choice was never persisted, so the default
  is authoritative.
- Other pages keep their separate `方案1/方案2` (`state.uiScheme`) topbar
  switcher; that is an unrelated config system.

### Automation Task Conversation

- `task-conversation.html?task=...` selects an item from
  `automationTaskCatalog`.
- Automation sessions use `source: "automation-task"` and intentionally do not
  render a user message bubble.
- `#chatSessionTitlebar` is sticky above `#chatFeed` after an AI message exists.
  It shows the task/session title and hosts the generated-results toggle.
- `openAutomationTaskConversation()` sets `state.activeAutomationTaskId`,
  `state.activeAutomationRunId`, opens generated results, and keeps the right
  panel in list mode.
- The automation right panel has two independent cards:
  `任务报告` and `业务生成结果`. The wrapper is transparent in
  `#chatOutputPanelShell.automation-list`.
- Both automation cards use the same compact generated-output row rhythm:
  46px minimum row height, 10px internal item gap, and 4px left inset.
- Each automation card body scrolls independently after five rows; do not put
  the two-card list behind one shared five-row height cap.
- `任务报告` rows use `.automation-report-row.active` for selected run and
  `.automation-report-row.unread` for unread blue dot.
- Blue dot semantics: left automation task unread marker means at least one
  unread report exists inside; right report blue dot marks the specific unread
  report. Merely opening a task does not clear unread. Clicking a concrete
  `[data-automation-run-id]` calls `markAutomationRunRead(taskId, runId)`,
  clears that report dot, and recomputes the left unread count.
- Clicking an automation report switches the active run, refreshes the central
  CRM report, and clears stale output detail state.
- Automation `业务生成结果` is task-level output, not active-run output. It
  aggregates all generated docs and business objects for the current automation
  task, so switching `任务历史` rows does not filter or replace this card.
- Automation business output rows reuse the static no-dynamic-tab behavior and
  open the detached business object drawer.
- Automation `业务生成结果` list rows use text-square icons: PDF red, DOC blue,
  and CRM purple. Icons are 24px in the task conversation generated-results
  list; CRM icon text is 9px. Action tags that mean read-only viewing, such as
  `查询` or `查看`, are hidden; mutating tags such as `创建` or `更新` remain
  visible.
- Business generated-result rows in task conversations usually expose only one
  forward action. Use the compact single-action width so object titles can show
  more text before truncation.

### Chat And Routing

- Default sidebar rows use `data-panel` to route to task, market, docs, or home.
- The default sidebar uses one `历史会话` group. `renderHistoryList()` mixes
  automation task rows and normal conversation rows in `#historyList`.
- Automation rows use `data-history-type="automation"` plus
  `data-automation-task` and route to `task-conversation.html?task=...`; on
  `task-conversation.html`, clicking another automation row updates the current
  task in place through `openAutomationTaskConversation()`.
- Normal history rows with `data-session-id` open the corresponding
  conversation session.
- Haiyue brief prompts containing `复盘`, `客户简报`, `侧边栏`, or `产出物` route
  into the Haiyue brief flow.
- Chat cards with supported `data-chat-card` values may route to messenger and
  set `state.mainPanel = "messenger"` plus `state.currentChannel = "messenger"`.
- Agent/skill use buttons route through `openMarketUseConversation(type, title)`
  and may navigate to `conversation.html?launch=market-use&type=...&label=...`.
- Special trigger words are normalized as route launches into
  `conversation.html`, not handled as separate local scene starters on each
  input page. Current trigger words are `信息收集`, `信息补全`, `删除客户`, `新建对象`,
  `编辑对象`, `更新对象`, `复杂查询`, and `新建定时任务`.
- The canonical trigger routes are `launch=info-collection`,
  `launch=md-info-demo`, `launch=delete-customer-demo`, and
  `launch=agent-action&type=create-object|edit-object|update-object|complex-query|create-scheduled-task`.

### Customer / Deal Flow

- Customer creation prompts are handled by `extractCustomerCreationName(text)`
  and `beginCreateCustomerConversation(promptText, customerName)`.
- Customer confirmation uses `#customerCreateComposerCard`.
- Confirm changes session stage to `created`; cancel changes stage to
  `canceled`.
- The reply chip `create-deal` calls `beginCreateDealFromCustomer(session)`.
- Deal flow progresses through `deal-thinking`, `deal-loading`,
  `deal-confirming`, then `deal-created` or `deal-canceled`.

## Page Notes

### `index.html`

Use for shared shell and dashboard-level behavior. Its right output panel is
simpler than `conversation.html`.

### `conversation.html`

Use for independent chat and advanced chat-side interactions: dynamic output
tabs, output details, static business object drawer, customer/deal confirmation,
Haiyue brief flow, and mock PDF generation.
Mock AI PDF cards use `.chat-info-card.is-pdf`: compact artifact-card rhythm,
left `PDF` square with `#FFF5F0` background and `#D93518` text, title as the
document name, and subtitle as `创建时间: ...` instead of `已生成 PDF · ...`.
Conversation generated-results PDF rows use the same text-square PDF icon
treatment instead of the old image icon. All `conversation.html`
generated-results list icons use a 24px square with 9px text.
CRM object artifact cards hide the action tag when `actionLabel` is `查询`;
creation/update tags remain visible.
Conversation generated-results business rows also hide read-only tags such as
`查询` or `查看`; mutating tags such as `创建` or `更新` remain visible.
Haiyue brief chat cards reuse the same artifact system: the customer link is a
CRM object artifact card, and `doc-haiyue-brief` is a PDF artifact card with
`创建时间: ...`.

### `task-conversation.html`

Use for automation task chat and sidebar behavior. It owns task-specific CRM
report content, automation run selection, automation unread report semantics,
and the two-card automation generated-results panel.

### `task.html`

Task records are static front-end data in `taskPageRecords`. Filtering is
front-end only through `taskPageState`. Create/edit task interactions show
toast feedback and do not persist records.

### `messenger.html`

Messenger is driven by `messengerThreads` and `state.activeMessengerThread`.
`renderMessengerShell()` hard-codes visible content for supported threads.

### `market.html`

Market data comes from `marketCollections`. `renderCreatedView()`,
`renderBatchView()`, and `renderShareView()` are skill-centered in current
behavior. Skill import is simulated with a predefined Skill file preview.

## Update Policy

Update this semantic memory in the same task when current system facts change:

- page ownership or canonical file responsibility,
- core layout selectors,
- state fields controlling navigation, active session, generated results, or
  unread/read behavior,
- render functions or event delegation selectors,
- right-panel interaction contracts,
- cross-page navigation,
- customer/deal/task/messenger/market semantic mappings.

If a change is mainly about why a decision exists, a user correction, or a
do-not-regress warning, update `SHARECLAW_DECISION_LOG.md` instead.
