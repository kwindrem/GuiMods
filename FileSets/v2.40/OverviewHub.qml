////// MODIFIED to show:
//////  tanks in a row along bottom
//////  PV voltage and current and DC power current (up to two MPPTs)
//////  voltage, current, frequency in AC tiles (plus current limit for AC input)
//////  time of day
//////  current in DC Loads
//////  remaining time in Battery tile
//////  bar graphs on AC in/out and Multi
//////  popups for AC input current limit and inverter mode

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
    property int tanksHeight: 45
    property int bottomTileHeight: 91
    property string settingsBindPreffix: "com.victronenergy.settings"
    property string pumpBindPreffix: "com.victronenergy.pump.startstop0"
    property int numberOfTanks: 0
    property bool showTanks: showStatusBar ? false : numberOfTanks > 0 ? true : false
    property string incomingTankServiceName: ""
//////// add for PV CHARGER voltage and current
    property string pvChargerPrefix1: ""
    property string pvChargerPrefix2: ""
    property int numberOfPvChargers: 0
    property int numberOfMultis: 0
    property string vebusPrefix: ""


    Component.onCompleted: discoverServices()

//////// add for mods
    VBusItem { id: pvCurrent1; bind: Utils.path(pvChargerPrefix1, "/Pv/I") }
    VBusItem { id: pvVoltage1;  bind: Utils.path(pvChargerPrefix1, "/Pv/V") }
    VBusItem { id: pvName1;  bind: Utils.path(pvChargerPrefix1, "/CustomName") }
    VBusItem { id: pvCurrent2; bind: Utils.path(pvChargerPrefix2, "/Pv/I") }
    VBusItem { id: pvVoltage2;  bind: Utils.path(pvChargerPrefix2, "/Pv/V") }
    VBusItem { id: pvName2;  bind: Utils.path(pvChargerPrefix2, "/CustomName") }
    VBusItem { id: timeToGo;  bind: Utils.path("com.victronenergy.system","/Dc/Battery/TimeToGo") }

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
////// add power bar graph
        PowerGuage
        {
            id: acInBar
            width: parent.width
            height: 12
            anchors
            {
                top: parent.top; topMargin: 16
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.acInput
        }
	}


	Multi {
		id: multi
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top; topMargin: 5
		}
