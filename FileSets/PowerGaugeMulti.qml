// displays value as a bar surrounded by three range regions
// use for Multi only

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

Item {
	id: root

	property VBusItem darkMode: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }

    property string inverterService: ""
    property VBusItem inverterModeItem: VBusItem { bind: Utils.path(inverterService, "/Mode" ) }
    VBusItem
    {
        id: systemStateItem
        bind: Utils.path("com.victronenergy.system", "/SystemState/State")
    }

    VBusItem
    {
        id: pInL1; bind: Utils.path(inverterService, "/Ac/ActiveIn/L1/P")
        onValidChanged: calculateBar1 ()
        onValueChanged: calculateBar1 ()
    }
    VBusItem
    {
        id: pInL2; bind: Utils.path(inverterService, "/Ac/ActiveIn/L2/P")
        onValidChanged: calculateBar2 ()
        onValueChanged: calculateBar2 ()
    }
    VBusItem
    {
        id: pInL3; bind: Utils.path(inverterService, "/Ac/ActiveIn/L3/P")
        onValidChanged: calculateBar3 ()
        onValueChanged: calculateBar3 ()
    }
    VBusItem
    {
        id: pOutL1; bind: Utils.path(inverterService, "/Ac/Out/L1/P")
        onValidChanged: calculateBar1 ()
        onValueChanged: calculateBar1 ()
    }
    VBusItem
    {
        id: pOutL2; bind: Utils.path(inverterService, "/Ac/Out/L2/P")
        onValidChanged: calculateBar2 ()
        onValueChanged: calculateBar2 ()
    }
    VBusItem
    {
        id: pOutL3; bind: Utils.path(inverterService, "/Ac/Out/L3/P")
        onValidChanged: calculateBar3 ()
        onValueChanged: calculateBar3 ()
    }

    VBusItem
    {
        id: phaseCountItem
        bind: Utils.path(inverterService, "/Ac/NumberOfPhases" )
    }
    property int phaseCount: phaseCountItem.valid ? phaseCountItem.value : 0

    VBusItem
    {
        id: inverterContinuousPowerItem
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/GaugeLimits/ContiuousPower")
        onValueChanged: calculateAllBars ()
        onValidChanged: calculateAllBars ()
    }
    VBusItem
    {
        id: inverterPeakPowerItem
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/GaugeLimits/PeakPower")
        onValueChanged: calculateAllBars ()
        onValidChanged: calculateAllBars ()
    }
    VBusItem
    {
        id: inverterCautionPowerItem
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/GaugeLimits/CautionPower")
        onValueChanged: calculateAllBars ()
        onValidChanged: calculateAllBars ()
    }
    VBusItem
    {
        id: chargerMaxPowerItem
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/GaugeLimits/MaxChargerPower")
        onValueChanged: calculateAllBars ()
        onValidChanged: calculateAllBars ()
    }
	property real inverterMode: inverterModeItem.valid ? inverterModeItem.value : 0
	property real systemState: systemStateItem.valid ? systemStateItem.value : 0
	// inverter not producing output and charger not running - hide the guage
	// Mode:  undefined, Off
	// SystemState: Off, Fault
    property bool showGauge: ! (inverterMode <= 0 || inverterMode === 4 || systemState === 0 || systemState === 2 || totalDisplayedPower == 0)

    property real inverterContinuousPower: inverterContinuousPowerItem.valid ? inverterContinuousPowerItem.value : 0
	property real inverterCautionPower: inverterCautionPowerItem.valid ? inverterCautionPowerItem.value : 0
	property real inverterPeakPower: inverterPeakPowerItem.valid ? inverterPeakPowerItem.value : 0

    property real maxInverterDisplayed: inverterPeakPower * 1.1
    property real inverterOverload: Math.min (inverterCautionPower, inverterPeakPower)
	property real inverterCaution: Math.min (inverterContinuousPower, inverterOverload)

    property real chargerMaxPower: chargerMaxPowerItem.valid ? chargerMaxPowerItem.value : 0
    property real maxChargerDisplayed: chargerMaxPower * 1.1
    property real totalDisplayedPower: maxInverterDisplayed + maxChargerDisplayed
    property real scaleFactor: showGauge ? root.width / (maxInverterDisplayed + maxChargerDisplayed) : 0
    property real zeroOffset: showGauge ? maxChargerDisplayed * scaleFactor : 0

    property int barSpacing: phaseCount > 0 ? Math.max (height / (phaseCount + 1), 2) : 0
    property int barHeight: barSpacing < 3 ? barSpacing : barSpacing - 1
    property int firstBarVertPos: (height - barSpacing * phaseCount) / 2

	property real bar1offset
    property real bar2offset
    property real bar3offset
    property real bar1width
    property real bar2width
    property real bar3width

    property color bar1color: "black"
    property color bar2color: "black"
    property color bar3color: "black"

	Component.onCompleted: calculateAllBars ()

    // chaerger overload range (maxChargerDisplayed to chargerMaxPower)
    Rectangle
    {
        id: chargerOverloadRange
        width: visible ? (maxChargerDisplayed - chargerMaxPower) * scaleFactor : 0
        height: root.height
        clip: true
        color: darkMode.value == 0 ? "#ffb3b3" : "#bf8686"
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
        color: darkMode.value == 0 ? "#99ff99" : "#73bf73"
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
        color: darkMode.value == 0 ? "#bbbb00" : "#8c8c00"
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
        color: darkMode.value == 0 ? "#ffb3b3" : "#bf8686"
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
        width: root.bar1width
        height: barHeight
        clip: true
        color: root.bar1color
        anchors
        {
            top: root.top; topMargin: firstBarVertPos
            left: root.left; leftMargin: root.bar1offset
        }
        visible: showGauge && phaseCount >= 1
    }
    Rectangle
    {
        id: bar2
        width: root.bar2width
        height: barHeight
        clip: true
        color: root.bar2color
        anchors
        {
            top: root.top; topMargin: firstBarVertPos + barSpacing
            left: root.left; leftMargin: root.bar2offset
        }
        visible: showGauge && phaseCount >= 2
    }
    Rectangle
    {
        id: bar3
        width: root.bar3width
        height: barHeight
        clip: true
        color: root.bar3color
        anchors
        {
            top: root.top; topMargin: firstBarVertPos + barSpacing * 2
            left: root.left; leftMargin: root.bar3offset
        }
        visible: showGauge && phaseCount >= 3
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

    function calculateBar1 ()
    {
        var power, barWidth
        if (phaseCount >= 1 && pOutL1.valid && pInL1.valid)
        {
            power = pOutL1.value - pInL1.value
			root.bar1color = getBarColor (power)
			barWidth = Math.min ( Math.max (power, -maxChargerDisplayed), maxInverterDisplayed) * scaleFactor
			// left of bar is at 0 point
			if (barWidth >= 0)
			{
				root.bar1width = barWidth
				root.bar1offset = zeroOffset
			}
			// RIGHT of bar is at 0 point
			else
			{
				root.bar1width = -barWidth
				root.bar1offset = zeroOffset + barWidth
			}
        }
        else
        {
            root.bar1width = 0
            root.bar1offset = zeroOffset
		}
    }
    function calculateBar2 ()
    {
        var power, barWidth
        if (phaseCount >= 2 && pOutL2.valid && pInL2.valid)
        {
            power = pOutL2.value - pInL2.value
			root.bar2color = getBarColor (power)
			barWidth = Math.min ( Math.max (power, -maxChargerDisplayed), maxInverterDisplayed) * scaleFactor
			// left of bar is at 0 point
			if (barWidth >= 0)
			{
				root.bar2width = barWidth
				root.bar2offset = zeroOffset
			}
			// RIGHT of bar is at 0 point
			else
			{
				root.bar2width = -barWidth
				root.bar2offset = zeroOffset + barWidth
			}
        }
        else
        {
            root.bar2width = 0
            root.bar2offset = zeroOffset
		}
    }
    function calculateBar3 ()
    {
        var power, barWidth
        if (phaseCount >= 3 && pOutL3.valid && pInL3.valid)
        {
            power = pOutL3.value - pInL3.value
			root.bar3color = getBarColor (power)
			barWidth = Math.min ( Math.max (power, -maxChargerDisplayed), maxInverterDisplayed) * scaleFactor
			// left of bar is at 0 point
			if (barWidth >= 0)
			{
				root.bar3width = barWidth
				root.bar3offset = zeroOffset
			}
			// RIGHT of bar is at 0 point
			else
			{
				root.bar3width = -barWidth
				root.bar3offset = zeroOffset + barWidth
			}
        }
        else
        {
            root.bar3width = 0
            root.bar3offset = zeroOffset
		}
    }

    function getBarColor (power)
    {
        if (power > inverterOverload || power < -chargerMaxPower)
            return darkMode.value == 0 ? "#ff0000" : "#bf0000"
        else if (power > inverterCaution)
            return darkMode.value == 0 ? "#ffff00" : "#bfbf00"
        else
            return darkMode.value == 0 ? "#008000" : "#006000"
    }

	function calculateAllBars ()
	{
		    calculateBar1 ()
		    calculateBar2 ()
		    calculateBar3 ()
	}
}
