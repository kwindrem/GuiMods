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
    property int outputColumnWidth: 60
    property int powerColumnWidth: 60
    property int currentColumnWidth: 60
    property int voltageColumnWidth: 60
    property int stateColumnWidth: tableColumnWidth

	property bool multipleOutputWaring: false

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
                        width: outputColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Output") }
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

			// table of available AC chargers
			ListView
			{
				id: theTable

				width: tableHeaderRow.width
				height: root.height - 100
				interactive: true

				model: dcModel
				delegate: DcSystemRow
				{
					width: theTable.width
					nameColumnWidth: root.nameColumnWidth
					outputColumnWidth: root.outputColumnWidth
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
            // vertical spacer
            Row { Text { font.pixelSize: 12; width: nameColumnWidth; text: "" } }
			Row
			{
				Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: tableHeaderRow.width; horizontalAlignment: Text.AlignHCenter
					text: qsTr ("only #1 output is included in system totals")
					visible: multipleOutputWaring
				}
				
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

	VBusItem { id: numberOfOutputsItem;  bind: Utils.path(serviceName,"/NrOfOutputs") }
	property string serviceName: ""
	property int numberOfOutputs: 1

    function addService(service)
    {
        switch (service.type)
        {
        case DBusService.DBUS_SERVICE_AC_CHARGER:
			serviceName = service.name
            if ( numberOfOutputsItem.valid )
				numberOfOutputs = numberOfOutputsItem.value
			else
				numberOfOutputs = 1
			if (numberOfOutputs > 1)
				multipleOutputWaring = true
			for (var i = 0; i < numberOfOutputs; i++ )
				dcModel.append ( { serviceName: service.name, serviceType: service.type, instance: i } )
            break;;
        }
    }

    // Detect available services of interest
    function discoverServices()
    {
		dcModel.clear()
		multipleOutputWaring = false
        for (var i = 0; i < DBusServices.count; i++)
        {
            addService(DBusServices.at(i))
        }
    }
}
