////// modified to show power bar graphs

import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils

MbIcon {
	id: multi
	iconId: "overview-inverter"

	property string systemPrefix: "com.victronenergy.system"
	property VBusItem systemState: VBusItem { bind: Utils.path(systemPrefix, "/SystemState/State") }

////// added to show inverter mode in switch area
    property string inverterService: ""
    VBusItem
    { id: inverterMode;
        bind: Utils.path(inverterService, "/Mode")
    }
    // flag a VE.Direct inverter
    property VBusItem isInverterChargerItem: VBusItem { bind: Utils.path(inverterService, "/IsInverterCharger") }
    property bool isInverter: isInverterChargerItem.valid ? true : false

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
                    if (isInverter)
                        return "O n"
                    else
                        return "I n v"
                    break;
                case 3:
                    return "O n"
                    break;
                case 5:
                    return "E c o"
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
			bind: Utils.path(inverterService, "/Leds/Mains")
			onColor: "#68FF00"
		}

		Led {
			bind: Utils.path(inverterService, "/Leds/Bulk")
		}

		Led {
			bind: Utils.path(inverterService, "/Leds/Absorption")
		}

		Led {
			bind: Utils.path(inverterService, "/Leds/Float")
		}
	}

	Column {
		spacing: 3
		anchors {
			right: parent.right; rightMargin: 28
			top: parent.top; topMargin: 62
		}

		Led {
			bind: Utils.path(inverterService, "/Leds/Inverter")
			onColor: "#68FF00"
		}

		Led {
			bind: Utils.path(inverterService, "/Leds/Overload")
			onColor: "#F75E25"
		}

		Led {
			bind: Utils.path(inverterService, "/Leds/LowBattery")
			onColor: "#F75E25"
		}

		Led {
			bind: Utils.path(inverterService, "/Leds/Temperature")
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
        text: inverterService != "" ? vebusState.text : "---"

		SystemState {
			id: vebusState
			bind: systemState.valid?Utils.path(systemPrefix, "/SystemState/State"):Utils.path(inverterService, "/State")
		}
	}
}

