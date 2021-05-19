import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

QtObject {
	property string bindPrefix

	property VBusItem powerL1: VBusItem { bind: Utils.path(bindPrefix, "/L1/Power"); unit: "W"}
	property VBusItem powerL2: VBusItem { bind: Utils.path(bindPrefix, "/L2/Power"); unit: "W"}
	property VBusItem powerL3: VBusItem { bind: Utils.path(bindPrefix, "/L3/Power"); unit: "W"}
	property VBusItem phaseCount: VBusItem { bind: Utils.path(bindPrefix, "/NumberOfPhases") }
	property VBusItem power: VBusItem { unit: "W" }
	// As systemcalc doesn't provide the totals anymore we calculate it here.
	// Timer is needed because the values are not received in once and then the total
	// changes too often on system with more than one phase
	property Timer timer: Timer {
		interval: 1000
		running: true
		repeat: true
		onTriggered: {
			power.value = powerL1.valid || powerL2.valid || powerL3.valid ? (powerL1.valid ? powerL1.value : 0) +
						   (powerL2.valid ? powerL2.value : 0) +
						   (powerL3.valid ? powerL3.value : 0) : undefined
		}
	}
}
