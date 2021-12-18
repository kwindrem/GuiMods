// New for GuiMods to display temperature sensors
//  based on TileTank.qml
//  same tile sizes and look

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
    property VBusItem temperatureItem: VBusItem { id: temperatureItem; bind: Utils.path(bindPrefix, "/Temperature") }
    property VBusItem rawValueItem: VBusItem { id: rawValueItem; bind: Utils.path(bindPrefix, "/RawValue") }
    property VBusItem scaleItem: VBusItem { id: scaleItem; bind: Utils.path(bindPrefix, "/Scale") }
    property VBusItem offsetItem: VBusItem { id: offsetItem; bind: Utils.path(bindPrefix, "/Offset") }
    property real scale: scaleItem.valid ? scaleItem.value : 1.0
    property real offset: offsetItem.valid ? offsetItem.value : 0.0
    property real temperature: rawValueItem.valid ? ((rawValueItem.value * 100.0) - 273.15) * scale + offset : temperatureItem.valid ? temperatureItem.value : -99
	property VBusItem temperatureTypeItem: VBusItem { id: temperatureTypeItem; bind: Utils.path(bindPrefix, "/TemperatureType") }
    property VBusItem customNameItem: VBusItem { id: customNameItem; bind: Utils.path(bindPrefix, "/CustomName") }
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

		MarqueeEnhanced
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
                if (root.temperature == -99)
                    return "--"
                else if (tempScale == 1)
                    return root.temperature.toFixed (1) + "°C"
                else if (tempScale == 2)
                    return ((root.temperature * 9 / 5) + 32).toFixed (1) + "°F"
                else if (root.compact)
                    return root.temperature.toFixed (1) + "C " + ((root.temperature * 9 / 5) + 32).toFixed (1) + "F"
                else
                    return root.temperature.toFixed (1) + "°C " + ((root.temperature * 9 / 5) + 32).toFixed (1) + "°F"
            }
        }
	}
}
