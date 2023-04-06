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

    property int dataColumns: 4
    property int rowTitleWidth: 100
    property int totalDataWidth: 340 - rowTitleWidth
    property int tableColumnWidth: totalDataWidth / dataColumns
    
    property int legColumnWidth: phaseCount <= 1 ? tableColumnWidth * 3 : tableColumnWidth * 3 / phaseCount

    property int phaseCount: sys.acInput.phaseCount.valid ? sys.acInput.phaseCount.value : 0

    VBusItem { id: vebusServiceItem; bind: Utils.path(systemPrefix, "/VebusService") }
    property string inverterService: vebusServiceItem.valid ? vebusServiceItem.value : ""
    VBusItem { id: splitPhaseL2Passthru; bind: Utils.path(inverterService, "/Ac/State/SplitPhaseL2Passthru") }
    property bool l1AndL2OutShorted: splitPhaseL2Passthru.valid && splitPhaseL2Passthru.value === 0

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
	
    Component.onCompleted: { getActualCurrent () }

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
    VBusItem { id: activeInputItem; bind: Utils.path(inverterService, "/Ac/ActiveIn/ActiveInput") }
    VBusItem { id: numberOfAcInputs; bind: Utils.path(inverterService, "/Ac/In/NumberOfAcInputs") }
    VBusItem { id: activeSourceItem; bind: Utils.path(systemPrefix, "/Ac/ActiveIn/Source") }
    VBusItem { id: acIn1sourceItem; bind: Utils.path(settingsPrefix, "/Settings/SystemSetup/AcInput1") }
    VBusItem { id: acIn2sourceItem; bind: Utils.path(settingsPrefix, "/Settings/SystemSetup/AcInput2") }
	property int activeSource: activeSourceItem.valid ? activeSourceItem.value : 0
	property int acIn1source: acIn1sourceItem.valid ? acIn1sourceItem.value : 0
	property int acIn2source: acIn2sourceItem.valid ? acIn2sourceItem.value : 0
    property int activeInput: activeInputItem.valid && activeInputItem.value == 1 ? 2 : 1
    property bool hasTwoInputs: numberOfAcInputs.valid && numberOfAcInputs.value == 2

    property variant acSourceName: [qsTr("---"), qsTr("Grid"), qsTr("Generator"), qsTr("Shore")]

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
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                    text: qsTr("Total Power") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                    width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                    text: EnhFmt.formatVBusItem (sys.acInput.power, "W")
                }
                PowerGauge
                {
                    id: gauge
                    width: totalDataWidth - tableColumnWidth
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
                        width: rowTitleWidth + tableColumnWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("Active Source") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: totalDataWidth - tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text:
						{
							if (activeSource == 240)
								return quTr ("no input")
							else if (hasTwoInputs)
								return acSourceName[activeSource] + " (AC in " + activeInput + ")"
							else
								return acSourceName[activeSource]
						}
				}
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L1" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L2"; visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L3"; visible: phaseCount >= 3 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr ("Freq") }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("Power") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.acInput.powerL1, "W") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: l1AndL2OutShorted ? "< < <" : EnhFmt.formatVBusItem (sys.acInput.powerL2, "W"); visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.acInput.powerL3, "W"); visible: phaseCount >= 3 }
            }
            Row
            {
				Text { font.pixelSize: 12; font.bold: true; color: "black"
						width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("Voltage / Freq") }
				Text { font.pixelSize: 12; font.bold: true; color: "black"
						width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
						text: EnhFmt.formatVBusItem (sys.acInput.voltageL1, "V") }
				Text { font.pixelSize: 12; font.bold: true; color: "black"
						width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
						text: l1AndL2OutShorted ? "< < <" : EnhFmt.formatVBusItem (sys.acInput.voltageL2, "V"); visible: phaseCount >= 2 }
				Text { font.pixelSize: 12; font.bold: true; color: "black"
						width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
						text: EnhFmt.formatVBusItem (sys.acInput.voltageL3, "V"); visible: phaseCount >= 3 }
				Text { font.pixelSize: 12; font.bold: true; color: "black"
						width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
						text: EnhFmt.formatVBusItem (sys.acInput.frequency, "Hz") }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("Current") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.acInput.currentL1, "A") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: l1AndL2OutShorted ? "< < <" : EnhFmt.formatVBusItem (sys.acInput.currentL2, "A"); visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: EnhFmt.formatVBusItem (sys.acInput.currentL3, "A"); visible: phaseCount >= 3 }
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
                        text: "L2 values included in L1"
                        visible: l1AndL2OutShorted }
            }
            Row
            {
                 Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth + totalDataWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Avaliable Sources") }
			}
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L1" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L2"; visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L3"; visible: phaseCount >= 3 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr ("Freq") }
            }
            Row
            {
				Text { font.pixelSize: 12; font.bold: true; color: "black"
						width: 20; horizontalAlignment: Text.AlignHCenter
						text: activeSource == 1 || activeSource == 3 ? ">" : "" }
				Text { font.pixelSize: 12; font.bold: true; color: "black"
						width: rowTitleWidth - 20; horizontalAlignment: Text.AlignRight
						text:
						{
							if (acIn1source == 3 || acIn2source == 3)
								return acSourceName[3]
							else
								return acSourceName[1]
						}
				}
				Text { font.pixelSize: 12; font.bold: true; color: "black"
						width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
						text: EnhFmt.formatVBusItem (sys.grid.voltageL1, "V") }
				Text { font.pixelSize: 12; font.bold: true; color: "black"
						width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
						text: l1AndL2OutShorted ? "< < <" : EnhFmt.formatVBusItem (sys.grid.voltageL2, "V"); visible: phaseCount >= 2 }
				Text { font.pixelSize: 12; font.bold: true; color: "black"
						width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
						text: EnhFmt.formatVBusItem (sys.grid.voltageL3, "V"); visible: phaseCount >= 3 }
				Text { font.pixelSize: 12; font.bold: true; color: "black"
						width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
						text: EnhFmt.formatVBusItem (sys.grid.frequency, "Hz") }
            }
            Row
            {
				Text { font.pixelSize: 12; font.bold: true; color: "black"
						width: 20; horizontalAlignment: Text.AlignHCenter
						text: activeSource == 2 ? ">" : "" }
				Text { font.pixelSize: 12; font.bold: true; color: "black"
						width: rowTitleWidth - 20; horizontalAlignment: Text.AlignRight
						text: acSourceName[2] }
				Text { font.pixelSize: 12; font.bold: true; color: "black"
						width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
						text: EnhFmt.formatVBusItem (sys.genset.voltageL1, "V") }
				Text { font.pixelSize: 12; font.bold: true; color: "black"
						width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
						text: l1AndL2OutShorted ? "< < <" : EnhFmt.formatVBusItem (sys.genset.voltageL2, "V"); visible: phaseCount >= 2 }
				Text { font.pixelSize: 12; font.bold: true; color: "black"
						width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
						text: EnhFmt.formatVBusItem (sys.genset.voltageL3, "V"); visible: phaseCount >= 3 }
				Text { font.pixelSize: 12; font.bold: true; color: "black"
						width: tableColumnWidth; horizontalAlignment: Text.AlignHCenter
						text: EnhFmt.formatVBusItem (sys.genset.frequency, "Hz") }
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
