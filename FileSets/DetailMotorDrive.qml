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

    property int nameColumnWidth: 130
    property int tableColumnWidth: 80
    property int directionColumnWidth: tableColumnWidth
    property int powerColumnWidth: tableColumnWidth
    property int temperatureColumnWidth: tableColumnWidth
    property int rpmColumnWidth: tableColumnWidth

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
                Text { id: totalPower; font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text: EnhFmt.formatVBusItem (motorDrivePowerItem, "W")
                }
                PowerGauge
                {
                    id: gauge
					width: (root.width * 0.9) - totalLabel.width - totalPower.width
                    height: 15
                    connection: motorDrivePowerItem
					maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxMotorDriveLoad"
					maxReversePowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxMotorDriveCharge"
                }
			}
            // vertical spacer
            Row { Text { font.pixelSize: 12; width: nameColumnWidth; text: "" } }
            Row
            {
                id: tableHeaderRow
				anchors.horizontalCenter: parent.horizontalCenter
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: nameColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Name") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: directionColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: qsTr("Direction") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: powerColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Power") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: temperatureColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Temperature") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rpmColumnWidth; horizontalAlignment: Text.AlignHCenter
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
            width: theTable.width
            nameColumnWidth: root.nameColumnWidth
			directionColumnWidth: root.directionColumnWidth
			powerColumnWidth: root.powerColumnWidth
			temperatureColumnWidth: root.temperatureColumnWidth
			rpmColumnWidth: root.rpmColumnWidth
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
        case DBusService.DBUS_SERVICE_MOTOR_DRIVE:
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
