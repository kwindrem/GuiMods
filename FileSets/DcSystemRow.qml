// Display individual DC System services

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0
import "enhancedFormat.js" as EnhFmt

Row {
	id: root

	property bool isBattery: false
	property string direction: ""
	property bool useMonitorMode: false
	property bool positivePowerIsConsuming: false

	// passed from parent
	property bool showDevice: false
	property bool showDirection: false
	property bool showState: false
	property bool showTemperature: false
	property bool showRpm: false
	property bool showVoltage: false
	property bool showCurrent: false
	property string speedParam: "/Speed"
	property string temperatureParam: "/Dc/0/Temperature"


    Component.onCompleted:
    {
		if (serviceType == DBusService.DBUS_SERVICE_DCSYSTEM)
		{
			positivePowerIsConsuming = true
		}
		else if (serviceType == DBusService.DBUS_SERVICE_BATTERY)
		{
			isBattery = true
			positivePowerIsConsuming = true
		}
		else if (serviceType == DBusService.DBUS_SERVICE_DCSOURCE)
		{
			useMonitorMode = true
			positivePowerIsConsuming = false
		}
		else if (serviceType == DBusService.DBUS_SERVICE_DCLOAD)
		{
			useMonitorMode = true
			positivePowerIsConsuming = true
		}
		else if (serviceType == DBusService.DBUS_SERVICE_MOTOR_DRIVE)
		{
			positivePowerIsConsuming = true
			speedParam = "/Motor/RPM"
			temperatureParam = "/Motor/Temperature"
		}
	}

    // uses the same sizes as DetailsDcSystem page
    property int tableColumnWidth: 0
    property int rowTitleWidth: 0

	VBusItem { id: monitorModeItem; bind: Utils.path(serviceName, "/Settings/MonitorMode") }
	property int monitorMode: monitorModeItem.valid ? monitorModeItem.value : 0

    VBusItem { id: customNameItem; bind: Utils.path(serviceName, "/CustomName") }
    VBusItem { id: productNameItem; bind: Utils.path(serviceName, "/ProductName") }
	VBusItem { id: dbusPowerItem; bind: Utils.path (serviceName, "/Dc/0/Power") }
	VBusItem { id: dbusVoltageItem; bind: Utils.path (serviceName, "/Dc/0/Voltage") }
	VBusItem { id: dbusCurrentItem; bind: Utils.path (serviceName, "/Dc/0/Current") }
	VBusItem { id: dbusTemperatureItem; bind: Utils.path (serviceName, "/Dc/0/Temperature") }
	VBusItem { id: stateItem; bind: Utils.path (serviceName, temperatureParam) }
	VBusItem { id: rpmItem; bind: Utils.path (serviceName, speedParam) }

	// use system temperature scale if it exists (v2.90 onward) - otherwise use the GuiMods version
    property VBusItem systemScaleItem: VBusItem { bind: "com.victronenergy.settings/Settings/System/Units/Temperature" }
    property VBusItem guiModsTempScaleItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/TemperatureScale" }
    property int tempScale: systemScaleItem.valid ? systemScaleItem.value == "fahrenheit" ? 2 : 1 : guiModsTempScaleItem.valid ? guiModsTempScaleItem.value : 1



    property string rowName: customNameItem.valid && customNameItem.value != "" ? customNameItem.value : productNameItem.valid ? productNameItem.value : ""

	SystemStateShort
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
        text: rowName
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
            text: formatDeviceType ()
            visible: showDevice }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: formatDirection ()
            visible: showDirection }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: formatItem (dbusPowerItem, "W") }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: formatItem (dbusVoltageItem, "V")
            visible: showVoltage }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: formatItem (dbusCurrentItem, "A")
            visible: showCurrent }
    MarqueeEnhanced
    {
        id: state
        width: tableColumnWidth
        height: parent.height
        text: formatState ()
        fontSize: 12
        textColor: "black"
        bold: true
        textHorizontalAlignment: Text.AlignHCenter
        scroll: false
        visible: showState
        anchors
        {
            verticalCenter: parent.verticalCenter
        }
    }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text:
            {
				if (! dbusTemperatureItem.valid)
					return ""
                else if (tempScale == 2)
                    return ((dbusTemperatureItem.value * 9 / 5) + 32).toFixed (1) + " °F"
                else
                    return dbusTemperatureItem.value.toFixed (1) + " °C"
			}
			visible: showTemperature }


    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: rpmItem.valid ? rpmItem.value : ""
            visible: showRpm }


    function formatItem (item, unit)
    {
        var value
        if (item.valid)
        {
			value = item.value
			if (showDirection && value < 0)
				power = -power

			return EnhFmt.formatValue (value, unit)
		}
        else
        {
            return ""
		}
	}

	// show no direction if power is small
	function formatDirection ()
	{
        var power
        if (dbusPowerItem.valid)
        {
            power = dbusPowerItem.value
            if (positivePowerIsConsuming)
				power = -power
			if (power > 1)
				return qsTr ("supplying")
			else if (power < -1)
				return qsTr ("consuming")
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

	function formatDeviceType ()
	{
		if (useMonitorMode)
		{
			switch (monitorMode)
			{
				case -1:
					return qsTr ("Source")
				case -2:
					return qsTr ("AC Charger")
				case -3:
					return qsTr ("DC-DC charger")
				case -4:
					return qsTr ("Water gen")
				case -6:
					return qsTr ("Alternator")
				case -8:
					return qsTr ("Wind gen")
				case -7:
					return qsTr ("Shaft gen")

				case 1:
					return qsTr ("Load")
				case 3:
					return qsTr ("Fridge")
				case 4:
					return qsTr ("Water pump")
				case 5:
					return qsTr ("Bilge pump")
				case 7:
					return qsTr ("Inverter")
				case 8:
					return qsTr ("Water heater")
				default:
					return qsTr ("unknown mode")
			}
		}
		else
		{
			switch (serviceType)
			{
				case DBusService.DBUS_SERVICE_BATTERY:
					return qsTr ("Battery")
				case DBusService.DBUS_SERVICE_MULTI:
					return qsTr ("Multi")
				case DBusService.DBUS_SERVICE_INVERTER:
					return qsTr ("Inverter")
				case DBusService.DBUS_SERVICE_ALTERNATOR:
					return qsTr ("Alternator")
				case DBusService.DBUS_SERVICE_FUELCELL:
					return qsTr ("Fuel Dell")
				case DBusService.DBUS_SERVICE_AC_CHARGER:
					return qsTr ("AC Dharger")
				case DBusService.DBUS_SERVICE_DCSYSTEM:
					return qsTr ("DC System")
				case DBusService.DBUS_SERVICE_MULTI_RS:
					return qsTr ("Multi RS")
				default:
					return qsTr ("unknown")
			}
		}
	}
}
