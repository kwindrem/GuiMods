////// modified to show voltage, current and frequency in flow overview
// probably doesn't support paralleled Multis/Quatros

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
 
 ////// add to show voltage, current and frequency
    property VBusItem vebusService: VBusItem { bind: Utils.path(systemPrefix, "/VebusService") }
    property VBusItem inCurrentLimit: VBusItem { bind: Utils.path(vebusService.value, "/Ac/ActiveIn/CurrentLimit"); unit: "A"}

    property VBusItem inVoltageL1: VBusItem { bind: Utils.path(vebusService.value, "/Ac/ActiveIn/L1/V"); unit: "V"}
    property VBusItem inCurrentL1: VBusItem { bind: Utils.path(vebusService.value, "/Ac/ActiveIn/L1/I"); unit: "A"}
    property VBusItem inFrequencyL1: VBusItem { bind: Utils.path(vebusService.value, "/Ac/ActiveIn/L1/F"); unit: "Hz"}
    property VBusItem outVoltageL1: VBusItem { bind: Utils.path(vebusService.value, "/Ac/Out/L1/V"); unit: "V"}
    property VBusItem outCurrentL1: VBusItem { bind: Utils.path(vebusService.value, "/Ac/Out/L1/I"); unit: "A"}
    property VBusItem outFrequencyL1: VBusItem { bind: Utils.path(vebusService.value, "/Ac/Out/L1/F"); unit: "Hz"}

    property VBusItem inVoltageL2: VBusItem { bind: Utils.path(vebusService.value, "/Ac/ActiveIn/L2/V"); unit: "V"}
    property VBusItem inCurrentL2: VBusItem { bind: Utils.path(vebusService.value, "/Ac/ActiveIn/L2/I"); unit: "A"}
    property VBusItem inFrequencyL2: VBusItem { bind: Utils.path(vebusService.value, "/Ac/ActiveIn/L2/F"); unit: "Hz"}
    property VBusItem outVoltageL2: VBusItem { bind: Utils.path(vebusService.value, "/Ac/Out/L2/V"); unit: "V"}
    property VBusItem outCurrentL2: VBusItem { bind: Utils.path(vebusService.value, "/Ac/Out/L2/I"); unit: "A"}
    property VBusItem outFrequencyL2: VBusItem { bind: Utils.path(vebusService.value, "/Ac/Out/L2/F"); unit: "Hz"}
    

    property VBusItem inVoltageL3: VBusItem { bind: Utils.path(vebusService.value, "/Ac/ActiveIn/L3/V"); unit: "V"}
    property VBusItem inCurrentL3: VBusItem { bind: Utils.path(vebusService.value, "/Ac/ActiveIn/L3/I"); unit: "A"}
    property VBusItem inFrequencyL3: VBusItem { bind: Utils.path(vebusService.value, "/Ac/ActiveIn/L3/F"); unit: "Hz"}
    property VBusItem outVoltageL3: VBusItem { bind: Utils.path(vebusService.value, "/Ac/Out/L3/V"); unit: "V"}
    property VBusItem outCurrentL3: VBusItem { bind: Utils.path(vebusService.value, "/Ac/Out/L3/I"); unit: "A"}
    property VBusItem outFrequencyL3: VBusItem { bind: Utils.path(vebusService.value, "/Ac/Out/L3/F"); unit: "Hz"}
 ////// end add to show voltage, current and frequency
    
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
