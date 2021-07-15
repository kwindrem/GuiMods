//////// modified for VE.Direct inverter support
import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

Item {
	id: root

    property variant sys: theSystem

	property string systemPrefix: "com.victronenergy.system"
	property string vebusPrefix: _vebusService.valid ? _vebusService.value : ""

//////// add to support VE.Direct inverters
    property string inverterService: ""

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
	property VBusItem systemType: VBusItem { bind: Utils.path(systemPrefix, "/SystemType") }
	property variant acSource: _acSource.value

	property alias pvOnGrid: _pvOnAcIn2
	property variant acInput: (acSource === acSourceGenset ? _genset :
							(acSource === acSourceGrid || acSource === acSourceShore ? _grid  :
							_acUnknown))

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
		bindPrefix: Utils.path(systemPrefix, "/Ac/Genset")
        inverterSource: "/Ac/ActiveIn"
        inverterService: sys.vebusPrefix != "" ? sys.vebusPrefix : root.inverterService
	}

	VBusItem {
		id: _acSource
		bind: Utils.path(systemPrefix, "/Ac/ActiveIn/Source")
	}

	ObjectAcConnection {
		id: _grid
		bindPrefix: Utils.path(systemPrefix, "/Ac/Grid")
        inverterSource: "/Ac/ActiveIn"
        inverterService: sys.vebusPrefix != "" ? sys.vebusPrefix : root.inverterService
	}

	ObjectAcConnection {
		id: _acLoad
		bindPrefix: Utils.path(systemPrefix, "/Ac/Consumption")
        inverterSource: "/Ac/Out"
        inverterService: sys.vebusPrefix != "" ? sys.vebusPrefix : root.inverterService
	}

	ObjectAcConnection {
		id: _acOutLoad
		bindPrefix: Utils.path(systemPrefix, "/Ac/ConsumptionOnOutput")
	}

	ObjectAcConnection {
		id: _acInLoad
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

//////// add to support VE.Direct inverters
    Component.onCompleted: discoverServices()

    // When new service is found check if is a tank sensor
    Connections
    {
        target: DBusServices
        onDbusServiceFound: addService(service)
    }
    function addService(service)
    {
        switch (service.type)
        {
        case DBusService.DBUS_SERVICE_INVERTER:
            if (inverterService === "")
                inverterService = service.name;
            break;;
        }
    }

    // Check available services inverter services
    function discoverServices()
    {
        for (var i = 0; i < DBusServices.count; i++)
                addService(DBusServices.at(i))
    }
}
