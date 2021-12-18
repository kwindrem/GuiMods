////// detail page for displaying battery details
////// pushed from Flow overview

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

MbPage
{
	id: root
 
    title: "Battery Detail"
    
    property variant sys: theSystem
    property string systemPrefix: "com.victronenergy.system"
    property color backgroundColor: "#b3b3b3"

    property int buttonHeight: 40
    property int tableColumnWidth: 100
    property int rowTitleWidth: 160
    property int tableWidth: rowTitleWidth + tableColumnWidth * 2
    property int essWidth: tableWidth / 4
    property bool showEssCodes: systemType.valid && systemType.value === "ESS" || systemType.value === "Hub-4"
    property real essDimOpacity: 0.2

    VBusItem { id: timeToGo;  bind: Utils.path("com.victronenergy.system","/Dc/Battery/TimeToGo") }
    VBusItem { id: consumedAh;  bind: Utils.path("com.victronenergy.system","/Dc/Battery/ConsumedAmphours") }

    VBusItem { id: systemType; bind: Utils.path(systemPrefix, "/SystemType") }
    VBusItem { id: lowSoc; bind: Utils.path(systemPrefix, "/SystemState/LowSoc") }
    VBusItem { id: slowCharge; bind: Utils.path(systemPrefix, "/SystemState/SlowCharge") }
    VBusItem { id: batteryLife; bind: Utils.path(systemPrefix, "/SystemState/BatteryLife") }
    VBusItem { id: chargeDisabled; bind: Utils.path(systemPrefix, "/SystemState/ChargeDisabled") }
    VBusItem { id: dischargeDisabled; bind: Utils.path(systemPrefix, "/SystemState/DischargeDisabled") }
    VBusItem { id: chargeLimited; bind: Utils.path(systemPrefix, "/SystemState/UserChargeLimited") }
    VBusItem { id: dischargeLimited; bind: Utils.path(systemPrefix, "/SystemState/UserDischargeLimited") }

    // background
    Rectangle
    {
        anchors
        {
            fill: parent
        }
        color: root.backgroundColor
    }

    Column 
    {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2
        Row
        {
            PowerGaugeBattery
            {
                id: gauge
                width: tableWidth
                height: 15
            }
        }
        Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr ("State of charge") }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text: sys.battery.soc.valid ? sys.battery.soc.value.toFixed (1) + " %" : "--"}
             Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter; text: "" }
        }
        Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr ("Remainig time") }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text: timeToGo.valid ? Utils.secondsToString(timeToGo.value) : "" }
             Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter; text: "" }
        }
        Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr ("State") }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                text:
                {
                    if (sys.battery.power.valid)
                    {
                        if (sys.battery.power.value < 0)
                            return qsTr ("Discharging")
                        else if (sys.battery.power.value > 0)
                            return qsTr ("Charging")
                        else
                            return qsTr ("Idle")
                    }
                    else
                        return ""
                }
            }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter; text: "" }
        }
       Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr ("Power") }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text: Math.abs (sys.battery.power.value.toFixed(1)) + " W" }
            Text { id: chargingText; font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text: sys.battery.power.value < 0 ? qsTr ("from battery") : sys.battery.power.value > 0 ? qsTr ("to battery") : "" }
        }
        Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr ("Voltage") }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text: sys.battery.voltage.format(1) }
             Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter; text: "" }
        }
        Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr ("Current") }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text: Math.abs (sys.battery.power.value / sys.battery.voltage.value).toFixed(1) + " A" }
             Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter; text: chargingText.text }
        }
        Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr ("Consumed Amp-Hours") }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text: formatValue (consumedAh, " AH") }
             Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter; text: "" }
        }
        Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableWidth; horizontalAlignment: Text.AlignHCenter
                    text: qsTr ("ESS Reason codes")
                    visible: showEssCodes }
        }
        Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: essWidth; horizontalAlignment: Text.AlignHCenter
                    text: qsTr ("Low SOC"); visible: showEssCodes; opacity: lowSoc.value === 1 ? 1 : essDimOpacity }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: essWidth; horizontalAlignment: Text.AlignHCenter
                    text: qsTr ("Slow Charge"); visible: showEssCodes; opacity: slowCharge.value === 1 ? 1 : essDimOpacity }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: essWidth * 2; horizontalAlignment: Text.AlignHCenter
                    text: qsTr ("Battery Life"); visible: showEssCodes; opacity: batteryLife.value === 1 ? 1 : essDimOpacity}
        }
        Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: essWidth * 2; horizontalAlignment: Text.AlignHCenter
                    text: qsTr ("Charge Disabled"); visible: showEssCodes; opacity: chargeDisabled.value === 1 ? 1 : essDimOpacity }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: essWidth * 2; horizontalAlignment: Text.AlignHCenter
                    text: qsTr ("Discharge Disabled") ; visible: showEssCodes; opacity: dischargeDisabled.value === 1 ? 1 : essDimOpacity }
        }
        Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: essWidth * 2; horizontalAlignment: Text.AlignHCenter
                    text: qsTr ("Charge Limited"); visible: showEssCodes; opacity: chargeLimited.value === 1 ? 1 : essDimOpacity }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: essWidth * 2; horizontalAlignment: Text.AlignHCenter
                    text: qsTr ("Discharge Limited") ; visible: showEssCodes; opacity: dischargeLimited.value === 1 ? 1 : essDimOpacity }
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
            return "--"
    }
}

