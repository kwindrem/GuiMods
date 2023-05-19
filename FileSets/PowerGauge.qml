// displays value as a bar surrounded by three range regions
// use for I/O, PV inverter & charger

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

Item {
	id: root

////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 1

    property variant connection

    property bool reversePower: false
    property bool useInputCurrentLimit: false
    property variant endLabelFontSize: 16
    property color endLabelBackgroundColor: "transparent"

    property int phaseCount: root.connection == undefined ? 0 : root.connection.l1AndL2OutShorted ? 1 : connection.phaseCount != undefined && connection.phaseCount.valid ? connection.phaseCount.value : 1


    property string maxForwardPowerParameter: ""
    VBusItem { id: maxForwardLimitItem; bind: root.maxForwardPowerParameter }

    property string maxReversePowerParameter: ""
    VBusItem { id: maxReverseLimitItem; bind: root.maxReversePowerParameter }

    property real inPowerLimit: sys.acInput.inCurrentLimit.valid ? sys.acInput.inCurrentLimit.value * sys.acInput.voltageL1.value : 0

    property real maxForwardLimit: useInputCurrentLimit ? inPowerLimit : maxForwardLimitItem.valid ? maxForwardLimitItem.value : 0
    property real maxReverseLimit: maxReverseLimitItem.valid ? maxReverseLimitItem.value : 0
	// overload range is 10% of forward to reverse limits
	property real overload: (maxForwardLimit + maxReverseLimit) * 0.1
	property real maxForwardDisplayed: maxForwardLimit > 0 ? maxForwardLimit + overload : 0
	property real maxReverseDisplayed: maxReverseLimit > 0 ? maxReverseLimit + overload : 0
	property real totalPowerDisplayed: maxForwardDisplayed + maxReverseDisplayed

	property bool showLabels: false
	property variant endLabelColor: "white"
    property real labelOffset: 15
	property real showLeftLabel: showGauge && showLabels && maxReverseLimit != 0
	property bool showRightLabel: showGauge && showLabels && maxForwardLimit != 0
	property int labelCount: (showLeftLabel ? 1 : 0) + (showRightLabel ? 1 : 0)

	property bool showGauge: root.connection != undefined && totalPowerDisplayed > 0 && phaseCount > 0
	property real scaleFactor: showGauge ? (root.width - (labelCount * labelOffset)) / totalPowerDisplayed : 0
	property real zeroOffset: showGauge ? ( maxReverseDisplayed * scaleFactor + (showLeftLabel ? labelOffset : 0 )) : 0

    property int barSpacing: phaseCount > 0 ? Math.max (height / (phaseCount + 1), 2) : 0
    property int barHeight: barSpacing < 3 ? barSpacing : barSpacing - 1
    property int firstBarVertPos: (height - barSpacing * phaseCount) / 2
    property real bar1offset
    property real bar2offset
    property real bar3offset

    property color bar1color: "black"
    property color bar2color: "black"
    property color bar3color: "black"

    // left end label
	Rectangle
	{
		anchors.fill: leftlabelText
		color: endLabelBackgroundColor
        visible: showLeftLabel
	}
    TileText
    {
		id: leftlabelText
        text: "S"
        color: endLabelColor
        font.pixelSize: endLabelFontSize
        width: labelOffset
        anchors
        {
			verticalCenter: root.verticalCenter
			verticalCenterOffset: 1
            left: root.left
        }
        visible: showLeftLabel
    }
    // right end label
    Rectangle
	{
		anchors.fill: rightLabelText
		color: endLabelBackgroundColor
        visible: showRightLabel
	}
    TileText
    {
		id: rightLabelText
        text: "C"
        color: endLabelColor
        font.pixelSize: endLabelFontSize
        width: labelOffset
        anchors
        {
			verticalCenter: leftlabelText.verticalCenter
            right: root.right
        }
        visible: showRightLabel
    }
    // overload range Left
    Rectangle
    {
        id: overloadLeft
        width: showGauge ? scaleFactor * (maxReverseDisplayed - maxReverseLimit) : 0
        height: root.height
        clip: true
////// GuiMods — DarkMode
        color: !darkMode ? "#ffb3b3" : "#bf8686"
        visible: showGauge
        anchors
        {
            top: root.top
            left: root.left; leftMargin: showLeftLabel ? labelOffset : 0
        }
    }
    // OK range (both left and right in a single rectangle)
    Rectangle
    {
        id: okRange
        width: showGauge ? scaleFactor * (maxForwardLimit + maxReverseLimit) : 0
        height: root.height
        clip: true
////// GuiMods — DarkMode
        color: !darkMode ? "#99ff99" : "#73bf73"
        visible: showGauge
        anchors
        {
            top: root.top
            left: overloadLeft.right
        }
    }
    // overload range right
    Rectangle
    {
        id: overloadRight
        width: showGauge ? scaleFactor * (maxForwardDisplayed - maxForwardLimit) : 0
        height: root.height
        clip: true
////// GuiMods — DarkMode
        color: !darkMode ? "#ffb3b3" : "#bf8686"
        visible: showGauge
        anchors
        {
            top: root.top
            left: okRange.right
        }
    }

    // actual bars
    Rectangle
    {
        id: bar1
        width: phaseCount >= 1 ? calculateBar1width () : 0
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
        width: phaseCount >= 2 ? calculateBar2width () : 0
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
        width: phaseCount >= 3 ? calculateBar3width () : 0
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
        visible: showGauge && maxReverseLimit > 0
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
		if (root.connection.powerL1 != undefined)
            currentValue = root.connection.powerL1.valid ? root.connection.powerL1.value : 0
		else if (root.connection.power != undefined)
            currentValue = root.connection.power.valid ? root.connection.power.value : 0
		else
            currentValue = 0

        if (reversePower)
			currentValue = -currentValue

        root.bar1color = getBarColor (currentValue)
        barWidth = Math.min ( Math.max (currentValue, -maxReverseDisplayed), maxForwardDisplayed) * scaleFactor
        // left of bar is at 0 point
        if (barWidth >= 0)
        {
			root.bar1offset = zeroOffset
            return barWidth
        }
        // RIGHT of bar is at 0 point
        else
        {
            root.bar1offset = zeroOffset + barWidth
            return -barWidth
        }
    }
    function calculateBar2width ()
    {
        var currentValue, barWidth
        currentValue = root.connection.powerL2.valid ? root.connection.powerL2.value : 0
        if (reversePower)
			currentValue = -currentValue
		root.bar2color = getBarColor (currentValue)
        barWidth = Math.min ( Math.max (currentValue, -maxReverseDisplayed), maxForwardDisplayed) * scaleFactor
        // left of bar is at 0 point
        if (barWidth >= 0)
        {
			root.bar2offset = zeroOffset
            return barWidth
        }
        // RIGHT of bar is at 0 point
        else
        {
			root.bar2offset = zeroOffset + barWidth
            return -barWidth
        }
    }
    function calculateBar3width ()
    {
        var currentValue, barWidth
        currentValue = root.connection.powerL3.valid ? root.connection.powerL3.value : 0
        if (reversePower)
			currentValue = -currentValue
		root.bar3color = getBarColor (currentValue)
        barWidth = Math.min ( Math.max (currentValue, -maxReverseDisplayed), maxForwardDisplayed) * scaleFactor
        // left of bar is at 0 point
        if (barWidth >= 0)
        {
			root.bar3offset = zeroOffset
            return barWidth
        }
        // RIGHT of bar is at 0 point
        else
        {
			root.bar3offset = zeroOffset + barWidth
            return -barWidth
        }
    }

    function getBarColor (currentValue)
    {
        if (currentValue > maxForwardLimit || currentValue < -maxReverseLimit)
////// GuiMods — DarkMode
            return !darkMode ? "#ff0000" : "#bf0000"
        else
////// GuiMods — DarkMode
            return !darkMode ? "#008000" : "#006000"
    }
}
