# ShareClaw UI Memory

This file is the project-level memory for the ShareClaw demo HTML framework.
Update it in the same task whenever layout structure, selector names, state
fields, navigation flow, or major interactions change.

Before starting work on this project, read `SHARECLAW_PROJECT_GUIDELINES.md`.

## Purpose

ShareClaw is currently a static multi-page HTML demo. The main pages inline
their CSS, markup, and JavaScript in each HTML file. Several files duplicate
the same shell, so UI changes often need to be applied to more than one file.

Use this document as the first reference when a request describes UI by
business language, for example "右侧生成结果栏", "企信线程列表", "技能中心已添加区域",
or "创建客户确认卡片".

## Shared Shell

| Semantic area | Selector / state | Role |
| --- | --- | --- |
| Top bar | `.topbar` | Company name, search, top-right icons, scheme switch. |
| Left primary rail | `.channel-rail`, `.channel-item[data-channel]` | First-level product navigation such as Claw, 企信, 待办, CRM, 工作, 日程. |
| Left secondary sidebar | `.sidebar` | Second-level navigation. Changes between ShareClaw menu, settings menu, config menu, and messenger thread list. |
| Default sidebar view | `#defaultSidebarView` | ShareClaw menu with new conversation, shortcuts, task, market, docs, and history. |
| Settings sidebar view | `#settingsSidebarView` | Settings tabs: onboarding, runtime, basic. |
| Config sidebar view | `#configSidebarView` | Scheme 2 market config tabs: market, skill, automation. |
| Messenger sidebar view | `#messengerSidebarView`, `#messengerThreadList` | Thread list for 企信. |
| Main page shell | `.main-shell` | Center content container for home/chat/task/docs/settings/messenger/market pages. |
| Home/chat shell | `#homeDashboardShell`, `.home-center-shell` | Hosts dashboard hero, chat feed, composer, and optional right panels. |
| Chat feed | `#chatFlowShell`, `#chatFeed` | Main conversation display area. |
| Composer | `.composer-stage`, `.composer-card`, `#composerEditor`, `#sendBtn` | Chat input, mode picker, skill/agent selection, send action. |
| Home insight rail | `#homeInsightRail`, `#homeInsightToggle` | Right-side Daily insight panel on the dashboard. |
| Chat output panel | `#chatOutputPanelShell`, `#chatOutputPanel`, `#chatOutputToggleBtn` | Right-side generated results panel in chat mode. |

Important shared state fields:

| State field | Meaning |
| --- | --- |
| `state.mainPanel` | Active main module: `home`, `task`, `docs`, `settings`, `messenger`, `market`. |
| `state.homeView` | Home sub-mode: `dashboard` or `chat`. |
| `state.currentChannel` | Active first-level rail channel. |
| `state.activeChatId` | Current conversation session id. |
| `state.activeHistoryId` | Active sidebar history row. |
| `state.activeMessengerThread` | Current 企信 thread id. |
| `state.outputResultsPanelOpen` | Whether the chat output panel is open. |
| `state.activeSchemePlanId` | Active first-level interaction scheme in the top scheme switcher. Default is `sidebar-interaction`. |
| `state.activeSchemeCapability` | Active second-level capability for the selected scheme: `dynamic-tabs` or `static-tabs`. |
| `state.schemeCapabilityByPlan` | Per-scheme capability map so every first-level scheme owns its own dynamic-tab mode. |
| `state.marketMode` | Market mode: `agent`, `skill`, `automation`. |
| `state.marketPage` | Market subpage: `square`, `created`, `batch`, `share`, `skill-import`. |

Primary shared render/navigation functions:

| Function | Role |
| --- | --- |
| `renderMainPanels()` | Central refresh function for panel visibility, sidebar state, history, channel rail, and active page rendering. |
| `renderHomePanels()` | Toggles dashboard vs chat, insight rail, chat feed, composer state, and output panel. |
| `renderSidebarMode()` | Switches secondary sidebar view between default, settings, config, and messenger. |
| `renderChannelRail()` | Syncs active first-level channel. |
| `renderHistoryList()` | Renders chat history rows in the default sidebar. |
| `navigateToPanel(panel, params)` | Cross-page navigation for main modules. |
| `navigateToConversation(params)` | Cross-page navigation into `conversation.html`. |
| `openSidebarHome()` | Returns to home dashboard. |
| `openConversationSession(sessionId)` | Opens an existing conversation and switches to chat mode. |
| `openMessengerConversation(threadId)` | Opens a 企信 thread and switches sidebar/main content accordingly. |

## Page Ownership

