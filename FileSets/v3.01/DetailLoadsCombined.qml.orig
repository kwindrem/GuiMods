import QtQuick 1.1
import "utils.js" as Utils

Item {
	id: root

	property string systemPrefix: "com.victronenergy.system"
	property string vebusPrefix: _vebusService.valid ? _vebusService.value : ""

	property variant battery: _battery
	property alias dcSystem: _dcSystem
	property alias pvCharger: _pvCharger
	property alias pvOnAcIn1: _pvOnAcIn1
	property alias pvOnAcIn2: _pvOnAcIn2
	property alias pvOnAcOut: _pvOnAcOut
	property alias vebusDc: _vebusDc
	property alias acLoad: _acLoad
	property alias acInLoad: _acInLoad
	property alias acOutLoad: _acOutLoad
	property alias grid: _grid
	property alias genset: _genset
	property alias acInput: _activein
	property VBusItem systemType: VBusItem { bind: Utils.path(systemPrefix, "/SystemType") }
	property variant acSource: _acSource.value

	property alias pvOnGrid: _pvOnAcIn2

	property int batteryStateIdle: 0
	property int batteryStateCharging: 1
	property int batteryStateDischarging: 2

	property int acSourceNotAvailable: 0
	property int acSourceGrid: 1
	property int acSourceGenset: 2
	property int acSourceShore: 3 // same as grid

	property alias pvInvertersProductIds: _pvInvertersProductIds
	property alias batteryProductId: _batteryProductId

	VBusItem {
		id: _pvInvertersProductIds
		bind: Utils.path(systemPrefix, "/PvInvertersProductIds")
	}

	VBusItem {
		id: _batteryProductId
		bind: Utils.path(systemPrefix, "/Dc/Battery/ProductId")
	}

	VBusItem {
		id: _vebusService
		bind: Utils.path(systemPrefix, "/VebusService")
	}

	QtObject {
		id: _pvCharger
		property VBusItem power: VBusItem { bind: Utils.path(systemPrefix, "/Dc/Pv/Power"); unit: "W"}
	}

	ObjectAcConnection {
		id: _pvOnAcOut
		bindPrefix: Utils.path(systemPrefix, "/Ac/PvOnOutput")
	}

	ObjectAcConnection {
		id: _pvOnAcIn1
		bindPrefix: Utils.path(systemPrefix, "/Ac/PvOnGenset")
	}

	ObjectAcConnection {
		id: _pvOnAcIn2
		bindPrefix: Utils.path(systemPrefix, "/Ac/PvOnGrid")
	}

	ObjectAcConnection {
		id: _genset
		splitPhaseL2PassthruDisabled: _splitPhaseL2Passthru.value === 0
		bindPrefix: Utils.path(systemPrefix, "/Ac/Genset")
	}

	VBusItem {
		id: _acSource
		bind: Utils.path(systemPrefix, "/Ac/ActiveIn/Source")
	}

	/*
	 * Single Multis that can be split-phase reports NrOfPhases of 2
	 * When L2 is disconnected from the input the output L1 and L2
	 * are shorted. This item indicates if L2 is passed through
	 * from AC-in to AC-out.
	 * 1: L2 is being passed through from AC-in to AC-out.
	 * 0: L1 and L2 are shorted together.
	 * invalid: The unit is configured in such way that its L2 output is not used.
	 */

	VBusItem {
		id: _splitPhaseL2Passthru
		bind: Utils.path(vebusPrefix, "/Ac/State/SplitPhaseL2Passthru")
	}

	ObjectAcConnection {
		id: _grid
		splitPhaseL2PassthruDisabled: _splitPhaseL2Passthru.value === 0
		bindPrefix: Utils.path(systemPrefix, "/Ac/Grid")
	}

	ObjectAcConnection {
		id: _activein
		bindPrefix: Utils.path(systemPrefix, "/Ac/ActiveIn")
	}

	ObjectAcConnection {
		id: _acLoad
		splitPhaseL2PassthruDisabled: _splitPhaseL2Passthru.value === 0
		isAcOutput: true
		bindPrefix: Utils.path(systemPrefix, "/Ac/Consumption")
	}

	ObjectAcConnection {
		id: _acOutLoad
		splitPhaseL2PassthruDisabled:_splitPhaseL2Passthru.value === 0
		isAcOutput: true
		bindPrefix: Utils.path(systemPrefix, "/Ac/ConsumptionOnOutput")
	}

	ObjectAcConnection {
		id: _acInLoad
		splitPhaseL2PassthruDisabled: _splitPhaseL2Passthru.value === 0
		bindPrefix: Utils.path(systemPrefix, "/Ac/ConsumptionOnInput")
	}

	ObjectAcConnection {
		id: _acUnknown
	}

	QtObject {
		id: _vebusDc
		/*
		 * property VBusItem power: VBusItem { bind: Utils.path(vebusPrefix, "/Dc/0/Power"); unit: "W"}
		 * DONE: can interface doesn't support this yet! TODO use it...?
		 */
		property VBusItem current: VBusItem { bind: Utils.path(vebusPrefix, "/Dc/0/Current"); unit: "A"}
		property VBusItem voltage: VBusItem { bind: Utils.path(vebusPrefix, "/Dc/0/Voltage"); unit: "V"}
		property VBusItem power: VBusItem {
			value: _vebusDc.current.valid && _vebusDc.voltage.valid ?
				   _vebusDc.current.value * _vebusDc.voltage.value :
				   undefined
			unit: "W"
		}
	}

	QtObject {
		id: _battery
		property VBusItem power: VBusItem { bind: Utils.path(systemPrefix, "/Dc/Battery/Power"); unit: "W"}
		property VBusItem voltage: VBusItem { bind: Utils.path(systemPrefix, "/Dc/Battery/Voltage"); unit: "V"}
		property VBusItem current: VBusItem { bind: Utils.path(systemPrefix, "/Dc/Battery/Current"); unit: "A"}
		property VBusItem soc: VBusItem { bind: Utils.path(systemPrefix, "/Dc/Battery/Soc"); unit: "%"}

		// Get the battery charge state, see batteryState properties
		property VBusItem state: VBusItem { bind: Utils.path(systemPrefix, "/Dc/Battery/State")}
	}

	QtObject {
		id: _dcSystem
		property VBusItem power: VBusItem { bind: Utils.path(systemPrefix, "/Dc/System/Power"); unit: "W"}
	}
}
