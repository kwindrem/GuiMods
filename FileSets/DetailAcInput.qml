////// detail page for setting input current limit
////// and displaying AC input details
////// pushed from Flow overview

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

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
    property int tableColumnWidth: 60
    property int rowTitleWidth: 130
    property int dataColumns: 3
    property int totalDataWidth: tableColumnWidth * dataColumns
    property int legColumnWidth: phaseCount <= 1 ? totalDataWidth : totalDataWidth / phaseCount

    property int numberOfMultis: 0
    property int numberOfInverters: 0
    property string inverterService: ""
    property bool isMulti: numberOfMultis === 1
    property bool isInverter: numberOfMultis === 0 && numberOfInverters === 1
    property int phaseCount: sys.acInput.phaseCount.valid ? sys.acInput.phaseCount.value : 0

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

    Component.onCompleted: { discoverServices(); getActualCurrent () }

//    VBusItem
//    {
//        id: currentLimitIsAdjustable
//        bind: Utils.path(inverterService, "/Ac/ActiveIn/CurrentLimitIsAdjustable")
//        onValueChanged: getActualCurrent ()
//        onValidChanged: getActualCurrent ()
//    }
    VBusItem
    {
        id: currentLimitItem
        bind: Utils.path(inverterService, "/Ac/ActiveIn/CurrentLimit")
        onValueChanged: getActualCurrent ()
        onValidChanged: getActualCurrent ()
    }

    VBusItem { id: voltageL1; bind: Utils.path(inverterService, "/Ac/ActiveIn/L1/V") }
    VBusItem { id: voltageL2; bind: Utils.path(inverterService, "/Ac/ActiveIn/L2/V") }
    VBusItem { id: voltageL3; bind: Utils.path(inverterService, "/Ac/ActiveIn/L3/V") }
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
                        text: formatValue (sys.acInput.powerL1, " W") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (sys.acInput.powerL2, " W"); visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (sys.acInput.powerL3, " W"); visible: phaseCount >= 3 }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("Voltage") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (voltageL1, " V") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (voltageL2, " V"); visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (voltageL3, " V"); visible: phaseCount >= 3 }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("Current") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: calculateCurrent (sys.acInput.powerL1, voltageL1, " A") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: calculateCurrent (sys.acInput.powerL2, voltageL2, " A"); visible: phaseCount >= 2 }
               Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                         text: calculateCurrent (sys.acInput.powerL3, voltageL3, " A"); visible: phaseCount >= 3 }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: qsTr("Frequency") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: totalDataWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (frequencyL1, " Hz") }
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
                        text: qsTr("Current values are estimated") }
            }
        }
        Column
        {
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Current Limit") }
            }
            width: 140
            spacing: 4

            Row
            {
                width: (parent.width / 2) - 4
                spacing: 4
                Button
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
                Button
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
                width: (parent.width / 2) - 4
                spacing: 4
                Button
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
                Button
                {
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
                width: (parent.width / 2) - 4
                spacing: 4
                Button
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
                Button
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
                width: parent.width
                spacing: 4
                Button
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
//        if (!currentLimitIsAdjustable.valid || currentLimitIsAdjustable.value != 1)
//            return

        newCurrentLimit = newValue
    }

    function trimNewValue (trimValue)
    {
//        if (!currentLimitIsAdjustable.valid || currentLimitIsAdjustable.value != 1)
//            return

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
//        if (!currentLimitIsAdjustable.valid || currentLimitIsAdjustable.value != 1)
//            return

        if (currentLimitItem.valid)
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
    function calculateCurrent (powerItem, voltageItem, unit)
    {
        var current
        if (powerItem.valid && voltageItem.valid && voltageItem.value != 0)
        {
            current = powerItem.value / voltageItem.value
            if (current < 100)
                return current.toFixed (1) + unit
            else
                return current.toFixed (0) + unit
        }
        else
            return "--"
    }

    function formatValue (item, unit)
    {
        var value
        if (item.valid)
        {
            value = item.value
            if (value < 100)
                return value.toFixed (1) + unit
            else
                return value.toFixed (0) + unit
        }
        else
            return "--"
    }
}
