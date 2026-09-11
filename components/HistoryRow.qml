import QtQuick
import QtQuick.Layouts
import qs.Commons
import "../NavigationModel.js" as NavModel

Rectangle {
  id: root

  property string title: ""
  property string keyString: ""
  property string icon: "󰌌"
  property string category: "general"
  property double timestamp: 0
  property string action: ""

  property color foreground: Color.popups.text
  property color accent: Color.accent
  property bool hovered: mouseArea.containsMouse

  signal triggered(string actionCmd)

  implicitWidth: parent ? parent.width : Style.space(380)
  implicitHeight: Style.space(36)
  radius: Style.space(5)

  color: hovered ? Util.alpha(accent, 0.12) : Util.alpha(foreground, 0.03)
  border.color: hovered ? Util.alpha(accent, 0.45) : Util.alpha(foreground, 0.06)
  border.width: 1

  Behavior on color { ColorAnimation { duration: 100 } }
  Behavior on border.color { ColorAnimation { duration: 100 } }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: root.action ? Qt.PointingHandCursor : Qt.ArrowCursor
    onClicked: {
      if (root.action) root.triggered(root.action)
    }
  }

  RowLayout {
    anchors.fill: parent
    anchors.leftMargin: Style.space(10)
    anchors.rightMargin: Style.space(10)
    spacing: Style.space(8)

    // Leading action icon
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
      elide: Text.ElideRight
      Layout.fillWidth: true
    }

    // Relative timestamp chip
    Text {
      text: NavModel.formatTimeAgo(root.timestamp)
      font.family: Style.font.family
      font.pixelSize: Style.font.caption - 1
      color: Util.alpha(root.foreground, 0.5)
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
          active: root.hovered
        }
      }
    }
  }
}
