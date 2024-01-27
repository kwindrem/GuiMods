// Display individual DC System services

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0
import "enhancedFormat.js" as EnhFmt

Row {
	id: root

//	parameters passed in .append:
//		serviceName
//		serviceType
//		instance

//	instance is a zero-based number indicitng the main (0)
//		or sub-unit (1, etc)
//	each instance is appended separately and the row content
//		is differnet for instance 0 than for other instances

	property bool isBattery: false
	property bool isMotorDrive: false
	property string direction: ""
	property bool useMonitorMode: false
	property bool positivePowerIsConsuming: false

	// column widths - passed from parent
	// caller can omit widths for columns that should not show or set the width to 0
    property int nameColumnWidth: 0
    property int deviceColumnWidth: 0
    property int directionColumnWidth: 0
    property int powerColumnWidth: 0
    property int voltageColumnWidth: 0
    property int currentColumnWidth: 0
    property int stateColumnWidth: 0
    property int temperatureColumnWidth: 0
    property int rpmColumnWidth: 0
    property int outputColumnWidth: 0

	property string speedParam: "/Speed"

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
			isMotorDrive = true
		}
	}


	VBusItem { id: monitorModeItem; bind: Utils.path(serviceName, "/Settings/MonitorMode") }
	property int monitorMode: monitorModeItem.valid ? monitorModeItem.value : 0

    VBusItem { id: customNameItem; bind: Utils.path(serviceName, "/CustomName") }
    VBusItem { id: productNameItem; bind: Utils.path(serviceName, "/ProductName") }
	VBusItem { id: dbusPowerItem; bind: Utils.path (serviceName, "/Dc/", instance, "/Power") }
	VBusItem { id: dbusVoltageItem; bind: Utils.path (serviceName, "/Dc/", instance, "/Voltage") }
	VBusItem { id: dbusCurrentItem; bind: Utils.path (serviceName, "/Dc/", instance, "/Current") }
	VBusItem { id: dbusTemperatureItem; bind: Utils.path (serviceName, isMotorDrive ? "/Motor/Temperature" : "/Dc/" + instance + "/Temperature") }
	VBusItem { id: stateItem; bind: Utils.path (serviceName, "/State") }
	VBusItem { id: rpmItem; bind: Utils.path (serviceName, speedParam) }

	// use system temperature scale if it exists (v2.90 onward) - otherwise use the GuiMods version
    property VBusItem systemScaleItem: VBusItem { bind: "com.victronenergy.settings/Settings/System/Units/Temperature" }
    property VBusItem guiModsTempScaleItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/TemperatureScale" }
    property int tempScale: systemScaleItem.valid ? systemScaleItem.value == "fahrenheit" ? 2 : 1 : guiModsTempScaleItem.valid ? guiModsTempScaleItem.value : 1

	SystemStateShort
	{
		id: stateTranslation
		bind: Utils.path (serviceName, "/State")
	}

    function doScroll()
    {
        name.doScroll()
		device.doScroll()
        state.doScroll()
    }

    MarqueeEnhanced
    {
        id: name
        width: nameColumnWidth
        height: parent.height
        text:
        {
			if (instance > 0) // show only for first instance
				return ""
            else if (customNameItem.valid && customNameItem.value != "")
				return customNameItem.value
			else if (productNameItem.valid)
				return productNameItem.value
			else
				return ""
		}
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
    MarqueeEnhanced
    {
		id: device
        width: deviceColumnWidth
        height: parent.height
		text: instance == 0 ? formatDeviceType () : " " // show only for first instance
        fontSize: 12
        textColor: "black"
        bold: true
        textHorizontalAlignment: Text.AlignHCenter
        scroll: false
        anchors
        {
            verticalCenter: parent.verticalCenter
        }
		visible: deviceColumnWidth > 0
    }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: directionColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: instance == 0 ? formatDirection () : " " // show only for first instance
            visible: directionColumnWidth > 0 }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: outputColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: (instance + 1).toString()
            visible: outputColumnWidth > 0 }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: powerColumnWidth; horizontalAlignment: Text.AlignHCenter
            text:
            {
				if (dbusPowerItem.valid)
					return formatValue (dbusPowerItem.value, "W")
				else if (dbusVoltageItem.valid && dbusCurrentItem.valid)
					return formatValue (dbusVoltageItem.value * dbusCurrentItem.value, "W")
				else
					return ""
			}
            visible: powerColumnWidth > 0 }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: voltageColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: formatItem (dbusVoltageItem, "V")
            visible: voltageColumnWidth > 0 }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: currentColumnWidth; horizontalAlignment: Text.AlignHCenter
            text:
            {
				if (dbusCurrentItem.valid)
					return formatValue (dbusCurrentItem.value, "A")
				else if (dbusVoltageItem.valid && dbusPowerItem.valid)
					return formatValue (dbusPowerItem.value / dbusVoltageItem.value, "A")
				else
					return ""
			}
            visible: currentColumnWidth > 0
	}
    MarqueeEnhanced
    {
        id: state
        width: stateColumnWidth
        height: parent.height
        text: instance == 0 ? formatState () : "" // show state only for first instance
        fontSize: 12
        textColor: "black"
        bold: true
        textHorizontalAlignment: Text.AlignHCenter
        scroll: false
        visible: stateColumnWidth > 0
        anchors
        {
            verticalCenter: parent.verticalCenter
        }
    }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: temperatureColumnWidth; horizontalAlignment: Text.AlignHCenter
            text:
            {
				if (! dbusTemperatureItem.valid || instance != 0) // show only for first instance
					return ""
                else if (tempScale == 2)
                    return ((dbusTemperatureItem.value * 9 / 5) + 32).toFixed (1) + " °F"
                else
                    return dbusTemperatureItem.value.toFixed (1) + " °C"
			}
			visible: temperatureColumnWidth > 0 }


    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: rpmColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: rpmItem.valid && instance == 0 ? rpmItem.value : "" // show rpm only for first instance
            visible: rpmColumnWidth > 0 }


    function formatItem (item, unit)
    {
        var value
        if (item.valid)
        {
			value = item.value
			if (directionColumnWidth > 0 && value < 0)
				value = -value

			return EnhFmt.formatValue (value, unit)
		}
        else
        {
            return ""
		}
	}

    function formatValue (value, unit)
    {
		if (directionColumnWidth > 0 && value < 0)
			value = -value

		return EnhFmt.formatValue (value, unit)
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
					return qsTr ("AC charger")
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
					return qsTr ("AC Charger")
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
