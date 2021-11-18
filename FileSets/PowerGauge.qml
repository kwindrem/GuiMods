// displays value as a bar surrounded by three range regions
// use for I/O, PV inverter & charger

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

Item {
	id: root
	width: parent.width

    property variant connection
    onConnectionChanged:
    {
        setPhaseCount ()
        setLimits ()
    }
    property int connectionPhaseCount: connection.phaseCount != undefined && connection.phaseCount.valid ? connection.phaseCount.value : 0
    onConnectionPhaseCountChanged:
    {
        setPhaseCount ()
        setLimits ()
    }

    property int phaseCount: 0

    property string maxForwardPowerParameter: ""
    VBusItem
    {
        id: maxForwardLimitItem
        bind: root.maxForwardPowerParameter
        onValueChanged: setLimits ()
        onValidChanged: setLimits ()
    }

    property string maxReversePowerParameter: ""
    VBusItem
    {
        id: maxReverseLimitItem
        bind: root.maxReversePowerParameter
        onValueChanged: setLimits ()
        onValidChanged: setLimits ()
    }

    property real inPowerLimit: sys.acInput.inCurrentLimit.value * sys.acInput.voltageL1.value
    onInPowerLimitChanged:
    {
        if (connection === sys.acInput)
            setLimits ()
    }

    property real maxForwardLimit: 0
    property real maxDisplayed: 0
    property real maxReverseLimit: 0
    property real maxLoadDisplayed: 0
    property real scaleFactor
    property real zeroOffset

    property int barSpacing: phaseCount > 0 ? Math.max (height / (phaseCount + 1), 2) : 0
    property int barHeight: barSpacing < 3 ? barSpacing : barSpacing - 1
    property int firstBarVertPos: (height - barSpacing * phaseCount) / 2
    property real bar1offset
    property real bar2offset
    property real bar3offset
    
    property color bar1color: "black"
    property color bar2color: "black"
    property color bar3color: "black"
    
    property bool showGauge: false
    
    Component.onCompleted:
    {
        setPhaseCount ()
        setLimits ()
    } 

    // overload range Left
    Rectangle
    {
        id: overloadLeft
        width: showGauge ? scaleFactor * (maxLoadDisplayed - maxReverseLimit) : 0
        height: root.height
        clip: true
        color: "#ffb3b3"
        visible: showGauge
        anchors
        {
            top: root.top
            left: root.left;
        }
    }
    // OK range (both left and right in a single rectangle)
    Rectangle
    {
        id: okRange
        width: showGauge ? scaleFactor * (maxForwardLimit + maxReverseLimit) : 0
        height: root.height
        clip: true
        color: "#99ff99"
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
        width: showGauge ? scaleFactor * (maxDisplayed - maxForwardLimit) : 0
        height: root.height
        clip: true
        color: "#ffb3b3"
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
        width: visible ? calculateBar1width () : 0
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
        width: visible ? calculateBar2width () : 0
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
        width: visible ? calculateBar3width () : 0
        height: barHeight
        clip: true
        color: bar3color
        anchors
        {
            top: root.top; topMargin: firstBarVertPos + barSpacing * 2
            left: root.left; leftMargin: bar3offset
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
        if (phaseCount < 1)
            return 0
        if (root.connection === sys.pvCharger || root.connection === sys.dcSystem)
            currentValue = root.connection.power.valid ? root.connection.power.value : 0
        else
            currentValue = root.connection.powerL1.valid ? root.connection.powerL1.value : 0
        bar1color = getBarColor (currentValue)
        barWidth = Math.min ( Math.max (currentValue, -maxLoadDisplayed), maxDisplayed) * scaleFactor
        // left of bar is at 0 point
        if (barWidth >= 0)
        {
            bar1offset = zeroOffset
            return barWidth
        }
        // RIGHT of bar is at 0 point
        else
        {
            bar1offset = zeroOffset + barWidth
            return -barWidth
        }
        return bar1width
    }
    function calculateBar2width ()
    {
        var currentValue
        if (phaseCount < 2)
            return 0
        currentValue = root.connection.powerL2.valid ? root.connection.powerL2.value : 0
        bar2color = getBarColor (currentValue)
        barWidth = Math.min ( Math.max (currentValue, -maxLoadDisplayed), maxDisplayed) * scaleFactor
        // left of bar is at 0 point
        if (barWidth >= 0)
        {
            bar2offset = zeroOffset
            return barWidth
        }
        // RIGHT of bar is at 0 point
        else
        {
            bar1offset = zeroOffset + barWidth
            return -barWidth
        }
    }
    function calculateBar3width ()
    {
        var currentValue
        if (phaseCount < 3)
            return 0
        currentValue = root.connection.powerL3.valid ? root.connection.powerL3.value : 0
        bar3color = getBarColor (currentValue)
        barWidth = Math.min ( Math.max (currentValue, -maxLoadDisplayed), maxDisplayed) * scaleFactor
        // left of bar is at 0 point
        if (barWidth >= 0)
        {
            bar3offset = zeroOffset
            return barWidth
        }
        // RIGHT of bar is at 0 point
        else
        {
            bar3offset = zeroOffset + barWidth
            return -barWidth
        }
    }

    function setLimits ()
    {
        // gauges disabled if not receiving valid phase count
        //   or connection not defined
        if (phaseCount === 0 || sys === undefined)
        {
            showGauge = false
            return
        }
        
        if (root.connection === sys.acInput)
            maxForwardLimit = inPowerLimit
        else
            maxForwardLimit = maxForwardLimitItem.valid ? maxForwardLimitItem.value : 0
        // gauges disabled if maxForwardLimit is 0
        if (maxForwardLimit === 0)
        {
            showGauge = false
            return
        }
        maxReverseLimit = maxReverseLimitItem.valid ? maxReverseLimitItem.value : 0
                
        // overload range is 10%
        // at left end also if showing load values to left of zero
        var overload = (maxForwardLimit + maxReverseLimit) * 0.1
        maxDisplayed = maxForwardLimit + overload
        if (maxReverseLimit > 0)
            maxLoadDisplayed = maxReverseLimit + overload
        else
            maxLoadDisplayed = 0

        scaleFactor = root.width / (maxDisplayed + maxLoadDisplayed)
        zeroOffset = maxLoadDisplayed * scaleFactor

        showGauge = true

    }
    
    // for connections, phaseCount comes from the connection (if defined)
    // phaseCount is always 1 for the PV charger connection
    function setPhaseCount ()
    {
        if (root.connection === undefined)
            phaseCount = 0
        else if (root.connection === sys.pvCharger || root.connection === sys.dcSystem)
            phaseCount = 1
        else if (root.connection.l1AndL2OutShorted)
            phaseCount = 1
        else
            phaseCount = root.connectionPhaseCount
    }

    function getBarColor (currentValue)
    {
        if (currentValue > maxForwardLimit || currentValue < -maxReverseLimit)
            return "red"
        else
            return "green"
    }
}
