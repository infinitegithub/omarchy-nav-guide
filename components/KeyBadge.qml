import QtQuick
import qs.Commons

Rectangle {
  id: root
  property string keyText: ""
  property color foreground: Color.popups.text
  property color accent: Color.accent
  property bool active: false

  implicitWidth: Math.max(Style.space(22), keyLabel.implicitWidth + Style.space(12))
  implicitHeight: Style.space(22)
  radius: Style.space(4)

  color: active
    ? Util.alpha(root.accent, 0.25)
    : Util.alpha(root.foreground, 0.08)

  border.color: active
    ? Util.alpha(root.accent, 0.7)
    : Util.alpha(root.foreground, 0.2)
  border.width: 1

  // Subtle keycap 3D lower lip for tactile feel
  Rectangle {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    height: 2
    radius: parent.radius
    color: root.active ? Util.alpha(root.accent, 0.5) : Util.alpha(root.foreground, 0.15)
  }

  Text {
    id: keyLabel
    anchors.centerIn: parent
    text: root.keyText
    color: root.active ? root.accent : root.foreground
    font.family: Style.font.family
    font.pixelSize: Style.font.caption
    font.bold: true
  }
}
