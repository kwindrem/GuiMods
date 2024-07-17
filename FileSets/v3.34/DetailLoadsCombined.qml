////// detail page for displaying critical AC output details
////// pushed from Flow overview

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0
import "enhancedFormat.js" as EnhFmt

MbPage {
	id: root
 
    title: qsTr ("AC Loads detail")
    
    property variant sys: theSystem
    property string systemPrefix: "com.victronenergy.system"

	property int fontPixelSize: 18
    property color backgroundColor: "#b3b3b3"

    property int dataColumns: 3
    property int rowTitleWidth: 130
    property int totalDataWidth: root.width - rowTitleWidth - 20
    property int tableColumnWidth: totalDataWidth / dataColumns
    property int legColumnWidth: phaseCount <= 1 ? totalDataWidth : totalDataWidth / phaseCount

    property int phaseCount: sys.acLoad.phaseCount.valid ? sys.acLoad.phaseCount.value : 0

    VBusItem { id: vebusServiceItem; bind: Utils.path(systemPrefix, "/VebusService") }
    property string inverterService: vebusServiceItem.valid ? vebusServiceItem.value : ""
    property bool l2AndL1OutSummed: sys.acLoad.l2AndL1OutSummed

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
        anchors.verticalCenter: parent.verticalCenter
        Column 
        {
            spacing: 2
            Row
            {
                Text { id: totalLabel; font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr("Total Power") }
                Text { id: totalPower; font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text: EnhFmt.formatVBusItem (sys.acLoad.power, "W")
                }
                PowerGauge
                {
                    id: gauge
					width: (root.width * 0.9) - totalLabel.width - totalPower.width
                    height: 15
                    maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/AcOutputMaxPower"
                    connection: sys.acLoad
                }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: "" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L1" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L2"; visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L3"; visible: phaseCount >= 3 }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("Power") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.acLoad.powerL1, "W") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: l2AndL1OutSummed ? "< < <" : EnhFmt.formatVBusItem (sys.acLoad.powerL2, "W"); visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.acLoad.powerL3, "W"); visible: phaseCount >= 3 }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("Voltage") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.acLoad.voltageL1, "V") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: l2AndL1OutSummed ? "< < <" : EnhFmt.formatVBusItem (sys.acLoad.voltageL2, "V"); visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.acLoad.voltageL3, "V"); visible: phaseCount >= 3 }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("Current") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.acLoad.currentL1, "A") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: l2AndL1OutSummed ? "< < <" : EnhFmt.formatVBusItem (sys.acLoad.currentL2, "A"); visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.acLoad.currentL3, "A"); visible: phaseCount >= 3 }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("Frequency") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: totalDataWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.acLoad.frequency, "Hz") }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth + totalDataWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L2 values included in L1"
                        visible: l2AndL1OutSummed }
            }
        }
    }
}
