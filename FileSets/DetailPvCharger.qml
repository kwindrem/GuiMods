////// detail page for displaying PV charger details
////// pushed from Flow overview

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0
import "enhancedFormat.js" as EnhFmt

MbPage
{
	id: root
 
    title: "PV Charger detail"
    
    property variant sys: theSystem
    property string systemPrefix: "com.victronenergy.system"
    property color backgroundColor: "#b3b3b3"

    property int dataColumns: 4
    property int rowTitleWidth: 130
    property int totalDataWidth: root.width - rowTitleWidth - 20
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
        anchors.top: parent.top; anchors.topMargin: + 10
        Column 
        {
            spacing: 2
            Row
            {
				anchors.horizontalCenter: parent.horizontalCenter
				Text { id: totalLabel; font.pixelSize: 12; font.bold: true; color: "black"
						width: rowTitleWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Total power") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text: EnhFmt.formatVBusItem (sys.pvCharger.power) }                        
                PowerGauge
                {
                    id: gauge
                    width: totalDataWidth - tableColumnWidth
                    height: 15
                    connection: sys.pvCharger
                    maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/PvChargerMaxPower"
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
                        text: qsTr("Device Name") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Power") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("PV Voltage") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("PV Current") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("State") }
            }

        }
    }

    // table of available PV Chargers
    ListView
    {
        id: pvChargerTable

        anchors
        {
            top: root.top; topMargin: 60
            horizontalCenter: root.horizontalCenter
        }
        width: tableHeaderRow.width
        height: root.height - 60
        interactive: true

        model: pvChargerModel
        delegate: PvChargerRow
        {
            tableColumnWidth: root.tableColumnWidth
            rowTitleWidth: root.rowTitleWidth
            width: pvChargerTable.width
            Connections
            {
                target: scrollTimer
                onTriggered: doScroll()
            }
        }
    }



    ListModel { id: pvChargerModel }

    // Synchronise PV charger name text scroll start
    Timer
    {
        id: scrollTimer
        interval: 5000
        repeat: true
        running: root.active
    }

	VBusItem { id: numberOfTrackers;  bind: Utils.path(serviceName,"/NrOfTrackers") }
	property string serviceName: ""

    function addService(service)
    {
        switch (service.type)
        {
        case DBusService.DBUS_SERVICE_SOLAR_CHARGER:
			serviceName = service.name
			// for single tracker create a single charger row with tracker instance -1
            if ( ! numberOfTrackers.valid || numberOfTrackers.value == 1)
				pvChargerModel.append ( {serviceName: service.name, tracker: -1} )
			// create a separate charger row for each tracker
			else
			{
				var tracker
				pvChargerModel.append ( {serviceName: service.name, tracker: 0} )
				for ( tracker = 1; tracker <= numberOfTrackers.value; tracker++ )
					pvChargerModel.append ( {serviceName: service.name, tracker: tracker} )
			}
            break;;
        }
    }

    // Detect available services of interest
    function discoverServices()
    {
        pvChargerModel.clear()
        for (var i = 0; i < DBusServices.count; i++)
        {
            addService(DBusServices.at(i))
        }
    }
}

