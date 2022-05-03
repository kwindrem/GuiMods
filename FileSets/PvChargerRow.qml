// Display individual PV charger / inverter devices in Details page
// tracker is passed from DetailPvCharger.qml
//	-1 indicates a single tracker MPPT
//	0 indicates the overview for a multiple tracker MPPT
//		this will display the MPPT name, total PV yield and charging mode
// 1 - n indicates specific tracker informaiton
//		this will display tracker power, voltage and current only

import QtQuick 1.1
import "utils.js" as Utils

Row {
	id: root
    // uses the same sizes as DetailsPvCharger page
    property int tableColumnWidth: 0
    property int rowTitleWidth: 0
    property int index: tracker - 1
    property bool singleTracker: tracker == -1
    property bool multiTrackerHeader: tracker == 0
    property bool useTrackerInfo: tracker > 0
    property bool showNameAndTotal: singleTracker || multiTrackerHeader

    VBusItem { id: customNameItem; bind: Utils.path(serviceName, "/CustomName") }

    property string pvName: showNameAndTotal ? customNameItem.valid ? customNameItem.value : "--" : "    tracker " + tracker.toString()
    VBusItem { id: pvVoltage;  bind: Utils.path(serviceName, singleTracker ? "/Pv/V" : useTrackerInfo ? "/Pv/" + index.toString() + "/V" : "") }
    VBusItem { id: pvPower; bind: Utils.path(serviceName, showNameAndTotal ? "/Yield/Power" : "/Pv/" + index.toString() + "/P") }

	SystemState {
		id: state
		bind: Utils.path (serviceName, "/State")
	}


    function doScroll()
    {
        pvText.doScroll()
    }

    MarqueeEnhanced
    {
        id: pvText
        width: rowTitleWidth
        height: parent.height
        text: pvName
        fontSize: 12
        textColor: "black"
        bold: true
        textHorizontalAlignment: Text.AlignLeft
        scroll: false
        anchors
        {
            verticalCenter: parent.verticalCenter
        }
    }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: pvPowerPath }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: multiTrackerHeader ? " " : formatValue (pvVoltage, " V") }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: multiTrackerHeader ? " " : calculateCurrent (pvPower, pvVoltage, " A") }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: showNameAndTotal ? state.text : " " }

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
    
    function calculateCurrent (powerItem, voltageItem, unit)
    {
        var current
        if (powerItem.valid && voltageItem.valid && voltageItem.value != 0)
        {
            current = powerItem.value / voltageItem.value
            if (current < 100)
                return current.toFixed (1) + unit
            else
                return current.toFixed (0) + unit
        }
        else
            return ""
    }
}
