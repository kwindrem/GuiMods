// displays value as a bar surrounded by three range regions

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

Item {
	id: root
	width: parent.width

    property variant connection

    property bool useMultiInfo: false

    // if connection is undefined, then this instance is for the inverter, so use it's phase count
    property VBusItem vebusService: VBusItem { bind: Utils.path("com.victronenergy.system", "/VebusService") }
    property VBusItem inverterPhaseCount: VBusItem { bind: Utils.path(vebusService.value, "/Ac/NumberOfPhases" ) }

    property int phaseCount: useMultiInfo
            ? inverterPhaseCount.valid ? inverterPhaseCount.value : 0
            : root.connection !== undefined && root.connection.phaseCount.valid ? root.connection.phaseCount.value : 0
    
    property VBusItem inverterContinuousPowerItem: VBusItem { bind: Utils.path("com.victronenergy.settings", "/Settings/InverterLimits/ContiuousPower") }
    property VBusItem inverterPeakPowerItem: VBusItem { bind: Utils.path("com.victronenergy.settings", "/Settings/InverterLimits/PeakPower") }
    property VBusItem inverterCautionPowerItem: VBusItem { bind: Utils.path("com.victronenergy.settings", "/Settings/InverterLimits/CautionPower") }
    property VBusItem outputPowerLimitItem: VBusItem { bind: Utils.path("com.victronenergy.settings", "/Settings/InverterLimits/OutputPowerLimit") }
    property VBusItem systemStateItem: VBusItem { bind: Utils.path("com.victronenergy.system", "/SystemState/State") }
    property real inverterContinuousPower: inverterContinuousPowerItem.valid ? inverterContinuousPowerItem.value : 0
    property real inverterPeakPower: inverterPeakPowerItem.valid ? inverterPeakPowerItem.value : 0
    property real inverterCautionPower: inverterCautionPowerItem.valid ? inverterCautionPowerItem.value : 0
    property real outPowerLimit: outputPowerLimitItem.valid ? outputPowerLimitItem.value : 0
    property real inPowerLimit: sys.acInput.inCurrentLimit.value * sys.acInput.inVoltageL1.value
    property int inverterState: systemStateItem.valid ? systemStateItem.value : 0

    property real barMax: 0
    property real overload: 0
    property real caution: 0

    property int barHeight: phaseCount > 0 ? Math.max (height / (phaseCount + 1), 2) : 0
    property int firstBarVertPos: (height - barHeight * phaseCount) / 2
    
    property color bar1color: "black"
    property color bar2color: "black"
    property color bar3color: "black"
    
    // reset bar limits every 2 seconds since there is no other real way to trigger this
    property Timer timer: Timer
    {
        interval: 2000
        running: true
        repeat: true
        onTriggered: setLimits ()
    }
    
    // OK range (0 to caution)
    Rectangle
    {
        id: okRange
        width: barMax != 0 ? root.width * caution / barMax : 0
        height: root.height
        clip: true
        color: "#99ff99"
        visible: width > 0 && phaseCount > 0
        anchors
        {
            top: root.top
            left: root.left
        }
    }
    // caution range (caution to overload)
    Rectangle
    {
        id: cautionRange
        width: barMax != 0 ? root.width * (overload - caution) / barMax : 0
        height: root.height
        clip: true
        color: "#bbbb00"
        visible: width > 0 && phaseCount > 0
        anchors
        {
            top: root.top
            left: root.left; leftMargin: root.width * caution / barMax
        }
    }
    // overload range (overload to barMax)
    Rectangle
    {
        id: overloadRange
        width: barMax != 0 ? root.width * (barMax - overload) / barMax : 0
        height: root.height
        clip: true
        color: "#ffb3b3"
        visible: width > 0 && phaseCount > 0
        anchors
        {
            top: root.top
            left: root.left; leftMargin: root.width * overload / barMax
        }
    }
    // actual bars
    Rectangle
    {
        id: bar1
        width: barMax != 0 ? root.width * currentValueL1 () / barMax : 0
        height: barHeight
        clip: true
        color: bar1color
        anchors
        {
            top: root.top; topMargin: firstBarVertPos
            left: root.left
        }
        visible: width > 0 && phaseCount >= 1
    }
    Rectangle
    {
        id: bar2
        width: barMax != 0 ? root.width * currentValueL2 () / barMax : 0
        height: barHeight
        clip: true
        color: bar2color
        anchors
        {
            top: root.top; topMargin: firstBarVertPos + barHeight
            left: root.left
        }
        visible: width > 0 && phaseCount >= 1
    }
    Rectangle
    {
        id: bar3
        width: barMax != 0 ? root.width * currentValueL3 () / barMax : 0
        height: barHeight
        clip: true
        color: bar3color
        anchors
        {
            top: root.top; topMargin: firstBarVertPos + barHeight * 2
            left: root.left
        }
        visible: width > 0 && phaseCount >= 1
    }

    function setLimits ()
    {
        // guages disabled if inverterPeakPower is 0
        if (inverterPeakPower === 0)
        {
            barMax = 0
            overload = 0
            caution = 0
            return
        }
        if (root.connection === sys.acInput)
        {
            barMax = inPowerLimit * 1.2
            overload = inPowerLimit
            caution = inPowerLimit // no caution - overload range
        }
        // acLoad and inverter power limits
        else
        {
            barMax = inverterPeakPower
            overload = inverterContinuousPower
            caution = inverterCautionPower
            if (root.connection === sys.acLoad)
            {
                // if acLoads and not inverting, add in shore power limit
                if (inverterState != 9)
                {
                    barMax += inPowerLimit
                    overload += inPowerLimit
                    caution += inPowerLimit
                }
                // apply system output limit
                if (outPowerLimit != 0 && overload > outPowerLimit)
                {
                    overload = outPowerLimit
                    barMax = outPowerLimit * 1.2                
                }
            }
        }
        
        // make sure regions are in expected order
        if (overload > barMax)
            overload = barMax
        if (caution > overload)
            caution = overload
    }
    
    function currentValueL1 ()
    {
        var currentValue
        if (phaseCount < 1)
            return 0
        if (root.connection === sys.acInput)
            currentValue = sys.acInput.powerL1.valid ? sys.acInput.powerL1.value : 0
        else
        {
            currentValue = sys.acLoad.powerL1.valid ? sys.acLoad.powerL1.value : 0 
            // subtract off input power for the inverter bar graph
            if (root.connection != sys.acLoad && sys.acInput.powerL1.valid )
                currentValue -= sys.acInput.powerL1.value
        }
        bar1color = currentValue > overload ? "red" : currentValue > caution ? "yellow" : "green"

        return Math.max (currentValue, 0)
    }
    function currentValueL2 ()
    {
        var currentValue
        if (phaseCount < 2)
            return 0
        if (root.connection === sys.acInput)
            currentValue = sys.acInput.powerL2.valid ? sys.acInput.powerL2.value : 0
        else
        {
            currentValue = sys.acLoad.powerL2.valid ? sys.acLoad.powerL2.value : 0
            // subtract off input power for the inverter bar graph
            if (root.connection != sys.acLoad && sys.acInput.powerL2.valid )
                currentValue -= sys.acInput.powerL2.value
        }

        bar2color = currentValue > overload ? "red" : currentValue > caution ? "yellow" : "green"
        return Math.max (currentValue, 0)
    }
    function currentValueL3 ()
    {
        var currentValue
        if (phaseCount < 3)
            return 0
        if (root.connection === sys.acInput)
            currentValue = sys.acInput.powerL3.valid ? sys.acInput.powerL3.value : 0
        else
        {
            currentValue = sys.acLoad.powerL3.valid ? sys.acLoad.powerL3.value : 0
            // subtract off input power for the inverter bar graph
            if (root.connection != sys.acLoad && sys.acInput.powerL3.valid )
                currentValue -= sys.acInput.powerL3.value
        }

        bar3color = currentValue > overload ? "red" : currentValue > caution ? "yellow" : "green"
        return Math.max (currentValue, 0)
    }
}
