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

  property string currentTab: "context" // "context" | "all"
  property string searchQuery: ""

  // Refresh active window and all client windows
  function refreshState() {
    if (!stateProc.running) {
      stateProc.running = true
    }
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

  // Update whenever Wayland toplevel changes or panel opens
  onToplevelChanged: Qt.callLater(refreshState)
  onOpenedChanged: {
    if (opened) {
      refreshState()
      searchField.text = ""
      root.searchQuery = ""
    }
  }

  Timer {
    interval: 2500
    running: true
    repeat: true
    onTriggered: root.refreshState()
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
  // Dismisses popup panel first, then executes command after 50ms so compositor
  // restores focus to client window and dispatchers execute without layer-shell interception.
  function executeAction(cmd) {
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
          Quickshell.execDetached("bash", ["-c", pendingCmd])
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
    tooltipText: "Navigation Guide (" + root.activeApp.label + ")"
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

    contentWidth: panel.fittedContentWidth(Style.space(480))
    contentHeight: panel.fittedContentHeight(Style.space(560), 640)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: searchField.activeFocus
      onCloseRequested: root.close()
      onTextKey: function(t) {
        if (t === "/") searchField.forceActiveFocus()
      }

      ColumnLayout {
        anchors.fill: parent
        spacing: Style.space(8)

        // Header with title & segmented tab buttons
        RowLayout {
          Layout.fillWidth: true
          spacing: Style.space(8)

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
            Layout.leftMargin: Style.space(8)

            // Context Tab
            Rectangle {
              implicitWidth: contextTabLabel.implicitWidth + Style.space(12)
              implicitHeight: Style.space(22)
              radius: Style.space(4)
              color: root.currentTab === "context" && root.searchQuery === ""
                ? Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.22)
                : Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.08)

              Text {
                id: contextTabLabel
                anchors.centerIn: parent
                text: "🎯 Context Guide"
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: root.currentTab === "context"
                color: root.currentTab === "context" && root.searchQuery === "" ? Color.accent : Color.foreground
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

            // All Keybinds Tab
            Rectangle {
              implicitWidth: allTabLabel.implicitWidth + Style.space(12)
              implicitHeight: Style.space(22)
              radius: Style.space(4)
              color: root.currentTab === "all" && root.searchQuery === ""
                ? Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.22)
                : Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.08)

              Text {
                id: allTabLabel
                anchors.centerIn: parent
                text: "📋 All Keybinds"
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: root.currentTab === "all"
                color: root.currentTab === "all" && root.searchQuery === "" ? Color.accent : Color.foreground
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
          }

          Item { Layout.fillWidth: true }

          // Keyboard hint
          Text {
            text: "Press / to search"
            font.family: Style.font.family
            font.pixelSize: Style.font.caption - 1
            color: Qt.darker(Color.popups.text, 1.6)
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
        }

        // Active Window Status Banner
        ContextHeader {
          Layout.fillWidth: true
          categoryLabel: root.activeApp.label
          categoryIcon: root.activeApp.icon
          windowTitle: root.rawActive.title || (root.toplevel ? root.toplevel.title : "No active window")
          workspaceName: (root.rawActive.workspace && root.rawActive.workspace.name) ? String(root.rawActive.workspace.name) : "1"
          isFloating: root.rawActive.floating === true
          isFullscreen: root.rawActive.fullscreen !== undefined && root.rawActive.fullscreen !== 0
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
                text: "MATCHING SHORTCUTS (" + root.searchResults.length + ")"
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
                  onTriggered: function(cmd) { root.executeAction(cmd) }
                }
              }

              Text {
                visible: root.searchResults.length === 0
                width: parent.width
                text: "No shortcuts match \"" + root.searchQuery + "\""
                font.family: Style.font.family
                font.pixelSize: Style.font.body
                color: Qt.darker(Color.popups.text, 1.5)
                horizontalAlignment: Text.AlignHCenter
                topPadding: Style.space(16)
              }
            }

            // -----------------------------------------------------------
            // VIEW B: SMART CONTEXT GUIDE (DEFAULT)
            // -----------------------------------------------------------
            Column {
              visible: root.searchQuery === "" && root.currentTab === "context"
              width: parent.width
              spacing: Style.space(6)

              // 1. Switch to Open Windows (Top Priority)
              Column {
                visible: root.smartNav.openTasks.length > 0
                width: parent.width
                spacing: Style.space(4)

                PanelSectionHeader {
                  text: "SWITCH TO RUNNING APPS (" + root.smartNav.openTasks.length + ")"
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
                    onTriggered: function(cmd) { root.executeAction(cmd) }
                  }
                }

                PanelSeparator {
                  width: parent.width
                  topPadding: Style.space(2)
                  bottomPadding: Style.space(2)
                }
              }

              // 2. In-App Navigation / Tabs (if in browser, editor, terminal)
              Column {
                visible: root.smartNav.inAppTabs.length > 0
                width: parent.width
                spacing: Style.space(4)

                PanelSectionHeader {
                  text: root.activeApp.label.toUpperCase() + " TAB & IN-APP SHORTCUTS"
                }

                Repeater {
                  model: root.smartNav.inAppTabs
                  delegate: SuggestionCard {
                    width: parent.width
                    title: modelData.title
                    desc: modelData.desc
                    keyString: modelData.key
                    icon: modelData.icon
                    action: modelData.action
                    badgeText: modelData.badge
                    onTriggered: function(cmd) { root.executeAction(cmd) }
                  }
                }

                PanelSeparator {
                  width: parent.width
                  topPadding: Style.space(2)
                  bottomPadding: Style.space(2)
                }
              }

              // 3. Current Window Controls
              Column {
                visible: root.smartNav.currentWindow.length > 0
                width: parent.width
                spacing: Style.space(4)

                PanelSectionHeader {
                  text: "CURRENT WINDOW CONTROLS"
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
                    onTriggered: function(cmd) { root.executeAction(cmd) }
                  }
                }

                PanelSeparator {
                  width: parent.width
                  topPadding: Style.space(2)
                  bottomPadding: Style.space(2)
                }
              }

              // 4. Quick Launch / Workspaces
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
                    onTriggered: function(cmd) { root.executeAction(cmd) }
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
                  onTriggered: function(cmd) { root.executeAction(cmd) }
                }
              }
            }
          }
        }
      }
    }
  }
}
