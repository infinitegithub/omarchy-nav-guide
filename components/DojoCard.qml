import QtQuick
import QtQuick.Layouts
import qs.Commons
import "../NavigationModel.js" as NavModel

Rectangle {
  id: root

  property var drills: NavModel.getDojoDrills()
  property int currentIndex: 0
  property int comboCount: 0
  property bool completedCurrent: false

  readonly property var currentDrill: (drills && drills.length > 0) ? drills[currentIndex % drills.length] : null

  property color foreground: Color.popups.text
  property color accent: Color.accent

  signal executed(string key, string desc, string icon, string category, string cmd)

  implicitWidth: Style.space(380)
  implicitHeight: mainCol.implicitHeight + Style.space(20)
  radius: Style.space(6)
  color: Util.alpha(accent, 0.08)
  border.color: completedCurrent ? Util.alpha(Color.accent, 0.8) : Util.alpha(accent, 0.3)
  border.width: completedCurrent ? 2 : 1

  Behavior on border.color { ColorAnimation { duration: 150 } }

  ColumnLayout {
    id: mainCol
    anchors.fill: parent
    anchors.margins: Style.space(12)
    spacing: Style.space(10)

    // Header: Mode title + Combo Badge
    RowLayout {
      Layout.fillWidth: true

      Text {
        text: "🥋 SHORTCUT DOJO"
        font.family: Style.font.family
        font.pixelSize: Style.font.caption - 1
        font.bold: true
        color: root.accent
      }

      Item { Layout.fillWidth: true }

      // Combo Pill
      Rectangle {
        visible: root.comboCount > 1
        implicitWidth: comboLabel.implicitWidth + Style.space(10)
        implicitHeight: Style.space(18)
        radius: Style.space(3)
        color: Util.alpha(Color.urgent, 0.25)

        Text {
          id: comboLabel
          anchors.centerIn: parent
          text: "🔥 " + root.comboCount + "x COMBO"
          font.family: Style.font.family
          font.pixelSize: Style.font.caption - 1
          font.bold: true
          color: Color.urgent
        }
      }

      // XP Reward Pill
      Rectangle {
        implicitWidth: xpLabel.implicitWidth + Style.space(10)
        implicitHeight: Style.space(18)
        radius: Style.space(3)
        color: Util.alpha(root.accent, 0.2)

        Text {
          id: xpLabel
          anchors.centerIn: parent
          text: "+" + (root.currentDrill ? root.currentDrill.xp : 20) + " XP"
          font.family: Style.font.family
          font.pixelSize: Style.font.caption - 1
          font.bold: true
          color: root.accent
        }
      }
    }

    // Challenge Prompt Box
    Rectangle {
      Layout.fillWidth: true
      implicitHeight: promptCol.implicitHeight + Style.space(14)
      radius: Style.space(5)
      color: Util.alpha(root.foreground, 0.04)
      border.color: Util.alpha(root.foreground, 0.08)
      border.width: 1

      ColumnLayout {
        id: promptCol
        anchors.fill: parent
        anchors.margins: Style.space(10)
        spacing: Style.space(4)

        RowLayout {
          spacing: Style.space(8)

          Text {
            text: root.currentDrill ? root.currentDrill.icon : "🎯"
            font.pixelSize: Style.font.title
          }

          Text {
            text: root.currentDrill ? root.currentDrill.title : "Challenge"
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            font.bold: true
            color: root.foreground
          }

          Rectangle {
            implicitWidth: diffLabel.implicitWidth + Style.space(6)
            implicitHeight: Style.space(14)
            radius: Style.space(2)
            color: Util.alpha(root.foreground, 0.08)

            Text {
              id: diffLabel
              anchors.centerIn: parent
              text: root.currentDrill ? root.currentDrill.difficulty : "Normal"
              font.family: Style.font.family
              font.pixelSize: Style.font.caption - 2
              color: Util.alpha(root.foreground, 0.6)
            }
          }
        }

        Text {
          text: root.currentDrill ? root.currentDrill.prompt : "Press the requested key combo"
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          color: Util.alpha(root.foreground, 0.7)
          wrapMode: Text.WordWrap
          Layout.fillWidth: true
        }
      }
    }

    // Target Keys Demonstration & Test Button
    RowLayout {
      Layout.fillWidth: true
      spacing: Style.space(8)

      // Key Badges
      Row {
        spacing: Style.space(4)
        Layout.alignment: Qt.AlignVCenter

        Repeater {
          model: root.currentDrill ? NavModel.parseKeys(root.currentDrill.targetKey) : []
          delegate: KeyBadge {
            keyText: modelData
            foreground: root.foreground
            accent: root.accent
            active: root.completedCurrent
          }
        }
      }

      Item { Layout.fillWidth: true }

      // Fire / Practice Button
      Rectangle {
        implicitWidth: testLabel.implicitWidth + Style.space(14)
        implicitHeight: Style.space(26)
        radius: Style.space(4)
        color: testMouse.containsMouse ? Util.alpha(root.accent, 0.3) : Util.alpha(root.accent, 0.18)
        border.color: Util.alpha(root.accent, 0.5)
        border.width: 1

        Text {
          id: testLabel
          anchors.centerIn: parent
          text: root.completedCurrent ? "✓ Completed!" : "⚡ Practice Now"
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          font.bold: true
          color: root.accent
        }

        MouseArea {
          id: testMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (root.currentDrill) {
              root.completedCurrent = true
              root.comboCount += 1
              root.executed(
                root.currentDrill.targetKey,
                root.currentDrill.title,
                root.currentDrill.icon,
                "dojo",
                root.currentDrill.action
              )
            }
          }
        }
      }

      // Next Drill Button
      Rectangle {
        implicitWidth: nextLabel.implicitWidth + Style.space(14)
        implicitHeight: Style.space(26)
        radius: Style.space(4)
        color: nextMouse.containsMouse ? Util.alpha(root.foreground, 0.12) : Util.alpha(root.foreground, 0.06)
        border.color: Util.alpha(root.foreground, 0.12)
        border.width: 1

        Text {
          id: nextLabel
          anchors.centerIn: parent
          text: "Next ❯"
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          font.bold: true
          color: root.foreground
        }

        MouseArea {
          id: nextMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            root.completedCurrent = false
            root.currentIndex += 1
          }
        }
      }
    }
  }
}
