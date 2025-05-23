import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbPage {
	id: root
	title: qsTr("Generator start/stop settings")
	property string settingsBindPrefix
	property string startStopBindPrefix
	property VBusItem acIn1Source: VBusItem { bind: "com.victronenergy.settings/Settings/SystemSetup/AcInput1" }
	property VBusItem acIn2Source: VBusItem { bind: "com.victronenergy.settings/Settings/SystemSetup/AcInput2" }
	property VBusItem capabilities: VBusItem { bind: Utils.path(startStopBindPrefix, "/Capabilities") }
	property int warmupCapability: 1

	model: VisibleItemModel {

		MbSubMenu {
			id: conditions
			description: qsTr("Conditions")
			subpage:
				Component {
				PageGeneratorConditions {
					title: qsTr("Conditions")
					bindPrefix: root.settingsBindPrefix
					startStopBindPrefix: root.startStopBindPrefix
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

		MbSubMenu {
			show: capabilities.value & warmupCapability
			description: qsTr("Warm-up & cool-down")
			subpage:
				Component {
                PageSettingsGeneratorWarmup {
                    title: qsTr("Warm-up & cool-down")
				}
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
		}

//// GuiMods
		MbSwitch {
			name: qsTr("Link to external running state")
			bind: Utils.path(settingsBindPrefix, "/LinkToExternalStatus")
			onClicked:
			{
				if (!checked)
					toast.createToast(qsTr("Manual run will be synchronized with the generaror 'is running digital input' or AC input"), 10000, "icon-info-active")
			}
		}

		MbSwitch {
			name: qsTr("Alarm when generator is not in auto start mode")
			bind: Utils.path(settingsBindPrefix, "/Alarms/AutoStartDisabled")
			onClicked: {
				if (!checked) {
					toast.createToast(qsTr("An alarm will be triggered when auto start function is left disabled for more than 10 minutes."), 12000, "icon-info-active")
				}
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
	}
}
