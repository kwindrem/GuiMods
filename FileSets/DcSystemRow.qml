// Display individual DC System services

import QtQuick 1.1
import "utils.js" as Utils

Row {
	id: root

    Component.onCompleted:
    {
		if (deviceType == "PV Chargers")
		{
			powerItem = sys.pvCharger.power
			isPvCharger = true
		}
		else if (deviceType == "(unknown)")
		{
			powerItem = sys.dcSystem.power
			reversePower = true
		}
		else if (deviceType == "Battery")
		{
			reversePower = true
			isBattery = true
		}
	}

	property bool isPvCharger: false
	property bool isBattery: false
	property string direction: ""
	property bool reversePower: false

    // uses the same sizes as DetailsDcSystem page
    property int tableColumnWidth: 0
    property int rowTitleWidth: 0

    VBusItem { id: customNameItem; bind: Utils.path(serviceName, "/CustomName") }
	VBusItem { id: dbusPowerItem; bind: Utils.path (serviceName, "/Dc/0/Power") }
	VBusItem { id: stateItem; bind: Utils.path (serviceName, "/State") }
	property VBusItem powerItem: dbusPowerItem

    property string customName: customNameItem.valid ? customNameItem.value : ""

	SystemState
	{
		id: stateTranslation
		bind: Utils.path (serviceName, "/State")
	}

    function doScroll()
    {
        name.doScroll()
    }

    MarqueeEnhanced
    {
        id: name
        width: rowTitleWidth
        height: parent.height
        text: customName
        fontSize: 12
        textColor: "black"
        bold: true
        textHorizontalAlignment: Text.AlignLeft
        scroll: false
        anchors
        {
            verticalCenter: parent.verticalCenter
        }
    }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: deviceType }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: formatPower () }
    MarqueeEnhanced
    {
        id: value
        width: tableColumnWidth
        height: parent.height
        text: formatDirection ()
        fontSize: 12
        textColor: "black"
        bold: true
        textHorizontalAlignment: Text.AlignHCenter
        scroll: false
        anchors
        {
            verticalCenter: parent.verticalCenter
        }
    }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: formatDirection () }

    function formatPower ()
    {
        var power
        if (powerItem.valid)
        {
            power = powerItem.value
            if (reversePower)
				power = -power
			if (power > 0)
			{
				if (power < 100)
					return power.toFixed (1) + " W"
				else
					return power.toFixed (0) + " W"
			}
			else if (power < 0)
			{
				if (power > -100)
					return power.toFixed (1) + " W"
				else
					return power.toFixed (0) + " W"
			}
			else
			{
				return "0 W"
			}
        }
        else
        {
            return ""
		}
	}

	function formatDirection ()
	{
        var power
		if (isPvCharger)
			return "Supplying"
        if (powerItem.valid)
        {
            power = powerItem.value
            if (reversePower)
				power = -power
			if (power > 0)
				return "Supplying"
			else if (power < 0)
				return "Consuming"
			else
				return ""
        }
        else
            return ""
	}

	function formatState ()
	{
		if ( ! stateItem.valid)
			return ""
		if (isBattery)
		{
			switch (stateItem.value)
			{
				case 0:
				case 1:
				case 2:
				case 3:
				case 4:
				case 5:
				case 6:
				case 7:
				case 8:
					return qsTr ("Initializing")
				case 9:
					return qsTr ("Running")
				case 10:
					return qsTr ("Error")
				case 11:
					return qsTr ("Unknown")
				case 12:
					return qsTr ("Shutdown")
				case 13:
					return qsTr ("Updating")
				case 14:
					return qsTr ("Standby")
				case 15:
					return qsTr ("Going to run")
				case 16:
					return qsTr ("Pre-Charging")
				case 17:
					return qsTr ("Contactor check")
				default:
						return qsTr ("???")
			
			}
		}
		else
			return stateTranslation.text
	}
}