| File | Primary ownership |
| --- | --- |
| `index.html` | Home dashboard and base shared shell. Good starting point for shared layout, topbar, rail, default sidebar, dashboard, composer, and basic output panel behavior. |
| `conversation.html` | Enhanced independent chat page. Owns advanced chat flows, output detail panel, business source detail, customer/deal creation confirmation, and right-side generated result tab behavior. |
| `task.html` | Task page. Owns task list, task filters, task status tabs, and create-task dialog. |
| `messenger.html` | Message page. Owns 企信 thread sidebar and message canvas rendering. |
| `market.html` | Agent/skill/automation area. Owns agent square, skill center, automation view, created/batch/share flows, and skill import flow. |
| `docs.html` | Shared shell plus docs library. Not deeply mapped yet except through shared navigation. |
| `settings.html` | Shared shell plus settings pages. Not deeply mapped yet except through shared navigation. |
| `object-detail-overlay.html` | Separate CRM-style object detail overlay reference. Not part of the main ShareClaw three-column shell. |

## Semantic Lookup

| User wording | Primary file | Selector / state | Function / event |
| --- | --- | --- | --- |
| 左侧一级菜单 / 左侧 rail | shared | `.channel-rail`, `.channel-item[data-channel]`, `state.currentChannel` | `renderChannelRail()`, channel click listeners |
| 左侧二级菜单 | shared | `.sidebar`, `#defaultSidebarView` | `renderSidebarMode()`, `syncSidebarSelection()` |
| 新建会话按钮 | shared | `.sidebar-primary-entry[data-panel="home"]` | `openSidebarHome()` |
| 历史会话列表 | shared | `#historyList`, `.history-row` | `renderHistoryList()`, `openConversationSession()` |
| 中间 chat | `conversation.html`, `index.html` | `#chatFlowShell`, `#chatFeed`, `state.activeChatId` | `renderChatConversation()` |
| 输入框 / composer | shared | `#composerEditor`, `.composer-card`, `#sendBtn` | send button click handler, `openMockAiConversation()` |
| 模式选择 / 指定智能体 | shared | `#agentPickerBtn`, `#agentPickerMenu`, `state.composerMode`, `state.activeAgent` | `setComposerMode()`, `renderAgentPill()`, `renderExposedPicker()` |
| 右侧 Daily 洞察 | `index.html`, shared shell | `#homeInsightRail`, `#homeInsightToggle`, `state.homeInsightRailCollapsed` | insight action listeners, `openInsightConversation()` |
| 右侧生成结果栏 | mostly `conversation.html` | `#chatOutputPanelShell`, `#chatOutputPanel`, `state.outputResultsPanelOpen` | `renderChatOutputPanel()` |
| 右侧生成结果列表 | `conversation.html` | `[data-output-doc-id]`, `[data-output-business-id]` | `getCurrentOutputResults()`, `renderOutputListPanel()`; fixed to current conversation outputs, merged document/business rows, sorted newest first |
| 右侧通用文档操作 | `conversation.html`, `docs.html` | `[data-output-doc-menu-action]`, `[data-output-doc-action]`, `.docs-row-inline-action` | Generic document rows expose download and forward icons like the docs library; remaining actions stay in the more menu. |
| 右侧业务文档操作 | `conversation.html` | `[data-output-business-id]`, `[data-output-business-menu-action="forward"]` | Business source rows expose only the forward icon; row click still opens business detail. |
| 方案切换入口 | `conversation.html` | `#schemeSwitchBtn`, `#schemeSwitchMenu`, `state.activeSchemePlanId`, `state.activeSchemeCapability` | `renderSchemeSwitch()`; first level is scheme list, second level is dynamic-tab capability. |
| 右侧文档详情 | `conversation.html` | `state.outputOpenTabs`, `state.activeOutputTabId` | `openOutputPanelTab("doc", id)`, `renderOutputDetailPanel()` |
| 右侧业务详情 / 客户详情 | `conversation.html` | `[data-output-business-id]`, `.embedded-object-detail` | `openOutputPanelTab("business", id)`, `renderOutputBusinessDetail()` |
| 右侧详情宽度拖拽 | `conversation.html` | `[data-output-resize-handle]`, `state.outputDetailPanelWidth` | pointerdown/move/up listeners, `applyOutputDetailPanelWidth()` |
| 创建客户确认卡片 | `conversation.html` | `#customerCreateComposerCard`, `state.activeChatId`, session `source: "create-customer"` | `beginCreateCustomerConversation()`, `updateCustomerCreateComposer()` |
| 创建商机确认卡片 | `conversation.html` | `#dealCreateComposerCard`, session `stage: "deal-confirming"` | `beginCreateDealFromCustomer()`, deal composer listeners |
| 客户卡片 / 商机卡片 | `conversation.html` | `[data-chat-card]`, `.chat-customer-card` | chat feed click handler |
| 海岳客户简报 | `conversation.html` | session id `haiyue-brief`, doc id `doc-haiyue-brief` | `openHaiyueBriefConversation()`, `renderHaiyueBriefConversation()` |
| 企信线程列表 | `messenger.html` | `#messengerThreadList`, `[data-thread-id]`, `state.activeMessengerThread` | `renderMessengerSidebar()`, `openMessengerConversation()` |
| 企信消息内容 | `messenger.html` | `#messengerHeader`, `#messengerCanvas` | `renderMessengerShell()`, `renderMessengerCanvasContent()` |
| 任务页 | `task.html` | `#taskShell` | `openTaskPage()`, `renderTaskPage()` |
| 任务 tab | `task.html` | `[data-task-tab]`, `taskPageState.tab` | tab click listeners |
| 任务搜索 / 状态筛选 | `task.html` | `#taskSearchInput`, `#taskStatusFilter`, `taskPageState.query/status` | `getVisibleTaskRecords()`, `renderTaskPage()` |
| 创建任务弹窗 | `task.html` | `#createTaskOverlay`, `#createTaskDialogBody`, `state.createTaskForm` | `openCreateTaskDialog()`, `renderCreateTaskDialog()`, `confirmCreateTaskDialog()` |
| 智能体广场 | `market.html` | `#marketShell`, `#appSquarePage`, `state.marketMode` | `openMarketPage("square")`, `renderMarketSquare()` |
| 智能体卡片 | `market.html` | `#enterpriseGrid`, `#marketPublicGrid`, `[data-agent-action]`, `[data-use-id]` | `renderAgentSquareCard()`, agent grid click handlers |
| 广场筛选 chip | `market.html` | `#marketFilterChips`, `[data-market-filter]`, `state.marketCategory` | `renderFilterChips()`, `renderMarketSquare()` |
| 技能中心 / 已添加 | `market.html` | `#createdPage`, `#manageInstalledTab`, `#createdGrid`, `state.manageSource = "installed"` | `renderCreatedView()` |
| 我创建的技能 | `market.html` | `#manageCreatedTab`, `state.manageSource = "created"` | `renderCreatedView()` |
| 批量操作 | `market.html` | `#bulkEditBtn`, `[data-batch-id]`, `state.selectedCreatedIds`, `state.manageBatchMode` | created grid click handler, batch action handlers |
| 共享给同事 | `market.html` | `#sharePage`, `#selectedShareList` | `renderShareView()`, `confirmShareBtn` listener |
| 导入技能 | `market.html` | `#skillImportPage`, `#skillImportTableBody`, `state.skillImportStatus` | `renderSkillImportView()`, skill import click/input handlers |
| 自动化任务页 | `market.html` | `#marketAutomationView`, `state.marketMode = "automation"` | `switchMarketMode("automation")`, `renderMarketSquare()` |

