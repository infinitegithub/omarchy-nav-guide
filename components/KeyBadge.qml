import QtQuick
import qs.Commons

Rectangle {
  id: root
  property string keyText: ""
  property color foreground: Color.foreground
  property color accent: Color.accent

  implicitWidth: Math.max(Style.space(22), keyLabel.implicitWidth + Style.space(12))
  implicitHeight: Style.space(22)
  radius: Style.space(4)

  color: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.12)
  border.color: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.25)
  border.width: 1

  Text {
    id: keyLabel
    anchors.centerIn: parent
    text: root.keyText
    color: root.foreground
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
    font.bold: true
  }
}
