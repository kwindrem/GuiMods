// Display individual PV charger / inverter devices in Details page

import QtQuick 1.1
import "utils.js" as Utils
import "enhancedFormat.js" as EnhFmt

Row {
	id: root
    // uses the same sizes as DetailsPvCharger page
    property int tableColumnWidth: 0
    property int rowTitleWidth: 0
	property int phaseCount: 0

    VBusItem { id: customNameItem; bind: Utils.path(serviceName, "/CustomName") }
    VBusItem { id: pvTotalPower; bind: Utils.path(serviceName, "/Ac/Power") }
    VBusItem { id: pvPowerL1; bind: Utils.path(serviceName, "/Ac/L1/Power") }
    VBusItem { id: pvPowerL2; bind: Utils.path(serviceName, "/Ac/L2/Power") }
    VBusItem { id: pvPowerL3; bind: Utils.path(serviceName, "/Ac/L3/Power") }
    VBusItem { id: position; bind: Utils.path(serviceName, "/Position") }

    function doScroll()
    {
        pvText.doScroll()
    }

    MarqueeEnhanced
    {
        id: pvText
        width: rowTitleWidth
        height: parent.height
        text: customNameItem.valid ? customNameItem.value : "--"
        fontSize: 12
        textColor: "black"
        bold: true
        textHorizontalAlignment: Text.AlignHCenter
        scroll: false
        anchors
        {
            verticalCenter: parent.verticalCenter
        }
    }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: EnhFmt.formatVBusItem (pvTotalPower, "W") }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: EnhFmt.formatVBusItem (pvPowerL1, "W"); visible: phaseCount > 1 }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: EnhFmt.formatVBusItem (pvPowerL2, "W"); visible: phaseCount >= 2 }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: EnhFmt.formatVBusItem (pvPowerL3, "W"); visible: phaseCount >= 3 }
    Text { font.pixelSize: 12; font.bold: true; color: "black"
            width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
            text: 
            {
                if (position.valid)
                {
                    switch (position.value)
                    {
                        case 0:
                            return "Input 1"
                            break;;
                        case 2:
                            return "Input 2"
                            break;;
                        // AC critical output
                        case 1:
                            return "Output"
                            break;;
                        default:
                            return "?"
                            break;;
                    }
                }
                else
                    return "--"
            }
    }
}
