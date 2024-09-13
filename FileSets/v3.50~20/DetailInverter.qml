////// detail page for setting inverter mode
////// and displaying inverter details
////// pushed from Flow overview

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0
import "enhancedFormat.js" as EnhFmt

MbPage {
	id: root

    title: "Inverter detail"

    property variant sys: theSystem
    property string systemPrefix: "com.victronenergy.system"

	property int fontPixelSize: 18
	property color buttonColor: "#979797"
    property color pressedColor: "#d3d3d3"
    property color backgroundColor: "#b3b3b3"

    property int inverterMode: inverterModeItem.valid ? inverterModeItem.value : 0
    property bool editable: inverterService != "" && inverterModeItem.valid

    property int buttonHeight: 40
    property int buttonWidth: 72
	property int buttonAreaWidth: buttonWidth * 2 + 4

    property int rowTitleWidth: 132
    property int dataColumns: 3
	property int totalDataWidth: root.width - rowTitleWidth - buttonAreaWidth - 12
    property int tableColumnWidth: totalDataWidth / dataColumns
    property int legColumnWidth: phaseCount <= 1 ? totalDataWidth : totalDataWidth / phaseCount

    property int numberOfMultis: 0
    property int numberOfInverters: 0
    property string inverterService: ""
    property bool isInverter: numberOfMultis === 0 && numberOfInverters === 1

    Component.onCompleted: { discoverServices(); highlightMode () }

	property bool showChargePriority: numberOfMultis > 0 && sys.preferRenewableEnergy.valid
	property bool preferRenewableEnergy: showChargePriority && sys.preferRenewableEnergy.value == 1
	property bool autoReturnToRenewable: sys.remoteGeneratorSelected.valid
	property bool acInIsGenerator: sys.acSource == 2

    VBusItem
    {
        id: inverterModeItem
        bind: Utils.path(inverterService, "/Mode")
        onValidChanged: highlightMode ()
        onValueChanged: highlightMode ()
    }
    property VBusItem systemState: VBusItem { bind: Utils.path(systemPrefix, "/SystemState/State") }
    SystemState
    {
        id: vebusState
        bind: systemState.valid ? Utils.path(systemPrefix, "/SystemState/State") : Utils.path(inverterService, "/State")
    }
    VBusItem { id: pInL1; bind: Utils.path(inverterService, "/Ac/ActiveIn/L1/P") }
    VBusItem { id: pInL2; bind: Utils.path(inverterService, "/Ac/ActiveIn/L2/P") }
    VBusItem { id: pInL3; bind: Utils.path(inverterService, "/Ac/ActiveIn/L2/P") }
    VBusItem { id: vInL1; bind: Utils.path(inverterService, "/Ac/ActiveIn/L1/V") }
    VBusItem { id: vInL2; bind: Utils.path(inverterService, "/Ac/ActiveIn/L2/V") }
    VBusItem { id: vInL3; bind: Utils.path(inverterService, "/Ac/ActiveIn/L3/V") }
    VBusItem { id: iInL1; bind: Utils.path(inverterService, "/Ac/ActiveIn/L1/I") }
    VBusItem { id: iInL2; bind: Utils.path(inverterService, "/Ac/ActiveIn/L2/I") }
    VBusItem { id: iInL3; bind: Utils.path(inverterService, "/Ac/ActiveIn/L3/I") }
    VBusItem { id: pOutL1; bind: Utils.path(inverterService, "/Ac/Out/L1/P") }
    VBusItem { id: pOutL2; bind: Utils.path(inverterService, "/Ac/Out/L2/P") }
    VBusItem { id: pOutL3; bind: Utils.path(inverterService, "/Ac/Out/L3/P") }
    VBusItem { id: vOutL1; bind: Utils.path(inverterService, "/Ac/Out/L1/V") }
    VBusItem { id: vOutL2; bind: Utils.path(inverterService, "/Ac/Out/L2/V") }
    VBusItem { id: vOutL3; bind: Utils.path(inverterService, "/Ac/Out/L3/V") }
    VBusItem { id: iOutL1; bind: Utils.path(inverterService, "/Ac/Out/L1/I") }
    VBusItem { id: iOutL2; bind: Utils.path(inverterService, "/Ac/Out/L2/I") }
    VBusItem { id: iOutL3; bind: Utils.path(inverterService, "/Ac/Out/L3/I") }
    VBusItem { id: fInL1; bind: Utils.path(inverterService, "/Ac/ActiveIn/L1/F") }
    VBusItem { id: fOutL1; bind: Utils.path(inverterService, "/Ac/Out/L1/F") }
    VBusItem { id: dcPower; bind: Utils.path(inverterService, "/Dc/0/Power") }
    VBusItem { id: dcCurrent; bind: Utils.path(inverterService, "/Dc/0/Current") }
    VBusItem { id: _l2L1OutSummed; bind: Utils.path(inverterService, "/Ac/State/SplitPhaseL2L1OutSummed") }
    VBusItem { id: phaseCountItem; bind: Utils.path(inverterService, "/Ac/NumberOfPhases") }

	property bool noL2inverter: _l2L1OutSummed.valid
    property bool l2AndL1OutSummed: noL2inverter && _l2L1OutSummed.value === 1
    property int phaseCount: phaseCountItem.valid ? phaseCountItem.value : 0

    // background
    Rectangle
    {
        anchors
        {
            fill: parent
        }
        color: root.backgroundColor
    }

	Column 
	{
		spacing: 2
		anchors.verticalCenter: parent.verticalCenter
		anchors.left: parent.left; anchors.leftMargin: 3
		Row
		{
			PowerGaugeMulti
			{
				id: gauge
				width: rowTitleWidth + totalDataWidth
				height: 15
				inverterService: root.inverterService
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
						var total = 0
						var totalValid = false
						if (pOutL1.valid && pInL1.valid)
						{
							total += pOutL1.value - pInL1.value
							totalValid = true
						}
						if (pOutL2.valid && pInL2.valid)
						{
							total += pOutL2.value - pInL2.value
							totalValid = true
						}
						if (pOutL3.valid && pInL3.valid)
						{
							total += pOutL3.value - pInL3.value
							totalValid = true
						}
						if (totalValid)
							return EnhFmt.formatValue (total, "W")
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
					text: qsTr("State") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: totalDataWidth; horizontalAlignment: Text.AlignHCenter
					text: vebusState.text }
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
					text: formatValueDiff (pOutL1, pInL1, "W") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
					text:
					{
						if (l2AndL1OutSummed)
							return "< < <"
						else if (noL2inverter)
							return qsTr("none")
						else
							return formatValueDiff (pOutL2, pInL2, "W")
					}
					visible: phaseCount >= 2
			}
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: formatValueDiff (pOutL3, pInL3, "W"); visible: phaseCount >= 3 }
		}
		Row
		{
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: rowTitleWidth; horizontalAlignment: Text.AlignRight
					text: qsTr("Input Voltage") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: EnhFmt.formatVBusItem (vInL1, "V") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: EnhFmt.formatVBusItem (vInL2, "V"); visible: phaseCount >= 2 }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: EnhFmt.formatVBusItem (vInL3, "V"); visible: phaseCount >= 3 }
		}
		Row
		{
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: rowTitleWidth; horizontalAlignment: Text.AlignRight
					text: qsTr("Output Voltage") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: EnhFmt.formatVBusItem (vOutL1, "V") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: EnhFmt.formatVBusItem (vOutL2, "V"); visible: phaseCount >= 2 }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: EnhFmt.formatVBusItem (vOutL3, "V"); visible: phaseCount >= 3 }
		}
		Row
		{
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: rowTitleWidth; horizontalAlignment: Text.AlignRight
					text: qsTr("Input Current") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: EnhFmt.formatVBusItem (iInL1, "A") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: EnhFmt.formatVBusItem (iInL2, "A"); visible: phaseCount >= 2 }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: EnhFmt.formatVBusItem (iInL3, "A"); visible: phaseCount >= 3 }
		}
		Row
		{
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: rowTitleWidth; horizontalAlignment: Text.AlignRight
					text: qsTr("Output Current") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: EnhFmt.formatVBusItem (iOutL1, "A") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: l2AndL1OutSummed ? "< < <" : EnhFmt.formatVBusItem (iOutL2, "A"); visible: phaseCount >= 2 }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
					text: EnhFmt.formatVBusItem (iOutL3, "A"); visible: phaseCount >= 3 }
		}
		Row
		{
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: rowTitleWidth; horizontalAlignment: Text.AlignRight
					text: qsTr("Frequency In / Out") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: totalDataWidth / 2; horizontalAlignment: Text.AlignHCenter
					text: EnhFmt.formatVBusItem (fInL1, "Hz") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: totalDataWidth / 2; horizontalAlignment: Text.AlignHCenter
					text: EnhFmt.formatVBusItem (fOutL1, "Hz") }
		}
		Row
		{
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: rowTitleWidth; horizontalAlignment: Text.AlignRight
					text:
					{
						if (! dcPower.valid)
							return ""
						else if (dcPower.value > 0)
							return qsTr ("DC: supplying")
						else if (dcPower.value < 0)
							return qsTr ("DC: consuming")
						else
							return ""
					}
			}
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: totalDataWidth / 2; horizontalAlignment: Text.AlignHCenter
					text: EnhFmt.formatVBusItemAbs (dcPower, "W") }
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: totalDataWidth / 2; horizontalAlignment: Text.AlignHCenter
					text: EnhFmt.formatVBusItemAbs (dcCurrent, "A") }
		}
		Row
		{
			Text { font.pixelSize: 12; font.bold: true; color: "black"
					width: rowTitleWidth + totalDataWidth; horizontalAlignment: Text.AlignHCenter
					text: l2AndL1OutSummed ? qsTr ("L2 Output values included in L1") : qsTr ("L2 AC out from AC in (no inverter)")
					visible: noL2inverter
				}
		}
	}
	Column
	{
		id: inverterModeButtonArea
		width: root.buttonAreaWidth
		anchors.top: parent.top; anchors.topMargin: 3
		anchors.right: parent.right; anchors.rightMargin: 3
		spacing: 4

		Row
		{
			Text
			{
				font.pixelSize: 12; color: "black"
				width: root.buttonAreaWidth; horizontalAlignment: Text.AlignHCenter
				text: qsTr("Inverter mode")
				visible: showChargePriority
			}
		}
		Row
		{
			spacing: 4
			DetailButton
			{
				id: onButton
				baseColor: inverterMode === 3 ? "green" : "#e6ffe6"
				pressedColor: root.pressedColor
				height: root.buttonHeight
				width: root.buttonWidth
				visible: !isInverter           
				onClicked: changeMode(3)
				content: TileText
				{
					text: qsTr("On"); font.bold: true;
					color: inverterMode === 3 ? "white" : "gray"
				}
			}
			DetailButton
			{
				id: offButton
				baseColor: inverterMode === 4 ? "black" : "#e6e6e6"
				pressedColor: root.pressedColor
				height: root.buttonHeight
				width: root.buttonWidth
				onClicked: changeMode(4)
				content: TileText
				{
					text: qsTr("Off"); font.bold: true;
					color: inverterMode === 4 ? "white" : "gray"
				}
			}
		}
		Row
		{
			spacing: 4
			DetailButton
			{
				id: invertOnlyButton
				baseColor: inverterMode === 2 ? "blue" : "#ccccff"
				pressedColor: root.pressedColor
				height: root.buttonHeight
				width: root.buttonWidth
				onClicked: changeMode(2)
				content: TileText
				{
					text: isInverter ? qsTr("On") : qsTr("Inverter\nOnly"); font.bold: true;
					color: inverterMode === 2 ? "white" : "gray"
				}
			}
			DetailButton
			{
				id: chargeOnlyButton
				baseColor: inverterMode === 1 ? "orange" : "#ffedcc"
				pressedColor: root.pressedColor
				height: root.buttonHeight
				width: root.buttonWidth
				visible: !isInverter           
				onClicked: changeMode(1)
				content: TileText
				{
					text: qsTr("Charger\nOnly"); font.bold: true;
					color: inverterMode === 1 ? "white" : "gray"
				}
			}
			DetailButton
			{
				id: ecoButton
				baseColor: inverterMode === 5 ? "orange" : "#ffedcc"
				pressedColor: root.pressedColor
				height: root.buttonHeight
				width: root.buttonWidth
				visible: isInverter         
				onClicked: changeMode(5)
				content: TileText
				{
					text: qsTr("Eco"); font.bold: true;
					color: inverterMode === 5 ? "white" : "black"
				}
			}
		}
	}
	Column
	{
		id: chargePriorityButtonArea
		width: root.buttonAreaWidth
		anchors.bottom: parent.bottom; anchors.bottomMargin: 3
		anchors.right: parent.right; anchors.rightMargin: 3
		spacing: 4

		Row
		{
			Text
			{
				font.pixelSize: 12; color: "black"
				width: root.buttonAreaWidth; horizontalAlignment: Text.AlignHCenter
				text:  qsTr("Charge priority")
				visible: showChargePriority
			}
		}
		Row
		{
			spacing: 4
			DetailButton
			{
				id: acPriorityButton
				baseColor: ! preferRenewableEnergy && ! acInIsGenerator ? "orange" : "#ffedcc"
				pressedColor: root.pressedColor
				height: root.buttonHeight
				width: root.buttonWidth
				onClicked: { if (! acInIsGenerator) sys.preferRenewableEnergy.setValue (0)}
				visible: showChargePriority
				content: TileText
				{
					text: "Grid"; font.bold: true
					color: ! preferRenewableEnergy && ! acInIsGenerator ? "white" : "gray"
				}
			}
			DetailButton
			{
				id: renewablePriorityButton
				baseColor: preferRenewableEnergy && ! acInIsGenerator ? "green" : "#e6ffe6"
				pressedColor: root.pressedColor
				height: root.buttonHeight
				width: root.buttonWidth
				visible: showChargePriority
				onClicked: { if (! acInIsGenerator) sys.preferRenewableEnergy.setValue (1)}
				content: TileText
				{
					text: qsTr("Renew\nable"); font.bold: true
					color: preferRenewableEnergy && ! acInIsGenerator ? "white" : "gray"
				}
			}
		}
		Row
		{
			Text
			{
				font.pixelSize: 12; color: "black"
				width: root.buttonAreaWidth; horizontalAlignment: Text.AlignHCenter
				text:
				{
					if (acInIsGenerator)
						return qsTr ("Generator active\nno priority")
					else if (autoReturnToRenewable && ! preferRenewableEnergy)
						return qsTr ("returns to Renewable\n at 100% SOC")
					else return "\n"
				}
				visible: showChargePriority
			}
		}
	}


	function changeMode(newMode)
	{
        if (editable)
        {
            inverterModeItem.setValue(newMode)
            pageStack.pop() // return to flow screen after changing inverter mode
        }
	}

	function cancel()
	{
		pageStack.pop()
	}
 
    function highlightMode ()
    {
        if (editable)
            inverterMode = inverterModeItem.value
        else
            inverterMode = 0
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
        case DBusService.DBUS_SERVICE_MULTI_RS:
            numberOfMultis++
            if (numberOfMultis === 1)
                inverterService = service.name;
            break;;
        case DBusService.DBUS_SERVICE_INVERTER:
            numberOfInverters++
            if (numberOfInverters === 1 && numberOfMultis === 0)
                inverterService = service.name;
            break;;
        }
    }

    // Detect available services of interest
    function discoverServices()
    {
        numberOfMultis = 0
        numberOfInverters = 0
        inverterService = ""
        for (var i = 0; i < DBusServices.count; i++)
        {
            addService(DBusServices.at(i))
        }
    }

    function formatValueDiff (item1, item2, unit)
    {
        if (item1.valid && item2.valid)
            return EnhFmt.formatValue (item1.value - item2.value, unit)
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
		onButton, offButton, invertOnlyButton, chargeOnlyButton, ecoButton
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
