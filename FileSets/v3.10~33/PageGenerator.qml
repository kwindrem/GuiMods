//// changed total time to hours (from varilable format)

import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	id: root
	title: qsTr("Generator start/stop")
	property string settingsBindPrefix
	property string startStopBindPrefix
	property alias startStopModel: _startStopModel
	property bool allowDisableAutostart: true
	property VBusItem activeCondition: VBusItem { bind: Utils.path(startStopBindPrefix, "/RunningByCondition") }
	property VBusItem generatorState: VBusItem { bind: Utils.path(startStopBindPrefix, "/State") }
	property VBusItem runningTime: VBusItem { bind: Utils.path(startStopBindPrefix, "/Runtime") }
	property VBusItem historicalData: VBusItem { bind: Utils.path(settingsBindPrefix, "/AccumulatedDaily") }

//// changed total time to hours (from varilable format)
	function formatTime (time)
	{
		if (time >= 3600)
			return (time / 3600).toFixed(0) + " h"
		else
			return (time / 60).toFixed(0) + " m"
	}


	function getState()
	{
		switch(generatorState.value) {
		case 10:
			return qsTr("Error")
		case 2:
			return qsTr("Warm-up")
		case 3:
			return qsTr("Cool-down")
		case 4:
			return qsTr("Stopping")
		}

		switch(activeCondition.value) {
		case 'soc':
			return qsTr("Running by SOC condition")
		case 'acload':
			return qsTr("Running by AC Load condition")
		case 'batterycurrent':
			return qsTr("Running by battery current condition")
		case 'batteryvoltage':
			return qsTr("Running by battery voltage condition")
		case 'inverterhightemp':
			return qsTr("Running by inverter high temperature")
		case 'inverteroverload':
			return qsTr("Running by inverter overload")
		case 'testrun':
			return qsTr("Test run")
		case 'lossofcommunication':
			return qsTr("Running by loss of communication")
		case 'manual':
			return qsTr("Manually started")
		default:
			return qsTr("Stopped")
		}
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
			item.text: activeCondition.valid ? getState() : '---'
		}

		MbItemOptions {
			id: _gensetStatus
			description: qsTr("Error")
			bind: Utils.path(startStopBindPrefix, "/Error")
			readonly: true
			show: valid
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
			show: item.valid
			item {
				bind: Utils.path(settingsBindPrefix, "/AccumulatedTotal")
//// changed total time to hours (from varilable format)
				text: formatTime (item.value)
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
			show: allowDisableAutostart
		}

		MbSubMenu {
			description: qsTr("Manual start")
			subpage: Component {
				MbPage {
					id: manualStartPage
					title: qsTr("Manual start")
					model: VisibleItemModel {
						MbSwitch {
							id: manualSwitch
							name: qsTr("Start generator")
							bind: Utils.path(startStopBindPrefix, "/ManualStart")
							writeAccessLevel: User.AccessUser
							onCheckedChanged: {
								if (manualStartPage.active) {
									if (!checked)
										toast.createToast(qsTr("Stopping, generator will continue running if other conditions are reached"), 3000)
									if (checked && stopTimer.value == 0)
										toast.createToast(qsTr("Starting, generator won't stop till user intervention"), 5000)
									if (checked && stopTimer.value > 0)
										toast.createToast(qsTr("Starting. The generator will stop in %1, unless other conditions keep it running").arg(Utils.secondsToString(stopTimer.value)), 5000)
								}
							}

							VBusItem {
								id: stopTimer
								bind: Utils.path(startStopBindPrefix, "/ManualStartTimer")
							}
						}

						MbEditBoxTime {
							description: qsTr("Run for (hh:mm)")
							readonly: manualSwitch.checked
							item.bind: Utils.path(startStopBindPrefix, "/ManualStartTimer")
							writeAccessLevel: User.AccessUser
						}
					}
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
					settingsBindPrefix: root.settingsBindPrefix
					startStopBindPrefix: root.startStopBindPrefix
				}
			}
		}
	}
}
