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

  // Background Hyprland socket listener for live physical keypress logging
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
    onTriggered: {
      if (!statsProc.running) statsProc.running = true
    }
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

    contentWidth: panel.fittedContentWidth(Style.space(540))
    contentHeight: panel.fittedContentHeight(Style.space(660), 740)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: searchField.activeFocus
      onCloseRequested: root.close()

      onTabRequested: function(direction) {
        var tabs = ["context", "dojo", "history", "all"]
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

        // 1. Title Row with Keyboard Navigation Hints
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
            text: "Tab to cycle · / to search"
            font.family: Style.font.family
            font.pixelSize: Style.font.caption - 1
            color: Util.alpha(Color.popups.text, 0.5)
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

        // 2. Hero Rank, XP Progress & Daily Streak Banner (Always Visible)
        Rectangle {
          Layout.fillWidth: true
          implicitHeight: Style.space(38)
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
              text: "🔥 " + (root.navigatorRank && root.navigatorRank.streak ? root.navigatorRank.streak : (root.rawStats ? root.rawStats.streak : 1)) + "d"
              font.family: Style.font.family
              font.pixelSize: Style.font.caption - 1
              font.bold: true
              color: Color.urgent
            }

            // Dojo Quick Jump Button
            Rectangle {
              implicitWidth: dojoHeroBtn.implicitWidth + Style.space(10)
              implicitHeight: Style.space(22)
              radius: Style.space(4)
              color: root.currentTab === "dojo" ? Util.alpha(Color.accent, 0.3) : Util.alpha(Color.accent, 0.18)
              border.color: Util.alpha(Color.accent, 0.45)
              border.width: 1

              Text {
                id: dojoHeroBtn
                anchors.centerIn: parent
                text: "🥋 Dojo ❯"
                font.family: Style.font.family
                font.pixelSize: Style.font.caption - 1
                font.bold: true
                color: Color.accent
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
        }

        // 3. Full-Width Segmented Tab Navigation Bar
        RowLayout {
          Layout.fillWidth: true
          spacing: Style.space(6)

          // 1. Windows Tab
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
              text: "🎯 Windows"
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
              }
            }
          }

          // 2. Dojo Practice Tab (Prominently placed as tab 2)
          Rectangle {
            Layout.fillWidth: true
            implicitHeight: Style.space(28)
            radius: Style.space(4)
            color: root.currentTab === "dojo" && root.searchQuery === ""
              ? Util.alpha(Color.accent, 0.22)
              : (tab2Mouse.containsMouse ? Util.alpha(Color.popups.text, 0.09) : Util.alpha(Color.popups.text, 0.05))
            border.color: root.currentTab === "dojo" && root.searchQuery === "" ? Util.alpha(Color.accent, 0.5) : "transparent"
            border.width: 1

            Text {
              anchors.centerIn: parent
              text: "🥋 Practice Dojo"
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: root.currentTab === "dojo"
              color: root.currentTab === "dojo" && root.searchQuery === "" ? Color.accent : Color.popups.text
            }

            MouseArea {
              id: tab2Mouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.currentTab = "dojo"
                searchField.text = ""
                root.searchQuery = ""
              }
            }
          }

          // 3. History & Rank Tab
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
              }
            }
          }

          // 4. All Keybinds Tab
          Rectangle {
            Layout.fillWidth: true
            implicitHeight: Style.space(28)
            radius: Style.space(4)
            color: root.currentTab === "all" && root.searchQuery === ""
              ? Util.alpha(Color.accent, 0.22)
              : (tab4Mouse.containsMouse ? Util.alpha(Color.popups.text, 0.09) : Util.alpha(Color.popups.text, 0.05))
            border.color: root.currentTab === "all" && root.searchQuery === "" ? Util.alpha(Color.accent, 0.5) : "transparent"
            border.width: 1

            Text {
              anchors.centerIn: parent
              text: "📋 All Keys"
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: root.currentTab === "all"
              color: root.currentTab === "all" && root.searchQuery === "" ? Color.accent : Color.popups.text
            }

            MouseArea {
              id: tab4Mouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.currentTab = "all"
                searchField.text = ""
                root.searchQuery = ""
              }
            }
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

              Item { width: 1; height: Style.space(2) }
              PanelSeparator { width: parent.width }
              Item { width: 1; height: Style.space(2) }

              // Front-Page Dojo Spotlight Card
              Rectangle {
                width: parent.width
                implicitHeight: dojoSpotCol.implicitHeight + Style.space(20)
                radius: Style.space(6)
                color: Util.alpha(Color.accent, 0.08)
                border.color: Util.alpha(Color.accent, 0.25)
                border.width: 1

                ColumnLayout {
                  id: dojoSpotCol
                  anchors.fill: parent
                  anchors.margins: Style.space(12)
                  spacing: Style.space(6)

                  RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.space(6)

                    Text {
                      text: "🥋 MUSCLE MEMORY DOJO"
                      font.family: Style.font.family
                      font.pixelSize: Style.font.caption - 1
                      font.bold: true
                      color: Color.accent
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                      implicitWidth: spotXp.implicitWidth + Style.space(8)
                      implicitHeight: Style.space(18)
                      radius: Style.space(3)
                      color: Util.alpha(Color.accent, 0.2)

                      Text {
                        id: spotXp
                        anchors.centerIn: parent
                        text: "+25 XP / Drill"
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption - 2
                        font.bold: true
                        color: Color.accent
                      }
                    }
                  }

                  Text {
                    text: "Train your muscle memory for window management & tiling! Complete quick interactive drills under pressure, build your combo multiplier, and level up your Navigator Rank."
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    color: Util.alpha(Color.popups.text, 0.8)
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                  }

                  RowLayout {
                    Layout.fillWidth: true

                    Item { Layout.fillWidth: true }

                    Rectangle {
                      implicitWidth: enterDojoLabel.implicitWidth + Style.space(16)
                      implicitHeight: Style.space(26)
                      radius: Style.space(4)
                      color: Util.alpha(Color.accent, 0.22)
                      border.color: Util.alpha(Color.accent, 0.5)
                      border.width: 1

                      Text {
                        id: enterDojoLabel
                        anchors.centerIn: parent
                        text: "Enter Shortcut Dojo ❯"
                        font.family: Style.font.family
                        font.pixelSize: Style.font.caption
                        font.bold: true
                        color: Color.accent
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

              // Explanatory Intro Card
              Rectangle {
                width: parent.width
                implicitHeight: dojoGuideCol.implicitHeight + Style.space(18)
                radius: Style.space(6)
                color: Util.alpha(Color.accent, 0.08)
                border.color: Util.alpha(Color.accent, 0.22)
                border.width: 1

                ColumnLayout {
                  id: dojoGuideCol
                  anchors.fill: parent
                  anchors.margins: Style.space(12)
                  spacing: Style.space(4)

                  RowLayout {
                    spacing: Style.space(6)
                    Text {
                      text: "🥋 What is the Shortcut Dojo?"
                      font.family: Style.font.family
                      font.pixelSize: Style.font.caption
                      font.bold: true
                      color: Color.accent
                    }
                  }

                  Text {
                    text: "The Dojo is your interactive reflex trainer for Hyprland shortcuts. Follow the drill prompt below, then hit the shortcut physically on your keyboard OR click '⚡ Practice Now'. Every drill completed grants +XP to level up your Navigator Rank and builds your streak combo!"
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption - 1
                    color: Util.alpha(Color.popups.text, 0.8)
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                  }
                }
              }

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
