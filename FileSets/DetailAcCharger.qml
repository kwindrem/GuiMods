////// detail page for displaying AC Charger details
////// pushed from Flow overview

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0
import "enhancedFormat.js" as EnhFmt

MbPage
{
	id: root
 
    title: "AC Charger detail"
    
    property variant sys: theSystem
    property string systemPrefix: "com.victronenergy.system"
    property color backgroundColor: "#b3b3b3"

    property int tableColumnWidth: 80
    property int nameColumnWidth: 130
    property int powerColumnWidth: tableColumnWidth
    property int currentColumnWidth: tableColumnWidth
    property int voltageColumnWidth: tableColumnWidth
    property int stateColumnWidth: tableColumnWidth

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
                    text: EnhFmt.formatVBusItem (sys.acCharger.power)
                }
                PowerGauge
                {
                    id: gauge
                    width: (root.width * 0.9) - nameColumnWidth - tableColumnWidth
                    height: 15
                    connection: sys.acCharger
                    reversePower: true
					maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxAcChargerPower"
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
                        width: powerColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Power") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: voltageColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Voltage") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: currentColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Current") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: stateColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("State") }
            }
        }
    }

    // table of available AC chargers
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
			powerColumnWidth: root.powerColumnWidth
			voltageColumnWidth: root.voltageColumnWidth
			currentColumnWidth: root.currentColumnWidth
			stateColumnWidth: root.stateColumnWidth
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
        case DBusService.DBUS_SERVICE_AC_CHARGER:
			dcModel.append ( {serviceName: service.name, serviceType: service.type} )
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
