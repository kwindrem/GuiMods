////// detail page for displaying battery details
////// pushed from Flow overview

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0
import "enhancedFormat.js" as EnhFmt

MbPage
{
	id: root
 
    title: "PV Inverter detail"
    
    property variant sys: theSystem
    property string systemPrefix: "com.victronenergy.system"
    property color backgroundColor: "#b3b3b3"

	property int gridPhaseCount: sys.pvOnGrid.phaseCount.valid ? sys.pvOnGrid.phaseCount.value : 0
	property int outputPhaseCount: sys.pvOnAcOut.phaseCount.valid ? sys.pvOnAcOut.phaseCount.value : 0
	property int phaseCount: Math.max (gridPhaseCount, outputPhaseCount, 1)
    property int dataColumns: 2 + phaseCount
    property int rowTitleWidth: 130
    property int totalDataWidth: root.width - rowTitleWidth - 10
    property int tableColumnWidth: totalDataWidth / dataColumns

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
        anchors.top: parent.top; anchors.topMargin: 5
        Column 
        {
            spacing: 2
           Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr(" ") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Total") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L1"; visible: phaseCount > 1 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L2"; visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L3"; visible: phaseCount >= 3 }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("Grid") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.pvOnGrid.power) }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.pvOnGrid.powerL1); visible: phaseCount > 1 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.pvOnGrid.powerL2); visible: phaseCount >= 2}
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.pvOnGrid.powerL3); visible: phaseCount >= 3}
                PowerGauge
                {
                    id: pvGridGauge
                    width: tableColumnWidth
                    height: 15
                    connection: sys.pvOnGrid
                    maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/PvOnGridMaxPower"
                    visible: sys.pvOnGrid.power.valid
                }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("Output") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.pvOnAcOut.power) }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.pvOnAcOut.powerL1); visible: phaseCount > 1 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.pvOnAcOut.powerL2); visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.pvOnAcOut.powerL3); visible: phaseCount >= 3 }
                PowerGauge
                {
                    id: pvAcOutGauge
                    width: tableColumnWidth
                    height: 15
                    connection: sys.pvOnAcOut
                    maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/PvOnOutputMaxPower"
                    visible: sys.pvOnAcOut.power.valid
                }
            }
			Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr(" ") }
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
                        text: "L1"; visible: phaseCount > 1 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L2"; visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L3"; visible: phaseCount >= 3 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
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
            top: root.top; topMargin: 93
            horizontalCenter: root.horizontalCenter
        }
        width: tableHeaderRow.width
        height: root.height - 93
        interactive: true

        model: pvInverterModel
        delegate: PvInverterRow
        {
            tableColumnWidth: root.tableColumnWidth
            rowTitleWidth: root.rowTitleWidth
			phaseCount: root.phaseCount
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
}

