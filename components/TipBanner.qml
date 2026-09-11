import QtQuick
import QtQuick.Layouts
import qs.Commons
import "../TipCatalog.js" as TipCatalog

Rectangle {
  id: root

  property int currentTipIndex: 0
  property var tips: TipCatalog.generalTips
  readonly property var activeTip: (tips && tips.length > 0) ? tips[currentTipIndex % tips.length] : null

  property color foreground: Color.popups.text
  property color accent: Color.accent

  function nextTip() {
    if (!tips || tips.length === 0) return
    currentTipIndex = (currentTipIndex + 1) % tips.length
  }

  function prevTip() {
    if (!tips || tips.length === 0) return
    currentTipIndex = (currentTipIndex - 1 + tips.length) % tips.length
  }

  implicitWidth: parent ? parent.width : Style.space(380)
  implicitHeight: contentRow.implicitHeight + Style.space(16)
  radius: Style.cornerRadius
  color: Util.alpha(accent, 0.06)
  border.color: Util.alpha(accent, 0.2)
  border.width: 1

  Timer {
    interval: 14000
    running: true
    repeat: true
    onTriggered: root.nextTip()
  }

  RowLayout {
    id: contentRow
    anchors.fill: parent
    anchors.margins: Style.space(10)
    spacing: Style.space(10)

    Text {
      text: "💡"
      font.pixelSize: Style.font.title
      Layout.alignment: Qt.AlignTop
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.space(2)

      RowLayout {
        Layout.fillWidth: true
        spacing: Style.space(6)

        Text {
          text: root.activeTip ? ("Did You Know: " + root.activeTip.title) : "Navigation Tip"
          font.family: Style.font.family
          font.pixelSize: Style.font.body
          font.bold: true
          color: root.accent
          Layout.fillWidth: true
          elide: Text.ElideRight
        }

        // Navigation controls for tips
        Row {
          spacing: Style.space(4)

          Rectangle {
            width: Style.space(20)
            height: Style.space(20)
            radius: Style.space(4)
            color: prevMouse.containsMouse ? Util.alpha(root.accent, 0.2) : "transparent"

            Text {
              anchors.centerIn: parent
              text: "◀"
              font.pixelSize: Style.font.caption - 2
              color: root.foreground
            }
            MouseArea {
              id: prevMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.prevTip()
            }
          }

          Rectangle {
            width: Style.space(20)
            height: Style.space(20)
            radius: Style.space(4)
            color: nextMouse.containsMouse ? Util.alpha(root.accent, 0.2) : "transparent"

            Text {
              anchors.centerIn: parent
              text: "▶"
              font.pixelSize: Style.font.caption - 2
              color: root.foreground
            }
            MouseArea {
              id: nextMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.nextTip()
            }
          }
        }
      }

      Text {
        text: root.activeTip ? root.activeTip.text : ""
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
        color: root.foreground
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
      }
    }
  }
}
