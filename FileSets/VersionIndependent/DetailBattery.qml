////// detail page for displaying battery details
////// pushed from Flow overview

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0
import "timeToGo.js" as TTG
import "enhancedFormat.js" as EnhFmt

MbPage
{
	id: root
 
    title: "Battery detail"
    
    property variant sys: theSystem
    property string systemPrefix: "com.victronenergy.system"
    property color backgroundColor: "#b3b3b3"

    property int buttonHeight: 40
    property int tableColumnWidth: 80
    property int rowTitleWidth: 120
    property int tableWidth: rowTitleWidth * 2 + tableColumnWidth * 3
    property int essWidth3: tableWidth / 3
    property int essWidth2: tableWidth / 2
    property bool showEssCodes: systemType.valid && systemType.value === "ESS" || systemType.value === "Hub-4"
    property real essDimOpacity: 0.2

    VBusItem { id: timeToGo;  bind: Utils.path(systemPrefix,"/Dc/Battery/TimeToGo") }

    VBusItem { id: systemType; bind: Utils.path(systemPrefix, "/SystemType") }
    VBusItem { id: lowSoc; bind: Utils.path(systemPrefix, "/SystemState/LowSoc") }
    VBusItem { id: slowCharge; bind: Utils.path(systemPrefix, "/SystemState/SlowCharge") }
    VBusItem { id: batteryLife; bind: Utils.path(systemPrefix, "/SystemState/BatteryLife") }
    VBusItem { id: chargeDisabled; bind: Utils.path(systemPrefix, "/SystemState/ChargeDisabled") }
    VBusItem { id: dischargeDisabled; bind: Utils.path(systemPrefix, "/SystemState/DischargeDisabled") }
    VBusItem { id: chargeLimited; bind: Utils.path(systemPrefix, "/SystemState/UserChargeLimited") }
    VBusItem { id: dischargeLimited; bind: Utils.path(systemPrefix, "/SystemState/UserDischargeLimited") }
    VBusItem { id: batteryServiceItem; bind: Utils.path(systemPrefix, "/Dc/Battery/BatteryService") }

	property string batteryService: batteryServiceItem.valid ? batteryServiceItem.value : ""

	VBusItem { id: remainingItem;  bind: Utils.path(batteryService,"/Capacity") }
	property bool showRemaining: remainingItem.valid
	VBusItem { id: installedCapacityItem; bind: Utils.path(batteryService, "/InstalledCapacity") }
	property bool calculateConsumed: remainingItem.valid && installedCapacityItem.valid

	VBusItem { id: consumedItem;  bind: Utils.path(systemPrefix,"/Dc/Battery/ConsumedAmphours") }
	property real consumed: calculateConsumed ? installedCapacityItem.value - remainingItem.value : consumedItem.value
	property bool showConsumed: calculateConsumed || consumedItem.valid

	VBusItem { id: minimumCellVoltageItem; bind: Utils.path(batteryService, "/System/MinCellVoltage") }
	VBusItem { id: maximumCellVoltageItem; bind: Utils.path(batteryService, "/System/MaxCellVoltage") }
	property bool showCellVoltages: minimumCellVoltageItem.valid && maximumCellVoltageItem.valid
	VBusItem { id: chargeLimitItem; bind: Utils.path(batteryService, "/Info/MaxChargeCurrent") }
	VBusItem { id: dischargeLimitItem; bind: Utils.path(batteryService, "/Info/MaxDischargeCurrent") }
	property bool showChargeDischargeLimits: chargeLimitItem.valid || dischargeLimitItem.valid
	property bool chargeDisabled: chargeLimitItem.valid && chargeLimitItem.value == 0
	property bool dischargeDisabled: dischargeLimitItem.valid && dischargeLimitItem.value == 0
	VBusItem { id: auxVoltageItem; bind: Utils.path(batteryService, "/Dc/1/Voltage") }
	VBusItem { id: temperatureItem; bind: Utils.path(batteryService, "/Dc/0/Temperature") }
	// use system temperature scale if it exists (v2.90 onward) - otherwise use the GuiMods version
    property VBusItem systemScaleItem: VBusItem { bind: "com.victronenergy.settings/Settings/System/Units/Temperature" }
    property VBusItem guiModsTempScaleItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/TemperatureScale" }
    property int tempScale: systemScaleItem.valid ? systemScaleItem.value == "fahrenheit" ? 2 : 1 : guiModsTempScaleItem.valid ? guiModsTempScaleItem.value : 1


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
			anchors.horizontalCenter: parent.horizontalCenter
            PowerGaugeBattery
            {
                id: gauge
                width: tableWidth * 0.8
                height: 15
				endLabelColor: "black"
            }
        }
        Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr ("State of charge") }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: EnhFmt.formatVBusItem (sys.battery.soc) }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr ("State") }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                width: tableColumnWidth * 2; horizontalAlignment: Text.AlignHCenter
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
                        return "no state"
                }
            }
        }
        Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: showConsumed ? qsTr ("Consumed") : "" }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text: showConsumed ? EnhFmt.formatValue (consumed, "AH") : "" }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: showRemaining ? qsTr ("Remaining") : "" }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter;
                    text: showRemaining ? EnhFmt.formatValue (remainingItem.value, "AH") : ""
                    
			}
        }
        Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr ("Voltage") }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text: EnhFmt.formatVBusItem (sys.battery.voltage) }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr ("Remaining time") }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text: timeToGo.valid ? TTG.formatTimeToGo (timeToGo) : "" }
        }
       Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr ("Power") }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text: EnhFmt.formatVBusItemAbs (sys.battery.power) }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr ("Current") }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text:
                    {
						if (sys.battery.current.vaid)
							return EnhFmt.formatVBusItem (sys.battery.current, "A")
						else if (sys.battery.power.valid && sys.battery.voltage.valid)
							return EnhFmt.formatValueAbs (sys.battery.power.value / sys.battery.voltage.value, "A")
						else
							return ""
					}
			}
			Text { id: chargingText; font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text: sys.battery.power.value < 0 ? qsTr ("supplying") : sys.battery.power.value > 0 ? qsTr ("consuming") : "" }
        }
        Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr ("Aux Voltage")}
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: EnhFmt.formatVBusItem (auxVoltageItem, "V") }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr ("Temperature")}
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
				text:
				{
					if (! temperatureItem.valid )
						return ""
					else if (tempScale == 2)
						return ((temperatureItem.value * 9 / 5) + 32).toFixed (1) + " °F"
					else
						return temperatureItem.value.toFixed (1) + " °C"
				}
			}
		}
        Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr ("Min cell voltage") }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text: minimumCellVoltageItem.valid ? minimumCellVoltageItem.value.toFixed (3) + " V" : "" }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr ("Max cell voltage") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter;
                    text: maximumCellVoltageItem.valid ? maximumCellVoltageItem.value.toFixed (3) + " V" : ""}
			visible: showCellVoltages
        }
        Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: root.dischargeDisabled ? "red" : "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: root.dischargeDisabled ? qsTr ("Discharge") : qsTr ("Discharge Limit") }
            Text { font.pixelSize: 12; font.bold: true; color: root.dischargeDisabled ? "red" : "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text: root.dischargeDisabled ? qsTr ("disabled") : EnhFmt.formatVBusItem (dischargeLimitItem, "A")
			}
            Text { font.pixelSize: 12; font.bold: true; color: root.chargeDisabled ? "red" : "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: root.chargeDisabled ? qsTr ("Charge") : qsTr ("Charge Limit") }
            Text { font.pixelSize: 12; font.bold: true; color: root.chargeDisabled ? "red" : "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter;
                    text: root.chargeDisabled ? qsTr ("disabled") : EnhFmt.formatVBusItem (chargeLimitItem, "A") 
			}
			visible: showChargeDischargeLimits
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
                    width: essWidth3; horizontalAlignment: Text.AlignHCenter
                    text: qsTr ("Low SOC"); visible: showEssCodes; opacity: lowSoc.value === 1 ? 1 : essDimOpacity }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: essWidth3; horizontalAlignment: Text.AlignHCenter
                    text: qsTr ("Slow Charge"); visible: showEssCodes; opacity: slowCharge.value === 1 ? 1 : essDimOpacity }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: essWidth3; horizontalAlignment: Text.AlignHCenter
                    text: qsTr ("Battery Life"); visible: showEssCodes; opacity: batteryLife.value === 1 ? 1 : essDimOpacity}
        }
        Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: essWidth2; horizontalAlignment: Text.AlignHCenter
                    text: qsTr ("Charge Disabled"); visible: showEssCodes; opacity: chargeDisabled.value === 1 ? 1 : essDimOpacity }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: essWidth2; horizontalAlignment: Text.AlignHCenter
                    text: qsTr ("Discharge Disabled") ; visible: showEssCodes; opacity: dischargeDisabled.value === 1 ? 1 : essDimOpacity }
        }
        Row
        {
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: essWidth2; horizontalAlignment: Text.AlignHCenter
                    text: qsTr ("Charge Limited"); visible: showEssCodes; opacity: chargeLimited.value === 1 ? 1 : essDimOpacity }
            Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: essWidth2; horizontalAlignment: Text.AlignHCenter
                    text: qsTr ("Discharge Limited") ; visible: showEssCodes; opacity: dischargeLimited.value === 1 ? 1 : essDimOpacity }
        }
    }
}
