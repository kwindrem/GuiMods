////// popup for setting AC input current limit
// previously a "spinner" was used to select a new value
// the spinner functionality is retained
// with the addition of preset buttons for 4 user-specified currents
// preset values can be set via dbus-spy or from the GuiMods setup script

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

Tile {
	id: root

    property bool valid: vItem.value !== undefined
    property alias bind: vItem.bind
	property int fontPixelSize: 18
	property bool expanded: false // If the tile is 'expanded', additional touch buttons are shown
	property color buttonColor
	property alias containsMouse: mouseArea.containsMouse
    property real actualCurrentLimit: 0
    property real newCurrentLimit: 0

    VBusItem
    {
        id: acLimitPreset1Item
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/AcCurrentLimit/Preset1")
    }
    property real acLimitPreset1: acLimitPreset1Item.valid ? acLimitPreset1Item.value : 0
    VBusItem
    {
        id: acLimitPreset2Item
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/AcCurrentLimit/Preset2")
    }
    property real acLimitPreset2: acLimitPreset2Item.valid ? acLimitPreset2Item.value : 0
    VBusItem
    {
        id: acLimitPreset3Item
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/AcCurrentLimit/Preset3")
    }
    property real acLimitPreset3: acLimitPreset3Item.valid ? acLimitPreset3Item.value : 0
    VBusItem
    {
        id: acLimitPreset4Item
        bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/AcCurrentLimit/Preset4")
    }
    property real acLimitPreset4: acLimitPreset4Item.valid ? acLimitPreset4Item.value : 0

	height: contentHeight + 2
	editable: true

    Component.onCompleted: getActualCurrent ()

	Behavior on height {
		PropertyAnimation {
			duration: 150
		}
	}

	signal accepted()

	VBusItem {
		id: vItem
        onValueChanged: getActualCurrent ()
        onValidChanged: getActualCurrent ()
	}

	values:
    [
		Item { width: 1; height: expanded ?  4 : 0; visible: expanded},
        // spacer to expand hidden button over actual button of Multi icon
        TileText
        {
            text: " "
            font.pixelSize: 30
            visible: !expanded
        },
		Column
        {
			width: root.width - 8
			x: 2
			spacing: 4
			visible: expanded

            TileText
            {
                text: qsTr ("Actual: " + actualCurrentLimit.toFixed(1) + " A")
                font.bold: true; color: "black"           
            }
            TileText
            {
                text: qsTr ("New: " + newCurrentLimit.toFixed(1) + " A")
                font.bold: true; color: "black"
                opacity: newCurrentLimit !== actualCurrentLimit ? 1 : 0.001
            }
            Row
            {
                width: (parent.width / 2) - 4
                spacing: 4
                Button
                {
                    id: preset1button
                    baseColor: newCurrentLimit === acLimitPreset1 ? "black" : root.buttonColor
                    pressedColor: root.color
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
                    pressedColor: root.color
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
                    pressedColor: root.color
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
                    pressedColor: root.color
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
                    pressedColor: root.color
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
                    pressedColor: root.color
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
                width: (parent.width / 2) - 4
                spacing: 4
                Button
                {
                    id: acceptButton
                    baseColor: root.buttonColor
                    pressedColor: root.color
                    height: 40
                    width: parent.width
                    onClicked: accept()
                    content: TileText { text: qsTr ("Accept");
                            font.bold: true; color: newCurrentLimit !== actualCurrentLimit ? "white" : "#d9d9d9" }
                }
                Button
                {
                    id: cancelButton
                    baseColor: root.buttonColor
                    pressedColor: root.color
                    height: 40
                    width: parent.width
                    onClicked: cancel()
                    content: TileText { text: qsTr ("Cancel");
                            font.bold: true; color: "white" }
                }
            }
		}
	]

	function setNewValue (newValue)
	{
		if (!root.valid || root.readOnly)
			return

		newCurrentLimit = newValue
	}

    function trimNewValue (trimValue)
    {
        if (!root.valid || root.readOnly)
            return

        newCurrentLimit += trimValue
        if (newCurrentLimit < 0)
            newCurrentLimit = 0
    }

	function cancel ()
	{
        newCurrentLimit = actualCurrentLimit
		root.expanded = false
	}
 
    function accept ()
    {
        if (!root.valid || root.readOnly)
            return

        vItem.setValue (newCurrentLimit)
        expanded = false
        accepted()
    }
    
    function getActualCurrent ()
    {
        actualCurrentLimit = vItem.valid ? vItem.value : 0
        newCurrentLimit = actualCurrentLimit
    }
    
	MouseArea {
		id: mouseArea
		anchors.fill: parent
		enabled: !expanded
		onClicked: { root.expanded = true }
	}
}
