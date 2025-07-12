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
	property int maxRelays: 18
	property int numberOfRelaysShown: 0
	property int horizontalMargin: 8
	property int tileWidth: (root.width - (horizontalMargin * 2)) / root.relaysOnPage
	property int listWidth: tileWidth * Math.min ( numberOfRelaysShown, relaysOnPage)
	property int listHeight: root.height - 30

	property VBusItem switchableItem: VBusItem { bind: "com.victronenergy.system/SwitchableOutput/0/State" }
	property bool useSwitchable: switchableItem.valid
	
	property string showPrefix: useSwitchable ? "com.victronenergy.system/SwitchableOutput/" : "com.victronenergy.settings/Settings/Relay/"
	property string showParameter: useSwitchable ? "/Settings/ShowUIControl" : "/Show"
	property string statePrefix: useSwitchable ? "com.victronenergy.system/SwitchableOutput" : "com.victronenergy.system/Relay"
	


	// timer is used to minimize calls to updateRelays since so many parameters can change at the same
	//	time when initializing
	//
	// paramter changes start/restart the timer
	//
	// the updateRelays rebuilds the relay list when the timer times out

	Timer
	{
		id: refreshTimer
		interval: 100
		repeat: false
		running: false
		onTriggered: updateRelays ()
	}

////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 1

	VBusItem
	{
		id: relay0ShowItem
		bind: Utils.path(showPrefix, "0", showParameter)
		onValueChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay1ShowItem
		bind: Utils.path(showPrefix, "1", showParameter)
		onValueChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay2ShowItem
		bind: Utils.path(showPrefix, "2", showParameter)
		onValueChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay3ShowItem
		bind: Utils.path(showPrefix, "3", showParameter)
		onValueChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay4ShowItem
		bind: Utils.path(showPrefix, "4", showParameter)
		onValueChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay5ShowItem
		bind: Utils.path(showPrefix, "5", showParameter)
		onValueChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay6ShowItem
		bind: Utils.path(showPrefix, "6", showParameter)
		onValueChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay7ShowItem
		bind: Utils.path(showPrefix, "7", showParameter)
		onValueChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay8ShowItem
		bind: Utils.path(showPrefix, "8", showParameter)
		onValueChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay9ShowItem
		bind: Utils.path(showPrefix, "9", showParameter)
		onValueChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay10ShowItem
		bind: Utils.path(showPrefix, "10", showParameter)
		onValueChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay11ShowItem
		bind: Utils.path(showPrefix, "11", showParameter)
		onValueChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay12ShowItem
		bind: Utils.path(showPrefix, "12", showParameter)
		onValueChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay13ShowItem
		bind: Utils.path(showPrefix, "13", showParameter)
		onValueChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay14ShowItem
		bind: Utils.path(showPrefix, "14", showParameter)
		onValueChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay15ShowItem
		bind: Utils.path(showPrefix, "15", showParameter)
		onValueChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay16ShowItem
		bind: Utils.path(showPrefix, "16", showParameter)
		onValueChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay17ShowItem
		bind: Utils.path(showPrefix, "17", showParameter)
		onValueChanged: refreshTimer.restart ()
	}

	VBusItem
	{
		id: relay0StateItem
		bind: Utils.path(statePrefix, "/0/State")
		onValidChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay1StateItem
		bind: Utils.path(statePrefix, "/1/State")
		onValidChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay2StateItem
		bind: Utils.path(statePrefix, "/2/State")
		onValidChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay3StateItem
		bind: Utils.path(statePrefix, "/3/State")
		onValidChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay4StateItem
		bind: Utils.path(statePrefix, "/4/State")
		onValidChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay5StateItem
		bind: Utils.path(statePrefix, "/5/State")
		onValidChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay6StateItem
		bind: Utils.path(statePrefix, "/6/State")
		onValidChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay7StateItem
		bind: Utils.path(statePrefix, "/7/State")
		onValidChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay8StateItem
		bind: Utils.path(statePrefix, "/8/State")
		onValidChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay9StateItem
		bind: Utils.path(statePrefix, "/9/State")
		onValidChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay10StateItem
		bind: Utils.path(statePrefix, "/10/State")
		onValidChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay11StateItem
		bind: Utils.path(statePrefix, "/11/State")
		onValidChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay12StateItem
		bind: Utils.path(statePrefix, "/12/State")
		onValidChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay13StateItem
		bind: Utils.path(statePrefix, "/13/State")
		onValidChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay14StateItem
		bind: Utils.path(statePrefix, "/14/State")
		onValidChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay15StateItem
		bind: Utils.path(statePrefix, "/15/State")
		onValidChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay16StateItem
		bind: Utils.path(statePrefix, "/16/State")
		onValidChanged: refreshTimer.restart ()
	}
	VBusItem
	{
		id: relay17StateItem
		bind: Utils.path(statePrefix, "/17/State")
		onValidChanged: refreshTimer.restart ()
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

	Component.onCompleted: refreshTimer.restart ()

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
		color: darkMode ? "#707070" : "black"
		anchors
		{
			top: parent.top
			topMargin: 7
			horizontalCenter: parent.horizontalCenter
		}
		horizontalAlignment: Text.AlignHCenter
		text: numberOfRelaysShown > 0 ? qsTr("Relay overview") : qsTr("Relay overview (no relays)")
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
console.log ("updateRelays")
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
