////// MODIFIED to show tanks in a row along bottom

import QtQuick 1.1
import "utils.js" as Utils
////// ADDED to show tanks
import com.victron.velib 1.0

OverviewPage {
	id: root

	property variant sys: theSystem
	property bool hasAcSolarOnAcIn1: sys.pvOnAcIn1.power.valid
	property bool hasAcSolarOnAcIn2: sys.pvOnAcIn2.power.valid
	property bool hasAcSolarOnIn: hasAcSolarOnAcIn1 || hasAcSolarOnAcIn2
	property bool hasAcSolarOnOut: sys.pvOnAcOut.power.valid
	property bool hasAcSolar: hasAcSolarOnIn || hasAcSolarOnOut
	property bool hasDcSolar: sys.pvCharger.power.valid
	property bool hasDcAndAcSolar: hasAcSolar && hasDcSolar
////// ADDED to show tanks
    property int tanksHeight: 50
    property int bottomTileHeight: 91
    property string settingsBindPreffix: "com.victronenergy.settings"
    property string pumpBindPreffix: "com.victronenergy.pump.startstop0"
    property int numberOfTanks: 0
    property bool showTanks: numberOfTanks > 0 ? true : false

    Component.onCompleted: discoverTanks()
////// end add for show tanks

	title: qsTr("Overview")

	OverviewBox {
		id: acInBox

		width: 148
		height: showStatusBar ? 100 : 120
		title: getAcSourceName(sys.acSource)
		titleColor: "#E74c3c"
		color: "#C0392B"

		anchors {
			top: multi.top
			left: parent.left; leftMargin: 10
		}

		values:	OverviewAcValues {
			connection: sys.acInput
		}

		MbIcon {
			iconId: getAcSourceIcon(sys.acSource)
			anchors {
				bottom: parent.bottom
				left: parent.left; leftMargin: 2
			}
			opacity: 0.5
		}
	}

	Multi {
		id: multi
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top; topMargin: 5
		}
	}

