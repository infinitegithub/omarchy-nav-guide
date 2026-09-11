import QtQuick
import QtQuick.Layouts
import qs.Commons

Rectangle {
  id: root

  property var rank: null // from NavModel.getNavigatorRank()
  property int totalActions: 0
  property int streak: 1

  property color foreground: Color.popups.text
  property color accent: Color.accent

  implicitWidth: parent ? parent.width : Style.space(380)
  implicitHeight: column.implicitHeight + Style.space(18)
  radius: Style.space(6)
  color: Util.alpha(accent, 0.08)
  border.color: Util.alpha(accent, 0.25)
  border.width: 1

  ColumnLayout {
    id: column
    anchors.fill: parent
    anchors.margins: Style.space(12)
    spacing: Style.space(8)

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.space(10)

      Text {
        text: root.rank ? root.rank.icon : "🌱"
        font.pixelSize: Style.font.title + 6
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.space(1)

        RowLayout {
          spacing: Style.space(6)

          Text {
            text: root.rank ? root.rank.title : "Novice Tiler"
            font.family: Style.font.family
            font.pixelSize: Style.font.title
            font.bold: true
            color: root.foreground
          }

          // Level badge
          Rectangle {
            implicitWidth: levelText.implicitWidth + Style.space(8)
            implicitHeight: Style.space(18)
            radius: Style.space(3)
            color: Util.alpha(root.accent, 0.25)

            Text {
              id: levelText
              anchors.centerIn: parent
              text: "LVL " + (root.rank ? root.rank.level : 1)
              font.family: Style.font.family
              font.pixelSize: Style.font.caption - 1
              font.bold: true
              color: root.accent
            }
          }
        }

        RowLayout {
          spacing: Style.space(8)

          Text {
            text: root.totalActions + " shortcuts executed"
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            color: Util.alpha(root.foreground, 0.65)
          }

          Text {
            text: "•"
            font.pixelSize: Style.font.caption
            color: Util.alpha(root.foreground, 0.4)
          }

          Text {
            text: "🔥 " + (root.rank && root.rank.streak ? root.rank.streak : root.streak) + " Day Streak"
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            color: Color.urgent
          }
        }
      }

      // Next tier target badge
      Rectangle {
        implicitWidth: tagLabel.implicitWidth + Style.space(10)
        implicitHeight: Style.space(22)
        radius: Style.space(4)
        color: Util.alpha(root.accent, 0.18)
        border.color: Util.alpha(root.accent, 0.4)
        border.width: 1

        Text {
          id: tagLabel
          anchors.centerIn: parent
          text: root.rank ? ("Next: " + root.rank.nextTitle) : "Next Level"
          font.family: Style.font.family
          font.pixelSize: Style.font.caption - 1
          font.bold: true
          color: root.accent
        }
      }
    }

    // Progress Bar with XP info
    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.space(3)

      RowLayout {
        Layout.fillWidth: true

        Text {
          text: "MASTERY PROGRESS"
          font.family: Style.font.family
          font.pixelSize: Style.font.caption - 2
          font.bold: true
          color: Util.alpha(root.foreground, 0.5)
        }

        Item { Layout.fillWidth: true }

        Text {
          text: (root.rank ? root.rank.current : 0) + " / " + (root.rank ? root.rank.max : 15) + " XP"
          font.family: Style.font.family
          font.pixelSize: Style.font.caption - 1
          font.bold: true
          color: root.accent
        }
      }

      Rectangle {
        Layout.fillWidth: true
        implicitHeight: Style.space(6)
        radius: Style.space(3)
        color: Util.alpha(root.foreground, 0.08)

        Rectangle {
          width: Math.max(0, Math.min(parent.width, parent.width * (root.rank ? root.rank.percent : 0)))
          height: parent.height
          radius: parent.radius
          color: root.accent

          Behavior on width {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
          }
        }
      }
    }
  }
}
