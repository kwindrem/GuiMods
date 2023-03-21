//// addd service interval and reset

import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	id: root
	title: qsTr("Generator start/stop settings")
	property string settingsBindPrefix
	property string startStopBindPrefix

	model: VisualItemModel {

		MbSubMenu {
			id: conditions
			description: qsTr("Conditions")
			subpage:
				Component {
				PageGeneratorConditions {
					title: qsTr("Conditions")
					bindPrefix: root.settingsBindPrefix
				}
			}
		}

		MbSpinBox {
			description: qsTr("Minimum run time")
			item {
				bind: Utils.path(settingsBindPrefix, "/MinimumRuntime")
				unit: "m"
				decimals: 0
				step: 1
			}
		}

		MbSwitch {
			property bool generatorIsSet: acIn1Source.value === 2 || acIn2Source.value === 2
			name: qsTr("Detect generator at AC input")
			bind: Utils.path(settingsBindPrefix, "/Alarms/NoGeneratorAtAcIn")
			enabled: valid && (generatorIsSet || checked)
			onClicked: {
				if (!checked) {
					if (!generatorIsSet) {
						toast.createToast(qsTr("None of the AC inputs is set to generator. Go to the system setup page and set the correct " +
											   "AC input to generator in order to enable this functionality."), 10000, "icon-info-active")
					} else {
						toast.createToast(qsTr("An alarm will be triggered when no power from the generator is detected at the inverter AC input. " +
											   "Make sure that the correct AC input is set to generator on the system setup page."), 12000, "icon-info-active")
					}
				}
			}

			VBusItem {
				id: acIn1Source
				bind: "com.victronenergy.settings/Settings/SystemSetup/AcInput1"
			}

			VBusItem {
				id: acIn2Source
				bind: "com.victronenergy.settings/Settings/SystemSetup/AcInput2"
			}
		}

		MbSwitch {
			id: timeZones
			name: qsTr("Quiet hours")
			bind: Utils.path(settingsBindPrefix, "/QuietHours/Enabled")
			enabled: valid
			writeAccessLevel: User.AccessUser
		}

		MbEditBoxTime {
			description: qsTr("Quiet hours start time")
			item.bind: Utils.path(settingsBindPrefix, "/QuietHours/StartTime")
			show: timeZones.checked
			writeAccessLevel: User.AccessUser
		}

		MbEditBoxTime {
			description: qsTr("Quiet hours end time")
			item.bind: Utils.path(settingsBindPrefix, "/QuietHours/EndTime")
			show: timeZones.checked
			writeAccessLevel: User.AccessUser
		}

		MbOK {
			description: qsTr("Reset daily run time counters")
			value: qsTr("Press to reset")
			enabled: true
			editable: enabled
			onClicked: {
				if (state.value === 0) {
					var now = new Date()
					var today = new Date(Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()))
					var todayInSeconds = today.getTime() / 1000
					resetDaily.setValue('{"%1" : 0}'.arg(todayInSeconds.toString()))
					toast.createToast(qsTr("The daily runtime counter has been reset"))
				} else if (state.value === 1) {
					toast.createToast(qsTr("It is not possible to modify the counters while the generator is running"))
				}
			}

			VBusItem {
				id: resetDaily
				bind: Utils.path(settingsBindPrefix, "/AccumulatedDaily")
			}
		}

		MbEditBox {
			id: setTotalRunTime
			description: qsTr("Generator total run time (hours)")
			item {
				bind: Utils.path(settingsBindPrefix, "/AccumulatedTotal")
				text: Math.round(item.value / 60 / 60)
			}
//// added to avoid full keyboard
            numericOnlyLayout: true
			matchString: "0123456789"
			maximumLength: 6
			ignoreChars: "h"
			enabled: state.value === 0

			function editTextToValue() {
				return parseInt(_editText, 10)  * 60 * 60
			}

			Keys.onSpacePressed: {
				if (!enabled)
					toast.createToast(qsTr("It is not possible to modify the counters while the generator is running"))
			}
		}

//// addd service interval and reset
		MbEditBox
		{
			id: serviceInterval
			description: qsTr("Generator service interval (hours)")
			item {
				bind: Utils.path(settingsBindPrefix, "/ServiceInterval")
				text: Math.round(item.value / 60 / 60)
			}
            numericOnlyLayout: true
			matchString: "0123456789"
			maximumLength: 6
			ignoreChars: "h"

			function editTextToValue() {
				return parseInt(_editText, 10)  * 60 * 60
			}
		}
		MbOK
		{
			description: qsTr("Reset service timer")
			value: qsTr("Press to reset")
			show: timeSinceService.valid && timeSinceService.value > 0
			editable: true
			VBusItem
			{
				id: timeSinceService
				bind: Utils.path(settingsBindPrefix, "/TimeSinceService")
			}

			function clicked()
			{
				timeSinceService.setValue (0)
				toast.createToast(qsTr("the service timer has been reset to ") + (serviceInterval.item.value / 3600).toFixed (0) + "h")
			}
		}
	}

	VBusItem {
		id: state
		bind: Utils.path(startStopBindPrefix, "/State")
	}
}
