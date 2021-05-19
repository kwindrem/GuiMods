////// modified to show power bar graphs

import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbIcon {
	id: multi
	iconId: "overview-inverter"

	property string vebusPrefix: ""
	property string systemPrefix: "com.victronenergy.system"
	property VBusItem systemState: VBusItem { bind: Utils.path(systemPrefix, "/SystemState/State") }

	Component.onCompleted: discoverMultis()

////// added to show inverter mode in switch area
    VBusItem
    { id: inverterMode;
        bind: Utils.path(sys.vebusPrefix, "/Mode")
    }
    SvgRectangle
    {
        id:inverterModeBackground
        width: 15
        height: 42
        radius: 3
        color: "#000000"
        anchors
        {
            horizontalCenter: multi.horizontalCenter; horizontalCenterOffset: -6.5
            verticalCenter: multi.verticalCenter; verticalCenterOffset: 8
        }
        visible: inverterMode.valid
    }
    Text
    {
        anchors
        {
            horizontalCenter: multi.horizontalCenter; horizontalCenterOffset: -6.7
            verticalCenter: multi.verticalCenter; verticalCenterOffset: 5
        }
        horizontalAlignment: Text.AlignHCenter
        width: 10
        wrapMode: Text.WrapAnywhere
        color: "white"
        font {pixelSize: 14; bold: true}
        text: inverterModeText ()
        lineHeightMode: Text.FixedHeight
        lineHeight: 12
        visible: inverterMode.valid
    }
    function inverterModeText ()
    {
        switch (inverterMode.value)
        {
            case 4:
                return "O f f"
                break;
            case 1:
                return "C h"
                break;
            case 2:
                return "I n v"
                break;
            case 3:
                return "O n"
                break;
        }
    }

	Column {
		spacing: 3
		x: 26
		y: 62

		Led {
			bind: Utils.path(sys.vebusPrefix, "/Leds/Mains")
			onColor: "#68FF00"
		}

		Led {
			bind: Utils.path(sys.vebusPrefix, "/Leds/Bulk")
		}

		Led {
			bind: Utils.path(sys.vebusPrefix, "/Leds/Absorption")
		}

		Led {
			bind: Utils.path(sys.vebusPrefix, "/Leds/Float")
		}
	}

	Column {
		spacing: 3
		x: multi.width - 28
		y: 62

		Led {
			bind: Utils.path(sys.vebusPrefix, "/Leds/Inverter")
			onColor: "#68FF00"
		}

		Led {
			bind: Utils.path(sys.vebusPrefix, "/Leds/Overload")
			onColor: "#F75E25"
		}

		Led {
			bind: Utils.path(sys.vebusPrefix, "/Leds/LowBattery")
			onColor: "#F75E25"
		}

		Led {
			bind: Utils.path(sys.vebusPrefix, "/Leds/Temperature")
			onColor: "#F75E25"
		}
	}

	Text {
		anchors {
			horizontalCenter: multi.horizontalCenter
////// modified to show power bar graphs
			top: multi.top; topMargin: 4
		}
		horizontalAlignment: Text.AlignHCenter
		color: "white"
////// modified to show power bar graphs
		font {pixelSize: 14; bold: true}
		text: vebusState.text

		SystemState {
			id: vebusState
			bind: systemState.valid?Utils.path(systemPrefix, "/SystemState/State"):Utils.path(sys.vebusPrefix, "/State")
		}
	}

	// When a new service is found check if is a multi
	Connections {
		target: DBusServices
		onDbusServiceFound: addService(service)
	}

	function addService(service)
	{
		if (service.type === DBusService.DBUS_SERVICE_MULTI) {
			if (vebusPrefix === "")
				vebusPrefix = service.name;
		}
	}

	// Check available services to find multis
	function discoverMultis()
	{
		for (var i = 0; i < DBusServices.count; i++) {
			if (DBusServices.at(i).type === DBusService.DBUS_SERVICE_MULTI) {
				addService(DBusServices.at(i))
			}
		}
	}
}

