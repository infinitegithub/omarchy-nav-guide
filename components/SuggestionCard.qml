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

  readonly property var mastery: NavModel.getMasteryTier(root.usageCount)

  property color foreground: Color.popups.text
  property color accent: Color.accent
  property bool hovered: mouseArea.containsMouse

  signal triggered(string actionCmd)

  implicitWidth: parent ? parent.width : Style.space(380)
  implicitHeight: Math.max(Style.space(36), row.implicitHeight + Style.space(12))
  radius: Style.space(6)

  color: hovered
    ? Qt.rgba(accent.r, accent.g, accent.b, 0.12)
    : Qt.rgba(foreground.r, foreground.g, foreground.b, 0.03)

  border.color: hovered
    ? Qt.rgba(accent.r, accent.g, accent.b, 0.45)
    : Qt.rgba(foreground.r, foreground.g, foreground.b, 0.08)
  border.width: 1

  Behavior on color {
    ColorAnimation { duration: 100 }
  }
  Behavior on border.color {
    ColorAnimation { duration: 100 }
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

    // Leading Icon
    Text {
      text: root.icon
      font.family: Style.font.family
      font.pixelSize: Style.font.body
      color: root.hovered ? root.accent : root.foreground
    }

    // Title & Optional Subtext
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 0

      RowLayout {
        spacing: Style.space(6)

        Text {
          text: root.title
          font.family: Style.font.family
          font.pixelSize: Style.font.body
          font.bold: true
          color: root.foreground
          elide: Text.ElideRight
        }

        // Primary badge pill
        Rectangle {
          visible: root.badgeText !== ""
          implicitWidth: badgeLabel.implicitWidth + Style.space(8)
          implicitHeight: Style.space(16)
          radius: Style.space(3)
          color: root.badgeText.indexOf("Switch") !== -1
            ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.22)
            : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.1)

          Text {
            id: badgeLabel
            anchors.centerIn: parent
            text: root.badgeText
            font.family: Style.font.family
            font.pixelSize: Style.font.caption - 1
            font.bold: true
            color: root.badgeText.indexOf("Switch") !== -1 ? root.accent : root.foreground
          }
        }

        // Mastery badge pill
        Rectangle {
          visible: root.mastery !== null
          implicitWidth: masteryLabel.implicitWidth + Style.space(8)
          implicitHeight: Style.space(16)
          radius: Style.space(3)
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.12)

          Text {
            id: masteryLabel
            anchors.centerIn: parent
            text: root.mastery ? root.mastery.tag : ""
            font.family: Style.font.family
            font.pixelSize: Style.font.caption - 1
            color: root.accent
          }
        }
      }

      Text {
        visible: root.desc !== "" && root.desc !== root.title
        text: root.desc
        font.family: Style.font.family
        font.pixelSize: Style.font.caption - 1
        color: Qt.darker(root.foreground, 1.4)
        elide: Text.ElideRight
        Layout.fillWidth: true
      }
    }

    // Key badges (right-aligned)
    Row {
      spacing: Style.space(3)
      Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

      Repeater {
        model: NavModel.parseKeys(root.keyString)
        delegate: KeyBadge {
          keyText: modelData
          foreground: root.foreground
          accent: root.accent
        }
      }
    }
  }
}