////// ADDED to show time inside inverter icon
    Timer {
        id: wallClock
        running: true
        repeat: true
        interval: 1000
        triggeredOnStart: true
        onTriggered: time = Qt.formatDateTime(new Date(), "h:mm ap")

        property string time
    }
    TileText
    {
        text: wallClock.time
        font.pixelSize: 18
        anchors
        {
            top: multi.top; topMargin: 96
            horizontalCenter: multi.horizontalCenter
        }
    }

	OverviewBox {
		id: acLoadBox
		title: qsTr("AC Loads")
		color: "#27AE60"
		titleColor: "#2ECC71"
		width: 148
		height: showStatusBar ? 100 : 120

		anchors {
			right: parent.right; rightMargin: 10
			top: multi.top
		}

		values: OverviewAcValues {
			connection: sys.acLoad
		}
	}

	Battery {
		id: battery

		soc: sys.battery.soc.valid ? sys.battery.soc.value : 0

////// MODIFIED to show tanks
        height: bottomTileHeight
		anchors {
			bottom: parent.bottom; bottomMargin: showTanks ? tanksHeight : 5;
			left: parent.left; leftMargin: 10
		}
		values: Column {
			width: parent.width

			TileText {
				// Use value here instead of format() because format adds the unit to the number and we
				// show the percentage symbol in a separated smaller text.
				text: sys.battery.soc.value === undefined ? "--" : sys.battery.soc.value.toFixed(0)
				font.pixelSize: 40

				Text {
					anchors {
						bottom: parent.bottom; bottomMargin: 9
						horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: parent.paintedWidth / 2 + 5
					}
					visible: sys.battery.soc.valid
					text: "%"
					color: "white"
					font.bold: true
					font.pixelSize: 12
				}
			}
			TileText {
				text: sys.battery.power.format(0)
			}
			TileText {
				text: sys.battery.voltage.format(1) + "   " + sys.battery.current.format(1)
			}
		}
	}

	VBusItem {
		id: hasDcSys
		bind: "com.victronenergy.settings/Settings/SystemSetup/HasDcSystem"
	}

	OverviewBox {
		id: dcSystemBox
		width: 105
		height: 45
		visible: hasDcSys.value > 0
		title: qsTr("DC Power")

		anchors {
			horizontalCenter: multi.horizontalCenter
////// MODIFIED to show tanks
			bottom: parent.bottom; bottomMargin: showTanks ? tanksHeight : 5
		}

		values: TileText {
			anchors.centerIn: parent
			text: sys.dcSystem.power.format(0)
		}
	}

	OverviewSolarCharger {
		id: blueSolarCharger

////// MODIFIED to show tanks
        height: hasDcAndAcSolar ? 65 : showTanks ? bottomTileHeight : 114
        width: 148
		title: qsTr("PV Charger")
////// MODIFIED - always hide icon peaking out from under PV tile
		showChargerIcon: false
		visible: hasDcSolar || hasDcAndAcSolar

		anchors {
			right: root.right; rightMargin: 10
            bottom: parent.bottom; bottomMargin: showTanks ? tanksHeight : 5
		}

		values: TileText {
			y: 5
			text: sys.pvCharger.power.format(0)
			font.pixelSize: 20
		}
	}

    OverviewSolarInverter {
        id: pvInverter
        height: hasDcAndAcSolar ? 65 : 115
        width: 148
        title: qsTr("PV Inverter")
        showInverterIcon: !hasDcAndAcSolar
        visible: hasAcSolar

        anchors {
            right: root.right; rightMargin: 10;
            bottom: root.bottom; bottomMargin: hasDcAndAcSolar ? 75 : 5
        }

        OverviewAcValues {
            connection: hasAcSolarOnOut ? sys.pvOnAcOut : hasAcSolarOnAcIn1 ? sys.pvOnAcIn1 : sys.pvOnAcIn2
            visible: !coupledPvAc.visible
        }

        TileText {
            id: coupledPvAc

            property double pvInverterOnAcOut: sys.pvOnAcOut.power.valid ? sys.pvOnAcOut.power.value : 0
            property double pvInverterOnAcIn1: sys.pvOnAcIn1.power.valid ? sys.pvOnAcIn1.power.value : 0
            property double pvInverterOnAcIn2: sys.pvOnAcIn2.power.valid ? sys.pvOnAcIn2.power.value : 0

            y: 5
            text: (pvInverterOnAcOut + pvInverterOnAcIn1 + pvInverterOnAcIn2).toFixed(0) + "W"
            font.pixelSize: hasDcAndAcSolar ? 20 : 25
            visible: hasDcAndAcSolar || (hasAcSolarOnIn && hasAcSolarOnOut) || (hasAcSolarOnAcIn1 && hasAcSolarOnAcIn2)
        }
    }

	OverviewEssReason {
		anchors {
			bottom: parent.bottom; bottomMargin: dcSystemBox.visible ? battery.height + 15 : 5
			horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: dcSystemBox.visible ? -(root.width / 2 - battery.width / 2 - 10)  : 0
		}
	}

	OverviewConnection {
		id: acInToMulti
		ballCount: 2
		path: straight
		active: root.active
		value: flow(sys.acInput ? sys.acInput.power : 0)

		anchors {
			left: acInBox.right; leftMargin: -10; top: multi.verticalCenter;
			right: multi.left; rightMargin: -10; bottom: multi.verticalCenter
		}
	}

	OverviewConnection {
		id: multiToAcLoads
		ballCount: 2
		path: straight
		active: root.active
		value: flow(sys.acLoad.power)

		anchors {
			left: multi.right; leftMargin: -10;
			top: multi.verticalCenter
			right: acLoadBox.left; rightMargin: -10
			bottom: multi.verticalCenter
		}
	}

	OverviewConnection {
		id: pvInverterToMulti

		property int hasDcAndAcFlow: Utils.sign(noNoise(sys.pvOnAcOut.power) + noNoise(sys.pvOnAcIn1.power) + noNoise(sys.pvOnAcIn2.power))

		ballCount: 4
		path: corner
		active: root.active && hasAcSolar
		value: hasDcAndAcSolar ? hasDcAndAcFlow : flow(sys.pvOnAcOut.power)

		anchors {
			left: pvInverter.left; leftMargin: 8
			top: pvInverter.verticalCenter; topMargin: hasDcAndAcSolar ? 1 : 0
			right: multi.horizontalCenter; rightMargin: -20
			bottom: multi.bottom; bottomMargin: 10
		}
	}

	// invisible anchor point to connect the chargers to the battery
	Item {
		id: dcConnect
		anchors {
			left: multi.horizontalCenter; leftMargin: hasAcSolar ? -20  : 0
			bottom: dcSystemBox.top; bottomMargin: 10
		}
	}

	OverviewConnection {
		id: multiToDcConnect
		ballCount: 3
		path: straight
		active: root.active
		value: -flow(sys.vebusDc.power);
		startPointVisible: false

		anchors {
			left: dcConnect.left
			top: dcConnect.top

			right: dcConnect.left
			bottom: multi.bottom; bottomMargin: 10
		}
	}

	OverviewConnection {
		id: blueSolarChargerDcConnect
		ballCount: 3
		path: straight
		active: root.active && hasDcSolar
		value: -flow(sys.pvCharger.power)
		startPointVisible: false

		anchors {
			left: dcConnect.left
			top: dcConnect.top

			right: blueSolarCharger.left; rightMargin: -8
			bottom: dcConnect.top;
		}
	}

	OverviewConnection {
		id: chargersToBattery
		ballCount: 3
		path: straight
		active: root.active
		value: Utils.sign(noNoise(sys.pvCharger.power) + noNoise(sys.vebusDc.power))
		startPointVisible: false

		anchors {
			left: dcConnect.left
			top: dcConnect.top

			right: battery.right; rightMargin: 10
			bottom: dcConnect.top
		}
	}

	OverviewConnection {
		id: batteryToDcSystem
		ballCount: 2
		path: straight
		active: root.active && hasDcSys.value > 0
		value: flow(sys.dcSystem.power)

		anchors {
			left: battery.right; leftMargin: -10
			top: dcSystemBox.verticalCenter;
			right: dcSystemBox.left; rightMargin: -10
			bottom: dcSystemBox.verticalCenter
		}
	}

