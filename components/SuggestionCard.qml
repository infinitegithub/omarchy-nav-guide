import QtQuick
import QtQuick.Layouts
import qs.Commons
import "../NavigationModel.js" as NavModel

Rectangle {
  id: root

  property string title: ""
  property string desc: ""
  property string keyString: ""
  property string icon: "󰌌"
  property string badgeText: ""
  property string action: ""
  property int usageCount: 0
  property int acceleratorIndex: -1
  property bool selected: false

  readonly property var mastery: NavModel.getMasteryTier(root.usageCount)

  property color foreground: Color.popups.text
  property color accent: Color.accent
  readonly property bool hovered: mouseArea.containsMouse

  signal triggered(string actionCmd)

  implicitWidth: Style.space(380)
  implicitHeight: Math.max(Style.space(38), row.implicitHeight + Style.space(12))
  radius: Style.space(6)

  color: (root.selected || root.hovered)
    ? Util.alpha(accent, 0.14)
    : Util.alpha(foreground, 0.035)

  border.color: root.selected
    ? Util.alpha(accent, 0.85)
    : (root.hovered ? Util.alpha(accent, 0.5) : Util.alpha(foreground, 0.08))
  border.width: root.selected ? 2 : 1

  Behavior on color {
    ColorAnimation { duration: 120 }
  }
  Behavior on border.color {
    ColorAnimation { duration: 120 }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: root.action ? Qt.PointingHandCursor : Qt.ArrowCursor
    onClicked: {
      if (root.action) {
        root.triggered(root.action)
      }
    }
  }

  RowLayout {
    id: row
    anchors.fill: parent
    anchors.leftMargin: Style.space(10)
    anchors.rightMargin: Style.space(10)
    spacing: Style.space(8)

    // Optional Quick Accelerator Badge (e.g. "[1]")
    Rectangle {
      visible: root.acceleratorIndex > 0 && root.acceleratorIndex <= 9
      implicitWidth: Style.space(18)
      implicitHeight: Style.space(18)
      radius: Style.space(3)
      color: (root.selected || root.hovered)
        ? Util.alpha(root.accent, 0.3)
        : Util.alpha(root.foreground, 0.08)
      border.color: (root.selected || root.hovered)
        ? Util.alpha(root.accent, 0.7)
        : Util.alpha(root.foreground, 0.15)
      border.width: 1

      Text {
        anchors.centerIn: parent
        text: root.acceleratorIndex.toString()
        font.family: Style.font.family
        font.pixelSize: Style.font.caption - 1
        font.bold: true
        color: (root.selected || root.hovered) ? root.accent : Util.alpha(root.foreground, 0.7)
      }
    }

    // Leading Category/App Icon
    Text {
      text: root.icon
      font.family: Style.font.family
      font.pixelSize: Style.font.body + 1
      color: (root.selected || root.hovered) ? root.accent : root.foreground
    }

    // Title & Subtext
    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.space(1)

      RowLayout {
        Layout.fillWidth: true
        spacing: Style.space(6)

        Text {
          text: root.title
          font.family: Style.font.family
          font.pixelSize: Style.font.body
          font.bold: true
          color: root.foreground
          elide: Text.ElideRight
          // ElideRight does nothing until the text has a bounded width.
          // Without fillWidth the full string is the row's minimum width
          // and the key badges are pushed off the card.
          Layout.fillWidth: true
        }

        // Primary badge pill (e.g. "Switch", "Window", "System")
        Rectangle {
          visible: root.badgeText !== ""
          implicitWidth: badgeLabel.implicitWidth + Style.space(8)
          implicitHeight: Style.space(16)
          radius: Style.space(3)
          color: (root.badgeText.indexOf("Switch") !== -1 || root.badgeText.indexOf("WS") !== -1 || root.badgeText === "Focused")
            ? Util.alpha(root.accent, 0.22)
            : Util.alpha(root.foreground, 0.08)

          Text {
            id: badgeLabel
            anchors.centerIn: parent
            text: root.badgeText
            font.family: Style.font.family
            font.pixelSize: Style.font.caption - 1
            font.bold: true
            color: (root.badgeText.indexOf("Switch") !== -1 || root.badgeText.indexOf("WS") !== -1 || root.badgeText === "Focused") ? root.accent : root.foreground
          }
        }

        // Mastery / Usage count pill
        Rectangle {
          implicitWidth: masteryLabel.implicitWidth + Style.space(8)
          implicitHeight: Style.space(16)
          radius: Style.space(3)
          color: root.usageCount > 0
            ? Util.alpha(root.accent, 0.18)
            : Util.alpha(root.foreground, 0.06)

          Text {
            id: masteryLabel
            anchors.centerIn: parent
            text: root.usageCount > 0
              ? (root.mastery ? root.mastery.tag : (root.usageCount + "x"))
              : "0x"
            font.family: Style.font.family
            font.pixelSize: Style.font.caption - 1
            font.bold: root.usageCount > 0
            color: root.usageCount > 0 ? root.accent : Util.alpha(root.foreground, 0.5)
          }
        }
      }

      Text {
        visible: root.desc !== "" && root.desc !== root.title
        text: root.desc
        font.family: Style.font.family
        font.pixelSize: Style.font.caption - 1
        color: Util.alpha(root.foreground, 0.65)
        elide: Text.ElideRight
        Layout.fillWidth: true
      }
    }

    // Key badges
    Row {
      spacing: Style.space(3)
      Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

      Repeater {
        model: NavModel.parseKeys(root.keyString)
        delegate: KeyBadge {
          keyText: modelData
          foreground: root.foreground
          accent: root.accent
          active: root.selected || root.hovered
        }
      }
    }
  }
}
