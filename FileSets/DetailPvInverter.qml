////// detail page for displaying battery details
////// pushed from Flow overview

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

MbPage
{
	id: root
 
    title: "PV Inverter detail"
    
    property variant sys: theSystem
    property string systemPrefix: "com.victronenergy.system"
    property color backgroundColor: "#b3b3b3"

    property int tableColumnWidth: 60
    property int rowTitleWidth: 130

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
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignLeft
                        text: qsTr("Total PV power") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Grid") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (sys.pvOnGrid.power, " W") }
                PowerGauge
                {
                    id: pvGridGauge
                    width: tableColumnWidth * 3.3
                    height: 15
                    connection: sys.pvOnGrid
                    maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/PvOnGridMaxPower"
                }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignLeft
                        text: qsTr("Total PV power") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Output") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (sys.pvOnAcOut.power, " W") }
                PowerGauge
                {
                    id: pvAcOutGauge
                    width: tableColumnWidth * 3.3
                    height: 15
                    connection: sys.pvOnAcOut
                    maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/PvOnOutputMaxPower"
                }
            }
           Row
            {
                id: tableHeaderRow
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Device Name") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Total") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L1" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L2" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L3" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth * 1.3; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Connection") }
            }

        }
    }

    // table of available PV Inverters
    ListView
    {
        id: pvInverterTable

        anchors
        {
            top: root.top; topMargin: 60
            horizontalCenter: root.horizontalCenter
        }
        width: tableHeaderRow.width
        height: root.height - 60
        interactive: true

        model: pvInverterModel
        delegate: PvInverterRow
        {
            tableColumnWidth: root.tableColumnWidth
            rowTitleWidth: root.rowTitleWidth
            width: pvInverterTable.width
            Connections
            {
                target: scrollTimer
                onTriggered: doScroll()
            }
        }
    }



    ListModel { id: pvInverterModel }

    // Synchronise name text scroll start
    Timer
    {
        id: scrollTimer
        interval: 15000
        repeat: true
        running: root.active
    }


    function addService(service)
    {
        switch (service.type)
        {
        case DBusService.DBUS_SERVICE_PV_INVERTER:
            pvInverterModel.append ( {serviceName: service.name} )
            break;;
        }
    }

    // Detect available services of interest
    function discoverServices()
    {
        pvInverterModel.clear()
        for (var i = 0; i < DBusServices.count; i++)
        {
            addService(DBusServices.at(i))
        }
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
}

