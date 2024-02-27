// New for GuiMods to show relay info on a separate Overview page

import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils
import "tanksensor.js" as TankSensor

OverviewPage
{
	id: root

    property int relayWidth: 0
    property int relaysOnPage: 6
	property int maxRelays: 20
    property int numberOfRelaysShown: 0
    property int horizontalMargin: 8
    property int tileWidth: (root.width - (horizontalMargin * 2)) / root.relaysOnPage
    property int listWidth: tileWidth * Math.min ( numberOfRelaysShown, relaysOnPage)
    property int listHeight: root.height - 30

////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 1

    VBusItem
    {
        id: relay0ShowItem
        bind: Utils.path("com.victronenergy.settings", "/Settings/Relay/0/Show")
        onValueChanged: updateRelays ()
    }
    VBusItem
    {
        id: relay1ShowItem
        bind: Utils.path("com.victronenergy.settings", "/Settings/Relay/1/Show")
        onValueChanged: updateRelays ()
    }
    VBusItem
    {
        id: relay2ShowItem
        bind: Utils.path("com.victronenergy.settings", "/Settings/Relay/2/Show")
        onValueChanged: updateRelays ()
    }
    VBusItem
    {
        id: relay3ShowItem
        bind: Utils.path("com.victronenergy.settings", "/Settings/Relay/3/Show")
        onValueChanged: updateRelays ()
    }
    VBusItem
    {
        id: relay4ShowItem
        bind: Utils.path("com.victronenergy.settings", "/Settings/Relay/4/Show")
        onValueChanged: updateRelays ()
    }
	VBusItem
	{
		id: relay5ShowItem
		bind: Utils.path("com.victronenergy.settings", "/Settings/Relay/5/Show")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay6ShowItem
		bind: Utils.path("com.victronenergy.settings", "/Settings/Relay/6/Show")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay7ShowItem
		bind: Utils.path("com.victronenergy.settings", "/Settings/Relay/7/Show")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay8ShowItem
		bind: Utils.path("com.victronenergy.settings", "/Settings/Relay/8/Show")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay9ShowItem
		bind: Utils.path("com.victronenergy.settings", "/Settings/Relay/9/Show")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay10ShowItem
		bind: Utils.path("com.victronenergy.settings", "/Settings/Relay/10/Show")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay11ShowItem
		bind: Utils.path("com.victronenergy.settings", "/Settings/Relay/11/Show")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay12ShowItem
		bind: Utils.path("com.victronenergy.settings", "/Settings/Relay/12/Show")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay13ShowItem
		bind: Utils.path("com.victronenergy.settings", "/Settings/Relay/13/Show")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay14ShowItem
		bind: Utils.path("com.victronenergy.settings", "/Settings/Relay/14/Show")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay15ShowItem
		bind: Utils.path("com.victronenergy.settings", "/Settings/Relay/15/Show")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay16ShowItem
		bind: Utils.path("com.victronenergy.settings", "/Settings/Relay/16/Show")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay17ShowItem
		bind: Utils.path("com.victronenergy.settings", "/Settings/Relay/17/Show")
		onValueChanged: updateRelays ()
	}

    VBusItem
    {
        id: relay0StateItem
        bind: Utils.path("com.victronenergy.system", "/Relay/0/State")
        onValueChanged: updateRelays ()
    }
    VBusItem
    {
        id: relay1StateItem
        bind: Utils.path("com.victronenergy.system", "/Relay/1/State")
        onValueChanged: updateRelays ()
    }
    VBusItem
    {
        id: relay2StateItem
        bind: Utils.path("com.victronenergy.system", "/Relay/2/State")
        onValueChanged: updateRelays ()
    }
    VBusItem
    {
        id: relay3StateItem
        bind: Utils.path("com.victronenergy.system", "/Relay/3/State")
        onValueChanged: updateRelays ()
    }
    VBusItem
    {
        id: relay4StateItem
        bind: Utils.path("com.victronenergy.system", "/Relay/4/State")
        onValueChanged: updateRelays ()
    }
    VBusItem
    {
        id: relay5StateItem
        bind: Utils.path("com.victronenergy.system", "/Relay/5/State")
        onValueChanged: updateRelays ()
    }
	VBusItem
	{
		id: relay6StateItem
		bind: Utils.path("com.victronenergy.system", "/Relay/6/State")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay7StateItem
		bind: Utils.path("com.victronenergy.system", "/Relay/7/State")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay8StateItem
		bind: Utils.path("com.victronenergy.system", "/Relay/8/State")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay9StateItem
		bind: Utils.path("com.victronenergy.system", "/Relay/9/State")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay10StateItem
		bind: Utils.path("com.victronenergy.system", "/Relay/10/State")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay11StateItem
		bind: Utils.path("com.victronenergy.system", "/Relay/11/State")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay12StateItem
		bind: Utils.path("com.victronenergy.system", "/Relay/12/State")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay13StateItem
		bind: Utils.path("com.victronenergy.system", "/Relay/13/State")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay14StateItem
		bind: Utils.path("com.victronenergy.system", "/Relay/14/State")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay15StateItem
		bind: Utils.path("com.victronenergy.system", "/Relay/15/State")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay16StateItem
		bind: Utils.path("com.victronenergy.system", "/Relay/16/State")
		onValueChanged: updateRelays ()
	}
	VBusItem
	{
		id: relay17StateItem
		bind: Utils.path("com.victronenergy.system", "/Relay/17/State")
		onValueChanged: updateRelays ()
	}

    // Synchronise name text scroll start
    Timer
    {
        id: marqueeTimer
        interval: 5000
        repeat: true
        running: root.active
   }

	title: qsTr("Relay overview")
	clip: true

    Component.onCompleted: updateRelays ()

    // background
    Rectangle
    {
        anchors
        {
            fill: parent
        }
////// GuiMods — DarkMode
		color: !darkMode ? "gray" : "#202020"
    }

    ListModel { id: relaysModel }

    Text
    {
        font.pixelSize: 14
        font.bold: true
        color: "black"
        anchors
        {
            top: parent.top
            topMargin: 7
            horizontalCenter: parent.horizontalCenter
        }
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("Relay overview")
    }

	ListView
    {
        id: relaysColumn

        anchors.horizontalCenter: root.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 30
        width: listWidth
        height: listHeight
        orientation: ListView.Horizontal
        visible: numberOfRelaysShown > 0
        interactive: numberOfRelaysShown > relaysOnPage

        model: relaysModel
        delegate: TileRelay
        {
            width: tileWidth
            height: root.height - 38
            Connections
            {
                target: marqueeTimer
                onTriggered: doScroll()
            }
        }
    }

    function updateRelays ()
    {
        var show = false
        numberOfRelaysShown = 0
        relaysModel.clear()
        for (var i = 0; i < maxRelays; i++)
        {
            switch (i)
            {
			case 0:
				show = relay0StateItem.valid && relay0ShowItem.valid && relay0ShowItem.value === 1
				break;;
			case 1:
				show = relay1StateItem.valid && relay1ShowItem.valid && relay1ShowItem.value === 1
				break;;
			case 2:
				show = relay2StateItem.valid && relay2ShowItem.valid && relay2ShowItem.value === 1
				break;;
			case 3:
				show = relay3StateItem.valid && relay3ShowItem.valid && relay3ShowItem.value === 1
				break;;
			case 4:
				show = relay4StateItem.valid && relay4ShowItem.valid && relay4ShowItem.value === 1
				break;;
			case 5:
				show = relay5StateItem.valid && relay5ShowItem.valid && relay5ShowItem.value === 1
				break;;
			case 6:
				show = relay6StateItem.valid && relay6ShowItem.valid && relay6ShowItem.value === 1
				break;;
			case 7:
				show = relay7StateItem.valid && relay7ShowItem.valid && relay7ShowItem.value === 1
				break;;
			case 8:
				show = relay8StateItem.valid && relay8ShowItem.valid && relay8ShowItem.value === 1
				break;;
			case 9:
				show = relay9StateItem.valid && relay9ShowItem.valid && relay9ShowItem.value === 1
				break;;
			case 10:
				show = relay10StateItem.valid && relay10ShowItem.valid && relay10ShowItem.value === 1
				break;;
			case 11:
				show = relay11StateItem.valid && relay11ShowItem.valid && relay11ShowItem.value === 1
				break;;
			case 12:
				show = relay12StateItem.valid && relay12ShowItem.valid && relay12ShowItem.value === 1
				break;;
			case 13:
				show = relay13StateItem.valid && relay13ShowItem.valid && relay13ShowItem.value === 1
				break;;
			case 14:
				show = relay14StateItem.valid && relay14ShowItem.valid && relay14ShowItem.value === 1
				break;;
			case 15:
				show = relay15StateItem.valid && relay15ShowItem.valid && relay15ShowItem.value === 1
				break;;
			case 16:
				show = relay16StateItem.valid && relay16ShowItem.valid && relay16ShowItem.value === 1
				break;;
			case 17:
				show = relay17StateItem.valid && relay17ShowItem.valid && relay17ShowItem.value === 1
				break;;
			default:
                show = false
				break;;
            }

            if (show)
            {
                numberOfRelaysShown++ // increment before append so ListView centers properly
                relaysModel.append ({relayNumber: i})
            }
        }
    }
}
