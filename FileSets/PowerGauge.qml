// displays value as a bar surrounded by three range regions

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

Item {
	id: root
	width: parent.width

    property variant connection

    // if connection is undefined, then this instance is for the inverter, so use it's phase count
    property string inverterService: ""
    property bool useInverterInfo: false
    property VBusItem inverterPhaseCount: VBusItem { bind: Utils.path(inverterService, "/Ac/NumberOfPhases" ) }
    property VBusItem inverterModeItem: VBusItem { bind: Utils.path(inverterService, "/Mode" ) }
    property int inverterMode: inverterModeItem.valid ? inverterModeItem.value : 0

    property int phaseCount: 0

    VBusItem
    {
        id: inverterContinuousPowerItem
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/GaugeLimits/ContiuousPower")
        onValueChanged: setLimits ()
    }
    property real inverterContinuousPower: inverterContinuousPowerItem.valid ? inverterContinuousPowerItem.value : 0
    VBusItem
    {
        id: inverterPeakPowerItem
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/GaugeLimits/PeakPower")
        onValueChanged: setLimits ()
    }
    property real inverterPeakPower: inverterPeakPowerItem.valid ? inverterPeakPowerItem.value : 0
    VBusItem
    {
        id: inverterCautionPowerItem
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/GaugeLimits/CautionPower")
        onValueChanged: setLimits ()
    }
    property real inverterCautionPower: inverterCautionPowerItem.valid ? inverterCautionPowerItem.value : 0
    VBusItem
    {
        id: outputPowerLimitItem
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/GaugeLimits/AcOutputMaxPower")
        onValueChanged: setLimits ()
    }
    property real outPowerLimit: outputPowerLimitItem.valid ? outputPowerLimitItem.value : 0
    VBusItem
    {
        id: pvChargerMaxPowerItem
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/GaugeLimits/PvChargerMaxPower")
        onValueChanged: setLimits ()
    }
    property real pvChargerMaxPower: pvChargerMaxPowerItem.valid ? pvChargerMaxPowerItem.value : 0
    VBusItem
    {
        id: systemStateItem
        bind: Utils.path("com.victronenergy.system", "/SystemState/State")
        onValueChanged: setLimits ()
    }
    property int systemState: systemStateItem.valid ? systemStateItem.value : 0

    property real inPowerLimit: sys.acInput.inCurrentLimit.value * sys.acInput.voltageL1.value

    property real barMax: 0
    property real overload: 0
    property real caution: 0

    property int barHeight: phaseCount > 0 ? Math.max (height / (phaseCount + 1), 2) : 0
    property int firstBarVertPos: (height - barHeight * phaseCount) / 2
    
    property color bar1color: "black"
    property color bar2color: "black"
    property color bar3color: "black"
    
    Component.onCompleted:
    {
        setPhaseCount ()
        setLimits ()
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
        if (inverterPeakPower === 0 || sys === undefined)
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
            caution = overload // no caution - overload range
        }
        // acLoad power limits
        else if (root.connection === sys.acLoad)
        {
            // Inverter Only - only multi contribution
            if (inverterMode === 2 || systemState === 9)
            {
                barMax = inverterPeakPower
                overload = inverterContinuousPower
                caution = inverterCautionPower
            }
            // Charger Only - only AC input contribution
            else if (inverterMode === 1)
            {
                barMax = inPowerLimit * 1.2
                overload = inPowerLimit
                caution = inPowerLimit
            }
            // On - AC input + multi contribution
            else if (inverterMode === 3 && systemState >= 3)
            {
                barMax = inPowerLimit + inverterPeakPower
                overload = inPowerLimit + inverterContinuousPower
                caution = inPowerLimit + inverterCautionPower
            }
            // inverter is off or undefined - no AC output
            else
            {
                barMax = 0
                overload = 0
                caution = 0
            }
            // apply system output limit
            if (outPowerLimit != 0 && overload > outPowerLimit)
            {
                overload = outPowerLimit
                barMax = outPowerLimit * 1.2                
            }
        }
        else if (root.connection === sys.pvCharger || root.connection === sys.pvOnAcOut
                || root.connection === sys.pvOnAcIn1 || root.connection === sys.pvOnAcIn2)
        {
            overload = pvChargerMaxPower
            barMax = overload * 1.2
            caution = overload // no caution - overload range
        }
        // inverter power limits
        else 
        {
            // inverter not producing output - hide the guage
            // Mode:  undefined, Charger Only, Off
            // SystemState: Off, Fault
            if (inverterMode <= 1 || inverterMode === 4 || systemState === 0 || systemState === 2)
            {
                barMax = 0
                overload = 0
                caution = 0
            }
            else
            {
                barMax = inverterPeakPower
                overload = inverterContinuousPower
                caution = inverterCautionPower
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
        else if (root.connection === sys.pvCharger)
        {
            currentValue = sys.pvCharger.power.valid ? sys.pvCharger.power.value : 0
        }
        else if (root.connection === sys.pvOnAcOut)
        {
            currentValue = sys.pvOnAcOut.power.valid ? sys.pvOnAcOut.power.value : 0
        }
        else if (root.connection === sys.pvOnAcIn1)
        {
            currentValue = sys.pvOnAcIn1.power.valid ? sys.pvOnAcIn1.power.value : 0
        }
        else if (root.connection === sys.pvOnAcIn2)
        {
            currentValue = sys.pvOnAcIn2.power.valid ? sys.pvOnAcIn2.power.value : 0
        }
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

    // phaseCount comes from the connection (if defined)
    // phaseCount is always 1 for the PV charger connection
    // for the inverter/multi, connection will not be defined
    function setPhaseCount ()
    {
        // connection passed from parent
        if (root.connection !== undefined)
        {
            if (root.connection === sys.pvCharger)
                phaseCount = 1
            else if (root.connection.phaseCount.valid)
            {
                if (root.connection.l1AndL2OutShorted)
                    phaseCount = 1
                else
                    phaseCount = root.connection.phaseCount.value
            }
            else
                phaseCount = 0
        }
        // Multi or inverter can't define a connection
        // so service name is passed from parent
        // VE.Direct inverters don't set the phase count - only single phase
        else if (useInverterInfo)
        {
            if (inverterPhaseCount.valid)
                phaseCount =  inverterPhaseCount.value
            else
                phaseCount = 1
        }
        else
            phaseCount = 0
    }
}
