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

  // Refresh active window, all clients, and stats
  function refreshAll() {
    if (!stateProc.running) stateProc.running = true
    if (!statsProc.running) statsProc.running = true
  }

  Process {
    id: stateProc
    command: [root.pluginDir + "/bin/window-state"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: function(text) {
        try {
          var res = JSON.parse(text)
          root.rawActive = (res && res.active) ? res.active : {}
          root.rawClients = (res && Array.isArray(res.clients)) ? res.clients : []
        } catch (e) {
          root.rawActive = {}
          root.rawClients = []
        }
      }
    }
  }

  Process {
    id: statsProc
    command: [root.pluginDir + "/bin/stats-manager", "get"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: function(text) {
        try {
          var res = JSON.parse(text)
          root.rawStats = res || { totalActions: 0, streak: 1, history: [], stats: {} }
        } catch (e) {}
      }
    }
  }

  Process {
    id: recordProc
    property string pendingKey: ""
    property string pendingDesc: ""
    property string pendingIcon: ""
    property string pendingCategory: ""
    command: [root.pluginDir + "/bin/stats-manager", "record", pendingKey, pendingDesc, pendingIcon, pendingCategory]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: function(text) {
        try {
          var res = JSON.parse(text)
          root.rawStats = res || root.rawStats
        } catch (e) {}
      }
    }
  }

  function recordAction(key, desc, icon, category) {
    if (!key) return
    recordProc.pendingKey = key
    recordProc.pendingDesc = desc || ""
    recordProc.pendingIcon = icon || ""
    recordProc.pendingCategory = category || ""
    recordProc.running = true
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

  // Update whenever Wayland toplevel changes or panel opens
  onToplevelChanged: Qt.callLater(refreshAll)
  onOpenedChanged: {
    if (opened) {
      refreshAll()
      searchField.text = ""
      root.searchQuery = ""
      root.selectedIndex = 0
    }
  }

  Timer {
    interval: 2500
    running: true
    repeat: true
    onTriggered: root.refreshAll()
  }

  // App info for active window
  readonly property var activeApp: NavModel.detectAppInfo(
    root.rawActive.class || (toplevel ? toplevel.appId : ""),
    root.rawActive.title || (toplevel ? toplevel.title : "")
  )

  // Smart segmented navigation model
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

  // Filtered search list across all shortcuts
  function filterShortcuts(query) {
    if (!query) return []
    var q = query.toLowerCase().trim()
    var out = []
    var all = TipCatalog.allShortcuts
    for (var i = 0; i < all.length; i++) {
      var item = all[i]
      if (item.desc.toLowerCase().indexOf(q) !== -1 ||
          item.key.toLowerCase().indexOf(q) !== -1 ||
          item.category.toLowerCase().indexOf(q) !== -1) {
        out.push(item)
      }
    }
    return out
  }

  readonly property var searchResults: filterShortcuts(root.searchQuery)

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
    focusTarget: keyCatcher

    contentWidth: panel.fittedContentWidth(Style.space(520))
    contentHeight: panel.fittedContentHeight(Style.space(620), 700)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: searchField.activeFocus
      onCloseRequested: root.close()

      onTabRequested: function(direction) {
        var tabs = ["context", "all", "history", "dojo"]
        var curIdx = tabs.indexOf(root.currentTab)
        if (curIdx === -1) curIdx = 0
        var nextIdx = (curIdx + direction + tabs.length) % tabs.length
        root.currentTab = tabs[nextIdx]
        searchField.text = ""
        root.searchQuery = ""
        root.selectedIndex = 0
      }

      onMoveRequested: function(dx, dy) {
        if (dy > 0) root.selectedIndex += 1
        else if (dy < 0 && root.selectedIndex > 0) root.selectedIndex -= 1
      }

      onActivateRequested: {
        if (root.currentTab === "context") {
          var items = root.smartNav.openTasks.concat(root.smartNav.currentWindow).concat(root.smartNav.quickLaunch)
          if (root.selectedIndex >= 0 && root.selectedIndex < items.length) {
            var selected = items[root.selectedIndex]
            root.executeAction(selected.action, selected.key, selected.title, selected.icon, selected.badge)
          }
        }
      }

      onTextKey: function(t) {
        if (t === "/") {
          searchField.forceActiveFocus()
          return
        }

        // Accelerator numeric keys 1..9 trigger items instantly
        var num = parseInt(t)
        if (!isNaN(num) && num >= 1 && num <= 9 && root.currentTab === "context" && root.searchQuery === "") {
          var targetIndex = num - 1
          if (targetIndex < root.smartNav.openTasks.length) {
            var item = root.smartNav.openTasks[targetIndex]
            root.executeAction(item.action, item.key, item.title, item.icon, item.badge)
          }
        }
      }

      ColumnLayout {
        anchors.fill: parent
        spacing: Style.space(8)

        // Header with title & segmented tab buttons
        RowLayout {
          Layout.fillWidth: true
          spacing: Style.space(6)

          Text {
            text: "󰞋 Navigation"
            font.family: Style.font.family
            font.pixelSize: Style.font.title
            font.bold: true
            color: Color.popups.text
          }

          // Tab Switcher Pills
          Row {
            spacing: Style.space(4)
            Layout.leftMargin: Style.space(4)

            // 1. Windows Tab
            Rectangle {
              implicitWidth: contextTabLabel.implicitWidth + Style.space(10)
              implicitHeight: Style.space(22)
              radius: Style.space(4)
              color: root.currentTab === "context" && root.searchQuery === ""
                ? Util.alpha(Color.accent, 0.22)
                : Util.alpha(Color.popups.text, 0.06)

              Text {
                id: contextTabLabel
                anchors.centerIn: parent
                text: "🎯 Windows"
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: root.currentTab === "context"
                color: root.currentTab === "context" && root.searchQuery === "" ? Color.accent : Color.popups.text
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  root.currentTab = "context"
                  searchField.text = ""
                  root.searchQuery = ""
                }
              }
            }

            // 2. All Keybinds Tab
            Rectangle {
              implicitWidth: allTabLabel.implicitWidth + Style.space(10)
              implicitHeight: Style.space(22)
              radius: Style.space(4)
              color: root.currentTab === "all" && root.searchQuery === ""
                ? Util.alpha(Color.accent, 0.22)
                : Util.alpha(Color.popups.text, 0.06)

              Text {
                id: allTabLabel
                anchors.centerIn: parent
                text: "📋 All Keys"
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: root.currentTab === "all"
                color: root.currentTab === "all" && root.searchQuery === "" ? Color.accent : Color.popups.text
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  root.currentTab = "all"
                  searchField.text = ""
                  root.searchQuery = ""
                }
              }
            }

            // 3. History & Rank Tab
            Rectangle {
              implicitWidth: histTabLabel.implicitWidth + Style.space(10)
              implicitHeight: Style.space(22)
              radius: Style.space(4)
              color: root.currentTab === "history" && root.searchQuery === ""
                ? Util.alpha(Color.accent, 0.22)
                : Util.alpha(Color.popups.text, 0.06)

              Text {
                id: histTabLabel
                anchors.centerIn: parent
                text: "📜 History & Rank"
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: root.currentTab === "history"
                color: root.currentTab === "history" && root.searchQuery === "" ? Color.accent : Color.popups.text
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  root.currentTab = "history"
                  searchField.text = ""
                  root.searchQuery = ""
                }
              }
            }

            // 4. Dojo Practice Tab
            Rectangle {
              implicitWidth: dojoTabLabel.implicitWidth + Style.space(10)
              implicitHeight: Style.space(22)
              radius: Style.space(4)
              color: root.currentTab === "dojo" && root.searchQuery === ""
                ? Util.alpha(Color.accent, 0.22)
                : Util.alpha(Color.popups.text, 0.06)

              Text {
                id: dojoTabLabel
                anchors.centerIn: parent
                text: "🥋 Dojo"
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: root.currentTab === "dojo"
                color: root.currentTab === "dojo" && root.searchQuery === "" ? Color.accent : Color.popups.text
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  root.currentTab = "dojo"
                  searchField.text = ""
                  root.searchQuery = ""
                }
              }
            }
          }

          Item { Layout.fillWidth: true }

          // Keyboard hint
          Text {
            text: "Press / to search"
            font.family: Style.font.family
            font.pixelSize: Style.font.caption - 1
            color: Util.alpha(Color.popups.text, 0.5)
          }
        }

        // Search Field
        TextField {
          id: searchField
          Layout.fillWidth: true
          placeholderText: "Search shortcuts (e.g. terminal, split, workspace, float)..."
          onTextChanged: root.searchQuery = text

          Keys.onEscapePressed: {
            if (text !== "") {
              text = ""
              root.searchQuery = ""
            } else {
              root.close()
            }
          }

          Keys.onReturnPressed: {
            if (root.searchResults.length > 0) {
              var top = root.searchResults[0]
              root.executeAction(top.action, top.key, top.desc, top.icon, top.category)
            }
          }
        }

        // Scrollable Body
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
            spacing: Style.space(6)

            // -----------------------------------------------------------
            // VIEW A: SEARCH RESULTS
            // -----------------------------------------------------------
            Column {
              visible: root.searchQuery !== ""
              width: parent.width
              spacing: Style.space(4)

              PanelSectionHeader {
                text: "MATCHING SHORTCUTS (" + root.searchResults.length + ") · PRESS ENTER TO RUN TOP RESULT"
              }

              Repeater {
                model: root.searchResults
                delegate: SuggestionCard {
                  width: parent.width
                  title: modelData.desc
                  desc: "Category: " + modelData.category.toUpperCase()
                  keyString: modelData.key
                  icon: modelData.icon
                  action: modelData.action
                  badgeText: modelData.category
                  usageCount: root.getCountForKey(modelData.key)
                  selected: index === 0
                  onTriggered: function(cmd) { root.executeAction(cmd, modelData.key, modelData.desc, modelData.icon, modelData.category) }
                }
              }

              Item {
                visible: root.searchResults.length === 0
                width: parent.width
                height: Style.space(40)

                Text {
                  anchors.centerIn: parent
                  text: "No shortcuts match \"" + root.searchQuery + "\""
                  font.family: Style.font.family
                  font.pixelSize: Style.font.body
                  color: Util.alpha(Color.popups.text, 0.5)
                }
              }
            }

            // -----------------------------------------------------------
            // VIEW B: WINDOW NAVIGATION & CONTROLS (DEFAULT)
            // -----------------------------------------------------------
            Column {
              visible: root.searchQuery === "" && root.currentTab === "context"
              width: parent.width
              spacing: Style.space(6)

              // 1. Switch to Open Windows (with 1-9 number accelerators)
              Column {
                visible: root.smartNav.openTasks.length > 0
                width: parent.width
                spacing: Style.space(4)

                PanelSectionHeader {
                  text: "NAVIGATE BETWEEN OPEN WINDOWS (" + root.smartNav.openTasks.length + ") · PRESS [1-9] TO SWITCH"
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
                  text: "WINDOW TILING & LAYOUT"
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

              // 3. Quick Launch & Workspaces
              Column {
                width: parent.width
                spacing: Style.space(4)

                PanelSectionHeader {
                  text: "QUICK LAUNCH & WORKSPACES"
                }

                Repeater {
                  model: root.smartNav.quickLaunch
                  delegate: SuggestionCard {
                    width: parent.width
                    title: modelData.title
                    desc: modelData.desc
                    keyString: modelData.key
                    icon: modelData.icon
                    action: modelData.action
                    badgeText: modelData.badge
                    usageCount: root.getCountForKey(modelData.key)
                    onTriggered: function(cmd) { root.executeAction(cmd, modelData.key, modelData.title, modelData.icon, modelData.badge) }
                  }
                }
              }
            }

            // -----------------------------------------------------------
            // VIEW C: ALL KEYBINDS (BROWSE CATALOG)
            // -----------------------------------------------------------
            Column {
              visible: root.searchQuery === "" && root.currentTab === "all"
              width: parent.width
              spacing: Style.space(4)

              PanelSectionHeader {
                text: "ALL NAVIGATION & WINDOW KEYBINDINGS"
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
            // VIEW E: DOJO PRACTICE MODE (TRAINER)
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