////// add power bar graph
        PowerGuage
        {
            id: multiBar
            width: multi.width
            height: 12
            useMultiInfo: true
            anchors
            {
                top: parent.top; topMargin: 23
                horizontalCenter: parent.horizontalCenter
            }
            connection: undefined
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
		height: showStatusBar ? 80 : 100

		anchors {
			right: parent.right; rightMargin: 10
			top: multi.top
		}

		values: OverviewAcValues {
			connection: sys.acLoad
		}
////// add power bar graph
        PowerGuage
        {
            id: acLoadBar
            width: parent.width
            height: 12
            anchors
            {
                top: parent.top; topMargin: 16
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.acLoad
        }
	}

	Battery {
		id: battery

		soc: sys.battery.soc.valid ? sys.battery.soc.value : 0

////// MODIFIED to show tanks
        height: bottomTileHeight
		anchors {
			bottom: parent.bottom; bottomMargin: showTanks ? tanksHeight + 5 : 5;
			left: parent.left; leftMargin: 10
		}
		values: Column {
			width: parent.width

			TileText {
				text: sys.battery.soc.value === undefined ? "--" : sys.battery.soc.format (0)
				font.pixelSize: 25
			}
			TileText {
				text: sys.battery.power.format(0)
			}
			TileText {
				text: sys.battery.voltage.format(1) + "   " + sys.battery.current.format(1)
			}
            TileText {
                text: {
                    if (timeToGo.valid)
                        return "Remain: " + Utils.secondsToString(timeToGo.value)
                    else
                        return "Remain: ∞"
                }
            }
        }
	}

	VBusItem {
		id: hasDcSys
		bind: "com.victronenergy.settings/Settings/SystemSetup/HasDcSystem"
	}

	OverviewBox {
		id: dcSystemBox
////// wider to make room for current
		width: multi.width + 20
		height: 45
		visible: hasDcSys.value > 0
		title: qsTr("DC Loads")

		anchors {
			horizontalCenter: multi.horizontalCenter
////// MODIFIED to show tanks
			bottom: parent.bottom; bottomMargin: showTanks ? tanksHeight + 5 : 5
		}

		values: TileText {
			anchors.centerIn: parent
			text: Math.abs (sys.dcSystem.power.value / sys.battery.voltage.value) <= 100
                ? sys.dcSystem.power.format(0) + " " + (sys.dcSystem.power.value / sys.battery.voltage.value).toFixed(1) + "A"
                : sys.dcSystem.power.format(0) + " " + (sys.dcSystem.power.value / sys.battery.voltage.value).toFixed(0) + "A"
		}
	}

	OverviewSolarCharger {
		id: blueSolarCharger

////// MODIFIED to show tanks
        height: hasDcAndAcSolar ? 65 : showTanks ? bottomTileHeight + 20 : 114
        width: 148
		title: qsTr("PV Charger")
////// MODIFIED - always hide icon peaking out from under PV tile
		showChargerIcon: false
		visible: hasDcSolar || hasDcAndAcSolar

		anchors {
			right: root.right; rightMargin: 10
            bottom: parent.bottom; bottomMargin: showTanks ? tanksHeight + 5 : 5
		}

//////// add voltage and current
		values: 
        [
            TileText {
                y: 0
                text: sys.pvCharger.power.format(0)
                font.pixelSize: 25
            },
            TileText {
                y: 28
                text: numberOfPvChargers > 0 && pvName1.valid ? pvName1.text : ""
                visible: numberOfPvChargers > 0
            },
            TileText {
                y: 44
                text: numberOfPvChargers > 0 ? pvVoltage1.text + " " + pvCurrent1.text : ""
                font.pixelSize: 15
                visible: numberOfPvChargers > 0 && pvVoltage1.valid && pvCurrent1.valid
            },
            TileText {
                y: 60
                text: numberOfPvChargers > 0 && pvName2.valid ? pvName2.text : ""
                visible: numberOfPvChargers > 0
            },
            TileText {
                y: 74
                text: numberOfPvChargers > 1 ? pvVoltage2.text + " " + pvCurrent2.text : ""
                font.pixelSize: 15
                visible: numberOfPvChargers > 1 && pvVoltage2.valid && pvCurrent2.valid
            }
        ]
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

        width: parent.width
        property int tileWidth: width / Math.min (count, 4.5)
        height: tanksHeight
        anchors
        {
            bottom: root.bottom
            left: root.left
        }

/////// flickable list if more than will fit across bottom of screen
        interactive: count > 4 ? true : false
        orientation: ListView.Horizontal

        model: tanksModel
        delegate: TileTank {
            width: tanksColumn.tileWidth
            height: root.tanksHeight
            pumpBindPrefix: root.pumpBindPreffix
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
        if (service.type === DBusService.DBUS_SERVICE_TANK)
        {
            // hide the service for the physical sensor
            if (name !== incomingTankServiceName) // hide incoming N2K tank dBus object
            {
                tanksModel.append({serviceName: service.name})
                numberOfTanks++
            }
        }
//////// add for PV CHARGER voltage and current display and popups
        if (service.type === DBusService.DBUS_SERVICE_SOLAR_CHARGER)
        {
            numberOfPvChargers++
            if (numberOfPvChargers === 1)
                pvChargerPrefix1 = name;
            else if (numberOfPvChargers === 2)
                pvChargerPrefix2 = name;
        }
        else if (service.type === DBusService.DBUS_SERVICE_MULTI) {
            numberOfMultis++
            if (vebusPrefix === "")
                vebusPrefix = name;
        }
    }

    // Detect available services of interest
    function discoverServices()
    {
        incomingTankServiceName = incomingTankName.valid ? incomingTankName.value : ""
        tanksModel.clear()
        for (var i = 0; i < DBusServices.count; i++)
        {
            addService(DBusServices.at(i))
        }
    }
    VBusItem { id: incomingTankName;
        bind: Utils.path(settingsBindPreffix, "/Settings/Devices/TankRepeater/IncomingTankService") }


////// popup over AC input tile for current limit
    MouseArea {
        anchors.fill: parent
        enabled: parent.active
        onPressed: mouse.accepted = acCurrentButton.expanded
        onClicked: { acCurrentButton.cancel(); inverterModePopUp.cancel() }
    }
////// popup current limit box over the AC Input tile
    TileSpinBox {
        title: qsTr("AC Current Limit")
        id: acCurrentButton
        // hide button until it is expanded
        // 0 opacity blocks clicks so use a small value instead (0.001 appears to be smallest that works)
        opacity: expanded ? 1 : 0.001
        anchors.top: parent.top; anchors.topMargin: expanded ? 0 : acInBox.height * 2 /3
        anchors.left: acInBox.left
        isCurrentItem: false // don't show the edit icon
        focus: true

        bind: Utils.path(vebusPrefix, "/Ac/ActiveIn/CurrentLimit")
        color: containsMouse && !editMode ? "#d3d3d3" : "#A8A8A8"
        width: show ? acInBox.width : 0
        fontPixelSize: 14
        unit: "A"
        readOnly: currentLimitIsAdjustable.value !== 1 || numberOfMultis > 1
        buttonColor: "#979797"

        VBusItem { id: currentLimitIsAdjustable; bind: Utils.path(vebusPrefix, "/Ac/ActiveIn/CurrentLimitIsAdjustable") }
    }
    
////// popup inverter mode selector over the Mulit tile
    InverterModePopUp
    {
        title: qsTr("Inverter Mode")
        id: inverterModePopUp
        // hide button until it is expanded
        // 0 opacity blocks clicks so use a small value instead (0.001 appears to be smallest that works)
        opacity: expanded ? 1 : 0.001
        anchors.top: parent.top; anchors.topMargin: expanded ? 0 : multi.height / 3
        anchors.left: multi.left
        width: show ? multi.width : 0
        readOnly: !modeIsAdjustable.valid || modeIsAdjustable.value !== 1 || numberOfMultis > 1
        // disable mouse area if can't make the adjustment
        visible: !readOnly
        buttonColor: "#979797"
        color: containsMouse && !editMode ? "#d3d3d3" : "#A8A8A8"

        bind: Utils.path(vebusPrefix, "/Mode")
        VBusItem { id: inverterMode; bind: Utils.path(vebusPrefix, "/Mode") }
        VBusItem { id: modeIsAdjustable; bind: Utils.path(vebusPrefix,"/ModeIsAdjustable") }
    }
}
