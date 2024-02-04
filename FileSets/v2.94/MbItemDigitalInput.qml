//// modified for ExtTransferSwitch package

import QtQuick 1.1

MbItemOptions {
	show: valid
	signal disabled
	property variant previousValue: undefined
	possibleValues: [
		MbOption { description: qsTr("Disabled"); value: 0 },
		MbOption { description: qsTr("Pulse meter"); value: 1 },
		MbOption { description: qsTr("Door alarm"); value: 2 },
		MbOption { description: qsTr("Bilge pump"); value: 3 },
		MbOption { description: qsTr("Bilge alarm"); value: 4 },
		MbOption { description: qsTr("Burglar alarm"); value: 5 },
		MbOption { description: qsTr("Smoke alarm"); value: 6 },
		MbOption { description: qsTr("Fire alarm"); value: 7 },
		MbOption { description: qsTr("CO2 alarm"); value: 8 },
		MbOption { description: qsTr("Generator"); value: 9 },
//// added for ExtTransferSwitch package
		MbOption { description: qsTr("External transfer switch"); value: 11 }
	]
	onValueChanged: {
		if (valid) {
			if (previousValue != undefined && value == 0) disabled()
			previousValue = value
		}
	}
}
