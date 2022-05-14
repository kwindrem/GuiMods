// displays value as a bar surrounded by three range regions
// use for Multi only

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

Item {
	id: root
	width: parent.width

    property string inverterService: ""
    property VBusItem inverterModeItem: VBusItem { bind: Utils.path(inverterService, "/Mode" ) }
    VBusItem
    {
        id: systemStateItem
        bind: Utils.path("com.victronenergy.system", "/SystemState/State")
        onValueChanged: setLimits ()
    }

    VBusItem
    { 
        id: pInL1; bind: Utils.path(inverterService, "/Ac/ActiveIn/L1/P")
        onValidChanged: calculateBar1width ()
        onValueChanged: calculateBar1width ()
    }
    VBusItem
    { 
        id: pInL2; bind: Utils.path(inverterService, "/Ac/ActiveIn/L2/P")
        onValidChanged: calculateBar2width ()
        onValueChanged: calculateBar2width ()
    }
    VBusItem
    { 
        id: pInL3; bind: Utils.path(inverterService, "/Ac/ActiveIn/L3/P")
        onValidChanged: calculateBar3width ()
        onValueChanged: calculateBar3width ()
    }
    VBusItem
    { 
        id: pOutL1; bind: Utils.path(inverterService, "/Ac/Out/L1/P")
        onValidChanged: calculateBar1width ()
        onValueChanged: calculateBar1width ()
    }
    VBusItem
    { 
        id: pOutL2; bind: Utils.path(inverterService, "/Ac/Out/L2/P")
        onValidChanged: calculateBar2width ()
        onValueChanged: calculateBar2width ()
    }
    VBusItem
    { 
        id: pOutL3; bind: Utils.path(inverterService, "/Ac/Out/L3/P")
        onValidChanged: calculateBar3width ()
        onValueChanged: calculateBar3width ()
    }

    VBusItem
    {
        id: phaseCountItem
        bind: Utils.path(inverterService, "/Ac/NumberOfPhases" )
        onValueChanged: setLimits ()
        onValidChanged: setLimits ()
    }
    property int phaseCount : phaseCountItem.valid ? phaseCountItem.value : 0
    onPhaseCountChanged: setLimits ()

    VBusItem
    {
        id: inverterContinuousPowerItem
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/GaugeLimits/ContiuousPower")
        onValueChanged: setLimits ()
        onValidChanged: setLimits ()
    }
    VBusItem
    {
        id: inverterPeakPowerItem
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/GaugeLimits/PeakPower")
        onValueChanged: setLimits ()
        onValidChanged: setLimits ()
    }
    VBusItem
    {
        id: inverterCautionPowerItem
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/GaugeLimits/CautionPower")
        onValueChanged: setLimits ()
        onValidChanged: setLimits ()
    }
    VBusItem
    {
        id: chargerMaxPowerItem
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/GaugeLimits/MaxChargerPower")
        onValueChanged: setLimits ()
        onValidChanged: setLimits ()
    }
    property real maxInverterDisplayed: 0
    property real inverterOverload: 0
    property real inverterCaution: 0
    property real maxChargerDisplayed: 0
    property real chargerMaxPower: 0

    property int barSpacing: phaseCount > 0 ? Math.max (height / (phaseCount + 1), 2) : 0
    property int barHeight: barSpacing < 3 ? barSpacing : barSpacing - 1
    property int firstBarVertPos: (height - barSpacing * phaseCount) / 2
    property real scaleFactor
    property real zeroOffset
    
    property real bar1offset
    property real bar2offset
    property real bar3offset
    property real bar1width
    property real bar2width
    property real bar3width

    property color bar1color: "black"
    property color bar2color: "black"
    property color bar3color: "black"
    
    property bool showGauge: false
    
    Component.onCompleted:
    {
        setLimits ()
    } 

    // chaerger overload range (maxChargerDisplayed to chargerMaxPower)
    Rectangle
    {
        id: chargerOverloadRange
        width: visible ? (maxChargerDisplayed - chargerMaxPower) * scaleFactor : 0
        height: root.height
        clip: true
        color: "#ffb3b3"
        visible: showGauge
        anchors
        {
            top: root.top
            left: root.left
        }
    }
    // OK range (chargerMax to inverterCaution)
    Rectangle
    {
        id: okRange
        width: visible ? (inverterCaution + chargerMaxPower) * scaleFactor : 0
        height: root.height
        clip: true
        color: "#99ff99"
        visible: showGauge
        anchors
        {
            top: root.top
            left: chargerOverloadRange.right
        }
    }
    // inverterCaution range (inverterCaution to inverterOverload)
    Rectangle
    {
        id: inverterCautionRange
        width: visible ? (inverterOverload - inverterCaution) * scaleFactor : 0
        height: root.height
        clip: true
        color: "#bbbb00"
        visible: showGauge
        anchors
        {
            top: root.top
            left: okRange.right
        }
    }
    // inverterOverload range (inverterOverload to maxInverterDisplayed)
    Rectangle
    {
        id: inverterOverloadRange
        width: visible ? (maxInverterDisplayed - inverterOverload) * scaleFactor : 0
        height: root.height
        clip: true
        color: "#ffb3b3"
        visible: showGauge
        anchors
        {
            top: root.top
            left: inverterCautionRange.right
        }
    }
    // actual bars
    Rectangle
    {
        id: bar1
        width: visible ? bar1width : 0
        height: barHeight
        clip: true
        color: bar1color
        anchors
        {
            top: root.top; topMargin: firstBarVertPos
            left: root.left; leftMargin: bar1offset
        }
        visible: showGauge
    }
    Rectangle
    {
        id: bar2
        width: visible ? bar2width : 0
        height: barHeight
        clip: true
        color: bar2color
        anchors
        {
            top: root.top; topMargin: firstBarVertPos + barSpacing
            left: root.left; leftMargin: bar2offset
        }
        visible: showGauge
    }
    Rectangle
    {
        id: bar3
        width: visible ? bar3width : 0
        height: barHeight
        clip: true
        color: bar3color
        anchors
        {
            top: root.top; topMargin: firstBarVertPos + barSpacing * 2
            left: root.left; leftMargin: bar2offset
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
        visible: showGauge && chargerMaxPower > 0
        anchors
        {
            top: root.top
            left: root.left
            leftMargin: zeroOffset
        }
    }

    function calculateBar1width ()
    {
        var currentValue, barWidth
        if (phaseCount < 1)
            return 0
        if (pOutL1.valid && pInL1.valid)
            currentValue = pOutL1.value - pInL1.value
        else
            currentValue = 0
        bar1color = getBarColor (currentValue)
        barWidth = Math.min ( Math.max (currentValue, -maxChargerDisplayed), maxInverterDisplayed) * scaleFactor
        // left of bar is at 0 point
        if (barWidth >= 0)
        {
            bar1width = barWidth
            bar1offset = zeroOffset
        }
        // RIGHT of bar is at 0 point
        else
        {
            bar1width = -barWidth
            bar1offset = zeroOffset + barWidth
        }
    }
    function calculateBar2width ()
    {
        var currentValue, barWidth
        if (phaseCount < 2)
            return 0
        if (pOutL2.valid && pInL2.valid)
            currentValue = pOutL2.value - pInL2.value
        else
            currentValue = 0
        bar2color = getBarColor (currentValue)
        barWidth = Math.min ( Math.max (currentValue, -maxChargerDisplayed), maxInverterDisplayed) * scaleFactor
        // left of bar is at 0 point
        if (barWidth >= 0)
        {
            bar2offset = zeroOffset
            bar2width = barWidth
        }
        // RIGHT of bar is at 0 point
        else
        {
            bar2width -barWidth
            bar2offset = zeroOffset + barWidth
        }
    }
    function calculateBar3width ()
    {
        var currentValue, barWidth
        if (phaseCount < 3)
            return 0
        if (pOutL3.valid && pInL3.valid)
            currentValue = pOutL3.value - pInL3.value
        else
            currentValue = 0
        bar3color = getBarColor (currentValue)
        barWidth = Math.min ( Math.max (currentValue, -maxChargerDisplayed), maxInverterDisplayed) * scaleFactor
        // left of bar is at 0 point
        if (barWidth >= 0)
        {
            bar3offset = zeroOffset
            bar3width = barWidth
        }
        // RIGHT of bar is at 0 point
        else
        {
            bar3width = -barWidth
            bar3offset = zeroOffset + barWidth
        }
    }

    function setLimits ()
    {
        var inverterContinuousPower = inverterContinuousPowerItem.valid ? inverterContinuousPowerItem.value : 0
        var inverterCautionPower = inverterCautionPowerItem.valid ? inverterCautionPowerItem.value : 0
        var inverterPeakPower = inverterPeakPowerItem.valid ? inverterPeakPowerItem.value : 0
        var inverterMode = inverterModeItem.valid ? inverterModeItem.value : 0
        var systemState = systemStateItem.valid ? systemStateItem.value : 0

        // gauges disabled if not receiving valid phase count
        //   or if inverterPeakPower is 0
        if (phaseCount === 0 || inverterPeakPower === 0)
        {
            showGauge = false
            scaleFactor = 0
            zeroOffset = 0
            return
        }

        // inverter not producing output and charger not running - hide the guage
        // Mode:  undefined, Off
        // SystemState: Off, Fault
        if (inverterMode <= 0 || inverterMode === 4 || systemState === 0 || systemState === 2)
            showGauge = false
        else
        {
            maxInverterDisplayed = inverterPeakPower
            inverterOverload = inverterCautionPower
            inverterCaution = inverterContinuousPower
            chargerMaxPower = chargerMaxPowerItem.valid ? chargerMaxPowerItem.value : 0
            maxChargerDisplayed = chargerMaxPower * 1.1
            // make sure regions are in expected order
            if (inverterOverload > maxInverterDisplayed)
                inverterOverload = maxInverterDisplayed
            if (inverterCaution > inverterOverload)
                inverterCaution = inverterOverload
            scaleFactor = root.width / (maxInverterDisplayed + maxChargerDisplayed)
            zeroOffset = maxChargerDisplayed * scaleFactor
            showGauge = true
        }
    }
    function getBarColor (currentValue)
    {
        if (currentValue > inverterOverload || currentValue < -chargerMaxPower)
            return "red"
        else if (currentValue > inverterCaution)
            return "yellow"
        else
            return "green"
    }
}
