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

  // Current detected category and label
  readonly property var categoryInfo: NavModel.detectCategory(
    root.rawActive.class || (toplevel ? toplevel.appId : ""),
    root.rawActive.title || (toplevel ? toplevel.title : "")
  )

  // Smart contextual suggestions based on where you are AND all open windows
  readonly property var smartSuggestions: NavModel.buildSmartSuggestions(
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
  // Dismisses popup panel first, then triggers action after 60ms so compositor
  // returns focus to client windows and Hyprland dispatchers execute smoothly.
  function executeAction(cmd) {
    if (!cmd) return
    root.close()
    actionTimer.pendingCmd = cmd
    actionTimer.restart()
  }

  Timer {
    id: actionTimer
    interval: 60
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
    tooltipText: "Navigation Guide · " + root.categoryInfo.label
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
    contentHeight: panel.fittedContentHeight(Style.space(580), 660)

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
        spacing: Style.space(10)

        // Title and search row
        RowLayout {
          Layout.fillWidth: true
          spacing: Style.space(8)

          Text {
            text: "󰞋 Navigation Guide"
            font.family: Style.font.family
            font.pixelSize: Style.font.headline
            font.bold: true
            color: Color.popups.text
          }

          Item { Layout.fillWidth: true }

          // Quick Hint
          Text {
            text: "Press / to search · Esc to close"
            font.family: Style.font.family
            font.pixelSize: Style.font.caption - 1
            color: Qt.darker(Color.popups.text, 1.6)
          }
        }

        // Search Field
        TextField {
          id: searchField
          Layout.fillWidth: true
          placeholderText: "Search shortcuts (e.g. split, brave, terminal, workspace)..."
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

        // Active Window Context Banner
        ContextHeader {
          Layout.fillWidth: true
          categoryLabel: root.categoryInfo.label
          categoryIcon: root.categoryInfo.icon
          windowTitle: root.rawActive.title || (root.toplevel ? root.toplevel.title : "No window focused")
          workspaceName: (root.rawActive.workspace && root.rawActive.workspace.name) ? String(root.rawActive.workspace.name) : "1"
          isFloating: root.rawActive.floating === true
          isFullscreen: root.rawActive.fullscreen !== undefined && root.rawActive.fullscreen !== 0
        }

        // Scrollable Suggestions Body
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

            // When searching
            Column {
              visible: root.searchQuery !== ""
              width: parent.width
              spacing: Style.space(6)

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
                topPadding: Style.space(20)
              }
            }

            // Normal smart context view (not searching)
            Column {
              visible: root.searchQuery === ""
              width: parent.width
              spacing: Style.space(8)

              // Interactive Tip Banner
              TipBanner {
                width: parent.width
              }

              PanelSeparator {
                width: parent.width
              }

              PanelSectionHeader {
                text: "CONTEXTUAL SUGGESTIONS (" + (root.rawClients.length) + " WINDOW" + (root.rawClients.length === 1 ? "" : "S") + " OPEN)"
              }

              Repeater {
                model: root.smartSuggestions
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
              }

              PanelSectionHeader {
                text: "GLOBAL WORKSPACES & SHORTCUTS"
              }

              SuggestionCard {
                width: parent.width
                title: "Switch to Workspace 1"
                desc: "Hop to virtual workspace 1"
                keyString: "SUPER + 1"
                icon: "󰄲"
                badgeText: "WS 1"
                action: "hyprctl dispatch 'hl.dsp.focus({ workspace = \"1\" })'"
                onTriggered: function(cmd) { root.executeAction(cmd) }
              }

              SuggestionCard {
                width: parent.width
                title: "Switch to Workspace 2"
                desc: "Hop to virtual workspace 2"
                keyString: "SUPER + 2"
                icon: "󰄲"
                badgeText: "WS 2"
                action: "hyprctl dispatch 'hl.dsp.focus({ workspace = \"2\" })'"
                onTriggered: function(cmd) { root.executeAction(cmd) }
              }

              SuggestionCard {
                width: parent.width
                title: "Open Omarchy Menu"
                desc: "Search applications, power options, and tools"
                keyString: "SUPER + SPACE"
                icon: "󰍜"
                badgeText: "Menu"
                action: "omarchy-menu toggle"
                onTriggered: function(cmd) { root.executeAction(cmd) }
              }

              SuggestionCard {
                width: parent.width
                title: "Full Keybindings Explorer"
                desc: "Interactive searchable list of all active keybinds"
                keyString: "SUPER + K"
                icon: "󰌌"
                badgeText: "All Keys"
                action: "omarchy-menu-keybindings"
                onTriggered: function(cmd) { root.executeAction(cmd) }
              }
            }
          }
        }
      }
    }
  }
}
