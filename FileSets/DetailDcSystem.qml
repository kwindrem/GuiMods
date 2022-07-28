
////// detail page for displaying DC System details
////// pushed from Flow overview

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0
import "enhancedFormat.js" as EnhFmt

MbPage
{
	id: root
 
    title: "DC System detail"
    
    property variant sys: theSystem
    property string systemPrefix: "com.victronenergy.system"
    property color backgroundColor: "#b3b3b3"

    property int tableColumnWidth: 80
    property int rowTitleWidth: 130


	property int systemRows: Math.min (systemModel.count, 1)
	property int otherRows: otherModel.count
	property int totalTableRows: systemRows + otherRows

	property bool pvChargers: false

    VBusItem { id: dcSystemMeasurementItem; bind: "com.victronenergy.system/Dc/System/MeasurementType" }
	property bool dcSystemIsEstimated: ! dcSystemMeasurementItem.valid || dcSystemMeasurementItem.value != 1
	VBusItem { id: systemBatteryItem; bind: "com.victronenergy.system/Dc/Battery/BatteryService" }
	VBusItem { id: systemMultiItem; bind: "com.victronenergy.system/Ac/In/0/ServiceName" }
	VBusItem { id: flowOverviewItem; bind: "com.victronenergy.settings/Settings/GuiMods/FlowOverview" }
	property int flowOverview: flowOverviewItem.valid ? flowOverviewItem.value : 0

    Component.onCompleted: discoverServices()
 
	function adjustSystemTableHeight ()
	{
		if (totalTableRows < 9 || systemRows <= 3)
			systemTable.height = systemRows * 15
		else if (otherRows < 7)
			systemTable.height = (9 - otherRows) * 15
		else
			systemTable.height =  35
	}

    // When new service is found add it
    Connections
    {
        target: DBusServices
        onDbusServiceFound:
        {
			addService(service)	
			adjustSystemTableHeight ()
		}
    }

    // background
    Rectangle
    {
        anchors
        {
            fill: parent
        }
        color: root.backgroundColor
    }

	Column 
	{
		anchors
		{
			top: parent.top; topMargin: totalTableRows < 9 ? 10 : 5
			bottom: parent.bottom; bottomMargin: 5
		}
		spacing: 2
		Row
		{
			id: totalPowerRow
			anchors.horizontalCenter: parent.horizontalCenter
			Text { id: totalLabel; font.pixelSize: 12; font.bold: true; color: "black"
					horizontalAlignment: Text.AlignHCenter
					text: dcSystemIsEstimated ? qsTr("DC System power (est)") : qsTr("DC System power") }
			Text { id: totalPower; font.pixelSize: 12; font.bold: true; color: "black"
					width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
				text: EnhFmt.formatVBusItemAbs (sys.dcSystem.power) }
			PowerGauge
			{
				id: gauge
				width: (root.width * 0.9) - totalLabel.paintedWidth - totalPower.width
				height: 15
				showLabels: true
				endLabelColor: "black"
				connection: sys.dcSystem
				maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/DcSystemMaxLoad"
				maxReversePowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/DcSystemMaxCharge"
			}
		}
		Row
		{
			id: spacer1
			anchors.horizontalCenter: parent.horizontalCenter
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: rowTitleWidth; horizontalAlignment: Text.AlignHCenter
					text: "" }
			visible: totalTableRows < 8
		}
		Row
		{
			id: systemTableTitleRow
			anchors.horizontalCenter: parent.horizontalCenter
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: rowTitleWidth; horizontalAlignment: Text.AlignHCenter
					text: qsTr("Name") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: qsTr("Direction") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: qsTr("Power") }
		}
		Row {
			id: noSystemDevicesRow
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: root.width; horizontalAlignment: Text.AlignHCenter
					text: qsTr ("no DC system devces")
					visible: systemModel.count == 0 }
		}
		// table of system DC sources and loads
		ListView
		{
			id: systemTable

			anchors.horizontalCenter: systemTableTitleRow.horizontalCenter
			width: systemTableTitleRow.width
			height: 35 // adjusted later when rows are added to the two tables
			interactive: true
			clip: true
			model: systemModel
			delegate: DcSystemRow
			{
				tableColumnWidth: root.tableColumnWidth
				rowTitleWidth: root.rowTitleWidth
				width: systemTable.width
				showDirection: true
				Connections
				{
					target: scrollTimer
					onTriggered: doScroll()
				}
			}
		}
		Row
		{
			id: spacer2
			anchors.horizontalCenter: parent.horizontalCenter
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: rowTitleWidth; horizontalAlignment: Text.AlignHCenter
					text: "" }
			visible: totalTableRows < 9
		}
		Rectangle
		{
			id: separatorLine
			color: "black"
			anchors.horizontalCenter: parent.horizontalCenter
			width: otherTable.width
			height: 2
		}
		Row {
			id: otherDevicesTextRow
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: root.width; horizontalAlignment: Text.AlignHCenter
					text: qsTr ("other DC devices not shown on overview page") }
		}
		Row
		{
			id: otherTableTitleRow
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: rowTitleWidth; horizontalAlignment: Text.AlignHCenter
					text: qsTr("Name") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: qsTr("Device") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: qsTr("Direction") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: qsTr("Power") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: qsTr("State") }
		}
		// table of other DC sources and loads
		ListView
		{
			id: otherTable

			anchors.horizontalCenter: otherTableTitleRow.horizontalCenter
			width: otherTableTitleRow.width
			height: parent.height - y
			interactive: true
			clip: true
			model: otherModel
			delegate: DcSystemRow
			{
				tableColumnWidth: root.tableColumnWidth
				rowTitleWidth: root.rowTitleWidth
				width: otherTable.width
				showDevice: true
				showDirection: true
				showState: true
				Connections
				{
					target: scrollTimer
					onTriggered: doScroll()
				}
			}
		}
    }

    ListModel { id: systemModel }

    ListModel { id: otherModel }

    // Synchronise name text scroll start
    Timer
    {
        id: scrollTimer
        interval: 5000
        repeat: true
        running: root.active
    }

	property int numberOfInverters: 0

	// hack to get monitor mode from within a loop inside a function when service is changing
	property string tempServiceName: ""
	property VBusItem monitorModeItem: VBusItem { bind: Utils.path(tempServiceName, "/Settings/MonitorMode") }
	property int monitorMode: monitorModeItem.valid ? monitorModeItem.value : 0

    function addService (service)
    {
        switch (service.type)
        {
		case DBusService.DBUS_SERVICE_BATTERY:
			// skip THE system battery
			if (! systemBatteryItem.valid || service.name != systemBatteryItem.value)
				otherModel.append ( {serviceName: service.name, serviceType: service.type } )
            break;;

		case DBusService.DBUS_SERVICE_MULTI:
			// skip THE main Multi
			if (! systemMultiItem.valid || service.name != systemMultiItem.value)
				otherModel.append ( {serviceName: service.name, serviceType: service.type } )
            break;;
		case DBusService.DBUS_SERVICE_INVERTER:
			// skip if this the FIRST one unless a main Multi exists
			//	NOTE: the first one may not be THE system inverter but not sure how to figure that out exactly
			if (numberOfInverters > 0 || systemMultiItem.valid)
				otherModel.append ( {serviceName: service.name, serviceType: service.type } )
			numberOfInverters++
            break;;

		case DBusService.DBUS_SERVICE_ALTERNATOR:
		case DBusService.DBUS_SERVICE_AC_CHARGER:
        case DBusService.DBUS_SERVICE_FUELCELL:
			// skip if tile present in flow (flow == DC Coupled)
			if (flowOverview != 2)
				otherModel.append ( {serviceName: service.name, serviceType: service.type } )
			break;;

        case DBusService.DBUS_SERVICE_DCSYSTEM:
			systemModel.append ( {serviceName: service.name, serviceType: service.type } )
            break;;

        case DBusService.DBUS_SERVICE_DCSOURCE:
			root.tempServiceName = service.name
			// wind generator shown on DC and AC coupled overviews
			if (monitorMode != -8 || flowOverview < 2 )
				otherModel.append ( {serviceName: service.name, serviceType: service.type } )
			break;
        case DBusService.DBUS_SERVICE_DCLOAD:
			otherModel.append ( {serviceName: service.name, serviceType: service.type } )
            break;;
        }
    }

    // Detect available services of interest
    function discoverServices()
    {
		systemModel.clear()
		otherModel.clear()
        numberOfInverters = 0
        pvChargers = false
        for (var i = 0; i < DBusServices.count; i++)
            addService(DBusServices.at(i))

		adjustSystemTableHeight ()
    }
}
