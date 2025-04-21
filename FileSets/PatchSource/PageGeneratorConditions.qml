import QtQuick 2
import "utils.js" as Utils

MbPage {
	id: root

	property string bindPrefix
	property string startStopBindPrefix
	property variant availableBatteryMonitors: availableBatteryServices.valid ? availableBatteryServices.value : ""
	property VBusItem availableBatteryServices: VBusItem { bind: Utils.path("com.victronenergy.system", "/AvailableBatteryMeasurements") }
	property VBusItem stopOnAc1Item: VBusItem { bind: Utils.path(bindPrefix, "/StopWhenAc1Available") }
	property VBusItem stopOnAc2Item: VBusItem { bind: Utils.path(bindPrefix, "/StopWhenAc2Available") }
	property VBusItem capabilities: VBusItem { bind: Utils.path(startStopBindPrefix, "/Capabilities") }

	title: qsTr("Conditions")

	onAvailableBatteryMonitorsChanged: {
		if (availableBatteryMonitors !== "")
			monitorService.possibleValues = getMonitorList(availableBatteryMonitors)
	}

	function getMonitorList(list)
	{
		var fullList = []
		var component = Qt.createComponent("MbOption.qml");
		for (var i in list) {
			var params = {
				"description": list[i],
				"value": i
			}
				var option = component.createObject(root, params)
				fullList.push(option)
		}
		return fullList
	}

	model: VisibleItemModel {

		MbItemOptions {
			id: monitorService
			description: qsTr("Battery monitor")
			bind: Utils.path(settingsBindPrefix, "/BatteryService")
			unknownOptionText: qsTr("Unavailable monitor, set another")
			show: value !== "default"
		}

		MbItemOptions {
			description: qsTr("On loss of communication")
			bind: Utils.path(settingsBindPrefix, "/OnLossCommunication")
			possibleValues: [
				MbOption { description: qsTr("Stop generator"); value: 0 },
				MbOption { description: qsTr("Start generator"); value: 1 },
				MbOption { description: qsTr("Keep generator running"); value: 2 }
			]
		}

		MbItemOptions {
			description: qsTr("Stop generator when AC-input is available")
			value: stopOnAc1Item.value === 1 ? 1 : (stopOnAc2Item.value===1 ? 2 : 0)
			possibleValues:[
				MbOption { description: qsTr("Disabled"); value: 0 },
				MbOption { description: qsTr("AC input 1"); value: 1 },
				MbOption { description: qsTr("AC input 2"); value: 2; readonly: !(capabilities.value & 1) }
			]
			onOptionSelected: {
				stopOnAc1Item.setValue(newValue & 1)
				stopOnAc2Item.setValue((newValue & 2) >> 1)
//// GuiMods - remove warning since startstop.py ignores the setting if on generator
			}
		}

		GeneratorCondition {
			description: qsTr("Battery SOC")
			bindPrefix: Utils.path(root.bindPrefix, "/Soc")
			startValueIsGreater: false
			decimals: 0
			unit: "%"
		}

		GeneratorCondition {
			description: qsTr("Battery current")
			name: qsTr("battery current")
			bindPrefix: Utils.path(root.bindPrefix, "/BatteryCurrent")
			unit: "A"
		}

		GeneratorCondition {
			description: qsTr("Battery voltage")
			name: qsTr("battery voltage")
			bindPrefix: Utils.path(root.bindPrefix, "/BatteryVoltage")
			startValueIsGreater: false
			unit: "V"
		}

		MbSubMenu {
			description: qsTr("AC load")
			item {
				bind: Utils.path(root.bindPrefix, "/AcLoad/Enabled")
				text: item.value === 1 ? qsTr("Enabled") : qsTr("Disabled")
			}
			subpage: Component {
				PageGeneratorAcLoad {
					bindPrefix: Utils.path(root.bindPrefix, "/AcLoad")
				}
			}
		}

		GeneratorCondition {
			description: qsTr("Inverter high temperature")
			enableDescription: qsTr("Start on high temperature warning")
			startTimeDescription: qsTr("Start when warning is active for")
			stopTimeDescription: qsTr("When warning is cleared stop after")
			bindPrefix: Utils.path(root.bindPrefix, "/InverterHighTemp")
		}

		GeneratorCondition {
			description: qsTr("Inverter overload")
			enableDescription: qsTr("Start on overload warning")
			startTimeDescription: qsTr("Start when warning is active for")
			stopTimeDescription: qsTr("When warning is cleared stop after")
			supportsWarmup: (capabilities.value & 1)
			bindPrefix: Utils.path(root.bindPrefix, "/InverterOverload")
		}

		MbSubMenu {
			description: qsTr("Periodic run")
			item {
				bind: Utils.path(root.bindPrefix, "/TestRun/Enabled")
				text: item.value === 1 ? qsTr("Enabled") : qsTr("Disabled")
			}
			subpage:  PageGeneratorTestRun { bindPrefix: root.bindPrefix }
		}
	}
}
