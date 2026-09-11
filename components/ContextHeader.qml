import QtQuick
import QtQuick.Layouts
import qs.Commons

Rectangle {
  id: root

  property string categoryLabel: "Desktop"
  property string categoryIcon: "󰇄"
  property string windowTitle: "No focused window"
  property string workspaceName: "1"
  property bool isFloating: false
  property bool isFullscreen: false

  property color foreground: Color.popups.text
  property color accent: Color.accent

  implicitWidth: parent ? parent.width : Style.space(380)
  implicitHeight: contentRow.implicitHeight + Style.space(12)
  radius: Style.space(6)
  color: Util.alpha(accent, 0.08)
  border.color: Util.alpha(accent, 0.25)
  border.width: 1

  RowLayout {
    id: contentRow
    anchors.fill: parent
    anchors.leftMargin: Style.space(10)
    anchors.rightMargin: Style.space(10)
    spacing: Style.space(8)

    // Category Icon
    Text {
      text: root.categoryIcon
      font.family: Style.font.family
      font.pixelSize: Style.font.title
      color: root.accent
    }

    // App & Window Title
    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.space(1)

      Text {
        text: root.categoryLabel
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        font.bold: true
        color: root.foreground
        elide: Text.ElideRight
      }

      Text {
        visible: root.windowTitle !== ""
        text: root.windowTitle
        font.family: Style.font.family
        font.pixelSize: Style.font.caption - 1
        color: Util.alpha(root.foreground, 0.65)
        elide: Text.ElideMiddle
        Layout.fillWidth: true
      }
    }

    // Workspace badge
    Rectangle {
      implicitWidth: wsText.implicitWidth + Style.space(8)
      implicitHeight: Style.space(18)
      radius: Style.space(3)
      color: Util.alpha(root.foreground, 0.08)

      Text {
        id: wsText
        anchors.centerIn: parent
        text: "WS " + root.workspaceName
        font.family: Style.font.family
        font.pixelSize: Style.font.caption - 1
        font.bold: true
        color: root.foreground
      }
    }

    // Layout mode badge
    Rectangle {
      implicitWidth: layoutLabel.implicitWidth + Style.space(8)
      implicitHeight: Style.space(18)
      radius: Style.space(3)
      color: root.isFullscreen
        ? Util.alpha(Color.urgent, 0.2)
        : (root.isFloating
          ? Util.alpha(root.accent, 0.2)
          : Util.alpha(root.foreground, 0.08))

      Text {
        id: layoutLabel
        anchors.centerIn: parent
        text: root.isFullscreen ? "Fullscreen" : (root.isFloating ? "Floating" : "Tiled")
        font.family: Style.font.family
        font.pixelSize: Style.font.caption - 1
        font.bold: true
        color: root.isFullscreen ? Color.urgent : (root.isFloating ? root.accent : root.foreground)
      }
    }
  }
}
