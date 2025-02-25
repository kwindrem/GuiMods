import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

QtObject {
	property string bindPrefix
    property string inverterService: ""
    property string inverterSource: ""

	property VBusItem powerL1: VBusItem { bind: Utils.path(bindPrefix, "/L1/Power"); unit: "W"}
	property VBusItem powerL2: VBusItem { bind: Utils.path(bindPrefix, "/L2/Power"); unit: "W"}
	property VBusItem powerL3: VBusItem { bind: Utils.path(bindPrefix, "/L3/Power"); unit: "W"}
	property VBusItem power: VBusItem { unit: "W" }
    property VBusItem phaseCount: VBusItem { bind: Utils.path(bindPrefix, "/NumberOfPhases") }
    property bool splitPhaseL2PassthruDisabled: false
    property bool isAcOutput: false
	property bool l2AndL1OutSummed: false
////// added to show bar graphs
    property VBusItem inverterState: VBusItem { bind: Utils.path(systemPrefix, "/SystemState/State" ) }
 
 ////// add to show voltage, current, frequency and bar graphs and use grid/genset meter
    property VBusItem voltageL1: VBusItem { bind: Utils.path (bindPrefix, "/L1/Voltage"); unit: "V"}
    property VBusItem voltageL2: VBusItem { bind: Utils.path (bindPrefix, "/L2/Voltage"); unit: "V"}
    property VBusItem voltageL3: VBusItem { bind: Utils.path (bindPrefix, "/L3/Voltage"); unit: "V"}

    property VBusItem currentL1: VBusItem { bind: Utils.path (bindPrefix, "/L1/Current"); unit: "A"}
    property VBusItem currentL2: VBusItem { bind: Utils.path (bindPrefix, "/L2/Current"); unit: "A"}
    property VBusItem currentL3: VBusItem { bind: Utils.path (bindPrefix, "/L3/Current"); unit: "A"}

    property VBusItem frequency: VBusItem { bind: Utils.path (bindPrefix, "/Frequency"); unit: "Hz"}

    property VBusItem inCurrentLimit: VBusItem { bind: Utils.path(inverterService, inverterSource, "/CurrentLimit"); unit: "A"}
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
