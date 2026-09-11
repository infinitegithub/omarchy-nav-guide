import QtQuick
import QtQuick.Layouts
import qs.Commons

Rectangle {
  id: root

  property var rank: null // from NavModel.getNavigatorRank()
  property int totalActions: 0

  property color foreground: Color.popups.text
  property color accent: Color.accent

  implicitWidth: parent ? parent.width : Style.space(380)
  implicitHeight: column.implicitHeight + Style.space(16)
  radius: Style.space(6)
  color: Qt.rgba(accent.r, accent.g, accent.b, 0.08)
  border.color: Qt.rgba(accent.r, accent.g, accent.b, 0.25)
  border.width: 1

  ColumnLayout {
    id: column
    anchors.fill: parent
    anchors.margins: Style.space(10)
    spacing: Style.space(8)

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.space(10)

      Text {
        text: root.rank ? root.rank.icon : "🌱"
        font.pixelSize: Style.font.title + 4
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        Text {
          text: root.rank ? (root.rank.title + " (Level " + root.rank.level + ")") : "Explorer"
          font.family: Style.font.family
          font.pixelSize: Style.font.title
          font.bold: true
          color: root.foreground
        }

        Text {
          text: root.totalActions + " keyboard navigation actions executed"
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          color: Qt.darker(root.foreground, 1.3)
        }
      }

      Rectangle {
        implicitWidth: tagLabel.implicitWidth + Style.space(10)
        implicitHeight: Style.space(20)
        radius: Style.space(4)
        color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.2)

        Text {
          id: tagLabel
          anchors.centerIn: parent
          text: root.rank ? ("Next: " + root.rank.nextTitle) : "Next"
          font.family: Style.font.family
          font.pixelSize: Style.font.caption - 1
          font.bold: true
          color: root.accent
        }
      }
    }

    // Progress Bar
    Rectangle {
      Layout.fillWidth: true
      implicitHeight: Style.space(6)
      radius: Style.space(3)
      color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.1)

      Rectangle {
        width: Math.max(0, Math.min(parent.width, parent.width * (root.rank ? root.rank.percent : 0)))
        height: parent.height
        radius: parent.radius
        color: root.accent

        Behavior on width {
          NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }
      }
    }
  }
}
