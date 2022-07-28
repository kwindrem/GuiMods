// New for GuiMods to display temperature sensors
//  based on TileTank.qml
//  same tile sizes and look

import QtQuick 1.1
import "utils.js" as Utils
import "tanksensor.js" as TankSensor

Tile {
	id: root

	property string bindPrefix: serviceName
	property string alarmBase: Utils.path ("com.victronenergy.temprelay/Sensor/", serviceName.split(".")[3])
	property VBusItem alarmEnabledItem: VBusItem { bind: Utils.path ( alarmBase, "/Enabled" ) }
	property VBusItem condition1StateItem: VBusItem { bind: Utils.path ( alarmBase, "/0/State" ) }
	property VBusItem condition2StateItem: VBusItem { bind: Utils.path ( alarmBase, "/1/State" ) }
	property bool alarmEnabled: alarmEnabledItem.valid && alarmEnabledItem.value == 1
	property bool condition1Active: condition1StateItem.valid && condition1StateItem.value == 1
	property bool condition2Active: condition1StateItem.valid && condition2StateItem.value == 1
	property bool alarmActive: alarmEnabled & ( condition1Active || condition2Active )
	property bool alarmState: false

	// use system temperature scale if it exists (v2.90 onward) - otherwise use the GuiMods version
    property VBusItem systemScaleItem: VBusItem { bind: "com.victronenergy.settings/Settings/System/Units/Temperature" }
    property VBusItem guiModsTempScaleItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/TemperatureScale" }
    property int tempScale: systemScaleItem.valid ? systemScaleItem.value == "fahrenheit" ? 2 : 1 : guiModsTempScaleItem.valid ? guiModsTempScaleItem.value : 1

    // small tile height threshold
    property bool squeeze: height < 50

    property VBusItem temperatureItem: VBusItem { id: temperatureItem; bind: Utils.path(bindPrefix, "/Temperature") }
    property VBusItem humidityItem: VBusItem { id: humidityItem; bind: Utils.path(bindPrefix, "/Humidity") }
    property string humidityText: humidityItem.valid ? (" " + humidityItem.value.toFixed (0) + "%") : ""
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

    title: compact ? "" : tempName
	color: alarmActive && alarmState ? "red":  tempColor

	function doScroll()
	{
		nameText.doScroll()
		valueText.doScroll()
	}

	values: Item
    {
		width: root.width - 10
        height: compact ? root.height : squeeze ? 17 : 21

		MarqueeEnhanced
        {
			id: nameText
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
		MarqueeEnhanced
        {
			id: valueText
            width: root.width - 10 - (compact ? nameText.width : 0)
			height: compact ? 13 : parent.height
            text:
            {   
                if (root.temperature == -99)
                    return "--"
                else if (tempScale == 2)
                    return ((root.temperature * 9 / 5) + 32).toFixed (1) + "°F" + humidityText
                else
                    return root.temperature.toFixed (1) + "°C" + humidityText
            }
			textHorizontalAlignment: compact ? Text.AlignLeft : Text.AlignHCenter
			scroll: false
			anchors
            {
                verticalCenter: parent.verticalCenter; verticalCenterOffset: compact ? -9 : squeeze ? -4 : 0
                right: parent.right
			}
		}
	}

	Timer
	{
        id: alarmTimer
        interval: 1000
        repeat: true
        running: root.alarmActive
        onTriggered: root.alarmState = ! root.alarmState
	}
}
