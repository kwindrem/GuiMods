// displays value as a bar surrounded by three range regions

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

Item {
	id: root
	width: parent.width

    property int barHeight: Math.max (height / 2, 2)    
    property color barColor: "black"
    
    property real chargeOverload
    property real chargeCaution
    property real maxChargeDisplayed
    property real dischargeOverload
    property real dischargeCaution
    property real maxDischargeDisplayed
    property real scaleFactor
    property real zeroOffset
    property bool okToDisplay: false
    property real barWidth
    property real barOffset
    
    Component.onCompleted: setLimits ()

    VBusItem
    {
        id: maxCharge
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/GaugeLimits/BatteryMaxChargeCurrent")
        onValueChanged: setLimits ()
        onValidChanged: setLimits ()
    }
    VBusItem
    {
        id: maxDischarge
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/GaugeLimits/BatteryMaxDischargeCurrent")
        onValueChanged: setLimits ()
        onValidChanged: setLimits ()
    }
    VBusItem
    {
        id: batteryCurrent
        bind: Utils.path("com.victronenergy.system", "/Dc/Battery/Current")
        onValueChanged: calculateBarWidth ()
        onValidChanged: setLimits ()
    }

    // discharge overload range (beginning of bar dischargeOverload)
    Rectangle
    {
        id: dischargeOverloadRange
        width: okToDisplay ? scaleFactor * (maxDischargeDisplayed - dischargeOverload) : 0
        height: root.height
        clip: true
        color: "#ffb3b3"
        visible: okToDisplay
        anchors
        {
            top: root.top
            left: root.left
        }
    }
    // discharge caution range (overload to caution)
    Rectangle
    {
        id: dischargeCautionRange
        width: okToDisplay ? scaleFactor * (dischargeOverload - dischargeCaution) : 0
        height: root.height
        clip: true
        color: "#bbbb00"
        visible: okToDisplay
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
        width: okToDisplay ? scaleFactor * (dischargeCaution + chargeCaution) : 0
        height: root.height
        clip: true
        color: "#99ff99"
        visible: okToDisplay
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
        width: okToDisplay ? scaleFactor * (chargeOverload - chargeCaution) : 0
        height: root.height
        clip: true
        color: "#bbbb00"
        visible: okToDisplay
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
        width: okToDisplay ? scaleFactor * (maxChargeDisplayed - chargeOverload) : 0
        height: root.height
        clip: true
        color: "#ffb3b3"
        visible: okToDisplay
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
        width: okToDisplay ? barWidth : 0
        height: barHeight
        clip: true
        color: barColor
        anchors
        {
            verticalCenter: root.verticalCenter
            left: root.left; leftMargin: barOffset
        }
        visible: okToDisplay
    }

    // zero line - draw last so it's on top
    Rectangle
    {
        id: zeroLine
        width: 1
        height: root.height
        clip: true
        color: "black"
        visible: okToDisplay
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
                barColor = "red"
            else if (current > chargeCaution)
                barColor = "yellow"
            else
                barColor = "green"
            barOffset = zeroOffset
            barWidth = current * scaleFactor
        }
        else
         {
            if (current < -dischargeOverload)
                barColor = "red"
            else if (current < -dischargeCaution)
                barColor = "yellow"
            else
                barColor = "green"
            barWidth = -current * scaleFactor
            barOffset = zeroOffset - barWidth
        }
    }
    
    function setLimits ()
    {
        // guages disabled if maxDischarge is 0
        if (! maxDischarge.valid || maxDischarge.value === 0)
        {
            okToDisplay = false
            return
        }
        chargeOverload = maxCharge.value
        chargeCaution = chargeOverload
        maxChargeDisplayed = chargeOverload * 1.1

        dischargeOverload = maxDischarge.value
        dischargeCaution = dischargeOverload
        maxDischargeDisplayed = dischargeOverload * 1.1

        scaleFactor = root.width / (maxChargeDisplayed + maxDischargeDisplayed)
        zeroOffset = maxDischargeDisplayed * scaleFactor
        okToDisplay = true
        calculateBarWidth ()
    }
}
