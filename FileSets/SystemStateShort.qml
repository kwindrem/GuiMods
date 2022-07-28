import QtQuick 1.1
import com.victron.velib 1.0

Item {
	id: root

	property alias bind: multiStatus.bind
	property alias value: multiStatus.value
	property string name: getStateName(multiStatus.value)
	property string text: getStateText(multiStatus.value)

	property list<SystemStateDescription> stateNames: [
		SystemStateDescription { value: 0x00; name: "off"; text: qsTr("Off")},
		SystemStateDescription { value: 0x01; name: "low_power"; text: qsTr("Low Power")},
		SystemStateDescription { value: 0x02; name: "fault"; text: qsTr("Fault")},
		SystemStateDescription { value: 0x03; name: "bulk"; text: qsTr("Bulk")},
		SystemStateDescription { value: 0x04; name: "absorption"; text: qsTr("Absorption")},
		SystemStateDescription { value: 0x05; name: "float"; text:  qsTr("Float")},
		SystemStateDescription { value: 0x06; name: "storage"; text: qsTr("Storage")},
		SystemStateDescription { value: 0x07; name: "equalize"; text: qsTr("Equalize")},
		SystemStateDescription { value: 0x08; name: "passthru"; text: qsTr("Passthru")},
		SystemStateDescription { value: 0x09; name: "inverting"; text: qsTr("Inverting")},
		SystemStateDescription { value: 0x0A; name: "assisting"; text: qsTr("Assisting")},
		SystemStateDescription { value: 0x0B; name: "psu"; text: qsTr("Pwr Sup Mode")},

		SystemStateDescription { value: 0xF5; name: "wakeup"; text: qsTr("Wakeup")},
		SystemStateDescription { value: 0xF6; name: "rep_abs"; text: qsTr("Rep Abs")},
		SystemStateDescription { value: 0xF8; name: "battery_safe"; text: qsTr("Bat Safe")},
		SystemStateDescription { value: 0xF9; name: "load_detect"; text: qsTr("Test")},
		SystemStateDescription { value: 0xFA; name: "blocked"; text: qsTr("Blocked")},
		SystemStateDescription { value: 0xFB; name: "test"; text: qsTr("Test")},
		SystemStateDescription { value: 0xFC; name: "hub1"; text: qsTr("Ext cont")},

		// These are not VEBUS states, they are system states used with ESS
		SystemStateDescription { value: 0x100; name: "discharging"; text: qsTr("Discharging")},
		SystemStateDescription { value: 0x101; name: "sustain"; text: qsTr("Sustain")},
		SystemStateDescription { value: 0x102; name: "recharge"; text: qsTr("Recharge")},
		SystemStateDescription { value: 0x103; name: "scheduledcharge"; text: qsTr("Sch chg")}
	]

	VBusItem {
		id: multiStatus
	}

	function getStateName(value) {
		for (var i = 0; i < stateNames.length; i++) {
			var option = stateNames[i];
			if (option.value === value)
				return option.name;
		}
		return qsTr("Unknown")
	}

	function getStateText(value) {
		for (var i = 0; i < stateNames.length; i++) {
			var option = stateNames[i];
			if (option.value === value)
				return option.text;
		}
		return qsTr("Unknown")
	}
}
