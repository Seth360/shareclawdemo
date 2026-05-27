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
| Default sidebar | `#defaultSidebarView` | ShareClaw menu, shortcuts, automation tasks, and history. |
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
| `state.activeHistoryId` | Active sidebar history row. |
| `state.activeMessengerThread` | Current 企信 thread id. |
| `state.outputResultsPanelOpen` | Whether the generated results panel is open. |
| `state.outputResultsPanelMode` | Generated results mode: `list` or `detail`. |
| `state.outputOpenTabs`, `state.activeOutputTabId` | Dynamic generated-result detail tabs. |
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
| `renderHistoryList()` | Renders default sidebar history and automation task rows. |
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
| `object-detail-overlay.html` | Separate CRM-style object detail overlay reference, outside the main three-column shell. |

## Semantic Lookup

| User wording | Primary file | Selector / state | Function / event |
| --- | --- | --- | --- |
| 左侧一级菜单 / 左侧 rail | shared | `.channel-rail`, `.channel-item[data-channel]`, `state.currentChannel` | `renderChannelRail()`, channel click listeners |
| 左侧二级菜单 | shared | `.sidebar`, `#defaultSidebarView` | `renderSidebarMode()`, `syncSidebarSelection()` |
| 新建会话按钮 | shared | `.sidebar-primary-entry[data-panel="home"]` | `openSidebarHome()` |
| 历史会话列表 | shared | `#historyList`, `.history-row` | `renderHistoryList()`, `openConversationSession()` |
| 中间 chat | `index.html`, `conversation.html`, `task-conversation.html` | `#chatFlowShell`, `#chatFeed`, `state.activeChatId` | `renderChatConversation()` |
| Chat 吸顶标题区 | `task-conversation.html` | `#chatSessionTitlebar`, `#chatSessionTitleText`, `.chat-output-entry`, `#chatOutputToggleBtn` | `syncChatSessionTitlebar()` |
| 输入框 / composer | shared | `#composerEditor`, `.composer-card`, `#sendBtn` | send button listener, `openMockAiConversation()` |
| 模式选择 / 指定智能体 | shared | `#agentPickerBtn`, `#agentPickerMenu`, `state.composerMode`, `state.activeAgent` | `setComposerMode()`, `renderAgentPill()`, `renderExposedPicker()` |
| 右侧 Daily 洞察 | `index.html` | `#homeInsightRail`, `#homeInsightToggle`, `state.homeInsightRailCollapsed` | insight listeners, `openInsightConversation()` |
| 右侧生成结果栏 / 产出物侧边栏 | mostly `conversation.html` | `#chatOutputPanelShell`, `#chatOutputPanel`, `.chat-output-entry`, `#chatOutputToggleBtn`, `state.outputResultsPanelOpen`, `state.businessObjectOverlayOpen` | `renderChatOutputPanel()` |
| 右侧生成结果列表 | `conversation.html` | `[data-output-doc-id]`, `[data-output-business-id]` | `getCurrentOutputResults()`, `renderOutputListPanel()` |
| 右侧通用文档操作 | `conversation.html`, `docs.html` | `[data-output-doc-action]`, `[data-output-doc-menu-action]`, `.docs-row-inline-action` | Document row actions expose download and forward; remaining actions stay in more menu. |
| 右侧业务文档操作 | `conversation.html` | `[data-output-business-id]`, `[data-output-business-menu-action="forward"]` | Business source rows expose only forward icon in list. |
| 方案切换入口 | `conversation.html` | `#schemeSwitchBtn`, `#schemeSwitchMenu`, `state.activeSchemePlanId`, `state.activeSchemeCapability` | `renderSchemeSwitch()` |
| 右侧文档详情 | `conversation.html` | `state.outputOpenTabs`, `state.activeOutputTabId` | `openOutputPanelTab("doc", id)`, `renderOutputDetailPanel()` |
| 右侧业务详情 / 客户详情 | `conversation.html` | `[data-output-business-id]`, `.embedded-object-detail`, `#businessObjectOverlay` | `openOutputPanelTab("business", id)` or `openBusinessObjectOverlay(id)` |
| 右侧详情宽度拖拽 | `conversation.html` | `[data-output-resize-handle]`, `state.outputDetailPanelWidth` | pointer listeners, `applyOutputDetailPanelWidth()` |
| 创建客户确认卡片 | `conversation.html` | `#customerCreateComposerCard`, session `source: "create-customer"` | `beginCreateCustomerConversation()`, `updateCustomerCreateComposer()` |
| 创建商机确认卡片 | `conversation.html` | `#dealCreateComposerCard`, session `stage: "deal-confirming"` | `beginCreateDealFromCustomer()` |
| 客户卡片 / 商机卡片 | `conversation.html` | `[data-chat-card]`, `.chat-customer-card` | chat feed click handler |
| 海岳客户简报 | `index.html`, `conversation.html` | session `haiyue-brief`, doc `doc-haiyue-brief` | `shouldUseHaiyueBriefFlow()`, `openHaiyueBriefConversation()` |
| 企信线程列表 | `messenger.html` | `#messengerThreadList`, `[data-thread-id]`, `state.activeMessengerThread` | `renderMessengerSidebar()`, `openMessengerConversation()` |
| 企信消息内容 | `messenger.html` | `#messengerHeader`, `#messengerCanvas` | `renderMessengerShell()`, `renderMessengerCanvasContent()` |
| 任务页 | `task.html` | `#taskShell` | `openTaskPage()`, `renderTaskPage()` |
| 任务 tab | `task.html` | `[data-task-tab]`, `taskPageState.tab` | tab listeners |
| 任务搜索 / 状态筛选 | `task.html` | `#taskSearchInput`, `#taskStatusFilter`, `taskPageState.query/status` | `getVisibleTaskRecords()`, `renderTaskPage()` |
| 创建任务弹窗 | `task.html` | `#createTaskOverlay`, `#createTaskDialogBody`, `state.createTaskForm` | `openCreateTaskDialog()`, `renderCreateTaskDialog()`, `confirmCreateTaskDialog()` |
| 自动化任务对话 | `task-conversation.html` | `?task`, `state.activeAutomationTaskId`, `state.activeAutomationRunId`, `automationTaskCatalog` | `openAutomationTaskConversation()`, `renderAutomationTaskConversation()` |
| 自动化任务报告侧栏 | `task-conversation.html` | `#chatOutputPanelShell.automation-list`, `#chatOutputPanel`, `.automation-output-card`, `.automation-report-row.unread`, `[data-automation-run-id]`, `sidebarHistoryStatus.automationReadRunKeys` | `renderAutomationTaskReportCard()`, `renderOutputListPanel()`, `markAutomationRunRead()` |
| 自动化业务生成结果 | `task-conversation.html` | `#chatOutputPanelShell.automation-list`, `[data-output-doc-id]`, `[data-output-business-id]` | `renderBusinessOutputCard()`, `getAutomationOutputDocs()`, `getAutomationOutputBusinessSources()` |
| 智能体广场 | `market.html` | `#marketShell`, `#appSquarePage`, `state.marketMode` | `openMarketPage("square")`, `renderMarketSquare()` |
| 技能中心 / 已添加 | `market.html` | `#createdPage`, `#manageInstalledTab`, `#createdGrid`, `state.manageSource = "installed"` | `renderCreatedView()` |
| 我创建的技能 | `market.html` | `#manageCreatedTab`, `state.manageSource = "created"` | `renderCreatedView()` |
| 批量操作 | `market.html` | `#bulkEditBtn`, `[data-batch-id]`, `state.selectedCreatedIds`, `state.manageBatchMode` | created grid click handler |
| 共享给同事 | `market.html` | `#sharePage`, `#selectedShareList` | `renderShareView()`, share confirmation listener |
| 导入技能 | `market.html` | `#skillImportPage`, `#skillImportTableBody`, `state.skillImportStatus` | `renderSkillImportView()`, skill import listeners |
| 自动化任务页 | `market.html` | `#marketAutomationView`, `state.marketMode = "automation"` | `switchMarketMode("automation")`, `renderMarketSquare()` |

