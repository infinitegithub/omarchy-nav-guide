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
  implicitHeight: column.implicitHeight + Style.space(16)
  radius: Style.cornerRadius
  color: Qt.rgba(accent.r, accent.g, accent.b, 0.08)
  border.color: Qt.rgba(accent.r, accent.g, accent.b, 0.2)
  border.width: 1

  ColumnLayout {
    id: column
    anchors.fill: parent
    anchors.margins: Style.space(10)
    spacing: Style.space(6)

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.space(8)

      // Category Icon
      Text {
        text: root.categoryIcon
        font.family: Style.font.family
        font.pixelSize: Style.font.title
        color: root.accent
      }

      // Category Label
      Text {
        text: root.categoryLabel
        font.family: Style.font.family
        font.pixelSize: Style.font.title
        font.bold: true
        color: root.foreground
        Layout.fillWidth: true
        elide: Text.ElideRight
      }

      // Workspace badge
      Rectangle {
        implicitWidth: wsRow.implicitWidth + Style.space(10)
        implicitHeight: Style.space(20)
        radius: Style.space(4)
        color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.1)

        Row {
          id: wsRow
          anchors.centerIn: parent
          spacing: Style.space(4)

          Text {
            text: "WS " + root.workspaceName
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            color: root.foreground
          }
        }
      }

      // Layout mode badge
      Rectangle {
        implicitWidth: layoutLabel.implicitWidth + Style.space(10)
        implicitHeight: Style.space(20)
        radius: Style.space(4)
        color: root.isFullscreen
          ? Qt.rgba(Color.urgent.r, Color.urgent.g, Color.urgent.b, 0.2)
          : (root.isFloating
            ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.2)
            : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.1))

        Text {
          id: layoutLabel
          anchors.centerIn: parent
          text: root.isFullscreen ? "Fullscreen" : (root.isFloating ? "Floating" : "Tiled")
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          font.bold: true
          color: root.isFullscreen ? Color.urgent : (root.isFloating ? root.accent : root.foreground)
        }
      }
    }

    // Window title text
    Text {
      visible: root.windowTitle !== ""
      text: root.windowTitle
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      color: Qt.darker(root.foreground, 1.3)
      Layout.fillWidth: true
      elide: Text.ElideMiddle
      Layout.leftMargin: Style.space(24)
    }
  }
}
