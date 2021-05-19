import QtQuick 1.1
import "utils.js" as Utils

Tile {
	id: root

	property string bindPrefix: serviceName
	property string pumpBindPrefix
	property VBusItem levelItem: VBusItem { id: levelItem; bind: Utils.path(bindPrefix, "/Level"); decimals: 0; unit: "%" }
	property VBusItem fluidTypeItem: VBusItem { id: fluidTypeItem; bind: Utils.path(bindPrefix, "/FluidType") }
	property VBusItem pumpStateItem: VBusItem { id: pumpStateItem; bind: Utils.path(pumpBindPrefix, "/State") }
	property VBusItem pumpActiveService: VBusItem { id: pumpActiveService; bind: Utils.path(pumpBindPrefix, "/ActiveTankService") }
	property alias valueBarColor: valueBar.color
	property alias level: levelItem.value
	property int fullWarningLevel: ([2, 5].indexOf(fluidTypeItem.value) > -1) ? 80 : -1
	property int emptyWarningLevel: !([2, 5].indexOf(fluidTypeItem.value) > -1) ? 20 : -1
	property variant fluidTypes: [qsTr("FUEL"), qsTr("FRESH WATER"), qsTr("WASTE WATER"), qsTr("LIVE WELL"), qsTr("OIL"), qsTr("BLACK WATER")]
	property variant fluidColor: ["#1abc9c", "#4aa3df", "#95a5a6", "#dcc6e0", "#f1a9a0", "#7f8c8d"]
	property bool blink: true

	title: fluidTypeItem.valid ? fluidTypes[fluidTypeItem.value] : "TANK"
	color: fluidTypeItem.valid ? fluidColor[fluidTypeItem.value] : "#4aa3df"

	Timer {
		interval: 1000
		running: pumpActiveService.value === bindPrefix && pumpStateItem.value === 1
		repeat: true
		onTriggered: blink = !blink
		onRunningChanged: if (!running) blink = true
	}

	function warning()
	{
		if (fullWarningLevel != -1 && level >= fullWarningLevel)
			return true
		if (emptyWarningLevel != -1 && level <= emptyWarningLevel)
			return true
		return false
	}

	values: Rectangle {
		color: "#c0c0bd"
		border { width:1; color: "white" }
		width: root.width - 10
		height: 21

		Rectangle {
			id: valueBar
			width: root.level / 100 * parent.width - 2
			height: parent.height - 1
			color: warning() ? "#e74c3c" : "#34495e"
			opacity: blink ? 1 : 0.5
			anchors {
				verticalCenter: parent.verticalCenter
				left: parent.left; leftMargin: 1
			}
		}

		Text {
			font.pixelSize: 12
			font.bold: true
			text: root.levelItem.text
			anchors.centerIn: parent
			color: "white"
		}
	}

}
