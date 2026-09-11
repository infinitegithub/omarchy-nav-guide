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

  property color foreground: Color.popups.text
  property color accent: Color.accent
  property bool hovered: mouseArea.containsMouse

  signal triggered(string actionCmd)

  implicitWidth: parent ? parent.width : Style.space(380)
  implicitHeight: contentColumn.implicitHeight + Style.space(16)
  radius: Style.cornerRadius

  color: hovered
    ? Qt.rgba(accent.r, accent.g, accent.b, 0.12)
    : Qt.rgba(foreground.r, foreground.g, foreground.b, 0.04)

  border.color: hovered
    ? Qt.rgba(accent.r, accent.g, accent.b, 0.4)
    : Qt.rgba(foreground.r, foreground.g, foreground.b, 0.08)
  border.width: 1

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

  ColumnLayout {
    id: contentColumn
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.margins: Style.space(10)
    spacing: Style.space(4)

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.space(8)

      // Icon
      Text {
        text: root.icon
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        color: root.hovered ? root.accent : root.foreground
      }

      // Title
      Text {
        text: root.title
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        font.bold: true
        color: root.foreground
        Layout.fillWidth: true
        elide: Text.ElideRight
      }

      // Badge (optional)
      Rectangle {
        visible: root.badgeText !== ""
        implicitWidth: badgeLabel.implicitWidth + Style.space(8)
        implicitHeight: Style.space(16)
        radius: Style.space(3)
        color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.15)

        Text {
          id: badgeLabel
          anchors.centerIn: parent
          text: root.badgeText
          font.family: Style.font.family
          font.pixelSize: Style.font.caption - 1
          color: root.accent
        }
      }

      // Key badges
      Row {
        spacing: Style.space(4)
        Layout.alignment: Qt.AlignRight

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

    // Description
    Text {
      visible: root.desc !== ""
      text: root.desc
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      color: Qt.darker(root.foreground, 1.4)
      Layout.fillWidth: true
      wrapMode: Text.WordWrap
      Layout.leftMargin: Style.space(22)
    }
  }
}
