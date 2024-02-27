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
	property VBusItem relay6Item: VBusItem { bind: "com.victronenergy.system/Relay/6/State" }
	property bool hasRelay6: relay6Item.valid
	property VBusItem relay7Item: VBusItem { bind: "com.victronenergy.system/Relay/7/State" }
	property bool hasRelay7: relay7Item.valid
	property VBusItem relay8Item: VBusItem { bind: "com.victronenergy.system/Relay/8/State" }
	property bool hasRelay8: relay8Item.valid
	property VBusItem relay9Item: VBusItem { bind: "com.victronenergy.system/Relay/9/State" }
	property bool hasRelay9: relay9Item.valid
	property VBusItem relay10Item: VBusItem { bind: "com.victronenergy.system/Relay/10/State" }
	property bool hasRelay10: relay10Item.valid
	property VBusItem relay11Item: VBusItem { bind: "com.victronenergy.system/Relay/11/State" }
	property bool hasRelay11: relay11Item.valid 
	property VBusItem relay12Item: VBusItem { bind: "com.victronenergy.system/Relay/12/State" }
	property bool hasRelay12: relay12Item.valid 
	property VBusItem relay13Item: VBusItem { bind: "com.victronenergy.system/Relay/13/State" }
	property bool hasRelay13: relay13Item.valid 
	property VBusItem relay14Item: VBusItem { bind: "com.victronenergy.system/Relay/14/State" }
	property bool hasRelay14: relay14Item.valid 
	property VBusItem relay15Item: VBusItem { bind: "com.victronenergy.system/Relay/15/State" }
	property bool hasRelay15: relay15Item.valid 
	property VBusItem relay16Item: VBusItem { bind: "com.victronenergy.system/Relay/16/State" }
	property bool hasRelay16: relay16Item.valid 
	property VBusItem relay17Item: VBusItem { bind: "com.victronenergy.system/Relay/17/State" }
	property bool hasRelay17: relay17Item.valid 

	property VBusItem relay0NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/0/CustomName") }
	property VBusItem relay1NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/1/CustomName") }
	property VBusItem relay2NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/2/CustomName") }
	property VBusItem relay3NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/3/CustomName") }
	property VBusItem relay4NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/4/CustomName") }
	property VBusItem relay5NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/5/CustomName") }
	property VBusItem relay6NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/6/CustomName") }
	property VBusItem relay7NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/7/CustomName") }
	property VBusItem relay8NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/8/CustomName") }
	property VBusItem relay9NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/9/CustomName") }
	property VBusItem relay10NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/10/CustomName") }
	property VBusItem relay11NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/11/CustomName") }
	property VBusItem relay12NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/12/CustomName") }
	property VBusItem relay13NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/13/CustomName") }
	property VBusItem relay14NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/14/CustomName") }
	property VBusItem relay15NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/15/CustomName") }
	property VBusItem relay16NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/16/CustomName") }
	property VBusItem relay17NameItem: VBusItem { bind: Utils.path(bindPrefix, "/Settings/Relay/17/CustomName") }

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
			return prefix + (hasRelay1 ? qsTr("Relay 1") : qsTr("Relay")) + suffix + " " + qsTr("On")
		else
			return prefix + qsTr("Relay") + " " + relayNumber + suffix + " " + qsTr("On")
	}

	model: VisibleItemModel {
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
		MbSwitch {                                                                                               
			id: manualSwitch6                                                                                    
			name: relayName (relay6NameItem, 7)                                                      
			bind: "com.victronenergy.system/Relay/6/State"                                                       
			show: hasRelay6                                                                                                             
		}   
		MbSwitch {                                                                                               
			id: manualSwitch7                                                                                    
			name: relayName (relay7NameItem, 8)                                                      
			bind: "com.victronenergy.system/Relay/7/State"                                                       
			show: hasRelay7                                                                                                             
		}   
		MbSwitch {                                                                                               
			id: manualSwitch8                                                                                    
			name: relayName (relay8NameItem, 9)                                                      
			bind: "com.victronenergy.system/Relay/8/State"                                                       
			show: hasRelay8                                                                                                             
		}   
		MbSwitch {                                                                                               
			id: manualSwitch9                                                                                    
			name: relayName (relay9NameItem, 10)                                                      
			bind: "com.victronenergy.system/Relay/9/State"                                                       
			show: hasRelay9                                                                                                             
		}   
		MbSwitch {                                                                                               
			id: manualSwitch10                                                                                   
			name: relayName (relay10NameItem, 11)                                                     
			bind: "com.victronenergy.system/Relay/10/State"                                                       
			show: hasRelay10                                                                                     
		}
		MbSwitch {                                                                                               
			id: manualSwitch11                                                                                   
			name: relayName (relay11NameItem, 12)                                                    
			bind: "com.victronenergy.system/Relay/11/State"                                                      
			show: hasRelay11                                                                                     
		}
		MbSwitch {                                                                                               
			id: manualSwitch12                                                                                   
						name: relayName (relay12NameItem, 13)                                                    
			bind: "com.victronenergy.system/Relay/12/State"                                                      
			show: hasRelay12                                                                                     
		}
		MbSwitch {                                                                                               
			id: manualSwitch13                                                                                   
			name: relayName (relay13NameItem, 14)                                                    
			bind: "com.victronenergy.system/Relay/13/State"                                                      
			show: hasRelay13                                                                                     
		}
		MbSwitch {                                                                                               
			id: manualSwitch14                                                                                   
			name: relayName (relay14NameItem, 15)                                                    
			bind: "com.victronenergy.system/Relay/14/State"                                                      
			show: hasRelay14                                                                                     
		}
		MbSwitch {                                                                                               
			id: manualSwitch15                                                                                   
			name: relayName (relay15NameItem, 16)                                                    
			bind: "com.victronenergy.system/Relay/15/State"                                                      
			show: hasRelay15                                                                                     
		}
		MbSwitch {                                                                                               
			id: manualSwitch16                                                                                   
			name: relayName (relay16NameItem, 17)                                                    
			bind: "com.victronenergy.system/Relay/16/State"                                                      
			show: hasRelay16                                                                                     
		}
		MbSwitch {                                                                                               
			id: manualSwitch17                                                                                   
			name: relayName (relay17NameItem, 18)                                                    
			bind: "com.victronenergy.system/Relay/17/State"                                                      
			show: hasRelay17                                                                                     
		}

		MbSubMenu {
			id: conditions
			description: qsTr("Temperature control rules")
			show: relayFunction.value === 4 || relay1Function.value === 4
			subpage: Component {
				PageSettingsRelayTempSensors {
					id: relayPage
					title: qsTr("Temperature control rules")
				}
			}
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
																												 
		MbEditBox {                                                                                              
			id: relay6name                                                                                       
			description: qsTr("Relay 7 Name")                                                                    
			item.bind: "com.victronenergy.settings/Settings/Relay/6/CustomName"                                  
			show: item.valid                                                                                     
			maximumLength: 32                                                                                                           
			enableSpaceBar: true                                                                                 
		}                                                                                                        
		MbSwitch {                                                                                               
			id: showRelay6                                                                                       
			name: qsTr("Show Relay 7 in overview")                                                               
			bind: "com.victronenergy.settings/Settings/Relay/6/Show"                                             
			show: hasRelay6                                                                                                             
		}
																												 
		MbEditBox {                                                                                              
			id: relay7name                                                                                       
			description: qsTr("Relay 8 Name")                                                                    
			item.bind: "com.victronenergy.settings/Settings/Relay/7/CustomName"                                  
			show: item.valid                                                                                     
			maximumLength: 32                                                                                                           
			enableSpaceBar: true                                                                                 
		}                                                                                                        
		MbSwitch {                                                                                               
			id: showRelay7                                                                                       
			name: qsTr("Show Relay 8 in overview")                                                               
			bind: "com.victronenergy.settings/Settings/Relay/7/Show"                                             
			show: hasRelay7                                                                                                             
		}
																												 
		MbEditBox {                                                                                              
			id: relay8name                                                                                       
			description: qsTr("Relay 9 Name")                                                                    
			item.bind: "com.victronenergy.settings/Settings/Relay/8/CustomName"                                  
			show: item.valid                                                                                     
			maximumLength: 32                                                                                                           
			enableSpaceBar: true                                                                                 
		}                                                                                                        
		MbSwitch {                                                                                               
			id: showRelay8                                                                                       
			name: qsTr("Show Relay 9 in overview")                                                               
			bind: "com.victronenergy.settings/Settings/Relay/8/Show"                                             
			show: hasRelay8                                                                                                             
		}
																												 
		MbEditBox {                                                                                              
			id: relay9name                                                                                       
			description: qsTr("Relay 10 Name")                                                                    
			item.bind: "com.victronenergy.settings/Settings/Relay/9/CustomName"                                  
			show: item.valid                                                                                     
			maximumLength: 32                                                                                                           
			enableSpaceBar: true                                                                                 
		}                                                                                                        
		MbSwitch {                                                                                               
			id: showRelay9                                                                                       
			name: qsTr("Show Relay 10 in overview")                                                               
			bind: "com.victronenergy.settings/Settings/Relay/9/Show"                                             
			show: hasRelay9                                                                                                             
		}
																												 
		MbEditBox {                                                                                              
			id: relay10name                                                                                       
			description: qsTr("Relay 11 Name")                                                                   
			item.bind: "com.victronenergy.settings/Settings/Relay/10/CustomName"                                  
			show: item.valid                                                                                     
			maximumLength: 32                                                                                    
			enableSpaceBar: true                                                                                 
		}                                                                                                        
		MbSwitch {                                                                                               
			id: showRelay10                                                                                      
			name: qsTr("Show Relay 11 in overview")                                                              
			bind: "com.victronenergy.settings/Settings/Relay/10/Show"                                             
			show: hasRelay10                                                                                     
		}                                                                                                        
																												 
		MbEditBox {                                                                                              
			id: relay11name                                                                                      
			description: qsTr("Relay 12 Name")                                                                   
			item.bind: "com.victronenergy.settings/Settings/Relay/11/CustomName"                                 
			show: item.valid                                                                                     
			maximumLength: 32                                                                                    
			enableSpaceBar: true                                                                                 
		}                                                                                                        
		MbSwitch {                                                                                               
			id: showRelay11                                                                                      
			name: qsTr("Show Relay 12 in overview")                                                              
			bind: "com.victronenergy.settings/Settings/Relay/11/Show"                                            
			show: hasRelay11                                                                                     
		}                                                                                                        

		MbEditBox {                                                                                              
			id: relay12name                                                                                      
			description: qsTr("Relay 13 Name")                                                                   
			item.bind: "com.victronenergy.settings/Settings/Relay/12/CustomName"                                 
			show: item.valid                                                                                     
			maximumLength: 32                                                                                    
			enableSpaceBar: true                                                                                 
		}                                                                                                        
		MbSwitch {                                                                                               
			id: showRelay12                                                                                      
			name: qsTr("Show Relay 13 in overview")                                                              
			bind: "com.victronenergy.settings/Settings/Relay/12/Show"                                            
			show: hasRelay12                                                                                     
		}                                                                                                        

		MbEditBox {                                                                                              
			id: relay13name                                                                                      
			description: qsTr("Relay 14 Name")                                                                   
			item.bind: "com.victronenergy.settings/Settings/Relay/13/CustomName"                                 
			show: item.valid                                                                                     
			maximumLength: 32                                                                                    
			enableSpaceBar: true                                                                                 
		}                                                                                                        
		MbSwitch {                                                                                               
			id: showRelay13                                                                                      
			name: qsTr("Show Relay 14 in overview")                                                              
			bind: "com.victronenergy.settings/Settings/Relay/13/Show"                                            
			show: hasRelay13                                                                                     
		}                                                                                                        

		MbEditBox {                                                                                              
			id: relay14name                                                                                      
			description: qsTr("Relay 15 Name")                                                                   
			item.bind: "com.victronenergy.settings/Settings/Relay/14/CustomName"                                 
			show: item.valid                                                                                     
			maximumLength: 32                                                                                    
			enableSpaceBar: true                                                                                 
		}                                                                                                        
		MbSwitch {                                                                                               
			id: showRelay14                                                                                      
			name: qsTr("Show Relay 15 in overview")                                                              
			bind: "com.victronenergy.settings/Settings/Relay/14/Show"                                            
			show: hasRelay14                                                                                     
		}                                                                                                        

		MbEditBox {                                                                                              
			id: relay15name                                                                                      
			description: qsTr("Relay 16 Name")                                                                   
			item.bind: "com.victronenergy.settings/Settings/Relay/15/CustomName"                                 
			show: item.valid                                                                                     
			maximumLength: 32                                                                                    
			enableSpaceBar: true                                                                                 
		}                                                                                                        
		MbSwitch {                                                                                               
			id: showRelay15                                                                                      
			name: qsTr("Show Relay 16 in overview")                                                              
			bind: "com.victronenergy.settings/Settings/Relay/15/Show"                                            
			show: hasRelay15                                                                                     
		}                                                                                                        

		MbEditBox {                                                                                              
			id: relay16name                                                                                      
			description: qsTr("Relay 17 Name")                                                                   
			item.bind: "com.victronenergy.settings/Settings/Relay/16/CustomName"                                 
			show: item.valid                                                                                     
			maximumLength: 32                                                                                    
			enableSpaceBar: true                                                                                 
		}                                                                                                        
		MbSwitch {                                                                                               
			id: showRelay16                                                                                      
			name: qsTr("Show Relay 17 in overview")                                                              
			bind: "com.victronenergy.settings/Settings/Relay/16/Show"                                            
			show: hasRelay16                                                                                     
		}                                                                                                        
		MbEditBox {                                                                                              
			id: relay17name                                                                                      
			description: qsTr("Relay 18 Name")                                                                   
			item.bind: "com.victronenergy.settings/Settings/Relay/17/CustomName"                                 
			show: item.valid                                                                                     
			maximumLength: 32                                                                                    
			enableSpaceBar: true                                                                                 
		}                                                                                                        
		MbSwitch {                                                                                               
			id: showRelay17                                                                                      
			name: qsTr("Show Relay 18 in overview")                                                              
			bind: "com.victronenergy.settings/Settings/Relay/17/Show"                                            
			show: hasRelay17                                                                                     
		}                                                                                                        
	}
}
