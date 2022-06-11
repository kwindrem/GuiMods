import QtQuick 1.1
import "utils.js" as Utils
import "tanksensor.js" as TankSensor

Tile {
	id: root

	property variant service
	property string bindPrefix: service ? service.name : ""
	property string pumpBindPrefix
	property VBusItem levelItem: VBusItem { id: levelItem; bind: Utils.path(bindPrefix, "/Level"); decimals: 0; unit: "%" }
	property VBusItem fluidTypeItem: VBusItem { id: fluidTypeItem; bind: Utils.path(bindPrefix, "/FluidType") }
	property VBusItem pumpStateItem: VBusItem { id: pumpStateItem; bind: Utils.path(pumpBindPrefix, "/State") }
	property VBusItem pumpActiveService: VBusItem { id: pumpActiveService; bind: Utils.path(pumpBindPrefix, "/ActiveTankService") }
	property alias valueBarColor: valueBar.color
	property alias level: levelItem.value
	property int fullWarningLevel: ([2, 5].indexOf(fluidTypeItem.value) > -1) ? 80 : -1
	property int emptyWarningLevel: !([2, 5].indexOf(fluidTypeItem.value) > -1) ? 20 : -1
	property bool blink: true
	property bool compact: false
	property string tankName: service ? service.description : ""

	title: compact ? "" : tankName.toUpperCase()
	color: TankSensor.info(fluidTypeItem.value).color

	Timer {
		interval: 1000
		running: pumpActiveService.value === bindPrefix && pumpStateItem.value === 1
		repeat: true
		onTriggered: blink = !blink
		onRunningChanged: if (!running) blink = true
	}

	function doScroll()
	{
		tankText.doScroll()
	}

	function warning()
	{
		if (fullWarningLevel != -1 && level >= fullWarningLevel)
			return true
		if (emptyWarningLevel != -1 && level <= emptyWarningLevel)
			return true
		return false
	}

	values: Item {
		width: root.width - 10
		height: compact ? root.height : 21

		Marquee {
			id: tankText
			width: parent.width / 2
			height: compact ? 13 : parent.height
			text: compact ? tankName : ""
			textHorizontalAlignment: Text.AlignLeft
			visible: compact
			scroll: false
			anchors {
				verticalCenter: parent.verticalCenter; verticalCenterOffset: compact ? -9 : 0
			}
		}

		Rectangle {
			color: "#c0c0bd"
			border { width:1; color: "white" }
			width: root.width - 10 -  (compact ? tankText.width + 3 : 0)
			height: compact ? 13 : parent.height
			anchors {
				verticalCenter: parent.verticalCenter; verticalCenterOffset: compact ? -9 : 0
				right: parent.right
			}

			Rectangle {
				id: valueBar
				width: root.level / 100 * parent.width - 2
				height: parent.height - 1
				color: warning() ? "#e74c3c" : "#34495e"
				opacity: blink ? 1 : 0.5
				anchors {
					verticalCenter: parent.verticalCenter;
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
}
