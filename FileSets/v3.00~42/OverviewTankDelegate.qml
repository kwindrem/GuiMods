import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils
import "tanksensor.js" as TankSensor

Item {
	id: root

////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 1

	property string bindPrefix
	property variant service: DBusServices.get(bindPrefix)
	property variant info: TankSensor.info(fluidTypeItem.value)

	property VBusItem fluidTypeItem: VBusItem { bind: Utils.path(bindPrefix, "/FluidType") }
	property VBusItem volumeUnit: VBusItem { bind: "com.victronenergy.settings/Settings/System/VolumeUnit" }
	property VBusItem tankLevelItem: VBusItem {
		bind: Utils.path(bindPrefix, "/Level")
		decimals: 0
		unit: "%"
	}
	property VBusItem tankCapacityItem: VBusItem {
		bind: Utils.path(bindPrefix, "/Capacity")
		text: TankSensor.formatVolume(volumeUnit.value, value)
	}
	property VBusItem tankRemainingItem: VBusItem {
		bind: Utils.path(bindPrefix, "/Remaining")
		text: TankSensor.formatVolume(volumeUnit.value, value)
	}

	width: 65
	height: 150

	SvgRectangle {
		id: mainRect
		border { color: info.color; width: 2 }
		width: root.width
		height: root.height * 0.72
		color: !darkMode ? "white" : "#c0c0c0"

		SvgRectangle {
			color: info.color
			height: (parent.height - 4) * (tankLevelItem.value / 100)
			width: parent.width - 5
			anchors {
				left: parent.left; leftMargin: 2
				right: parent.right; rightMargin: 2
				bottom: parent.bottom; bottomMargin: 2
			}
		}

		Text {
			text: tankLevelItem.text
			width: parent.width
			font.pixelSize: width < 50 ? 12 : 18
			horizontalAlignment: Text.AlignHCenter
			clip: true
			anchors {
				horizontalCenter: parent.horizontalCenter
				top: parent.top; topMargin: 6
			}
		}

		MbIcon {
			iconId: info.icon
			anchors.centerIn: parent
		}

		Text {
			text: tankRemainingItem.text
			font.pixelSize: width < 50 ? 11 : 12
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			clip: true
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: _capacityText.top
			}
		}

		Text {
			id: _capacityText
			text: "(%1)".arg(tankCapacityItem.text)
			font.pixelSize: width < 50 ? 11 : 12
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			clip: true
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom; bottomMargin: 6
			}
		}
	}

	Text {
		id: _tankName
		text: service.description
		color: !darkMode ? "#ffffff" : "#e1e1e1"
		width: parent.width + (parent.width < 50 ? 4 : 13)
		horizontalAlignment: Text.AlignHCenter
		wrapMode: Text.WrapAtWordBoundaryOrAnywhere
		font.pixelSize: 12
		maximumLineCount: 2
		clip: true
		anchors {
			top: mainRect.bottom; topMargin: 6
			bottom: root.bottom
			horizontalCenter: root.horizontalCenter
		}
	}
}