## Interaction Contracts

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
- Generic document rows expose download and forward. Business source rows expose
  only forward in the list.
- `source.actionLabel` may render row action tags such as `查询`, `更新`, or
  `创建`.
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

### Scheme Switcher

- `conversation.html` scheme switcher is a two-level menu.
- First level lists interaction schemes. Default scheme:
  `侧边栏交互方案` (`sidebar-interaction`).
- First-level schemes can be added through the "新增方案" row.
- Clicking a first-level scheme drills into second-level capability selection.
- Second-level capabilities are `支持动态页签` (`dynamic-tabs`) and
  `不支持动态页签` (`static-tabs`).
- Default capability for `侧边栏交互方案` is `static-tabs`.
- Capability selection is stored per scheme in `state.schemeCapabilityByPlan`.

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
  CRM report, clears stale output detail state, and refreshes generated outputs.
- Automation business output rows reuse the static no-dynamic-tab behavior and
  open the detached business object drawer.

### Chat And Routing

- Default sidebar rows use `data-panel` to route to task, market, docs, or home.
- History rows with `data-session-id` open `conversation.html?session=...`.
- Haiyue brief prompts containing `复盘`, `客户简报`, `侧边栏`, or `产出物` route
  into the Haiyue brief flow.
- Chat cards with supported `data-chat-card` values may route to messenger and
  set `state.mainPanel = "messenger"` plus `state.currentChannel = "messenger"`.
- Agent/skill use buttons route through `openMarketUseConversation(type, title)`
  and may navigate to `conversation.html?launch=market-use&type=...&label=...`.

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
