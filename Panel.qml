import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Commons
import qs.Ui

import "NavigationModel.js" as NavModel
import "TipCatalog.js" as TipCatalog
import "components"

Panel {
  id: root
  moduleName: "nav-guide"
  ipcTarget: "nav-guide"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  readonly property string icon: "󰞋"

  // Base directory of the plugin
  readonly property string pluginDir: {
    var url = Qt.resolvedUrl(".").toString()
    url = url.replace(/^file:\/\//, "").replace(/\/$/, "")
    return url
  }

  // Active window and client state
  readonly property var toplevel: ToplevelManager.activeToplevel
  property var rawActive: ({})
  property var rawClients: []
  property var rawStats: ({ totalActions: 0, streak: 1, history: [], stats: {} })

  property string currentTab: "context" // "context" | "all" | "history" | "dojo"
  property string searchQuery: ""
  property int selectedIndex: 0

  // 1. Live Windows JSON FileView (Zero latency in-memory state)
  property string windowsPath: Quickshell.env("HOME") + "/.local/state/omarchy/nav-guide-windows.json"

  function loadWindows(rawText) {
    if (!rawText) return
    try {
      var data = JSON.parse(rawText)
      if (data && typeof data === "object") {
        root.rawActive = (data && data.active) ? data.active : {}
        root.rawClients = (data && Array.isArray(data.clients)) ? data.clients : []
      }
    } catch (e) {
      console.warn("nav-guide: failed to parse windows JSON:", e)
    }
  }

  FileView {
    id: windowsFile
    path: root.windowsPath
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: root.loadWindows(text())
    onFileChanged: reload()
  }

  // 2. Stats JSON FileView
  property string statsPath: Quickshell.env("HOME") + "/.local/state/omarchy/nav-guide-stats.json"

  function loadStats(rawText) {
    if (!rawText) return
    try {
      var data = JSON.parse(rawText)
      if (data && typeof data === "object") {
        root.rawStats = data
      }
    } catch (e) {
      console.warn("nav-guide: failed to parse stats JSON:", e)
    }
  }

  FileView {
    id: statsFile
    path: root.statsPath
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: root.loadStats(text())
    onLoadFailed: root.rawStats = { totalActions: 0, streak: 1, history: [], stats: {} }
    onFileChanged: reload()
  }

  // Refresh windows and stats synchronously
  function refreshAll() {
    windowsFile.reload()
    statsFile.reload()
    Quickshell.execDetached([root.pluginDir + "/bin/window-state"])
  }

  // Background Hyprland socket listener daemon (maintains nav-guide-windows.json & stats)
  Process {
    id: hyprListenerProc
    command: [root.pluginDir + "/bin/hypr-listener"]
    running: true
    stdout: SplitParser {
      onRead: function(line) {
        root.refreshAll()
      }
    }
  }

  Timer {
    id: statsRefreshTimer
    interval: 80
    repeat: false
    onTriggered: root.refreshAll()
  }

  function recordAction(key, desc, icon, category) {
    if (!key) return
    Quickshell.execDetached([
      "bash", "-c",
      'exec "$0" record "$1" "$2" "$3" "$4"',
      root.pluginDir + "/bin/stats-manager",
      key,
      desc || "",
      icon || "",
      category || ""
    ])
    statsRefreshTimer.restart()
  }

  function getCountForKey(key) {
    if (!root.rawStats || !root.rawStats.stats) return 0
    var item = root.rawStats.stats[key]
    return item ? (Number(item.count) || 0) : 0
  }

  Process {
    id: keybindInstaller
    command: [root.pluginDir + "/bin/register-keybind"]
  }

  Component.onCompleted: {
    keybindInstaller.running = true
    refreshAll()
  }

  // Hook both controller and opened property for popup open events
  Connections {
    target: root.controller
    function onOpenChanged() {
      if (root.controller.open) {
        root.recordAction("SUPER + K", "Navigation Guide HUD", "󰞋", "tools")
        root.refreshAll()
        searchField.text = ""
        root.searchQuery = ""
        root.selectedIndex = 0
        Qt.callLater(function() {
          searchField.forceActiveFocus()
        })
      }
    }
  }

  // Update whenever Wayland toplevel changes or panel opens
  onToplevelChanged: Qt.callLater(refreshAll)
  onOpenedChanged: {
    if (opened) {
      root.recordAction("SUPER + K", "Navigation Guide HUD", "󰞋", "tools")
      refreshAll()
      searchField.text = ""
      root.searchQuery = ""
      root.selectedIndex = 0
      Qt.callLater(function() {
        searchField.forceActiveFocus()
      })
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: root.refreshAll()
  }

  // App info for active window
  readonly property var activeApp: NavModel.detectAppInfo(
    root.rawActive.class || (toplevel ? toplevel.appId : ""),
    root.rawActive.title || (toplevel ? toplevel.title : "")
  )

  // Smart segmented navigation model (Real open windows & tabs)
  readonly property var smartNav: NavModel.buildSmartNavigation(
    root.rawActive,
    root.rawClients
  )

  // Mastery and Leaderboard models
  readonly property var navigatorRank: NavModel.getNavigatorRank(
    root.rawStats ? root.rawStats.totalActions : 0,
    root.rawStats ? root.rawStats.streak : 1
  )
  readonly property var leaderboardList: NavModel.getLeaderboard(
    root.rawStats ? root.rawStats.stats : {},
    TipCatalog.allShortcuts
  )
  readonly property var recentHistory: (root.rawStats && Array.isArray(root.rawStats.history)) ? root.rawStats.history : []
  readonly property var discoverList: NavModel.getDiscoverNext(
    root.rawStats ? root.rawStats.stats : {},
    TipCatalog.allShortcuts
  )

  // Omni Search: queries open windows first, then all shortcuts
  readonly property var searchResults: NavModel.searchAll(
    root.searchQuery,
    root.rawActive,
    root.rawClients,
    TipCatalog.allShortcuts
  )

  // Reliable action execution:
  // Dismisses popup panel first, logs the key to stats, then executes after 50ms
  function executeAction(cmd, key, desc, icon, category) {
    if (key) root.recordAction(key, desc, icon, category)
    if (!cmd) return
    root.close()
    actionTimer.pendingCmd = cmd
    actionTimer.restart()
  }

  Timer {
    id: actionTimer
    interval: 50
    repeat: false
    property string pendingCmd: ""
    onTriggered: {
      if (pendingCmd) {
        if (root.bar && root.bar.run) {
          root.bar.run(pendingCmd)
        } else {
          Quickshell.execDetached(["bash", "-lc", pendingCmd])
        }
        pendingCmd = ""
      }
    }
  }

  // Active items helper for keyboard selection
  function getActiveItems() {
    if (root.searchQuery !== "") {
      return root.searchResults
    }
    if (root.currentTab === "context") {
      return root.smartNav.openTasks.concat(root.smartNav.currentWindow).concat(root.smartNav.essentialTools)
    }
    if (root.currentTab === "all") {
      return TipCatalog.allShortcuts
    }
    if (root.currentTab === "history") {
      return root.leaderboardList
    }
    if (root.currentTab === "dojo") {
      return root.discoverList
    }
    return []
  }

  function selectNext() {
    var items = getActiveItems()
    if (items.length === 0) return
    root.selectedIndex = Math.min(items.length - 1, root.selectedIndex + 1)
  }

  function selectPrevious() {
    var items = getActiveItems()
    if (items.length === 0) return
    root.selectedIndex = Math.max(0, root.selectedIndex - 1)
  }

  function executeSelected() {
    var items = getActiveItems()
    if (items.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < items.length) {
      var item = items[root.selectedIndex]
      var key = item.key || ""
      var title = item.title || item.desc || ""
      var icon = item.icon || "󰌌"
      var badge = item.badge || item.category || ""
      root.executeAction(item.action, key, title, icon, badge)
    }
  }

  function cycleTab(direction) {
    var tabs = ["context", "all", "history", "dojo"]
    var curIdx = tabs.indexOf(root.currentTab)
    if (curIdx === -1) curIdx = 0
    var nextIdx = (curIdx + direction + tabs.length) % tabs.length
    root.currentTab = tabs[nextIdx]
    searchField.text = ""
    root.searchQuery = ""
    root.selectedIndex = 0
  }

  // Bar button
  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.icon
    slotSize: Style.bar.statusSlot
    tooltipText: "Navigation Guide · " + (root.navigatorRank ? root.navigatorRank.title : "Guide")
    onPressed: root.toggle()
  }

  // Flyout Panel
  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: searchField

    contentWidth: panel.fittedContentWidth(Style.space(560))
    contentHeight: panel.fittedContentHeight(Style.space(660), 760)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: searchField.activeFocus
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.cycleTab(direction) }
      onMoveRequested: function(dx, dy) {
        if (dy > 0) root.selectNext()
        else if (dy < 0) root.selectPrevious()
      }
      onActivateRequested: root.executeSelected()

      ColumnLayout {
        anchors.fill: parent
        spacing: Style.space(8)

        // 1. Sleek Top Header Row
        RowLayout {
          Layout.fillWidth: true
          spacing: Style.space(8)

          Text {
            text: "󰞋 Navigation Guide"
            font.family: Style.font.family
            font.pixelSize: Style.font.title
            font.bold: true
            color: Color.popups.text
          }

          Item { Layout.fillWidth: true }

          Text {
            text: "Tab to cycle · Esc to close"
            font.family: Style.font.family
            font.pixelSize: Style.font.caption - 1
            color: Util.alpha(Color.popups.text, 0.45)
          }

          Rectangle {
            implicitWidth: escBadge.implicitWidth + Style.space(8)
            implicitHeight: Style.space(18)
            radius: Style.space(3)
            color: Util.alpha(Color.popups.text, 0.08)
            border.color: Util.alpha(Color.popups.text, 0.15)
            border.width: 1

            Text {
              id: escBadge
              anchors.centerIn: parent
              text: "Esc"
              font.family: Style.font.family
              font.pixelSize: Style.font.caption - 2
              font.bold: true
              color: Util.alpha(Color.popups.text, 0.7)
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: root.close()
            }
          }
        }

        // 2. Rank & Daily Progress Banner (Clean, no dojo button)
        Rectangle {
          Layout.fillWidth: true
          implicitHeight: Style.space(36)
          radius: Style.space(6)
          color: Util.alpha(Color.accent, 0.08)
          border.color: Util.alpha(Color.accent, 0.22)
          border.width: 1

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Style.space(10)
            anchors.rightMargin: Style.space(10)
            spacing: Style.space(8)

            Text {
              text: (root.navigatorRank ? root.navigatorRank.icon : "🌱") + " LVL " + (root.navigatorRank ? root.navigatorRank.level : 1) + ": " + (root.navigatorRank ? root.navigatorRank.title : "Novice")
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: true
              color: Color.popups.text
            }

            // Progress bar
            Rectangle {
              Layout.fillWidth: true
              implicitHeight: Style.space(6)
              radius: Style.space(3)
              color: Util.alpha(Color.popups.text, 0.1)

              Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Math.max(Style.space(6), parent.width * (root.navigatorRank ? root.navigatorRank.percent : 0))
                radius: Style.space(3)
                color: Color.accent
                Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
              }
            }

            Text {
              text: (root.navigatorRank ? root.navigatorRank.current : 0) + " / " + (root.navigatorRank ? root.navigatorRank.max : 25) + " XP"
              font.family: Style.font.family
              font.pixelSize: Style.font.caption - 1
              font.bold: true
              color: Color.accent
            }

            Text {
              text: "🔥 " + (root.navigatorRank && root.navigatorRank.streak ? root.navigatorRank.streak : (root.rawStats ? root.rawStats.streak : 1)) + "d streak"
              font.family: Style.font.family
              font.pixelSize: Style.font.caption - 1
              font.bold: true
              color: Color.urgent
            }
          }
        }

        // 3. Segmented Navigation Tabs
        RowLayout {
          Layout.fillWidth: true
          spacing: Style.space(6)

          // Tab 1: Navigation (Primary)
          Rectangle {
            Layout.fillWidth: true
            implicitHeight: Style.space(28)
            radius: Style.space(4)
            color: root.currentTab === "context" && root.searchQuery === ""
              ? Util.alpha(Color.accent, 0.22)
              : (tab1Mouse.containsMouse ? Util.alpha(Color.popups.text, 0.09) : Util.alpha(Color.popups.text, 0.05))
            border.color: root.currentTab === "context" && root.searchQuery === "" ? Util.alpha(Color.accent, 0.5) : "transparent"
            border.width: 1

            Text {
              anchors.centerIn: parent
              text: "🎯 Navigation"
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: root.currentTab === "context"
              color: root.currentTab === "context" && root.searchQuery === "" ? Color.accent : Color.popups.text
            }

            MouseArea {
              id: tab1Mouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.currentTab = "context"
                searchField.text = ""
                root.searchQuery = ""
                root.selectedIndex = 0
                searchField.forceActiveFocus()
              }
            }
          }

          // Tab 2: All Commands Catalog
          Rectangle {
            Layout.fillWidth: true
            implicitHeight: Style.space(28)
            radius: Style.space(4)
            color: root.currentTab === "all" && root.searchQuery === ""
              ? Util.alpha(Color.accent, 0.22)
              : (tab2Mouse.containsMouse ? Util.alpha(Color.popups.text, 0.09) : Util.alpha(Color.popups.text, 0.05))
            border.color: root.currentTab === "all" && root.searchQuery === "" ? Util.alpha(Color.accent, 0.5) : "transparent"
            border.width: 1

            Text {
              anchors.centerIn: parent
              text: "📋 All Commands"
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: root.currentTab === "all"
              color: root.currentTab === "all" && root.searchQuery === "" ? Color.accent : Color.popups.text
            }

            MouseArea {
              id: tab2Mouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.currentTab = "all"
                searchField.text = ""
                root.searchQuery = ""
                root.selectedIndex = 0
                searchField.forceActiveFocus()
              }
            }
          }

          // Tab 3: History & Rank
          Rectangle {
            Layout.fillWidth: true
            implicitHeight: Style.space(28)
            radius: Style.space(4)
            color: root.currentTab === "history" && root.searchQuery === ""
              ? Util.alpha(Color.accent, 0.22)
              : (tab3Mouse.containsMouse ? Util.alpha(Color.popups.text, 0.09) : Util.alpha(Color.popups.text, 0.05))
            border.color: root.currentTab === "history" && root.searchQuery === "" ? Util.alpha(Color.accent, 0.5) : "transparent"
            border.width: 1

            Text {
              anchors.centerIn: parent
              text: "📜 History & Rank"
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: root.currentTab === "history"
              color: root.currentTab === "history" && root.searchQuery === "" ? Color.accent : Color.popups.text
            }

            MouseArea {
              id: tab3Mouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.currentTab = "history"
                searchField.text = ""
                root.searchQuery = ""
                root.selectedIndex = 0
                searchField.forceActiveFocus()
              }
            }
          }

          // Tab 4: Dojo Practice (Isolated here)
          Rectangle {
            Layout.fillWidth: true
            implicitHeight: Style.space(28)
            radius: Style.space(4)
            color: root.currentTab === "dojo" && root.searchQuery === ""
              ? Util.alpha(Color.accent, 0.22)
              : (tab4Mouse.containsMouse ? Util.alpha(Color.popups.text, 0.09) : Util.alpha(Color.popups.text, 0.05))
            border.color: root.currentTab === "dojo" && root.searchQuery === "" ? Util.alpha(Color.accent, 0.5) : "transparent"
            border.width: 1

            Text {
              anchors.centerIn: parent
              text: "🥋 Dojo Practice"
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: root.currentTab === "dojo"
              color: root.currentTab === "dojo" && root.searchQuery === "" ? Color.accent : Color.popups.text
            }

            MouseArea {
              id: tab4Mouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.currentTab = "dojo"
                searchField.text = ""
                root.searchQuery = ""
                root.selectedIndex = 0
                searchField.forceActiveFocus()
              }
            }
          }
        }

        // 4. Instant Search Bar (Auto-Focused)
        TextField {
          id: searchField
          Layout.fillWidth: true
          placeholderText: "Search commands or open windows (e.g. brave, blender, scratchpad, split)..."
          onTextChanged: {
            root.searchQuery = text
            root.selectedIndex = 0
          }

          Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
              if (searchField.text !== "") {
                searchField.text = ""
                root.searchQuery = ""
              } else {
                root.close()
              }
              event.accepted = true
              return
            }

            if (event.key === Qt.Key_Tab) {
              root.cycleTab(1)
              event.accepted = true
              return
            }

            if (event.key === Qt.Key_Backtab) {
              root.cycleTab(-1)
              event.accepted = true
              return
            }

            if (event.key === Qt.Key_Down) {
              root.selectNext()
              event.accepted = true
              return
            }

            if (event.key === Qt.Key_Up) {
              root.selectPrevious()
              event.accepted = true
              return
            }

            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              root.executeSelected()
              event.accepted = true
              return
            }

            // Quick accelerator 1..9 when search query is empty
            if (searchField.text === "" && (event.modifiers & (Qt.ControlModifier | Qt.AltModifier))) {
              var digit = event.key - Qt.Key_1 + 1
              if (digit >= 1 && digit <= 9 && digit <= root.smartNav.openTasks.length) {
                var target = root.smartNav.openTasks[digit - 1]
                root.executeAction(target.action, target.key, target.title, target.icon, target.badge)
                event.accepted = true
                return
              }
            }
          }
        }

        // 5. Scrollable Body
        Flickable {
          id: flick
          Layout.fillWidth: true
          Layout.fillHeight: true
          contentWidth: width
          contentHeight: scrollColumn.implicitHeight
          clip: true
          boundsBehavior: Flickable.StopAtBounds
          flickableDirection: Flickable.VerticalFlick
          interactive: contentHeight > height
          ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

          Column {
            id: scrollColumn
            width: flick.width
            spacing: Style.space(8)

            // -----------------------------------------------------------
            // VIEW A: UNIVERSAL SEARCH RESULTS (OPEN WINDOWS + COMMANDS)
            // -----------------------------------------------------------
            Column {
              visible: root.searchQuery !== ""
              width: parent.width
              spacing: Style.space(4)

              PanelSectionHeader {
                text: "MATCHING RESULTS (" + root.searchResults.length + ") · ENTER TO EXECUTE TOP RESULT"
              }

              Repeater {
                model: root.searchResults
                delegate: SuggestionCard {
                  width: parent.width
                  title: modelData.title || modelData.desc
                  desc: modelData.desc
                  keyString: modelData.key
                  icon: modelData.icon
                  action: modelData.action
                  badgeText: modelData.badge || modelData.category
                  usageCount: root.getCountForKey(modelData.key)
                  selected: root.selectedIndex === index
                  onTriggered: function(cmd) { root.executeAction(cmd, modelData.key, modelData.title || modelData.desc, modelData.icon, modelData.badge || modelData.category) }
                }
              }

              Item {
                visible: root.searchResults.length === 0
                width: parent.width
                height: Style.space(40)

                Text {
                  anchors.centerIn: parent
                  text: "No open windows or commands match \"" + root.searchQuery + "\""
                  font.family: Style.font.family
                  font.pixelSize: Style.font.body
                  color: Util.alpha(Color.popups.text, 0.5)
                }
              }
            }

            // -----------------------------------------------------------
            // VIEW B: NAVIGATION & REAL WINDOWS (PAGE 1 - CLEAN, NO DOJO)
            // -----------------------------------------------------------
            Column {
              visible: root.searchQuery === "" && root.currentTab === "context"
              width: parent.width
              spacing: Style.space(6)

              // Active Window Context Banner
              Rectangle {
                width: parent.width
                implicitHeight: activeWinRow.implicitHeight + Style.space(12)
                radius: Style.space(5)
                color: Util.alpha(Color.accent, 0.08)
                border.color: Util.alpha(Color.accent, 0.22)
                border.width: 1

                RowLayout {
                  id: activeWinRow
                  anchors.fill: parent
                  anchors.leftMargin: Style.space(10)
                  anchors.rightMargin: Style.space(10)
                  spacing: Style.space(8)

                  Text {
                    text: root.activeApp.icon
                    font.family: Style.font.family
                    font.pixelSize: Style.font.title
                    color: Color.accent
                  }

                  ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Style.space(1)

                    RowLayout {
                      spacing: Style.space(6)
                      Text {
                        text: "Currently focused: " + root.activeApp.label
                        font.family: Style.font.family
                        font.pixelSize: Style.font.body
                        font.bold: true
                        color: Color.popups.text
                      }
                      Rectangle {
                        implicitWidth: wsBadgeText.implicitWidth + Style.space(8)
                        implicitHeight: Style.space(15)
                        radius: Style.space(3)
                        color: Util.alpha(Color.accent, 0.2)
                        Text {
                          id: wsBadgeText
                          anchors.centerIn: parent
                          text: "Workspace " + ((root.rawActive && root.rawActive.workspace) ? root.rawActive.workspace.name : "1")
                          font.family: Style.font.family
                          font.pixelSize: Style.font.caption - 2
                          font.bold: true
                          color: Color.accent
                        }
                      }
                    }

                    Text {
                      text: (root.rawActive && root.rawActive.title) ? root.rawActive.title : "Active window"
                      font.family: Style.font.family
                      font.pixelSize: Style.font.caption - 1
                      color: Util.alpha(Color.popups.text, 0.65)
                      elide: Text.ElideRight
                      Layout.fillWidth: true
                    }
                  }
                }
              }

              // 1. Switch to Open Windows & Tabs (Highest Priority)
              Column {
                visible: root.smartNav.openTasks.length > 0
                width: parent.width
                spacing: Style.space(4)

                PanelSectionHeader {
                  text: "SWITCH TO OPEN APPS (" + root.smartNav.openTasks.length + ") · CLICK OR HIT ACCELERATOR"
                }

                Repeater {
                  model: root.smartNav.openTasks
                  delegate: SuggestionCard {
                    width: parent.width
                    title: modelData.title
                    desc: modelData.desc
                    keyString: modelData.key
                    icon: modelData.icon
                    action: modelData.action
                    badgeText: modelData.badge
                    acceleratorIndex: index + 1
                    selected: root.selectedIndex === index
                    usageCount: root.getCountForKey(modelData.key)
                    onTriggered: function(cmd) { root.executeAction(cmd, modelData.key, modelData.title, modelData.icon, modelData.badge) }
                  }
                }

                Item { width: 1; height: Style.space(2) }
                PanelSeparator { width: parent.width }
                Item { width: 1; height: Style.space(2) }
              }

              // 2. Window Tiling & Layout Controls
              Column {
                visible: root.smartNav.currentWindow.length > 0
                width: parent.width
                spacing: Style.space(4)

                PanelSectionHeader {
                  text: "ACTIVE WINDOW CONTROLS & TILING"
                }

                Repeater {
                  model: root.smartNav.currentWindow
                  delegate: SuggestionCard {
                    width: parent.width
                    title: modelData.title
                    desc: modelData.desc
                    keyString: modelData.key
                    icon: modelData.icon
                    action: modelData.action
                    badgeText: modelData.badge
                    selected: root.selectedIndex === (root.smartNav.openTasks.length + index)
                    usageCount: root.getCountForKey(modelData.key)
                    onTriggered: function(cmd) { root.executeAction(cmd, modelData.key, modelData.title, modelData.icon, modelData.badge) }
                  }
                }

                Item { width: 1; height: Style.space(2) }
                PanelSeparator { width: parent.width }
                Item { width: 1; height: Style.space(2) }
              }

              // 3. Essential Navigation Tools
              Column {
                width: parent.width
                spacing: Style.space(4)

                PanelSectionHeader {
                  text: "ESSENTIAL SYSTEM TOOLS"
                }

                Repeater {
                  model: root.smartNav.essentialTools
                  delegate: SuggestionCard {
                    width: parent.width
                    title: modelData.title
                    desc: modelData.desc
                    keyString: modelData.key
                    icon: modelData.icon
                    action: modelData.action
                    badgeText: modelData.badge
                    selected: root.selectedIndex === (root.smartNav.openTasks.length + root.smartNav.currentWindow.length + index)
                    usageCount: root.getCountForKey(modelData.key)
                    onTriggered: function(cmd) { root.executeAction(cmd, modelData.key, modelData.title, modelData.icon, modelData.badge) }
                  }
                }
              }
            }

            // -----------------------------------------------------------
            // VIEW C: ALL COMMANDS (BROWSE CATALOG)
            // -----------------------------------------------------------
            Column {
              visible: root.searchQuery === "" && root.currentTab === "all"
              width: parent.width
              spacing: Style.space(4)

              PanelSectionHeader {
                text: "ALL OMARCHY KEYBINDINGS (" + TipCatalog.allShortcuts.length + ")"
              }

              Repeater {
                model: TipCatalog.allShortcuts
                delegate: SuggestionCard {
                  width: parent.width
                  title: modelData.desc
                  desc: "Category: " + modelData.category.toUpperCase()
                  keyString: modelData.key
                  icon: modelData.icon
                  action: modelData.action
                  badgeText: modelData.category
                  selected: root.selectedIndex === index
                  usageCount: root.getCountForKey(modelData.key)
                  onTriggered: function(cmd) { root.executeAction(cmd, modelData.key, modelData.desc, modelData.icon, modelData.category) }
                }
              }
            }

            // -----------------------------------------------------------
            // VIEW D: HISTORY & LEADERBOARD (RANKING)
            // -----------------------------------------------------------
            Column {
              visible: root.searchQuery === "" && root.currentTab === "history"
              width: parent.width
              spacing: Style.space(8)

              // Navigator Level & Mastery Card
              MasteryCard {
                width: parent.width
                rank: root.navigatorRank
                totalActions: root.rawStats ? (root.rawStats.totalActions || 0) : 0
                streak: root.rawStats ? (root.rawStats.streak || 1) : 1
              }

              // Leaderboard: Most Used Shortcuts (Podium)
              PanelSectionHeader {
                text: "LEADERBOARD (MOST USED SHORTCUTS)"
              }

              Repeater {
                model: root.leaderboardList
                delegate: SuggestionCard {
                  width: parent.width
                  title: (index === 0 ? "🥇 " : (index === 1 ? "🥈 " : (index === 2 ? "🥉 " : (index + 1) + ". "))) + modelData.desc
                  desc: (modelData.tier ? modelData.tier.tag : (modelData.count + "x")) + " · Category: " + modelData.category.toUpperCase()
                  keyString: modelData.key
                  icon: modelData.icon
                  action: modelData.action
                  badgeText: modelData.tier ? modelData.tier.label : "Used"
                  selected: root.selectedIndex === index
                  usageCount: modelData.count
                  onTriggered: function(cmd) { root.executeAction(cmd, modelData.key, modelData.desc, modelData.icon, modelData.category) }
                }
              }

              Item {
                visible: root.leaderboardList.length === 0
                width: parent.width
                height: Style.space(36)

                Text {
                  anchors.centerIn: parent
                  text: "No shortcuts logged yet! Press shortcuts or click suggestions to start ranking."
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  color: Util.alpha(Color.popups.text, 0.5)
                }
              }

              PanelSeparator { width: parent.width }

              // Chronological History Stream
              PanelSectionHeader {
                text: "RECENT SHORTCUT EXECUTION HISTORY (" + root.recentHistory.length + ")"
              }

              Repeater {
                model: root.recentHistory.slice(0, 15)
                delegate: HistoryRow {
                  width: parent.width
                  title: modelData.desc || modelData.key
                  keyString: modelData.key
                  icon: modelData.icon || "󰌌"
                  category: modelData.category || "general"
                  timestamp: modelData.timestamp || 0
                  onTriggered: function(cmd) { root.executeAction(cmd, modelData.key, modelData.desc, modelData.icon, modelData.category) }
                }
              }

              Item {
                visible: root.recentHistory.length === 0
                width: parent.width
                height: Style.space(36)

                Text {
                  anchors.centerIn: parent
                  text: "No recent executions recorded yet."
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  color: Util.alpha(Color.popups.text, 0.5)
                }
              }
            }

            // -----------------------------------------------------------
            // VIEW E: DOJO PRACTICE MODE (TRAINER - ISOLATED IN TAB 4)
            // -----------------------------------------------------------
            Column {
              visible: root.searchQuery === "" && root.currentTab === "dojo"
              width: parent.width
              spacing: Style.space(8)

              DojoCard {
                width: parent.width
                onExecuted: function(key, desc, icon, category, cmd) {
                  root.executeAction(cmd, key, desc, icon, category)
                }
              }

              PanelSeparator { width: parent.width }

              PanelSectionHeader {
                text: "RECOMMENDED TO PRACTICE (UNDERUSED SHORTCUTS)"
              }

              Repeater {
                model: root.discoverList
                delegate: SuggestionCard {
                  width: parent.width
                  title: modelData.desc
                  desc: modelData.count === 0 ? "Untried · Expand your keyboard mastery" : ("Used only " + modelData.count + " times")
                  keyString: modelData.key
                  icon: modelData.icon
                  action: modelData.action
                  badgeText: modelData.count === 0 ? "Untried" : "Practice"
                  selected: root.selectedIndex === index
                  usageCount: modelData.count
                  onTriggered: function(cmd) { root.executeAction(cmd, modelData.key, modelData.desc, modelData.icon, modelData.category) }
                }
              }
            }
          }
        }
      }
    }
  }
}
