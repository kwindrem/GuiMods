// Display individual PV charger / inverter devices in Details page

import QtQuick 1.1
import "utils.js" as Utils

Row {
	id: root
    // uses the same sizes as DetailsPvCharger page
    property int tableColumnWidth: 0
    property int rowTitleWidth: 0

    VBusItem { id: customNameItem; bind: Utils.path(serviceName, "/CustomName") }

    property string pvName: customNameItem.valid ? customNameItem.value : "--"
    VBusItem { id: pvVoltage;  bind: Utils.path(serviceName, "/Pv/V") }
    VBusItem { id: pvPower; bind: Utils.path(serviceName, "/Yield/Power") }

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
            text: formatValue (pvPower, " W") }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: formatValue (pvVoltage, " V") }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: calculateCurrent (pvPower, pvVoltage, " A") }

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