## Interaction Flows

### Left Sidebar To Center

Default sidebar rows use `data-panel`:

- `data-panel="task"` -> `openTaskPage()` -> `task.html`
- `data-panel="market"` -> `openMarketPage(...)` -> `market.html`
- `data-panel="docs"` -> `openDocsPage()` -> `docs.html`
- home/new conversation -> `openSidebarHome()` -> `index.html`

History rows with `data-session-id` open `conversation.html?session=...` through
`openConversationSession(sessionId)`.

### Center Chat To Right Panel

In `conversation.html`, generated documents and business sources are opened
inside the right panel. The list view no longer has "当前 / 所有文档" tabs and
is fixed to outputs from the active conversation. Document outputs and business
source outputs are merged into one flat list and sorted by `sortKey` descending;
there is no separate "业务来源" section title:

- Document card or generated result row -> `openOutputPanelTab("doc", doc.id)`
- Business/customer source row -> `openOutputPanelTab("business", source.id)`
- Generic document rows expose the same primary operations as the docs library:
  download and forward icons are visible; sync CRM, jump to chat, and copy link
  stay under the more menu.
- Business source rows expose only the forward icon in the list. Copy/open
  actions remain available from detail or row click behavior.
- Business source rows can show an action tag after the title through
  `source.actionLabel`. Examples: query/view-generated cards -> `查询`, field
  update outputs -> `更新`, created-record outputs -> `创建`.
- Business object detail rendering omits the embedded object header module when
  shown inside the generated-results panel.
- Business object detail header actions show only the forward/share icon.
- Dynamic output tabs are visible only in output detail mode. Returning to the
  list hides the tab strip and removes the wide detail layout so the list panel
  keeps the normal sidebar width.
