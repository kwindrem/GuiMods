// New for GuiMods to display and control relays on separate overview page

import QtQuick 1.1
import "utils.js" as Utils

Tile {
	id: root

    property string systemPrefix: "com.victronenergy.system"
    property string settingsPrefix: "com.victronenergy.settings"
    property string functionPath: relayNumber === 0 ? "/Settings/Relay/Function" : "/Settings/Relay/" + relayNumber + "/Function"
    property string polarityPath: relayNumber === 0 ? "/Settings/Relay/Polarity" : "/Settings/Relay/" + relayNumber + "/Polarity"

    property int relayFunction: 0
    property bool relayInverted: polarityItem.valid ? polarityItem.value : false
    property bool relayActive: ((stateItem.value === 1) != relayInverted)

    property string activeText: ""
    property string inactiveText: ""
    property string offButtonText: ""
    property string onButtonText: ""
    property string autoButtonText: ""
    property string functionText: ""
    property bool autoButtonActive: false
    property bool offButtonActive: false
    property bool onButtonActive: false

    VBusItem
    {
        id: stateItem
        bind: Utils.path(systemPrefix, "/Relay/", relayNumber, "/State")
        onValueChanged: updateButtons ()
    }
    VBusItem
    {
        id: nameItem
        bind: Utils.path(settingsPrefix, "/Settings/Relay/", relayNumber, "/CustomName")
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
        bind: Utils.path("com.victronenergy.generator.startstop0" , "/Generator0/ManualStart")
        onValueChanged: updateButtons ()
    }
    VBusItem
    {
        id: generatorAutoRunItem
        bind: Utils.path(settingsPrefix, "/Settings/Generator0/AutoStartEnabled")
        onValueChanged: updateButtons ()
    }
    VBusItem
    {
        id: pumpModeItem
        bind: Utils.path(settingsPrefix, "/Settings/Pump0/Mode")
        onValueChanged: updateButtons ()
    }

    // relay function changes may instantiate new dBus services which takes time
    // this timer triggers button refreshe after a suitable delay (2 S)
    Timer
    {
        id: functionDelayTimer
        interval: 2000
        repeat: false
        running: false
        onTriggered: updateButtons ()
    }

    Component.onCompleted: updateFunction ()

    color: "#d9d9d9"

    function doScroll()
    {
        relayName.doScroll()
    }

	values: Item
    {
        Column
        {
            width: root.width
            height: contentHeight + 4
            x: 3
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
                color: "black"
                anchors
                {
                    horizontalCenter: parent.horizontalCenter
                }
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
                textColor: "black"
                scroll: false
            }
            Text
            {
                font.pixelSize: 12
                font.bold: true
                color: "black"
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                text: functionText
            }

            Text
            {
                id: relayState
                font.pixelSize: 12
                font.bold: true
                color: "black"
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                text:
                {
                    if (stateItem.valid)
                    {
                         if (relayActive)
                            text: activeText
                        else
                            text: inactiveText
                        }
                    else
                        text: "??"
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
                baseColor: onButtonActive ? "green" : "#e6ffe6"
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
                baseColor: offButtonActive ? "black" : "#e6e6e6"
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
                baseColor: autoButtonActive ? "orange" : "#ffedcc"
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
                offButtonText = "--" // empty string causes interactions between instances
                onButtonText = "--" // empty string causes interactions between instances
                autoButtonText = "--" // empty string causes interactions between instances
                onButton.show = false 
                offButton.show = false 
                autoButton.show = false 
                break;;
            // Generator
            case 1:
                functionText = qsTr("Generator")
                activeText = qsTr("Running")
                inactiveText = qsTr("Stopped")
                onButtonText = qsTr("Manual\nStart")
                offButtonText = qsTr("Manual\nStop")
                autoButtonText = qsTr("Auto\nEnable")
                onButton.show = true 
                offButton.show = true 
                autoButton.show = true
                break;;
            // pump
            case 3:
                functionText = qsTr("Pump")
                activeText = qsTr("On")
                inactiveText = qsTr("Off")
                onButtonText = qsTr("On")
                offButtonText = qsTr("Off")
                autoButtonText = qsTr("Auto")
                onButton.show = true 
                offButton.show = true 
                autoButton.show = true
                break;;
            // temperature
            case 4:
                functionText = qsTr("Temp")
                activeText = qsTr("Alarm")
                inactiveText = qsTr("No Alarm")
                onButtonText = "--"
                offButtonText = "--"
                autoButtonText = "--"
                onButton.show = false 
                offButton.show = false 
                autoButton.show = false
                break;;
            // manual (2) and undefined
            default:
                functionText = qsTr("Manual")
                activeText = qsTr("On")
                inactiveText = qsTr("Off")
                onButtonText = qsTr("On")
                offButtonText = qsTr("Off")
                autoButtonText = "--" // empty string causes interactions between instances
                onButton.show = true 
                offButton.show = true 
                autoButton.show = false 
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
            autoButton.show =false 
        }
        updateButtons ()
        // trigger delay to refresh buttons again after new dBus services can be established
        functionDelayTimer.running = true
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
                autoButtonActive = generatorAutoRunItem.value
            }
            else
            {
                offButtonActive = false
                onButtonActive = false
                autoButtonActive = false
            }
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
