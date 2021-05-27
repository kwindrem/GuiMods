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

    property VBusItem volumeUnit: VBusItem { bind: "com.victronenergy.settings/Settings/System/VolumeUnit" }
    // small tile height threshold
    property bool squeeze: height < 50

	property string bindPrefix: serviceName
	property VBusItem temperatureItem: VBusItem { id: temperatureItem; bind: Utils.path(bindPrefix, "/Temperature"); decimals: 0; unit: "°" }
    property real temperature: temperatureItem.valid ? temperatureItem.value : -99
	property VBusItem temperatureTypeItem: VBusItem { id: temperatureTypeItem; bind: Utils.path(bindPrefix, "/TemperatureType") }
	property VBusItem customNameItem: VBusItem { id: customNameItem; bind: Utils.path(bindPrefix, "/CustomName") }
	property bool compact: false

    property variant tempNames: [qsTr("Battery"), qsTr("Fridge"), qsTr("Generic")]
    property string tempName: customNameItem.valid && customNameItem.value !== "" ? customNameItem.value : temperatureTypeItem.valid ? tempNames [temperatureTypeItem.value] : "TEMP"
    property variant tempColors: ["#1abc9c", "#dcc6e0", "#F39C12"]
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
            width: Math.floor (parent.width * 0.3 )
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

		Rectangle
        {
			color: "#c0c0bd"
			border { width:1; color: "white" }
			width: root.width - 10 -  (compact ? tempText.width + 3 : 0)
			height: compact ? 13 : parent.height
            clip: true
			anchors {
                verticalCenter: parent.verticalCenter; verticalCenterOffset: compact ? -9 : squeeze ? -4 : 0
				right: parent.right
			}

            Rectangle
            {
                id: valueBarPos
                width: Math.max (temperature / root.tempSpan * parent.width - 2, 2)
                height: parent.height - 1
                color: "#006600"
                visible: temperature >= 0
                anchors
                {
                    verticalCenter: parent.verticalCenter;
                    left: zeroLine.horizontalCenter
                }
            }
            Rectangle
            {
                id: valueBarNeg
                width: Math.max (-temperature / root.tempSpan * parent.width - 2, 2)
                height: parent.height - 1
                color: "#000066"
                visible: temperature < 0
                anchors
                {
                    verticalCenter: parent.verticalCenter;
                    right: zeroLine.horizontalCenter
                }
            }
            // zero line - not visible, just for a reference for valueBar
            Rectangle
            {
                id: zeroLine
                width: 1
                height: root.height
                clip: true
                color: "white"
                visible: false
                anchors
                {
                    verticalCenter: parent.verticalCenter;
                    left: parent.left;  leftMargin: -root.minTemp / root.tempSpan * parent.width -2
                }
            }

			Text {
				font.pixelSize: 12
				font.bold: true
                text: root.temperature.toFixed (0) + "°C " + ((root.temperature * 9 / 5) + 32).toFixed (0) + "°F"
                anchors.centerIn: parent
				color: "white"
			}
		}
	}
}
