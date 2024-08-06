// displays value as a bar surrounded by three range regions

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

Item {
	id: root

////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/Gui/ColorScheme" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 0

    property variant endLabelFontSize: 16
    property color endLabelBackgroundColor: "transparent"

    property int barHeight: Math.max (height / 2, 2)
    property color barColor: "black"

    property real chargeOverload: maxCharge.valid ? maxCharge.value : 0
    property real chargeCaution: chargeOverload
    property real maxChargeDisplayed: chargeOverload * 1.1
    property real dischargeOverload: maxDischarge.valid ? maxDischarge.value : 0
    property real dischargeCaution: dischargeOverload
    property real maxDischargeDisplayed: dischargeOverload * 1.1
	property real totalPowerDisplayed: maxChargeDisplayed + maxDischargeDisplayed
    property bool showGauge: totalPowerDisplayed > 0
    property real labelOffset: showGauge &&  maxDischargeDisplayed != 0 && maxChargeDisplayed != 0 ? 15 : 0
    property real scaleFactor: showGauge ? ((root.width - labelOffset * 2) / totalPowerDisplayed) : 0
    property real zeroOffset: showGauge ? ((maxDischargeDisplayed * scaleFactor) + labelOffset) : 0
    property real barWidth
    property real barOffset
    property color endLabelColor: "white"

	Component.onCompleted: calculateBarWidth ()

    VBusItem
    {
        id: maxCharge
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/GaugeLimits/BatteryMaxChargeCurrent")
        onValueChanged: calculateBarWidth ()
        onValidChanged: calculateBarWidth ()
    }
    VBusItem
    {
        id: maxDischarge
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/GaugeLimits/BatteryMaxDischargeCurrent")
        onValueChanged: calculateBarWidth ()
        onValidChanged: calculateBarWidth ()
    }
    VBusItem
    {
        id: batteryCurrent
        bind: Utils.path("com.victronenergy.system", "/Dc/Battery/Current")
        onValueChanged: calculateBarWidth ()
    }

    // discharge end label
	Rectangle
	{
		anchors.fill: dischargeText
		color: endLabelBackgroundColor
        visible: labelOffset > 0
	}
    TileText
    {
		id: dischargeText
        text: "D"
        color: endLabelColor
        font.pixelSize: endLabelFontSize
        width: labelOffset
        anchors
        {
			verticalCenter: root.verticalCenter
			verticalCenterOffset: 1
            left: root.left
        }
        visible: showGauge
    }
    // charge end label
    Rectangle
	{
		anchors.fill: chargeText
		color: endLabelBackgroundColor
        visible: labelOffset > 0
	}
    TileText
    {
		id: chargeText
        text: "C"
        color: endLabelColor
        font.pixelSize: endLabelFontSize
        width: labelOffset
        anchors
        {
			verticalCenter: dischargeText.verticalCenter
            right: root.right
        }
        visible: showGauge
    }
    // discharge overload range (beginning of bar dischargeOverload)
    Rectangle
    {
        id: dischargeOverloadRange
        width: showGauge ? scaleFactor * (maxDischargeDisplayed - dischargeOverload) : 0
        height: root.height
        clip: true
////// GuiMods — DarkMode
        color: !darkMode ? "#ffb3b3" : "#bf8686"
        visible: showGauge
        anchors
        {
            top: root.top
            left: root.left; leftMargin: labelOffset
        }
    }
    // discharge caution range (overload to caution)
    Rectangle
    {
        id: dischargeCautionRange
        width: showGauge ? scaleFactor * (dischargeOverload - dischargeCaution) : 0
        height: root.height
        clip: true
////// GuiMods — DarkMode
        color: !darkMode ? "#bbbb00" : "#8c8c00"
        visible: showGauge
        anchors
        {
            top: root.top
            left: dischargeOverloadRange.right
        }
    }
    // OK range
    Rectangle
    {
        id: okRange
        width: showGauge ? scaleFactor * (dischargeCaution + chargeCaution) : 0
        height: root.height
        clip: true
////// GuiMods — DarkMode
        color: !darkMode ? "#99ff99" : "#73bf73"
        visible: showGauge
        anchors
        {
            top: root.top
            left: dischargeCautionRange.right
        }
    }
    // charge caution range (caution to overload)
    Rectangle
    {
        id: chargeCautionRange
        width: showGauge ? scaleFactor * (chargeOverload - chargeCaution) : 0
        height: root.height
        clip: true
////// GuiMods — DarkMode
        color: !darkMode ? "#bbbb00" : "#8c8c00"
        visible: showGauge
        anchors
        {
            top: root.top
            left: okRange.right
        }
    }
    // charge overload range (overload to end of bar)
    Rectangle
    {
        id: chargeOverloadRange
        width: showGauge ? scaleFactor * (maxChargeDisplayed - chargeOverload) : 0
        height: root.height
        clip: true
////// GuiMods — DarkMode
        color: !darkMode ? "#ffb3b3" : "#bf8686"
        visible: showGauge
        anchors
        {
            top: root.top
            left: chargeCautionRange.right
        }
    }

    // charging/discharging bar
    Rectangle
    {
        id: chargingBar
        width: showGauge ? root.barWidth : 0
        height: barHeight
        clip: true
        color: barColor
        anchors
        {
            verticalCenter: root.verticalCenter
            left: root.left; leftMargin: root.barOffset
        }
        visible: showGauge
    }

    // zero line - draw last so it's on top
    Rectangle
    {
        id: zeroLine
        width: 1
        height: root.height
        clip: true
        color: "black"
        visible: showGauge
        anchors
        {
            top: root.top
            left: root.left
            leftMargin: zeroOffset
        }
    }

    function calculateBarWidth ()
    {
        var current = batteryCurrent.valid ? batteryCurrent.value : 0

        current = Math.min ( Math.max (current, -maxDischargeDisplayed), maxChargeDisplayed)

        if (current >= 0)
        {
            if (current > chargeOverload)
////// GuiMods — DarkMode
                barColor = !darkMode ? "#ff0000" : "#bf0000"
            else if (current > chargeCaution)
////// GuiMods — DarkMode
                barColor = !darkMode ? "#ffff00" : "#bfbf00"
            else
////// GuiMods — DarkMode
                barColor = !darkMode ? "#008000" : "#006000"
            root.barOffset = zeroOffset
            root.barWidth = current * scaleFactor
        }
        else
        {
            if (current < -dischargeOverload)
////// GuiMods — DarkMode
                barColor = !darkMode ? "#ff0000" : "#bf0000"
            else if (current < -dischargeCaution)
////// GuiMods — DarkMode
                barColor = !darkMode ? "#ffff00" : "#bfbf00"
            else
////// GuiMods — DarkMode
                barColor = !darkMode ? "#008000" : "#006000"
            root.barWidth = -current * scaleFactor
            root.barOffset = zeroOffset - root.barWidth
        }
    }
}
