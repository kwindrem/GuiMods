// New for GuiMods to show relay info on a separate Overview page

import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils
import "tanksensor.js" as TankSensor

OverviewPage
{
	id: root

    property int relayWidth: 0
    property int maxRelays: 6
    property int numberOfRelaysShown: 0
    property int horizontalMargin: 8
    property int tileWidth: (root.width - (horizontalMargin * 2)) / root.maxRelays
    property int listWidth: tileWidth * numberOfRelaysShown
    property int listHeight: root.height - 30

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

    // Synchronise name text scroll start
    Timer
    {
        id: marqueeTimer
        interval: 15000
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
        color: "#b3b3b3"
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
        show: numberOfRelaysShown > 0
        interactive: false

        model: relaysModel
        delegate: TileRelay
        {
            width: tileWidth
            height: root.height - 40
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
            default:
                show = false
            }

            if (show)
            {
                numberOfRelaysShown++ // increment before append so ListView centers properly
                relaysModel.append ({relayNumber: i})
            }
        }
    }
}
