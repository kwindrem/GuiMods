// New for GuiMods to display digital inputs
//  based on TileTank.qml

import QtQuick 1.1
import "utils.js" as Utils
import "tanksensor.js" as TankSensor

Tile {
	id: root

	property string bindPrefix: serviceName
    property VBusItem nameItem: VBusItem { bind: Utils.path(bindPrefix, "/CustomName") }
    property VBusItem deviceItem: VBusItem { bind: Utils.path(bindPrefix, "/DeviceInstance") }
    property VBusItem aggregateItem: VBusItem { bind: Utils.path(bindPrefix, "/Aggregate") }
    property string digInName: nameItem.valid && nameItem.value != "" ? nameItem.value : getType (type)
    property VBusItem typeItem: VBusItem { bind: Utils.path(bindPrefix, "/Type") }
    property VBusItem stateItem: VBusItem { bind: Utils.path(bindPrefix, "/State") }
	property bool isPulseCounter: aggregateItem.valid
	// pulse counter doesn't have /Type so fill it in here
    property int type: isPulseCounter ? 1 : typeItem.valid ? typeItem.value : 0

    property variant bkgdColors: [ "#b3b3b3", "#4aa3df", "#1abc9c", "#F39C12", "#95a5a6", "#95a5a6","#dcc6e0", "#f1a9a0", "#7f8c8d", "#ebbc3a" ]
    property color bkgdColor: type > 0 && type < 10 ? bkgdColors [type] : "#b3b3b3"
	property variant units: ["m<sup>3</sup>", "L", "gal", "gal"]


	function getType(type)
	{
		switch (type)
		{
		case 0:
			return qsTr("Disabled")
		case 1:
			return qsTr("Pulse meter")
		case 2:
			return qsTr("Door alarm")
		case 3:
			return qsTr("Bilge pump")
		case 4:
			return qsTr("Bilge alarm")
		case 5:
			return qsTr("Burglar alarm")
		case 6:
			return qsTr("Smoke alarm")
		case 7:
			return qsTr("Fire alarm")
		case 8:
			return qsTr("CO2 alarm")
		case 9:
			return qsTr("Generator")
		case 10:
			return qsTr("Generic I/O")
//// added for ExtTransferSwitch package
		case 11:
			return qsTr("Transfer switch")
		default:
			return "Unknown"
		}
	}

	function getState(st)
	{
		switch (st)
		{
		case 0:
			return qsTr("Low")
		case 1:
			return qsTr("High")
		case 2:
			return qsTr("Off")
		case 3:
			return qsTr("On")
		case 4:
			return qsTr("No")
		case 5:
			return qsTr("Yes")
		case 6:
			return qsTr("Open")
		case 7:
			return qsTr("Closed")
		case 8:
			return qsTr("Ok")
		case 9:
			return qsTr("Alarm")
		case 10:
			return qsTr("Running")
		case 11:
			return qsTr("Stopped")
//// added for ExtTransferSwitch package
		case 12:
			return qsTr("On Generator")
		case 13:
			return qsTr("On Grid")
		default:
			return qsTr("Unknown")
		}

	}

    title: digInName + " (In " + (deviceItem.valid ? (deviceItem.value.toString ()) : "?") + ")"

	color: bkgdColor

	VBusItem
	{
		id: unitItem
		bind: Utils.path("com.victronenergy.settings/Settings/System/VolumeUnit")
	}

	values: Item
    {
		width: root.width - 10
        height: 12
		TileText
        {
            width: root.width
            text:
            {
				if (isPulseCounter)
					return aggregateItem.value.toString() + (unitItem.valid ? units[unitItem.value] : "??")
				else
					return stateItem.valid ? getState (stateItem.value) : "??"
			}
			horizontalAlignment: Text.AlignHCenter
			anchors
            {
                horizontalCenter: parent.horizontalCenter
			}
		}
	}
}
