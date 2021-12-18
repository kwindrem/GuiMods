//////// modified to
////////   add 6 relays for Raspberry PI
////////   custom relay name for Relay Overview
////////   show/hide relay in Relay Overview

import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	id: pageRelaySettings
	title: qsTr("Relay")
	property string bindPrefix: "com.victronenergy.settings"
    property VBusItem relay1Item: VBusItem { bind: "com.victronenergy.system/Relay/1/State" }
    property bool hasRelay1: relay1Item.valid

    property VBusItem relay2Item: VBusItem { bind: "com.victronenergy.system/Relay/2/State" }
    property bool hasRelay2: relay2Item.valid
    property VBusItem relay3Item: VBusItem { bind: "com.victronenergy.system/Relay/3/State" }
    property bool hasRelay3: relay3Item.valid
    property VBusItem relay4Item: VBusItem { bind: "com.victronenergy.system/Relay/4/State" }
    property bool hasRelay4: relay4Item.valid
    property VBusItem relay5Item: VBusItem { bind: "com.victronenergy.system/Relay/5/State" }
    property bool hasRelay5: relay5Item.valid

    property VBusItem relay0NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/0/CustomName") }
    property VBusItem relay1NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/1/CustomName") }
    property VBusItem relay2NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/2/CustomName") }
    property VBusItem relay3NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/3/CustomName") }
    property VBusItem relay4NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/4/CustomName") }
    property VBusItem relay5NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/5/CustomName") }

	function relayName (nameItem, relayNumber)
	{
		var prefix, suffix
		if (nameItem.valid && nameItem.value != "")
		{
			prefix = nameItem.value + " ("
			suffix = ")"
		}
		else
		{
			prefix = ""
			suffix = ""
		}
		if (relayNumber == 1)
			return prefix + (hasRelay1 ? qsTr("Relay 1") : qsTr("Relay")) + suffix + qsTr (" On")
		else
			return prefix + qsTr("Relay ") + relayNumber + suffix + qsTr (" On")
	}

	model: VisualItemModel {
		MbItemOptions {
			id: relayFunction
			description: hasRelay1 ? qsTr("Function (Relay 1)") : qsTr("Function")
			bind: Utils.path(bindPrefix, "/Settings/Relay/Function")
			possibleValues:[
				MbOption { description: qsTr("Alarm relay"); value: 0 },
				MbOption { description: qsTr("Generator start/stop"); value: 1 },
				MbOption { description: qsTr("Tank pump"); value: 3 },
				MbOption { description: qsTr("Manual"); value: 2 },
				MbOption { description: qsTr("Temperature"); value: 4 }
			]
		}

		MbItemOptions {
			description: qsTr("Alarm relay polarity")
			bind: Utils.path(bindPrefix, "/Settings/Relay/Polarity")
			show: relayFunction.value === 0
			possibleValues: [
				MbOption { description: qsTr("Normally open"); value: 0 },
				MbOption { description: qsTr("Normally closed"); value: 1 }
			]
		}

		MbSwitch {
			id: relaySwitch
			// Use a one-way binding, because the usual binding:
			// checked: Relay.relayOn
			// will be broken when the switched toggled, and changes in the relayOn property made
			// elsewhere will not change the state of the switch any more.
			Binding {
				target: relaySwitch
				property: "checked"
				value: Relay.relayOn
				when: true
			}
			enabled: userHasWriteAccess
			name: qsTr("Alarm relay On")
			onCheckedChanged: Relay.relayOn = checked;
			show: relayFunction.value === 0
		}

		MbSwitch {
			id: manualSwitch
			name: relayName (relay0NameItem, 1)
			bind: "com.victronenergy.system/Relay/0/State"
			show: relayFunction.value === 2 // manual mode
		}

		MbItemOptions {
			id: relay1Function
			description: hasRelay1 ? qsTr("Function (Relay 2)") : qsTr("Function")
			bind: Utils.path(bindPrefix, "/Settings/Relay/1/Function")
			show: hasRelay1
			possibleValues:[
				MbOption { description: qsTr("Manual"); value: 2 },
				MbOption { description: qsTr("Temperature"); value: 4 }
			]
		}
        MbSwitch {
            id: manualSwitch1
			name: relayName (relay1NameItem, 2)
            bind: "com.victronenergy.system/Relay/1/State"
            show: hasRelay1 && relay1Function.value === 2
        }
        MbSwitch {
            id: manualSwitch2
			name: relayName (relay2NameItem, 3)
            bind: "com.victronenergy.system/Relay/2/State"
            show: hasRelay2
        }
        MbSwitch {
            id: manualSwitch3
			name: relayName (relay3NameItem, 4)
            bind: "com.victronenergy.system/Relay/3/State"
            show: hasRelay3
        }
        MbSwitch {
            id: manualSwitch4
			name: relayName (relay4NameItem, 5)
            bind: "com.victronenergy.system/Relay/4/State"
            show: hasRelay4
        }
        MbSwitch {
            id: manualSwitch5
			name: relayName (relay5NameItem, 6)
            bind: "com.victronenergy.system/Relay/5/State"
            show: hasRelay5
        }

        MbEditBox {
            id: relay0name
            description: qsTr("Relay 1 Name")
            item.bind: "com.victronenergy.settings/Settings/Relay/0/CustomName"
            show: item.valid && relayFunction.value === 2 // manual mode
            maximumLength: 32
            enableSpaceBar: true
        }
        MbSwitch {
            id: showRelay0
            name: qsTr("Show Relay 1 in overview")
            bind: "com.victronenergy.settings/Settings/Relay/0/Show"
        }

        MbEditBox {
            id: relay1name
            description: qsTr("Relay 2 Name")
            item.bind: "com.victronenergy.settings/Settings/Relay/1/CustomName"
            show: item.valid
            maximumLength: 32
            enableSpaceBar: true
        }
        MbSwitch {
            id: showRelay1
            name: qsTr("Show Relay 2 in overview")
            bind: "com.victronenergy.settings/Settings/Relay/1/Show"
            show: hasRelay1
        }

		MbSubMenu {
			id: conditions
			description: qsTr("Temperature sensors")
			item: VBusItem { value: relayPage.summary }
			show: relayFunction.value === 4 || relay1Function.value === 4
			subpage: PageSettingsRelayTempSensors {
				id: relayPage
				title: qsTr("Temperature sensors")
			}
		}

        MbEditBox {
            id: relay2name
            description: qsTr("Relay 3 Name")
            item.bind: "com.victronenergy.settings/Settings/Relay/2/CustomName"
            show: item.valid
            maximumLength: 32
            enableSpaceBar: true
        }
        MbSwitch {
            id: showRelay2
            name: qsTr("Show Relay 3 in overview")
            bind: "com.victronenergy.settings/Settings/Relay/2/Show"
            show: hasRelay2
        }

        MbEditBox {
            id: relay3name
            description: qsTr("Relay 4 Name")
            item.bind: "com.victronenergy.settings/Settings/Relay/3/CustomName"
            show: item.valid
            maximumLength: 32
            enableSpaceBar: true
        }
        MbSwitch {
            id: showRelay3
            name: qsTr("Show Relay 4 in overview")
            bind: "com.victronenergy.settings/Settings/Relay/3/Show"
            show: hasRelay3
        }

        MbEditBox {
            id: relay4name
            description: qsTr("Relay 5 Name")
            item.bind: "com.victronenergy.settings/Settings/Relay/4/CustomName"
            show: item.valid
            maximumLength: 32
            enableSpaceBar: true
        }
        MbSwitch {
            id: showRelay4
            name: qsTr("Show Relay 5 in overview")
            bind: "com.victronenergy.settings/Settings/Relay/4/Show"
            show: hasRelay4
        }

        MbEditBox {
            id: relay5name
            description: qsTr("Relay 6 Name")
            item.bind: "com.victronenergy.settings/Settings/Relay/5/CustomName"
            show: item.valid
            maximumLength: 32
            enableSpaceBar: true
        }
        MbSwitch {
            id: showRelay5
            name: qsTr("Show Relay 6 in overview")
            bind: "com.victronenergy.settings/Settings/Relay/5/Show"
            show: hasRelay5
        }
	}
}
