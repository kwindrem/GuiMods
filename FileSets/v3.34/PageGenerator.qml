//// changed total time to hours (from varilable format)

import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	id: generator
	title: qsTr("Generator start/stop")
	property string settingsBindPrefix
	property string startStopBindPrefix
	property alias startStopModel: _startStopModel
	property VBusItem activeCondition: VBusItem { bind: Utils.path(startStopBindPrefix, "/RunningByCondition") }
	property VBusItem generatorState: VBusItem { bind: Utils.path(startStopBindPrefix, "/State") }
	property VBusItem runningTime: VBusItem { bind: Utils.path(startStopBindPrefix, "/Runtime") }
	property VBusItem historicalData: VBusItem { bind: Utils.path(settingsBindPrefix, "/AccumulatedDaily") }

	FnGeneratorStates {
		id: genState
	}

//// changed total time to hours (from varilable format)
	function formatTime (time)
	{
		if (time >= 3600)
			return (time / 3600).toFixed(0) + " h"
		else
			return (time / 60).toFixed(0) + " m"
	}

	model: startStopModel

	function formatError(text, value)
	{
		return "#" + value.toString() + " " + text
	}

	VisibleItemModel {
		id: _startStopModel

		MbItemValue {
			description: qsTr("State")
			show: startStopBindPrefix === "com.victronenergy.generator.startstop0"
			item.text: activeCondition.valid ? genState.getState(generatorState.value, activeCondition.value) : '---'
		}

		MbItemOptions {
			id: _gensetStatus
			description: qsTr("Error")
			bind: Utils.path(startStopBindPrefix, "/Error")
			readonly: true
			show: valid && startStopBindPrefix === "com.victronenergy.generator.startstop0"
			possibleValues: [
				MbOption { description: qsTr("No error"); value: 0 },
				MbOption { description: formatError(qsTr("Remote switch control disabled"), 1); value: 1 },
				MbOption { description: formatError(qsTr("Generator in fault condition"), 2); value: 2 },
				MbOption { description: formatError(qsTr("Generator not detected at AC input"), 3); value: 3 }
			]
		}

		MbItemValue {
			description: qsTr("Run time")
			item.text: runningTime.valid ? Utils.secondsToNoSecsString(runningTime.value) : "0"
			show: generatorState.value in [1, 2, 3] // Running, Warm-up, Cool-down
		}

		MbItemValue {
			description: qsTr("Total run time")
			item {
				bind: Utils.path(settingsBindPrefix, "/AccumulatedTotal")
				//// changed total time to hours (from varilable format)
				text: formatTime (item.value - accumulatedTotalOffset.value)
			}
			VBusItem {
				id: accumulatedTotalOffset
				bind: Utils.path(settingsBindPrefix, "/AccumulatedTotalOffset")
			}
		}

		MbItemValue {
			description: qsTr("Time to service")
			show: item.valid
			item {
				bind: Utils.path(startStopBindPrefix, "/ServiceCounter")
				text: qsTr("%1h").arg((item.value / 60 / 60).toFixed(0))
			}
		}

		MbItemValue {
			description: qsTr("Accumulated running time since last test run")
			show: user.accessLevel >= User.AccessService && nextTestRun.show
			backgroundColor: style.backgroundColorService
			item {
				text: Utils.secondsToNoSecsString(item.value)
				bind: Utils.path(startStopBindPrefix, "/TestRunIntervalRuntime")
			}
		}

		MbItemValue {
			id: nextTestRun
			description: qsTr("Time to next test run")
			show: item.valid && item.value > 0
			item {
				text: {
					var remainingTime = item.value - new Date().getTime() / 1000
					if (remainingTime > 0)
						return Utils.secondsToNoSecsString(remainingTime).toString()
					return qsTr("Running now")
				}
				bind: Utils.path(startStopBindPrefix, "/NextTestRun")
			}
		}

		MbSwitch {
			name: qsTr("Auto start functionality")
			bind: Utils.path(startStopBindPrefix, "/AutoStartEnabled")
			show: startStopBindPrefix === "com.victronenergy.generator.startstop0"
		}

		MbSubMenu {
		description: qsTr("Manual start")
		show: startStopBindPrefix === "com.victronenergy.generator.startstop0"
		subpage:
			Component {
			PageGeneratorManualStart {
				startStopBindPrefix: generator.startStopBindPrefix
			}
		}
	}

		MbSubMenu {
			description: qsTr("Daily run time")
			subpage: MbPage {
				// Invert the order
				property variant keys: historicalData.valid ?
										Object.keys(JSON.parse(historicalData.value)).reverse() : 0

				title: qsTr("Daily run time")
				focus: active
				model: keys
				delegate: MbItemValue {
					description: Qt.formatDate(new Date(parseInt(keys[index]) * 1000), "dd-MM-yyyy");
					item.text: Utils.secondsToNoSecsString(JSON.parse(historicalData.value)[keys[index]])
				}
			}
		}

		MbSubMenu {
			id: conditions
			description: qsTr("Settings")
			subpage: Component {
				PageSettingsGenerator {
					settingsBindPrefix: generator.settingsBindPrefix
					startStopBindPrefix: generator.startStopBindPrefix
				}
			}
		}
	}
}
