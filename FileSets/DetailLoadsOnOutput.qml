////// detail page for displaying critical AC output details
////// pushed from Flow overview

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

MbPage {
	id: root
 
    title: combineAcLoads ? qsTr ("AC Loads Detail") : qsTr ("Loads on AC Output Detail")
    
    property variant sys: theSystem
    property string systemPrefix: "com.victronenergy.system"
    property string settingsPrefix: "com.victronenergy.settings"

	property int fontPixelSize: 18
    property color backgroundColor: "#b3b3b3"

    property int tableColumnWidth: 60
    property int rowTitleWidth: 130
    property int dataColumns: 3
    property int totalDataWidth: tableColumnWidth * dataColumns
    property int legColumnWidth: phaseCount <= 1 ? totalDataWidth : totalDataWidth / phaseCount

    property int numberOfMultis: 0
    property int numberOfInverters: 0
    property string inverterService: ""
    property int phaseCount: outputLoad.phaseCount.valid ? outputLoad.phaseCount.value : 0

    Component.onCompleted: { discoverServices() }

    VBusItem { id: voltageL1; bind: Utils.path(inverterService, "/Ac/Out/L1/V") }
    VBusItem { id: voltageL2; bind: Utils.path(inverterService, "/Ac/Out/L2/V") }
    VBusItem { id: voltageL3; bind: Utils.path(inverterService, "/Ac/Out/L3/V") }
    VBusItem { id: frequencyL1; bind: Utils.path(inverterService, "/Ac/Out/L1/F") }
    VBusItem { id: splitPhaseL2Passthru; bind: Utils.path(inverterService, "/Ac/State/SplitPhaseL2Passthru") }
    VBusItem { id: _combineAcLoads; bind: "com.victronenergy.settings/Settings/GuiMods/EnhancedFlowCombineLoads" }
    property bool combineAcLoads: _combineAcLoads.valid && _combineAcLoads.value === 1
    property variant outputLoad: combineAcLoads ? sys.acLoad : sys.acOutLoad

    property bool l1AndL2OutShorted: splitPhaseL2Passthru.valid && splitPhaseL2Passthru.value === 0

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
                PowerGauge
                {
                    id: gauge
                    width: rowTitleWidth + totalDataWidth
                    height: 15
                    maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/AcOutputMaxPower"
                    connection: outputLoad
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
                        text: "L2" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L3"; visible: phaseCount >= 3 }
                visible: phaseCount >= 2
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: "Total Power" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: totalDataWidth; horizontalAlignment: Text.AlignHCenter
                    text:
                    {
                        if (outputLoad.power.valid)
                            return outputLoad.power.value.toFixed (0) + " W"
                        else
                            return "--"
                    }                        
                }
                visible: phaseCount >= 2
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: "Power" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (outputLoad.powerL1, " W") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (outputLoad.powerL2, " W"); visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (outputLoad.powerL3, " W"); visible: phaseCount >= 3 }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: "Voltage" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (voltageL1, " V") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (voltageL2, " V"); visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (voltageL3, " V"); visible: phaseCount >= 3 }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: "Current" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: calculateCurrent (outputLoad.powerL1, voltageL1, " A") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: calculateCurrent (outputLoad.powerL2, voltageL2, " A"); visible: phaseCount >= 2 }
               Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                         text: calculateCurrent (outputLoad.powerL3, voltageL3, " A"); visible: phaseCount >= 3 }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: "Frequency" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: totalDataWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (frequencyL1, " Hz") }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth + totalDataWidth; horizontalAlignment: Text.AlignHCenter
                        text: "Current values are estimated" }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth + totalDataWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L2 values included in L1"
                        visible: l1AndL2OutShorted }
            }
        }
    }


    // When new service is found check if is a tank sensor
    Connections
    {
        target: DBusServices
        onDbusServiceFound: addService(service)
    }

    function addService(service)
    {
         switch (service.type)
        {
        case DBusService.DBUS_SERVICE_MULTI:
            numberOfMultis++
            if (numberOfMultis === 1)
                inverterService = service.name;
            break;;
        case DBusService.DBUS_SERVICE_INVERTER:
            numberOfInverters++
            if (numberOfInverters === 1 && inverterService == "")
                inverterService = service.name;
            break;;
        }
    }

    // Detect available services of interest
    function discoverServices()
    {
        numberOfMultis = 0
        numberOfInverters = 0
        inverterService = ""
        for (var i = 0; i < DBusServices.count; i++)
        {
            addService(DBusServices.at(i))
        }
    }

    // fake current value from power / voltage
    // does not consider power factor so this value for current is not really correct
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
            return "--"
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
            return "--"
    }
}
