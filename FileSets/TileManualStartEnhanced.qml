//// Modified for GeneratorConnector / GuiMods
//		allow smaller inactive tile
//		expand tile to fit content when active
//		accommodate auto start enable/disable also

import QtQuick 1.1
import "utils.js" as Utils

ListView {
	id: root

	property int count: countownTime
	property int countownTime: 5
	property string bindPrefix
	property alias startCountdown: countdownTimer.running
	property bool connected: true
	property VBusItem state: VBusItem { bind: Utils.path(bindPrefix, "/State") }
	property VBusItem manualStart: VBusItem { bind: Utils.path(bindPrefix, "/ManualStart") }
	property VBusItem autoStart: VBusItem { bind: Utils.path(settingsBindPrefix, "/AutoStartEnabled") }
	property bool manualRunActive: manualStart.valid && manualStart.value == 1
	property bool autoStartEnabled: autoStart.valid && autoStart.value == 1
	property alias expanded: timerTile.expanded
	property int tileHeight: 40
	property bool buttonState: manualRunActive
	property alias editMode: timerTile.editMode

	model: tileModel
	height: timerTile.editMode ? timerTile.height : startTile.height

	Keys.onSpacePressed: { startTile.edit(false); event.accepted = true }

	VisualItemModel {
		id: tileModel
		Tile {
			id: startTile
			title:
			{
				if (manualRunActive)
					return qsTr ("MANUAL START - ACTIVE")
				else
					return qsTr ("MANUAL START - INACTIVE")
			}
			width: root.width
			height: root.startCountdown ? contentHeight : tileHeight
			readOnly: !manualStart.valid
			color: mouseArea.containsMouse ? "#f08b80" : "#e74c3c"
			show: !timerTile.editMode

			function edit(isMouse)
			{
				if (!connected) {
					toast.createToast(qsTr("Generator not connected."))
					return
				}
				if (buttonState || startCountdown)
					startCountdown = !startCountdown
				else
					timerTile.edit(isMouse)
			}

			MouseArea {
				id: mouseArea
				anchors.fill: parent
				onClicked: {
					parent.edit(true)
				}
			}

			values: [
				TileTextMultiLine {
					font.pixelSize: 12
					text:
					{
						if (root.activeFocus)
							return qsTr("press Center button to:")
						else
							return qsTr ("press Down button to:")
					}
					width: root.width - 6
					visible: !root.startCountdown || (root.startCountdown && !buttonState || countdownText.visible)
				},
				TileTextMultiLine {
					text:
					{
						if (! root.activeFocus)
							return qsTr ("SELECT")
						else if (root.startCountdown)
							return qsTr ("CANCEL")
						else if (buttonState)
								return qsTr("STOP")
						else
							return qsTr("START")
					}
					font.pixelSize: 22
					verticalAlignment: Text.AlignTop
					width: root.width - 6
				},
				TileTextMultiLine {
					id: countdownText
					text:
					{
						if (buttonState)
							return qsTr("Stopping in %1 seconds").arg(root.count)
						else
							return qsTr("Starting in %1 seconds").arg(root.count)
					}
					width: root.width - 6
					visible: root.startCountdown
				},
				TileTextMultiLine {
					text: qsTr("Already running, use to make sure generator will run for a fixed time")
					visible: state.value > 0 && !manualRunActive
					width: root.width - 6
				},
				TileTextMultiLine {
					text: autoStartEnabled ? qsTr("Generator won't stop if other conditions are reached") : ""
					visible: root.startCountdown && manualRunActive
					width: root.width - 6
				}
			]
		}
		TileSpinBox {
			id: timerTile
			title: qsTr("STOP TIMER")
			width: root.width
			height: Math.max (contentHeight + 2, tileHeight * 2)
			readOnly: manualRunActive
			enabled: !readOnly
			unit: ""
			stepSize: 60
			max: 86340
			min: 0
			focus: editMode
			show: editMode
			color: startTile.color
			description: qsTr("Run for:")
			extraDescription: autoStartEnabled ? qsTr("Generator will continue running if other conditions are reached") : ""
			bind: Utils.path(root.bindPrefix, "/ManualStartTimer")
			buttonColor: "#e02e1c"

			onAccepted: { root.startCountdown = true }

			function format(val)
			{
				if (!isNaN(val)) {
					if (val > 0)
						return Utils.secondsToNoSecsString(val);
					else
						return qsTr("Stop manually")
				}
				return val
			}
		}
	}
	function cancel() {
		if (timerTile.editMode) {
			timerTile.cancel()
		}
	}

	Timer {
		id: countdownTimer
		interval: 1000
		running: root.startCountdown
		repeat: root.count >= 0
		onRunningChanged: root.count = root.countownTime
		onTriggered: {
			if (root.count == 0)
			{
				manualStart.setValue((manualRunActive ? 0 : 1))
				root.startCountdown = false
			}
			root.count--
		}
	}
}