- In detail mode, the dynamic tab strip has an add-tab icon after the open
  tabs. It opens a small menu of current-session generated outputs that are not
  already open, and selecting one opens it as a new dynamic tab.
- Detail width adapts to the active generated-result type: business/object
  detail uses a wider target width, generic document preview uses a narrower
  target width, both clamped to viewport bounds. Previously persisted widths do
  not disable auto sizing; only a drag in the current page session switches to
  manual-width behavior.
- Right panel list/detail state is controlled by `state.outputResultsPanelMode`,
  `state.outputOpenTabs`, and `state.activeOutputTabId`.

In `index.html`, the output panel is simpler and mainly shows the generated
results list.

### Chat To Messenger

Chat cards with `data-chat-card` may route to messenger:

- `open-linsong` -> `openMessengerConversation("linsong")`
- `open-tencent-group` -> `openMessengerConversation("tencent-group")`
- `open-east-ops` -> `openMessengerConversation("east-ops")`

Opening messenger switches `state.mainPanel = "messenger"` and
`state.currentChannel = "messenger"`.

### Scheme Switcher

In `conversation.html`, the top scheme switcher is now a two-level menu:

- First level: interaction schemes. The default scheme is
  `侧边栏交互方案` (`sidebar-interaction`). The old visible "方案2" option was
  removed from the switcher.
- First-level schemes can be added through the "新增方案" row.
- Clicking a first-level scheme drills into the second-level capability menu;
  the menu content is replaced in place and shows a "返回方案列表" row.
- Second level: each scheme owns a dynamic-tab capability choice:
  `支持动态页签` (`dynamic-tabs`, current behavior) or
  `不支持动态页签` (`static-tabs`). For now, `static-tabs` maps to the same
  runtime behavior as `dynamic-tabs`; it is a copied branch reserved for the
  next requested interaction change.
- Capability selection is stored per scheme in `state.schemeCapabilityByPlan`.

### Market To Conversation

Agent/skill use buttons call `openMarketUseConversation(type, title)`.
If not already on `conversation.html`, this navigates with:

```text
conversation.html?launch=market-use&type=...&label=...
```

The conversation page then creates a draft session and presets the composer
with the selected skill or agent.

### Create Customer / Deal Flow

In `conversation.html`, message text that matches customer creation patterns
is handled by `extractCustomerCreationName(text)` and
`beginCreateCustomerConversation(promptText, customerName)`.

Flow:

1. Create dynamic session id `create-customer-{timestamp}`.
2. Set session `source = "create-customer"` and `stage = "thinking"`.
3. After timeout, stage becomes `confirming`.
4. `updateCustomerCreateComposer()` hides the normal composer and shows
   `#customerCreateComposerCard`.
5. Confirm changes stage to `created`; cancel changes stage to `canceled`.
6. The reply chip `create-deal` calls `beginCreateDealFromCustomer(session)`.
7. Deal flow progresses through `deal-thinking`, `deal-loading`,
   `deal-confirming`, then `deal-created` or `deal-canceled`.

## Page Notes

### `index.html`

Use for shared shell and dashboard-level behavior. It has the same general
three-column layout, but its right output panel is less capable than
`conversation.html`.

### `conversation.html`

Use for all independent chat and advanced chat-side interactions. It includes:

- dynamic output panel tabs,
- output detail mode,
- business source detail,
- embedded CRM object detail,
- customer/deal creation confirmation cards,
- Haiyue brief flow,
- mock PDF generation flow.

### `task.html`

Task page records are front-end static data in `taskPageRecords`.
Filtering is front-end only through `taskPageState`.
Creating or editing tasks currently shows toast feedback and does not persist
or append records.

### `messenger.html`

Messenger is driven by `messengerThreads` and `state.activeMessengerThread`.
`renderMessengerShell()` hard-codes the visible content for each supported
thread. The send button is static.

### `market.html`

Market data comes from `marketCollections`. Important caveats:

- `renderMarketSquare()` currently routes non-automation square behavior back
  to agent mode.
- `renderCreatedView()`, `renderBatchView()`, and `renderShareView()` force
  `state.createdType = "skill"`, so created-agent/created-automation controls
  are partly present but not fully active in current behavior.
- Skill import is simulated: click the dropzone, show loading, then render a
  predefined Skill file preview.

## Maintenance Rule

When changing this UI, update this file in the same task if any of the
following changes:

- HTML ownership or page responsibility,
- core layout selectors,
- state fields that control navigation, active page, or active session,
- render functions,
- event delegation selectors,
- right-panel behavior,
- cross-page navigation,
- customer/deal creation flow,
- task/messenger/market semantic mappings.

If the implementation duplicates changes across multiple HTML files, document
which files are now canonical or whether all copies must remain synchronized.
