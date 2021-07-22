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
    property bool okToDisplay:false
    property bool discharging:false
    
    Component.onCompleted: setLimits ()

    VBusItem
    {
        id: maxCharge
        bind: Utils.path("com.victronenergy.settings", "/Settings/SystemSetup/MaxChargeCurrent")
        onValueChanged: setLimits ()
    }
    VBusItem
    {
        id: maxDischarge
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/GaugeLimits/BatteryMaxDischargeCurrent")
        onValueChanged: setLimits ()
    }
    VBusItem
    {
        id: batteryCurrent
        bind: Utils.path("com.victronenergy.system", "/Dc/Battery/Current")
    }

    // discharge overload range (beginning of bar dischargeOverload)
    Rectangle
    {
        id: dischargeOverloadRange
        width: scaleFactor * (maxDischargeDisplayed - dischargeOverload)
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
        width: scaleFactor * (dischargeOverload - dischargeCaution)
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
        width: scaleFactor * (dischargeCaution + chargeCaution)
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
        width: scaleFactor * (chargeOverload - chargeCaution)
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
        width: scaleFactor * (maxChargeDisplayed - chargeOverload)
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
    // zero line
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
            leftMargin: maxDischargeDisplayed * scaleFactor
        }
    }

    // charging bar
    Rectangle
    {
        id: chargingBar
        width: barWidth ()
        height: barHeight
        clip: true
        color: barColor
        anchors
        {
            verticalCenter: root.verticalCenter
            left: zeroLine.horizontalCenter
        }
        visible: okToDisplay && ! discharging
    }
    // discharging bar
    Rectangle
    {
        id: dischargingBar
        width: barWidth ()
        height: barHeight
        clip: true
        color: barColor
        anchors
        {
            verticalCenter: root.verticalCenter
            right: zeroLine.horizontalCenter
        }
        visible: okToDisplay && discharging
    }
    
    function barWidth ()
    {
        var current = batteryCurrent.valid ? batteryCurrent.value : 0
    
        if (current >= 0)
        {
            if (current > chargeOverload)
                barColor = "red"
            else if (current > chargeCaution)
                barColor = "yellow"
            else
                barColor = "green"
            discharging = false
            return current * scaleFactor
        }
        else
         {
            if (current < -dischargeOverload)
                barColor = "red"
            else if (current < -dischargeCaution)
                barColor = "yellow"
            else
                barColor = "green"
            discharging = true
            return -current * scaleFactor
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
        chargeCaution = chargeOverload * 0.8
        maxChargeDisplayed = chargeOverload * 1.2

        dischargeOverload = maxDischarge.value
        dischargeCaution = dischargeOverload * 0.8
        maxDischargeDisplayed = dischargeOverload * 1.2

        scaleFactor = root.width / (maxChargeDisplayed + maxDischargeDisplayed)
        zeroOffset = maxDischargeDisplayed * scaleFactor
        okToDisplay = true
    }
}
