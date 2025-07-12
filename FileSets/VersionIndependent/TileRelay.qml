// New for GuiMods to display and control relays on separate overview page

import QtQuick 1.1
import "utils.js" as Utils

Tile {
	id: root

	property string settingsPrefix: "com.victronenergy.settings"

	property VBusItem switchableItem: VBusItem { bind: "com.victronenergy.system/SwitchableOutput/0/State" }
	property bool useSwitchable: switchableItem.valid
	
    property string functionPath: relayNumber === 0 ? "/Settings/Relay/Function" : "/Settings/Relay/" + relayNumber + "/Function"
    property string polarityPath: relayNumber === 0 ? "/Settings/Relay/Polarity" : "/Settings/Relay/" + relayNumber + "/Polarity"

    property int relayFunction: 0
    property bool relayInverted: polarityItem.valid ? polarityItem.value : false
    property bool relayActive: flase

    property string activeText: ""
    property string inactiveText: ""
    property string offButtonText: ""
    property string onButtonText: ""
    property string autoButtonText: ""
    property string functionText: ""
    property bool autoButtonActive: false
    property bool offButtonActive: false
    property bool onButtonActive: false

////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 1


    VBusItem
    {
        id: stateItem
        bind:
		{
			if (useSwitchable)
				Utils.path("com.victronenergy.system/SwitchableOutput/", relayNumber, "/State")
			else
				Utils.path("com.victronenergy.system/Relay/", relayNumber, "/State")
				
		}
        onValueChanged: updateButtons ()
    }
    VBusItem
    {
        id: nameItem
		bind:
		{
			if (useSwitchable)
				Utils.path("com.victronenergy.system/SwitchableOutput/", relayNumber, "/Settings/CustomName")
			else
				Utils.path("com.victronenergy.settings/Settings/Relay/", relayNumber, "/CustomName")
		}
    }
    VBusItem
    {
        id: functionItem
        bind: Utils.path(settingsPrefix, functionPath)
        onValueChanged: updateFunction ()
    }
    VBusItem
    {
        id: polarityItem
        bind: Utils.path(settingsPrefix, polarityPath)
    }
    VBusItem
    {
        id: generatorManualStartItem
        bind: Utils.path("com.victronenergy.generator.startstop0" , "/ManualStart")
        onValidChanged: updateButtons ()
        onValueChanged: updateButtons ()
    }
    VBusItem
    {
        id: generatorAutoRunItem
        bind: Utils.path(settingsPrefix, "/Settings/Generator0/AutoStartEnabled")
        onValidChanged: updateButtons ()
        onValueChanged: updateButtons ()
    }
    VBusItem
    {
        id: generatorStateItem
        bind: Utils.path("com.victronenergy.generator.startstop0" , "/State")
    }
    VBusItem
    {
        id: generatorConditionItem
        bind: Utils.path("com.victronenergy.generator.startstop0" , "/RunningByConditionCode")
    }
    VBusItem
    {
        id: generatorExternalOverrideItem
        bind: Utils.path("com.victronenergy.generator.startstop0" , "/ExternalOverride")
    }
    VBusItem
    {
        id: pumpModeItem
        bind: Utils.path(settingsPrefix, "/Settings/Pump0/Mode")
        onValidChanged: updateButtons ()
        onValueChanged: updateButtons ()
    }

    Component.onCompleted: updateFunction ()

////// GuiMods — DarkMode
	color: !darkMode ? "#d9d9d9" : "#202020"
	border.color: !darkMode ? "#fff" : "#707070"

	function doScroll()
    {
        relayName.doScroll ()
        relayState.doScroll ()
    }

	values: Item
    {
		anchors.horizontalCenter: parent.horizontalCenter
		Column
        {
            width: root.width
            spacing: 4
            visible: true
            anchors
            {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }
            Text
            {
                font.pixelSize: 12
                font.bold: true
////// GuiMods DarkMode                
				color: !darkMode ? "black" : "gray"
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                text: "Relay " + (relayNumber + 1)
            }
            MarqueeEnhanced
            {
                id: relayName
                width: parent.width - 4
                text: nameItem.valid && nameItem.value != "" ? nameItem.value : " "
                fontSize: 12
                bold: true
////// GuiMods DarkMode
				textColor: !darkMode ? "black" : "gray"
                scroll: false
            }
            Text
            {
                font.pixelSize: 12
                font.bold: true
////// GuiMods DarkMode
				color: !darkMode ? "black" : "gray"
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                text: functionText
            }

            MarqueeEnhanced
            {
                id: relayState
                width: parent.width - 4
                fontSize: 12
                bold: true
////// GuiMods DarkMode
				textColor: !darkMode ? "black" : "gray"
                scroll: false
                text:
                {
					// special handling for generator
					if (relayFunction == 1)
					{
						if (generatorExternalOverrideItem.valid && generatorExternalOverrideItem.value == 1)
							return qsTr ("External override - stopped")
						else if (!generatorStateItem.valid)
							return qsTr ("Error")
						else if (generatorStateItem.value == 2)
							return qsTr("Warm-up")
						else if (generatorStateItem.value == 3)
							return qsTr("Cool-down")
						else if (generatorStateItem.value == 4)
							return qsTr("Stopping")
						else if (generatorConditionItem.valid)
						{
							switch (generatorConditionItem.value)
							{
								case 0:
									return qsTr ("Stopped")
								case 1:
									return qsTr ("Man run")
								case 2:
									return qsTr ("Test run")
								case 3:
									return qsTr ("Loss of comms run")
								case 4:
									return qsTr ("SOC run")
								case 5:
									return qsTr ("Load run")
								case 6:
									return qsTr ("Battery current run")
								case 7:
									return qsTr ("Battery voltage run")
								case 8:
									return qsTr ("Inverter temperature run")
								case 9:
									return qsTr ("Inverter overload run")
								default:
									return "??"
							}
						}
						else
							return "??"
					}
                    else if (stateItem.valid)
                    {
						if (relayActive)
                            return activeText
                        else
                            return inactiveText
					}
                    else
                        return "??"
                }
            }
            // spacer
            Text
            {
                font.pixelSize: 4
                font.bold: true
				color: "black"
                height: 4
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                text: " "
            }
            Button
            {
                id: onButton
////// GuiMods - DarkMode
				baseColor: !darkMode ? (onButtonActive ? "green" : "#e6ffe6") : (onButtonActive ? "green" : "#003000")
                pressedColor: "#979797"
                height: 40
                width: parent.width - 6
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: buttonPress (1)
                content: TileText
                {
                    text: onButtonText; font.bold: true;
                    color: onButtonActive ? "white" : "black"
                }
            }
            Button
            {
                id: offButton
////// GuiMods - DarkMode
				baseColor: !darkMode ? (offButtonActive ? "black" : "#e6e6e6") : (offButtonActive ? "black" : "gray")
                pressedColor: "#979797"
                height: 40
                width: parent.width - 6
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: buttonPress (2)
                content: TileText
                {
                    text: offButtonText; font.bold: true;
                    color: offButtonActive ? "white" : "black"
                }
            }
            Button
            {
                id: autoButton
////// GuiMods - DarkMode                                          
				baseColor: !darkMode ? (autoButtonActive ? "orange" : "#ffedcc") : (autoButtonActive ? "orange" : "#3a2600")
                pressedColor: "#979797"
                height: 40
                width: parent.width - 6
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: buttonPress (3)
                content: TileText
                {
                    text: autoButtonText; font.bold: true;
                    color: autoButtonActive ? "white" : "black"
                }
            }
        }
	}
    function updateFunction ()
    {
        if (functionItem.valid)
        {
            relayFunction = functionItem.value
            switch (relayFunction)
            {
            // Alarm - no buttons
            case 0:
                functionText = qsTr("Alarm")
                activeText = qsTr("Alarm")
                inactiveText = qsTr("No Alarm")
                offButtonText = ""
                onButtonText = ""
                autoButtonText = ""
                onButton.visible = false 
                offButton.visible = false 
                autoButton.visible = false 
                break;;
            // Generator
            case 1:
                functionText = qsTr("Generator")
                activeText = qsTr("")	// generator state text handled below
                inactiveText = qsTr("")
                onButtonText = qsTr("Manual\nStart")
                offButtonText = qsTr("Manual\nStop")
                autoButtonText = qsTr("Auto\nEnable")
                onButton.visible = true 
                offButton.visible = true 
                autoButton.visible = true
                break;;
            // pump
            case 3:
                functionText = qsTr("Pump")
                activeText = qsTr("On")
                inactiveText = qsTr("Off")
                onButtonText = qsTr("On")
                offButtonText = qsTr("Off")
                autoButtonText = qsTr("Auto")
                onButton.visible = true 
                offButton.visible = true 
                autoButton.visible = true
                break;;
            // temperature
            case 4:
                functionText = qsTr("Temp")
                activeText = qsTr("Alarm")
                inactiveText = qsTr("No Alarm")
                onButtonText = "--"
                offButtonText = "--"
                autoButtonText = "--"
                onButton.visible = false 
                offButton.visible = false 
                autoButton.visible = false
                break;;
            // manual (2) and undefined
            default:
                functionText = qsTr("Manual")
                activeText = qsTr("On")
                inactiveText = qsTr("Off")
                onButtonText = qsTr("On")
                offButtonText = qsTr("Off")
                autoButtonText = ""
                onButton.visible = true 
                offButton.visible = true 
                autoButton.visible = false 
                break;;
            }
        }
        // only relay 1 has a function selector, so use manual settings for other relays
        else
        {
            relayFunction = 2
            functionText = qsTr("Manual")
            activeText = qsTr("On")
            inactiveText = qsTr("Off")
            onButtonText = qsTr("On")
            offButtonText = qsTr("Off")
            autoButtonText = "--" // empty string causes interactions
            autoButton.visible = false 
        }
        updateButtons ()
    }
    
    function updateButtons ()
    {
        switch (relayFunction)
        {
        // alarm - no buttons
        case 0:
            break;;
        // Generator
        case 1:
            if (generatorManualStartItem.valid)
            {
                onButtonActive = generatorManualStartItem.value === 1
                offButtonActive = ! onButtonActive
            }
            else
            {
                offButtonActive = false
                onButtonActive = false
            }
            if (generatorAutoRunItem.valid)
                autoButtonActive = generatorAutoRunItem.value
			else
                autoButtonActive = false
            break;;
        // pump
        case 3:
            if (pumpModeItem.valid)
            {
                switch (pumpModeItem.value)
                {
                // Auto
                case 0:
                    onButtonActive = false
                    offButtonActive = false
                    autoButtonActive = true
                    break;;
                // On
                case 1:
                    onButtonActive = true
                    offButtonActive = false
                    autoButtonActive = false
                    break;;
                 // Off
                case 2:
                    onButtonActive = false
                    offButtonActive = true
                    autoButtonActive = false
                    break;;
                default:
                    onButtonActive = false
                    offButtonActive = false
                    autoButtonActive = false
                    break;;
                }
            }
            else
            {
                offButtonActive = false
                onButtonActive = false
                autoButtonActive = false
            }
            break;;
        // manual (2) and undefined
        default:
            relayActive = stateItem.value === 1 != relayInverted
			onButtonActive = relayActive
            offButtonActive = ! onButtonActive
            autoButtonActive = false
            break;;
        }
    }

    function buttonPress (button)
    {
        switch (relayFunction)
        {
        // Generator
        case 1:
            switch (button)
            {
            // on
            case 1:
                generatorManualStartItem.setValue (1)
                break;;
            // off
            case 2:
                generatorManualStartItem.setValue (0)
                break;;
            // auto
            case 3:
                // toggle value
                generatorAutoRunItem.setValue (generatorAutoRunItem.value === 1 ? 0 : 1)
                break;;
            default:
                break;;
            }
            break;;
        // pump
        case 3:
            switch (button)
            {
            // on
            case 1:
                pumpModeItem.setValue (1)
                break;;
            // off
            case 2:
                pumpModeItem.setValue (2)
                break;;
            // auto
            case 3:
                pumpModeItem.setValue (0)
                break;;
            default:
                break;;
            }
            break;;
        // alarm - no buttons
        case 0:
            break;;
        // manual (2) and undefined
        default:
            switch (button)
            {
            // on
            case 1:
                stateItem.setValue (1)
                break;;
            // off
            case 2:
                stateItem.setValue (0)
                break;;
            default:
                break;;
            }
            break;;
        }
    }
}
