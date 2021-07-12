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
    VBusItem
    { id: numberOfAcInputs;
        bind: Utils.path(sys.vebusPrefix, "/Ac/NumberOfAcInputs")
    }
    SvgRectangle
    {
        id:inverterModeBackground
        width: 13
        height: 38
        radius: 3
        color: "#000000"
        anchors
        {
            horizontalCenter: multi.horizontalCenter; horizontalCenterOffset: -6.5
            verticalCenter: multi.verticalCenter; verticalCenterOffset: 10.5
        }
        visible: inverterMode.valid
    }
    Text
    {
        anchors
        {
            horizontalCenter: multi.horizontalCenter; horizontalCenterOffset: -6.5
            verticalCenter: multi.verticalCenter; verticalCenterOffset: 7.5
        }
        horizontalAlignment: Text.AlignHCenter
        width: 8
        wrapMode: Text.WrapAnywhere
        color: "white"
        font {pixelSize: 12; bold: true}
        text: inverterModeText ()
        lineHeightMode: Text.FixedHeight
        lineHeight: 11
        visible: inverterMode.valid
    }
    function inverterModeText ()
    {
        if (inverterMode.valid)
        {
            switch (inverterMode.value)
            {
                case 4:
                    return "O f f"
                    break;
                case 1:
                    return "C h g"
                    break;
                case 2:
                    if (numberOfAcInputs.valid && numberOfAcInputs.value > 0)
                        return "I n v"
                    else
                        return "O n"
                    break;
                case 3:
                    return "O n"
                    break;
                default:
                    return "?"
                    break;
            }
        }
        else
            return ""
    }

	Column {
		spacing: 3
		anchors {
			left: parent.left; leftMargin: 28
			top: parent.top; topMargin: 62
		}

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
		anchors {
			right: parent.right; rightMargin: 28
			top: parent.top; topMargin: 62
		}

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

