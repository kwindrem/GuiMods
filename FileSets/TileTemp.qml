// New for GuiMods to display temperature sensors
//  based on TileTank.qml
//  same tile sizes and look
//  no blink or color change for limits
//  displays temperature rather that tank level
//  bar grows from 0 C not from left end
//  bar has blueish tint if temp < 0 or greenish tint if >= 0

import QtQuick 1.1
import "utils.js" as Utils
import "tanksensor.js" as TankSensor

Tile {
	id: root

    property VBusItem tempScaleItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/TemperatureScale" }
    property int tempScale: tempScaleItem.valid ? tempScaleItem.value : 0
    // small tile height threshold
    property bool squeeze: height < 50

	property string bindPrefix: serviceName
	property VBusItem temperatureItem: VBusItem { id: temperatureItem; bind: Utils.path(bindPrefix, "/Temperature"); decimals: 0; unit: "°" }
    property real temperature: temperatureItem.valid ? temperatureItem.value : -99
	property VBusItem temperatureTypeItem: VBusItem { id: temperatureTypeItem; bind: Utils.path(bindPrefix, "/TemperatureType") }
    property VBusItem customNameItem: VBusItem { id: customNameItem; bind: Utils.path(bindPrefix, "/CustomName") }
    property VBusItem statusItem: VBusItem { id: statusItem; bind: Utils.path(bindPrefix, "/Status") }
	property bool compact: false

    property variant tempNames: [qsTr("Battery"), qsTr("Fridge"), qsTr("Generic")]
    property string tempName: customNameItem.valid && customNameItem.value !== "" ? customNameItem.value : temperatureTypeItem.valid ? tempNames [temperatureTypeItem.value] : "TEMP"
    property variant tempColors: ["#4aa3df", "#1abc9c", "#F39C12"]
    property color tempColor: temperatureTypeItem.valid ? tempColors [temperatureTypeItem.value] : "#7f8c8d"

    property real minTemp: -30
    property real maxTemp: 60
    property real tempSpan: (maxTemp - minTemp)

    title: compact ? "" : tempName
	color: tempColor

	function doScroll()
	{
		tempText.doScroll()
	}

	values: Item
    {
		width: root.width - 10
        height: compact ? root.height : squeeze ? 17 : 21

		Marquee
        {
			id: tempText
            width: Math.max (Math.floor (parent.width * 0.5 ), 44)
			height: compact ? 13 : parent.height
			text: compact ? tempName : ""
            textHorizontalAlignment: Text.AlignLeft
			visible: compact
			scroll: false
			anchors
            {
                verticalCenter: parent.verticalCenter; verticalCenterOffset: compact ? -9 : squeeze ? -4 : 0
			}
		}

        Text {
            font.pixelSize: 12
            font.bold: true
            color: "white"
            width: root.width - 10 - (compact ? tempText.width + 3 : 0)
            anchors {
                verticalCenter: parent.verticalCenter; verticalCenterOffset: compact ? -9 : squeeze ? -4 : 0
                right: parent.right
            }
            horizontalAlignment: compact ? Text.AlignRight : Text.AlignHCenter
            text:
            {   
                if (statusItem.value !== 0)
                    return "???"
                else if (tempScale == 1)
                    return root.temperature.toFixed (0) + "°C"
                else if (tempScale == 2)
                    return ((root.temperature * 9 / 5) + 32).toFixed (0) + "°F"
                else if (root.compact)
                    return root.temperature.toFixed (0) + "C " + ((root.temperature * 9 / 5) + 32).toFixed (0) + "F"
                else
                    return root.temperature.toFixed (0) + "°C " + ((root.temperature * 9 / 5) + 32).toFixed (0) + "°F"
            }
        }
	}
}
