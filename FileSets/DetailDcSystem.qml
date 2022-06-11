////// detail page for displaying DC System details
////// pushed from Flow overview

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

MbPage
{
	id: root
 
    title: "DC System detail"
    
    property variant sys: theSystem
    property string systemPrefix: "com.victronenergy.system"
    property color backgroundColor: "#b3b3b3"

    property int tableColumnWidth: 80
    property int rowTitleWidth: 130

	property bool pvChargers: false

    VBusItem { id: hasDcSysItem; bind: "com.victronenergy.settings/Settings/SystemSetup/HasDcSystem" }
    property bool hasDcSystem: hasDcSysItem.value > 0

    Component.onCompleted: discoverServices()

    // background
    Rectangle
    {
        anchors
        {
            fill: parent
        }
        color: root.backgroundColor
    }

    Row
    {
        spacing: 5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top; anchors.topMargin: + 10
        Column 
        {
            spacing: 2
            Row
            {
                id: tableHeaderRow
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Name") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Device") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Power") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("State") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Direction") }
            }
        }
    }

    // table of available DC sources and loads
    ListView
    {
        id: dcTable

        anchors
        {
            top: root.top; topMargin: 30
            horizontalCenter: root.horizontalCenter
        }
        width: tableHeaderRow.width
        height: root.height - 60
        interactive: true

        model: dcModel
        delegate: DcSystemRow
        {
            tableColumnWidth: root.tableColumnWidth
            rowTitleWidth: root.rowTitleWidth
            width: dcTable.width
            Connections
            {
                target: scrollTimer
                onTriggered: doScroll()
            }
        }
    }

    ListModel { id: dcModel }

    // Synchronise PV charger name text scroll start
    Timer
    {
        id: scrollTimer
        interval: 15000
        repeat: true
        running: root.active
    }

    function addService(service)
    {
		var monitorMode = ""
        switch (service.type)
        {
		case DBusService.DBUS_SERVICE_BATTERY:
			dcModel.append ( {serviceName: service.name, deviceType: "Battery"} )
            break;;
        case DBusService.DBUS_SERVICE_DCSOURCE:
			monitorMode = getMonitorMode (service.name)
			if (monitorMode != "")
				dcModel.append ( {serviceName: service.name, deviceType: monitorMode} )
			else
				dcModel.append ( {serviceName: service.name, deviceType: "Source"} )
            break;;
        case DBusService.DBUS_SERVICE_DCLOAD:
			monitorMode = getMonitorMode (service.name)
			if (monitorMode != "")
				dcModel.append ( {serviceName: service.name, deviceType: monitorMode} )
			else
				dcModel.append ( {serviceName: service.name, deviceType: "Load"} )
            break;;
        case DBusService.DBUS_SERVICE_DCSYSTEM:
			dcModel.append ( {serviceName: service.name, deviceType: "DC System"} )
            break;;
        case DBusService.DBUS_SERVICE_MULTI:
			dcModel.append ( {serviceName: service.name, deviceType: "Multi"} )
            break;;
		case DBusService.DBUS_SERVICE_MULTI_RS:
			pvChargers = true
			dcModel.append ( {serviceName: service.name, deviceType: "Multi RS"} )
            break;;
		case DBusService.DBUS_SERVICE_INVERTER:
			dcModel.append ( {serviceName: service.name, deviceType: "Inverter"} )
            break;;
        case DBusService.DBUS_SERVICE_ALTERNATOR:
			dcModel.append ( {serviceName: service.name, deviceType: "Altenator"} )
            break;;
        case DBusService.DBUS_SERVICE_SOLAR_CHARGER:
			pvChargers = true
            break;;
        case DBusService.DBUS_SERVICE_FUELCELL:
			dcModel.append ( {serviceName: service.name, deviceType: "Fuel Cell"} )
		case DBusService.DBUS_SERVICE_AC_CHARGER:
 			dcModel.append ( {serviceName: service.name, deviceType: "AC Charger"} )
           break;;
        }
    }

    // Detect available services of interest
    function discoverServices()
    {
        dcModel.clear()
        pvChargers = false
        for (var i = 0; i < DBusServices.count; i++)
        {
            addService(DBusServices.at(i))
        }
		if (pvChargers)
			dcModel.append ( {serviceName: "", deviceType: "PV Chargers"} )
		dcModel.append ( {serviceName: "", deviceType: "(unknown)"} )
    }

    function formatValue (item, unit)
    {
        var value
        if (item.valid)
        {
            value = item.value
            if (value < 100)
                return value.toFixed (1) + unit
            else
                return value.toFixed (0) + unit
        }
        else
            return ""
    }

	property string serviceName: ""
	property VBusItem monitorMode: VBusItem { bind: Utils.path(serviceName, "/Settings/MonitorMode") }
	
	function getMonitorMode (serviceName)
	{
		root.serviceName = serviceName
		if (monitorMode.valid)
		{
			switch (monitorMode.value)
			{
				case -1:
					return qsTr ("Source")
					break;;
				case -2:
					return qsTr ("AC Charger")
					break;;
				case -3:
					return qsTr ("DC-DC charger")
					break;;
				case -4:
					return qsTr ("Water gen")
					break;;
				case -6:
					return qsTr ("Alternator")
					break;;
				case -8:
					return qsTr ("Wind gen")
					break;;
				case -7:
					return qsTr ("Shaft gen")
					break;;

				case 1:
					return qsTr ("Load")
					break;;
				case 3:
					return qsTr ("Fridge")
					break;;
				case 4:
					return qsTr ("Water pump")
					break;;
				case 5:
					return qsTr ("Bilge pump")
					break;;
				case 7:
					return qsTr ("Inverter")
					break;;
				case 8:
					return qsTr ("Water heater")
					break;;
				default:
					return ("")
					break;;
			}
		}
		else
			return ""
	}
}