////// ADDED to show tanks
    ListView {
        id: tanksColumn

        width: parent.width / Math.min (count, 4.5)
        interactive: true // flickable
        orientation: ListView.Horizontal

        model: tanksModel
        delegate: TileTank {
            width: tanksColumn.width
            height: root.tanksHeight
            pumpBindPrefix: root.pumpBindPreffix
        }

        height: tanksHeight
        anchors {
            bottom: root.bottom
            left: root.left
        }
    }

    ListModel {
        id: tanksModel
    }
    // When new service is found check if is a tank sensor
    Connections {
        target: DBusServices
        onDbusServiceFound: addService(service)
    }

    function addService(service)
    {
        var name = service.name
        if (service.type === DBusService.DBUS_SERVICE_TANK) {
            // hide the service for the physical sensor
            if (name !== incomingTankServiceName) // hide incoming N2K tank dBus object
            {
                tanksModel.append({serviceName: service.name})
                numberOfTanks++
            }
        }
    }

    // Check available services to find tank sesnsors
    function discoverTanks()
    {
        incomingTankServiceName = incomingTankName.valid ? incomingTankName.value : ""
        tanksModel.clear()
        for (var i = 0; i < DBusServices.count; i++) {
            if (DBusServices.at(i).type === DBusService.DBUS_SERVICE_TANK) {
                addService(DBusServices.at(i))
            }
        }
    }
    property string incomingTankServiceName: ""
    VBusItem { id: incomingTankName;
        bind: Utils.path(settingsBindPreffix, "/Settings/Devices/TankRepeater/IncomingTankService") }
}
