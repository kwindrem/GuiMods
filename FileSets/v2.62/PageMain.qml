//////// modified order to put Settings, then Notifications at top of list

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

MbPage {
	id: root
	title: qsTr("Device List")
    property VBusItem moveSettings: VBusItem { id: moveSettings; bind: Utils.path("com.victronenergy.settings", "/Settings/GuiMods/MoveSettings")}
    property bool settingsAtTop: moveSettings.valid && moveSettings.value === 1

	model: VisualItemModel {
//////// put Settings at top of list
        MbSubMenu {
            description: qsTr("Settings")
            subpage: Component { PageSettings {} }
            show: settingsAtTop
        }

//////// put Notifications second
        MbSubMenu {
            id: menuNotifications
            description: qsTr("Notifications")
            item: VBusItem {
                property variant active: NotificationCenter.notifications.filter(
                                             function isActive(obj) { return obj.active} )
                value: active.length > 0 ? active.length : ""
            }
            subpage: Component { PageNotifications {} }
        }
        MbSubMenu {
            description: qsTr("Settings")
            subpage: Component { PageSettings {} }
            show: !settingsAtTop
        }
    }

	Component {
		id: submenuLoader
		MbDevice {
			iconId: "icon-toolbar-enter"
		}
	}

	Component {
		id: vebusPage
		PageVebus {}
	}

	Component {
		id: batteryPage
		PageBattery {}
	}

	Component {
		id: solarChargerPage
		PageSolarCharger {}
	}

	Component {
		id: acInPage
		PageAcIn {}
	}

	Component {
		id: acChargerPage
		PageAcCharger {}
	}

	Component {
		id: tankPage
		PageTankSensor {}
	}

	Component {
		id: motorDrivePage
		PageMotorDrive {}
	}

	Component {
		id: inverterPage
		PageInverter {}
	}

	Component {
		id: pulseCounterPage
		PagePulseCounter {}
	}

	Component {
		id: digitalInputPage
		PageDigitalInput {}
	}

	Component {
		id: temperatureSensorPage
		PageTemperatureSensor {}
	}

	Component {
		id: unsupportedDevicePage
		PageUnsupportedDevice {}
	}

	Component {
		id: meteoDevicePage
		PageMeteo {}
	}

	Component {
		id: evChargerPage
		PageEvCharger {}
	}

	function addService(service)
	{
		var name = service.name

		var page
		switch(service.type)
		{
		case DBusService.DBUS_SERVICE_MULTI:
			page = vebusPage
			break;
		case DBusService.DBUS_SERVICE_BATTERY:
			page = batteryPage
			break;
		case DBusService.DBUS_SERVICE_SOLAR_CHARGER:
			page = solarChargerPage
			break;
		case DBusService.DBUS_SERVICE_PV_INVERTER:
			page = acInPage
			break;
		case DBusService.DBUS_SERVICE_AC_CHARGER:
			page = acChargerPage
			break;
		case DBusService.DBUS_SERVICE_TANK:
			page = tankPage
			break;
		case DBusService.DBUS_SERVICE_GRIDMETER:
			page = acInPage
			break
		case DBusService.DBUS_SERVICE_GENSET:
			page = acInPage
			break
		case DBusService.DBUS_SERVICE_MOTOR_DRIVE:
			page = motorDrivePage
			break
		case DBusService.DBUS_SERVICE_INVERTER:
			page = inverterPage
			break;
		case DBusService.DBUS_SERVICE_TEMPERATURE_SENSOR:
			page = temperatureSensorPage
			break;
		case DBusService.DBUS_SERVICE_SYSTEM_CALC:
			return;
		case DBusService.DBUS_SERVICE_DIGITAL_INPUT:
			page = digitalInputPage
			break;
		case DBusService.DBUS_SERVICE_PULSE_COUNTER:
			page = pulseCounterPage
			break;
		case DBusService.DBUS_SERVICE_UNSUPPORTED:
			page = unsupportedDevicePage
			break;
		case DBusService.DBUS_SERVICE_METEO:
			page = meteoDevicePage
			break;
		case DBusService.DBUS_SERVICE_VECAN:
			return;
		case DBusService.DBUS_SERVICE_EVCHARGER:
			page = evChargerPage
			break
		case DBusService.DBUS_SERVICE_HUB4:
			return;
		default:
			console.log("unknown service " + name)
			return;
		}

		var submenu = submenuLoader.createObject(root)
		submenu.service = service

		// option 1, load when being opened
		// submenu.subpage = page
		// submenu.subpageProperties = {service: service}

		// option 2, create it now
		submenu.subpage = page.createObject(submenu, {service: service, bindPrefix: service.name})

		// sort on (initial) description
		var i = 0
//////// leave Settings and Notifications at top of list (don't sort first 2 entries)
        var i = settingsAtTop ? 2 : 0
        for (; i < model.count - 2; i++ ) {
			if (model.children[i].description.localeCompare(service.description) > 0)
				break;
		}

		model.insert(i, submenu)

		initListView()
	}

	Component.onCompleted: {
		for (var i = 0; i < DBusServices.count; i++)
			addService(DBusServices.at(i))
		listview.currentIndex = 0
	}

	Connections {
		target: DBusServices
		onDbusServiceFound: addService(service)
	}
}
