////// detail page for setting input current limit
////// and displaying AC input details
////// pushed from Flow overview

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0
import "enhancedFormat.js" as EnhFmt

MbPage {
	id: root
 
    title: "AC Input detail"
    
    property variant sys: theSystem
    property string systemPrefix: "com.victronenergy.system"
    property string settingsPrefix: "com.victronenergy.settings"

	property int fontPixelSize: 18
	property color buttonColor: "#979797"
    property color pressedColor: "#d3d3d3"
    property color backgroundColor: "#b3b3b3"

    property int buttonHeight: 40
    property int tableColumnWidth: 80
    property int rowTitleWidth: 100
    property int dataColumns: 3
    property int totalDataWidth: tableColumnWidth * dataColumns
    property int legColumnWidth: phaseCount <= 1 ? totalDataWidth : totalDataWidth / phaseCount

    property int numberOfMultis: 0
    property int numberOfInverters: 0
    property string inverterService: ""
    property bool isMulti: numberOfMultis === 1
    property bool isInverter: numberOfMultis === 0 && numberOfInverters === 1
    property int phaseCount: sys.acInput.phaseCount.valid ? sys.acInput.phaseCount.value : 0

	property string gridMeterService: ""
	property string gensetService: ""
    property string meterService: activeSource.valid && activeSource.value === 2 ? gensetService : gridMeterService
    property bool useMeter: meterService != ""
    property string pathPrefix: useMeter ? Utils.path ( meterService, "/Ac/") : Utils.path (inverterService, "/Ac/ActiveIn/")
    property string voltageSuffix: useMeter ? "/Voltage" : "/V"
    property string currentSuffix: useMeter ? "/Current" : "/I"

    

    property real actualCurrentLimit: 0
    property real newCurrentLimit: 0
    
    VBusItem { id: acLimitPreset1Item; bind: Utils.path(settingsPrefix, "/Settings/GuiMods/AcCurrentLimit/Preset1") }
    VBusItem { id: acLimitPreset2Item; bind: Utils.path(settingsPrefix, "/Settings/GuiMods/AcCurrentLimit/Preset2") }
    VBusItem { id: acLimitPreset3Item; bind: Utils.path(settingsPrefix, "/Settings/GuiMods/AcCurrentLimit/Preset3") }
    VBusItem { id: acLimitPreset4Item; bind: Utils.path(settingsPrefix, "/Settings/GuiMods/AcCurrentLimit/Preset4") }
    property real acLimitPreset1: acLimitPreset1Item.valid ? acLimitPreset1Item.value : 0
    property real acLimitPreset2: acLimitPreset2Item.valid ? acLimitPreset2Item.value : 0
    property real acLimitPreset3: acLimitPreset3Item.valid ? acLimitPreset3Item.value : 0
    property real acLimitPreset4: acLimitPreset4Item.valid ? acLimitPreset4Item.value : 0

	property bool currentLimitIsAdjustable: currentLimitIsAdjustableItem.valid && currentLimitIsAdjustableItem.value == 1  && currentLimitItem.valid

    Component.onCompleted: { discoverServices(); getActualCurrent () }

    VBusItem
    {
        id: currentLimitIsAdjustableItem
        bind: Utils.path(inverterService, "/Ac/ActiveIn/CurrentLimitIsAdjustable")
        onValueChanged: getActualCurrent ()
        onValidChanged: getActualCurrent ()
    }
    VBusItem
    {
        id: currentLimitItem
        bind: Utils.path(inverterService, "/Ac/ActiveIn/CurrentLimit")
        onValueChanged: getActualCurrent ()
        onValidChanged: getActualCurrent ()
    }

    VBusItem { id: voltageL1; bind: Utils.path(pathPrefix, "L1", voltageSuffix) }
    VBusItem { id: voltageL2; bind: Utils.path(pathPrefix, "L2", voltageSuffix) }
    VBusItem { id: voltageL3; bind: Utils.path(pathPrefix, "L3", voltageSuffix) }

    VBusItem { id: currentL1; bind: Utils.path (pathPrefix, "L1", currentSuffix) }
    VBusItem { id: currentL2; bind: Utils.path (pathPrefix, "L2", currentSuffix) }
    VBusItem { id: currentL3; bind: Utils.path (pathPrefix, "L3", currentSuffix) }

    VBusItem { id: frequencyL1; bind: Utils.path(inverterService, "/Ac/ActiveIn/L1/F") }
    VBusItem { id: activeSource; bind: Utils.path(systemPrefix, "/Ac/ActiveIn/Source") }
    VBusItem { id: activeInput; bind: Utils.path(inverterService, "/Ac/ActiveIn/ActiveInput") }

    // background
    Rectangle
    {
        anchors
        {
            fill: parent
        }
        color: root.backgroundColor
    }

    Row
    {
        spacing: 5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 6
        Column 
        {
            spacing: 2
            Row
            {
                PowerGauge
                {
                    id: gauge
                    width: rowTitleWidth + totalDataWidth
                    height: 15
                    connection: sys.acInput
					useInputCurrentLimit: true
					maxForwardPowerParameter: "" // handled internally - uses input current limit and AC input voltage
					maxReversePowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxFeedInPower"
                }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr("Total Power") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: totalDataWidth; horizontalAlignment: Text.AlignHCenter
                    text:
                    {
                        if (sys.acInput.power.valid)
                            return sys.acInput.power.value.toFixed (0) + " W"
                        else
                            return "--"
                    }                        
                }
                visible: phaseCount >= 2
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("Source") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: totalDataWidth; horizontalAlignment: Text.AlignHCenter
                        text: getAcSource (sys.acSource) }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: "" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L1" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L2" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L3"; visible: phaseCount >= 3 }
                visible: phaseCount >= 2
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("Power") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.acInput.powerL1) }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.acInput.powerL2); visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.acInput.powerL3); visible: phaseCount >= 3 }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("Voltage") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (voltageL1, " V") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (voltageL2, " V"); visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (voltageL3, " V"); visible: phaseCount >= 3 }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("Current") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: useMeter ? EnhFmt.formatVBusItem (currentL1, " A") : calculateCurrent (sys.acInput.powerL1, voltageL1) }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: useMeter ? EnhFmt.formatVBusItem (currentL2, " A") : calculateCurrent (sys.acInput.powerL2, voltageL2);
								visible: phaseCount >= 2 }
               Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
						text: useMeter ? EnhFmt.formatVBusItem (currentL3, " A") : calculateCurrent (sys.acInput.powerL3, voltageL3);
								visible: phaseCount >= 3 }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("Frequency") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: totalDataWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (frequencyL1, " Hz") }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("CurrentLimit") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: totalDataWidth; horizontalAlignment: Text.AlignHCenter
                        text:
                        {
                            var newText
                            if (newCurrentLimit != actualCurrentLimit)
                                newText = qsTr("  New ") + newCurrentLimit.toFixed (1) + " A"
                            else
                                newText = ""
                            return currentLimitItem.valid ? currentLimitItem.value.toFixed (1) + " A" + newText: "--" }
                }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth + totalDataWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Current values are estimated")
                        visible: ! useMeter }
            }
        }
        Column
        {
			id: currentButtonColumn
            width: 128
            spacing: 4

            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: currentButtonColumn.width; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Current Limit") }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: currentButtonColumn.width; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("is not adjustable")}
				visible: !currentLimitIsAdjustable
            }
            Row
            {
				visible: currentLimitIsAdjustable
                width: (parent.width / 2) - 2
                spacing: 4
                DetailButton
                {
                    id: preset1button
                    baseColor: newCurrentLimit === acLimitPreset1 ? "black" : root.buttonColor
                    pressedColor: root.pressedColor
                    opacity: acLimitPreset1 === 0 ? 0.001 : 1
                    height: 40
                    width: parent.width
                    onClicked: setNewValue (acLimitPreset1)
                    enabled: acLimitPreset1 === 0 ? false : true
                    content: TileText
						{
							text: qsTr(acLimitPreset1 + " A"); font.bold: true;
							color: "white"
						}
                }
                DetailButton
                {
                    id: preset2button
                    baseColor: newCurrentLimit === acLimitPreset2 ? "black" : root.buttonColor
                    pressedColor: root.pressedColor
                    opacity: acLimitPreset2 === 0 ? 0.001 : 1
                    height: 40
                    width: parent.width
                    onClicked: setNewValue (acLimitPreset2)
                    enabled: acLimitPreset2 === 0 ? false : true
                    content: TileText
						{
							text: qsTr(acLimitPreset2 + " A"); font.bold: true;
							color: "white"
						}
                }
            }
            Row
            {
				visible: currentLimitIsAdjustable
                width: (parent.width / 2) - 2
                spacing: 4
                DetailButton
                {
                    id: preset3button
                    baseColor: newCurrentLimit === acLimitPreset3 ? "black" : root.buttonColor
                    pressedColor: root.pressedColor
                    opacity: acLimitPreset3 === 0 ? 0.001 : 1
                    height: 40
                    width: parent.width
                    onClicked: setNewValue (acLimitPreset3)
                    enabled: acLimitPreset3 === 0 ? false : true
                    content: TileText
						{
							text: qsTr(acLimitPreset3 + " A"); font.bold: true;
							color: "white"
						}
                }
                DetailButton
                {
				visible: currentLimitIsAdjustable
                    id: preset4button
                    baseColor: newCurrentLimit === acLimitPreset4 ? "black" : root.buttonColor
                    pressedColor: root.pressedColor
                    opacity: acLimitPreset4 === 0 ? 0.001 : 1
                    height: 40
                    width: parent.width
                    onClicked: setNewValue (acLimitPreset4)
                    enabled: acLimitPreset4 === 0 ? false : true
                    content: TileText
						{
							text: qsTr(acLimitPreset4 + " A"); font.bold: true;
							color: "white"
						}
                }
            }
            Row
            {
				visible: currentLimitIsAdjustable
                width: (parent.width / 2) - 2
                spacing: 4
                DetailButton
                {
                    id: trimMinus
                    baseColor: root.buttonColor
                    pressedColor: root.pressedColor
                    height: 40
                    width: parent.width
                    enablePressAndHold: true
                    onClicked: trimNewValue (-1)
                    enabled: newCurrentLimit === acLimitPreset4 ? false : true
                    content: TileText
						{
							text: qsTr("-1 A"); font.bold: true;
							color: "white"
						}
                }
                DetailButton
                {
                    id: trimPlus
                    baseColor: root.buttonColor
                    pressedColor: root.pressedColor
                    height: 40
                    width: parent.width
                    enablePressAndHold: true
                    onClicked: trimNewValue (+1)
                    content: TileText
						{
							text: qsTr("+1 A"); font.bold: true;
							color: "white"
						}
                }
            }
            Row
            {
				visible: currentLimitIsAdjustable
                width: parent.width
                spacing: 4
                DetailButton
                {
                    id: acceptButton
                    baseColor: root.buttonColor
                    pressedColor: root.pressedColor
                    height: 40
                    width: parent.width
                    onClicked: accept()
                    content: TileText { text: qsTr ("Accept New");
					font.bold: true; color: newCurrentLimit !== actualCurrentLimit ? "white" : "#d9d9d9" }
                }
            }
        }
    }

    function setNewValue (newValue)
    {
        if (currentLimitIsAdjustable)
            newCurrentLimit = newValue
    }

    function trimNewValue (trimValue)
    {
        if (!currentLimitIsAdjustable)
            return

        newCurrentLimit += trimValue
        if (newCurrentLimit < 0)
            newCurrentLimit = 0
    }

    function cancel ()
    {
        newCurrentLimit = actualCurrentLimit
        pageStack.pop()
    }
 
    function accept ()
    {
        if (currentLimitIsAdjustable)
        {
            currentLimitItem.setValue (newCurrentLimit)
            pageStack.pop() // return to main screen after changing input current limit
        }
    }
    
    function getActualCurrent ()
    {
        actualCurrentLimit = currentLimitItem.valid ? currentLimitItem.value : 0
        newCurrentLimit = actualCurrentLimit
    }

    // When new service is found check if is a tank sensor
    Connections
    {
        target: DBusServices
        onDbusServiceFound: addService(service)
    }

    function addService(service)
    {
         switch (service.type)
        {
        case DBusService.DBUS_SERVICE_MULTI:
            numberOfMultis++
            if (numberOfMultis === 1)
                inverterService = service.name;
            break;;
        case DBusService.DBUS_SERVICE_INVERTER:
            numberOfInverters++
            if (numberOfInverters === 1 && inverterService == "")
                inverterService = service.name;
            break;;
		case DBusService.DBUS_SERVICE_GRIDMETER:
            if (gridMeterService === "")
				gridMeterService = service.name;
            break;;
		case DBusService.DBUS_SERVICE_GENSET:
            if (gensetService === "")
				gensetService = service.name;
            break;;
        }
    }

    // Detect available services of interest
    function discoverServices()
    {
        numberOfMultis = 0
        numberOfInverters = 0
        inverterService = ""
		gridMeterService = ""
		gensetService = ""
        for (var i = 0; i < DBusServices.count; i++)
        {
            addService(DBusServices.at(i))
        }
    }


    property variant acSourceName: [qsTr("Not available"), qsTr("Grid"), qsTr("Generator"), qsTr("Shore")]
    function getAcSource()
    {
        var input
        if (activeInput.valid)
            input = (activeInput.value + 1).toFixed (0)
        else
            input = '-'

        if (!activeSource.valid)
            return qsTr("AC Input")
        if (activeSource.value === 240)
            return ""
        return acSourceName[activeSource.value] + " (Input " + input + ")"
    }

    // fake current value from power / voltage
    // does not consider power factor so this value for current is not really correct
    function calculateCurrent (powerItem, voltageItem)
    {
        if (powerItem.valid && voltageItem.valid && voltageItem.value != 0)
			return EnhFmt.formatValue (powerItem.value / voltageItem.value, "A")
        else
            return "--"
    }


	//// hard key handler
	//		used to press buttons when touch isn't available
	//		UP and DOWN buttons cycle through the list of buttons
	//		"space" button is used to simulate a button press
	//		button must be highlighted so that other uses of "space"
	//		will still occur

	// list of buttons to be accessed via hard buttons
	property variant buttonList:
	[
		preset1button, preset2button, preset3button, preset4button, trimMinus, trimPlus, acceptButton
	]

	property int buttonIndex: 0

    Timer
    {
        id: targetTimer
        interval: 5000
        repeat: false
        running: false
        onTriggered: { clearHighlight () }
    }

	Keys.forwardTo: [keyHandler]

	Item
	{
		id: keyHandler
		Keys.onDownPressed:
		{
			nextTarget (+1)
			event.accepted = true
		}

		Keys.onUpPressed:
		{
			nextTarget (-1)
			event.accepted = true
		}
	}

	function nextTarget (increment)
	{
		// make one pass through all possible targets to find an enabled one
		// if found, that's the new selectedTarget,
		// if not selectedTarget does not change
		var newIndex = buttonIndex
		for (var i = 0; i < buttonList.length; i++)
		{
			// just restore highlight if not visible
			if ( ! targetTimer.running && buttonList[newIndex].visible)
			{
				setActiveButton (buttonIndex)
				return
			}
			newIndex += increment
			if (newIndex >= buttonList.length)
				newIndex = 0
			else if (newIndex < 0)
				newIndex = buttonList.length - 1
			if (buttonList[newIndex].visible)
			{
				setActiveButton (newIndex)
				break
			}
		}
	}

	// Keys.onSpacePressed doesn't work - stolen by pageHandler
	// so build a custom page handler so "space" can be used to press a button
	pageToolbarHandler: detailToolbarHandler
	ToolbarHandlerPages
	{
		id: detailToolbarHandler
		isDefault: true
		function centerAction()
		{
			acceptSpaceButton ()
		}
	}
    
	function acceptSpaceButton ()
	{
		if (targetTimer.running)
		{
			buttonList[buttonIndex].clicked ()
		}
	}

	function setActiveButton (newIndex)
	{
		buttonIndex = newIndex
		for (var i = 0; i < buttonList.length; i++)
		if (i == newIndex)
			buttonList[i].highlight = true
		else
			buttonList[i].highlight = false
		targetTimer.restart ()
	}

	function clearHighlight ()
	{
		for (var i = 0; i < buttonList.length; i++)
			buttonList[i].highlight = false
	}
}
