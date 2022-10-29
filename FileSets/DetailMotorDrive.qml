////// detail page for displaying Motor Drive details
////// pushed from Flow overview

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0
import "enhancedFormat.js" as EnhFmt

MbPage
{
	id: root
 
    title: "Motor Drive detail"
    
    property variant sys: theSystem
    property string systemPrefix: "com.victronenergy.system"
    property color backgroundColor: "#b3b3b3"

    property int rowTitleWidth: 130
    property int tableColumnWidth: 100
    property int totalDataWidth: tableColumnWidth * 3

	VBusItem { id: motorDrivePowerItem; bind: Utils.path(systemPrefix, "/Dc/MotorDrive/Power") }

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
				anchors.horizontalCenter: parent.horizontalCenter
                Text { id: totalLabel; font.pixelSize: 12; font.bold: true; color: "black"
                    horizontalAlignment: Text.AlignRight
                    text: qsTr("Total Power") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text: EnhFmt.formatVBusItem (motorDrivePowerItem, " W")
                }
                PowerGauge
                {
                    id: gauge
                    width: (root.width * 0.8) - totalLabel.paintedWidth - tableColumnWidth
                    height: 15
                    connection: motorDrivePowerItem
					maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxMotorDriveLoad"
					maxReversePowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxMotorDriveCharge"
                }
			}
            // vertical spacer
            Row { Text { font.pixelSize: 12; width: rowTitleWidth; text: "" } }
            Row
            {
                id: tableHeaderRow
				anchors.horizontalCenter: parent.horizontalCenter
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Name") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Power") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Temperature") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("RPM") }
            }
        }
    }

    // table of available alternators
    ListView
    {
        id: theTable

        anchors
        {
            top: root.top; topMargin: 60
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
            width: theTable.width
            showTemperature: true
            showRpm: true
            Connections
            {
                target: scrollTimer
                onTriggered: doScroll()
            }
        }
    }

    ListModel { id: dcModel }

    // Synchronise name text scroll start
    Timer
    {
        id: scrollTimer
        interval: 5000
        repeat: true
        running: root.active
    }

    function addService(service)
    {
        switch (service.type)
        {
        case DBusService.DBUS_SERVICE_ALTERNATOR:
			dcModel.append ( {serviceName: service.name, serviceType: service.type } )
            break;;
        }
    }

    // Detect available services of interest
    function discoverServices()
    {
		dcModel.clear()
        for (var i = 0; i < DBusServices.count; i++)
        {
            addService(DBusServices.at(i))
        }
    }
}
