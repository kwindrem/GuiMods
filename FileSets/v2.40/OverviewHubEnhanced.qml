////// MODIFIED to show:
//////  tanks in a row along bottom
//////  PV voltage and current and DC power current (up to 2 MPPTs with tanks and temps or 3 without)
//////  PV inverter power (up to 2 with tanks and temps or 3 without)
//////  voltage, current, frequency in AC tiles (plus current limit for AC input)
//////  time of day
//////  current in DC Loads
//////  remaining time in Battery tile
//////  bar graphs on AC in/out and Multi
//////  popups for AC input current limit and inverter mode
//////  bar gauge on PV Charger tile

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
    property int bottomOffset: 45
    property string settingsBindPreffix: "com.victronenergy.settings"
    property string pumpBindPreffix: "com.victronenergy.pump.startstop0"
    property int numberOfTanks: 0
    property int numberOfTemps: 0
//////// added/modified for control show/hide gauges, tanks and temps from menus
    property int tankCount: showTanksEnable ? numberOfTanks : 0
    property int tempCount: showTempsEnable ? numberOfTemps : 0
    property int tankTempCount: tankCount + tempCount
    property bool showTanks: showTanksEnable ? showStatusBar ? false : tankCount > 0 ? true : false : false
    property bool showTemps: showTempsEnable ? showStatusBar ? false : tempCount > 0 ? true : false : false
    property bool showTanksTemps: showTanks || showTemps
    property int compactThreshold: 45   // height below this will be compacted vertically
    property int batteryHeight: 91
    property bool compact: showTanks && showTemps && tankTempCount > 4
    property int tanksHeight: compact ? 22 : 45

//////// add for PV CHARGER voltage and current
    property string pvChargerPrefix1: ""
    property string pvChargerPrefix2: ""
    property string pvChargerPrefix3: ""
    property int numberOfPvChargers: 0
//////// add for PV INVERTER power
    property string pvInverterPrefix1: ""
    property string pvInverterPrefix2: ""
    property string pvInverterPrefix3: ""
    property int numberOfPvInverters: 0

    property int numberOfMultis: 0
    property string multiPrefix: ""
//////// add for VE.Direct inverters
    property int numberOfInverters: 0
    property string inverterService: ""
    property bool isMulti: numberOfMultis > 0
    property bool isInverter: !isMulti && numberOfInverters > 0

//////// added for control show/hide gauges, tanks and temps from menus
    property string guiModsPrefix: "com.victronenergy.settings/Settings/GuiMods"
    VBusItem { id: showGaugesItem; bind: Utils.path(guiModsPrefix, "/ShowGauges") }
    property bool showGauges: showGaugesItem.valid ? showGaugesItem.value === 1 ? true : false : false
    VBusItem { id: showTanksItem; bind: Utils.path(guiModsPrefix, "/ShowEnhancedFlowOverviewTanks") }
    property bool showTanksEnable: showTanksItem.valid ? showTanksItem.value === 1 ? true : false : false
    VBusItem { id: showTempsItem; bind: Utils.path(guiModsPrefix, "/ShowEnhancedFlowOverviewTemps") }
    property bool showTempsEnable: showTempsItem.valid ? showTempsItem.value === 1 ? true : false : false

//////// added to control time display
    VBusItem { id: timeFormatItem; bind: Utils.path(guiModsPrefix, "/TimeFormat") }
    property string timeFormat: getTimeFormat ()
    
    function getTimeFormat ()
    {
        if (!timeFormatItem.valid || timeFormatItem.value === 0)
            return ""
        else if (timeFormatItem.value === 2)
            return "h:mm ap"
        else
            return "hh:mm"
    }

//////// add to display PV charger voltage and current
    VBusItem { id: pvCurrent1; bind: Utils.path(pvChargerPrefix1, "/Pv/I") }
    VBusItem { id: pvVoltage1;  bind: Utils.path(pvChargerPrefix1, "/Pv/V") }
    VBusItem { id: pvName1;  bind: Utils.path(pvChargerPrefix1, "/CustomName") }
    VBusItem { id: pvCurrent2; bind: Utils.path(pvChargerPrefix2, "/Pv/I") }
    VBusItem { id: pvName2;  bind: Utils.path(pvChargerPrefix1, "/CustomName") }
    VBusItem { id: pvCurrent3; bind: Utils.path(pvChargerPrefix3, "/Pv/I") }
    VBusItem { id: pvVoltage3;  bind: Utils.path(pvChargerPrefix32, "/Pv/V") }
    VBusItem { id: pvName3;  bind: Utils.path(pvChargerPrefix3, "/CustomName") }
    VBusItem { id: timeToGo;  bind: Utils.path("com.victronenergy.system","/Dc/Battery/TimeToGo") }

//////// add to display PV Inverter power
    VBusItem { id: pvInverterPower1; bind: Utils.path(pvInverterPrefix1, "/Pv/P") }
    VBusItem { id: pvInverterName1; bind: Utils.path(pvInverterPrefix1, "/CustomName") }
    VBusItem { id: pvInverterPower2; bind: Utils.path(pvInverterPrefix2, "/Pv/P") }
    VBusItem { id: pvInverterName2; bind: Utils.path(pvInverterPrefix2, "/CustomName") }
    VBusItem { id: pvInverterPower3; bind: Utils.path(pvInverterPrefix3, "/Pv/P") }
    VBusItem { id: pvInverterName3; bind: Utils.path(pvInverterPrefix3, "/CustomName") }

    Component.onCompleted: discoverServices()

	title: qsTr("Overview")

	OverviewBox {
		id: acInBox
        visible: !isInverter
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
        PowerGauge
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
            show: showGauges
        }
	}


	Multi {
		id: multi
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top; topMargin: 3
		}
        inverterService: root.inverterService
////// add power bar graph
        PowerGauge
        {
            id: multiBar
            width: multi.width
            height: 12
            anchors
            {
                top: parent.top; topMargin: 23
                horizontalCenter: parent.horizontalCenter
            }
            connection: undefined
            useInverterInfo: true
            inverterService: root.inverterService
            show: showGauges
        }
	}

////// ADDED to show time inside inverter icon
    Timer {
        id: wallClock
        running: timeFormat != ""
        repeat: true
        interval: 1000
        triggeredOnStart: true
        onTriggered: time = Qt.formatDateTime(new Date(), timeFormat)

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
        show: wallClock.running
    }

	OverviewBox {
		id: acLoadBox
		title: qsTr("AC Loads")
		color: "#27AE60"
		titleColor: "#2ECC71"
		width: 148
		height: showStatusBar ? 80 : 102

		anchors {
			right: parent.right; rightMargin: 10
			top: multi.top
		}

		values: OverviewAcValues {
			connection: sys.acLoad
		}
////// add power bar graph
        PowerGauge
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
            inverterService: root.inverterService
            show: showGauges
        }
	}

	Battery {
		id: battery
        width: acInBox.width
		soc: sys.battery.soc.valid ? sys.battery.soc.value : 0
////// add battery current bar graph
        PowerGaugeBattery
        {
            id: batteryBar
            width: parent.width
            height: 10
            anchors
            {
                top: parent.top; topMargin: 52
                horizontalCenter: parent.horizontalCenter
            }
            show: showGauges
        }

////// MODIFIED to show tanks
        height: batteryHeight + 5
		anchors {
			bottom: parent.bottom; bottomMargin: showTanksTemps ? bottomOffset + 3 : 5;
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
                text: " "
                font.pixelSize: 6
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
            horizontalCenterOffset: 2
////// MODIFIED to show tanks
			bottom: parent.bottom; bottomMargin: showTanksTemps ? bottomOffset + 3 : 5
		}

		values: TileText {
			anchors.centerIn: parent
////// modified to show current
			text: dcSystemText ()
		}
	}

    function dcSystemText ()
    {
        if (sys.dcSystem.power.valid)
        {
            var current = sys.dcSystem.power.value / sys.battery.voltage.value
            if (Math.abs (current) <= 100)
                return sys.dcSystem.power.format(0) + " " + current.toFixed(1) + "A"
            else
                return sys.dcSystem.power.format(0) + " " + current.toFixed(0) + "A"
        }
        else
            return "--"
    }


	OverviewSolarCharger {
		id: blueSolarCharger

////// MODIFIED to show tanks & provide extra space if not
        height: hasDcAndAcSolar ? 65 : showTanksTemps ? batteryHeight + 20 : 114 + bottomOffset
        width: 148
		title: qsTr("PV Charger")
////// MODIFIED - always hide icon peaking out from under PV tile
		showChargerIcon: false
		visible: hasDcSolar || hasDcAndAcSolar

		anchors {
			right: root.right; rightMargin: 10
            bottom: parent.bottom; bottomMargin: showTanksTemps ? bottomOffset + 3 : 5
		}

//////// add voltage and current
		values: 
        [
            TileText {
                y: 8
                text: sys.pvCharger.power.format(0)
                font.pixelSize: 19
            },
            TileText {
                y: 29
                text: numberOfPvChargers > 0 && pvName1.valid ? pvName1.text : ""
                visible: numberOfPvChargers > 0
            },
            TileText {
                y: 45
                text: numberOfPvChargers > 0 ? pvVoltage1.text + " " + pvCurrent1.text : ""
                font.pixelSize: 15
                visible: numberOfPvChargers > 0 && pvVoltage1.valid && pvCurrent1.valid
            },
            TileText {
                y: 61
                text: numberOfPvChargers > 1 && pvName2.valid ? pvName2.text : ""
                visible: numberOfPvChargers > 1
            },
            TileText {
                y: 75
                text: numberOfPvChargers > 1 ? pvVoltage2.text + " " + pvCurrent2.text : ""
                font.pixelSize: 15
                visible: numberOfPvChargers > 1 && pvVoltage2.valid && pvCurrent2.valid
            },
            TileText {
                y: 91
                text: numberOfPvChargers > 2 && pvName3.valid ? pvName3.text : ""
                visible: numberOfPvChargers > 2 && ! showTanksTemps
            },
            TileText {
                y: 105
                text: numberOfPvChargers > 2 ? pvVoltage3.text + " " + pvCurrent3.text : ""
                font.pixelSize: 15
                visible: numberOfPvChargers > 2 && ! showTanksTemps && pvVoltage3.valid && pvCurrent3.valid
            }
        ]
////// add power bar graph
        PowerGauge
        {
            id: pvChargerBar
            width: parent.width
            height: 12
            anchors
            {
                top: parent.top; topMargin: -2
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.pvCharger
        }
	}

    OverviewSolarInverter {
        id: pvInverter
////// MODIFIED to show tanks & provide extra space if not
        height: hasDcAndAcSolar ? 65 : showTanksTemps ? batteryHeight + 20 : 114 + bottomOffset
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

//////// add individual PV inverter powers
        values:
        [
            TileText {
                id: coupledPvAc

                property double pvInverterOnAcOut: sys.pvOnAcOut.power.valid ? sys.pvOnAcOut.power.value : 0
                property double pvInverterOnAcIn1: sys.pvOnAcIn1.power.valid ? sys.pvOnAcIn1.power.value : 0
                property double pvInverterOnAcIn2: sys.pvOnAcIn2.power.valid ? sys.pvOnAcIn2.power.value : 0

                y: 5
                text: (pvInverterOnAcOut + pvInverterOnAcIn1 + pvInverterOnAcIn2).toFixed(0) + "W"
                font.pixelSize: hasDcAndAcSolar ? 20 : 25
                visible: hasDcAndAcSolar || (hasAcSolarOnIn && hasAcSolarOnOut) || (hasAcSolarOnAcIn1 && hasAcSolarOnAcIn2)
            },
            TileText {
                y: 8
                text: sys.pvCharger.power.format(0)
                font.pixelSize: 19
            },
            TileText {
                y: 29
                text: numberOfPvInverters > 0 && pvInverterName1.valid ? pvInverterName1.text : ""
                visible: !hasDcAndAcSolar && numberOfPvInverters > 0
            },
            TileText {
                y: 45
                text: numberOfPvInverters > 0 ? pvInverterPower1.text : ""
                font.pixelSize: 15
                visible: !hasDcAndAcSolar && numberOfPvInverters > 0 && pvInverterPower1.valid
            },
            TileText {
                y: 61
                text: numberOfPvInverters > 1 && pvInverterName2.valid ? pvInverterName2.text : ""
                visible: !hasDcAndAcSolar && numberOfPvInverters > 1
            },
            TileText {
                y: 75
                text: numberOfPvInverters > 1 ? pvInverterPower2.text : ""
                font.pixelSize: 15
                visible: !hasDcAndAcSolar && numberOfPvInverters > 1 && pvInverterPower2.valid
            },
            TileText {
                y: 91
                text: numberOfPvInverters > 2 && pvInverterName3.valid ? pvInverterName3.text : ""
                visible: !hasDcAndAcSolar && numberOfPvInverters > 2 && ! showTanksTemps
            },
            TileText {
                y: 105
                text: numberOfPvInverters > 2 ? pvInverterPower3.text : ""
                font.pixelSize: 15
                visible: !hasDcAndAcSolar && numberOfPvInverters > 2 && pvInverterPower3.valid
            }
        ]
////// add power bar graph
        PowerGauge
        {
            id: pvInverterBar
            width: parent.width
            height: 12
            anchors
            {
                top: parent.top; topMargin: -2
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.pvInverter
        }
    }

	OverviewConnection {
		id: acInToMulti
        visible: !isInverter
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
////// moved order so it covers connections
////// moved to under Multi
    OverviewEssReason {
        anchors {
            bottom: parent.bottom; bottomMargin: dcSystemBox.visible ? battery.height + 15 : 5
            horizontalCenter: parent.horizontalCenter
        }
    }

////// ADDED to show tanks & temps
    // Synchronise tank name text scroll start
    Timer
    {
        id: scrollTimer
        interval: 15000
        repeat: true
        running: root.active && root.compact
    }
    ListView
    {
        id: tanksColumn

        visible: showTanks
        width: compact ? root.width : root.width * tankCount / tankTempCount
        property int tileWidth: width / Math.min (count, 4.2)
        height: root.tanksHeight
        anchors
        {
            bottom: root.bottom
            left: root.left
        }

        // flickable list if more than will fit across bottom of screen
        interactive: count > 4 ? true : false
        orientation: ListView.Horizontal

        model: tanksModel
        delegate: TileTank
        {
            width: tanksColumn.tileWidth
            height: tanksColumn.height
            compact: root.compact
            pumpBindPrefix: root.pumpBindPreffix
            Connections
            {
                target: scrollTimer
                onTriggered: doScroll()
            }
        }
    }
    ListModel { id: tanksModel }

    ListView
    {
        id: tempsColumn

        visible: showTemps
        width: compact ? root.width : root.width * tempCount / tankTempCount
        property int tileWidth: width / Math.min (count, 4.2)
        height: root.tanksHeight
        anchors
        {
            bottom: root.bottom
            bottomMargin: compact ? root.tanksHeight : 0
            right: root.right
        }

        // make list flickable if more tiles than will fit completely
        interactive: count > 4 ? true : false
        orientation: ListView.Horizontal

        model: tempsModel
        delegate: TileTemp
        {
            width: tempsColumn.tileWidth
            height: tempsColumn.height
            compact: root.compact
            Connections
            {
                target: scrollTimer
                onTriggered: doScroll()
            }
        }
        Tile
        {
            title: qsTr("TEMPS")
            anchors.fill: parent
            values: TileText
            {
                text: qsTr("")
                width: parent.width
                wrapMode: Text.WordWrap
            }
            z: -1
        }
    }
    ListModel { id: tempsModel }

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
        case DBusService.DBUS_SERVICE_TANK:
            // hide incoming N2K tank dBus object if TankRepeater is running
            if ( ! incomingTankName.valid || incomingTankName.value !== service.name)
            {
                tanksModel.append({serviceName: service.name})
                numberOfTanks++
            }
            break;;
//////// add for temp sensors
        case DBusService.DBUS_SERVICE_TEMPERATURE_SENSOR:
            numberOfTemps++
            tempsModel.append({serviceName: service.name})
            break;;

        case DBusService.DBUS_SERVICE_MULTI:
            numberOfMultis++
            if (numberOfMultis === 1)
                inverterService = service.name;
            break;;
//////// add for VE.Direct inverters
        case DBusService.DBUS_SERVICE_INVERTER:
            numberOfInverters++
            if (numberOfInverters === 1 && inverterService == "")
                inverterService = service.name;
            break;;

//////// add for PV CHARGER voltage and current display
        case DBusService.DBUS_SERVICE_SOLAR_CHARGER:
            numberOfPvChargers++
            if (numberOfPvChargers === 1)
                pvChargerPrefix1 = service.name;
            else if (numberOfPvChargers === 2)
                pvChargerPrefix2 = service.name;
            break;;
        }
    }

    // Detect available services of interest
    function discoverServices()
    {
        tanksModel.clear()
        numberOfTanks = 0
        numberOfTemps = 0
        numberOfPvChargers = 0
        numberOfMultis = 0
        numberOfInverters = 0
        inverterService = ""
        pvChargerPrefix1 = ""
        pvChargerPrefix2 = ""
        for (var i = 0; i < DBusServices.count; i++)
        {
            addService(DBusServices.at(i))
        }
    }
    VBusItem { id: incomingTankName;
        bind: Utils.path(settingsBindPreffix, "/Settings/Devices/TankRepeater/IncomingTankService") }


////// handle clicks outside popup areas
    MouseArea {
        anchors.fill: parent
        enabled: parent.active
        onPressed: mouse.accepted = acCurrentLimitPopUp.expanded || inverterModePopUp.expanded
        onClicked: { acCurrentLimitPopUp.cancel(); inverterModePopUp.cancel() }
    }
////// popup current limit box over the AC Input tile
    AcCurrentLimitPopUp {
        title: qsTr("AC Current Limit")
        id: acCurrentLimitPopUp
        // hide button until it is expanded
        // 0 opacity blocks clicks so use a small value instead (0.001 appears to be smallest that works)
        opacity: expanded ? 1 : 0.001
        anchors.top: parent.top; anchors.topMargin: expanded ? 0 : acInBox.height * 2 /3
        anchors.left: acInBox.left
        width: show ? acInBox.width : 0

        color: containsMouse && !editMode ? "#d3d3d3" : "#A8A8A8"
        fontPixelSize: 14
        readOnly: ! isMulti || currentLimitIsAdjustable.value !== 1
        // disable mouse area if can't make the adjustment
        visible: !readOnly
        buttonColor: "#979797"

        bind: Utils.path(inverterService, "/Ac/ActiveIn/CurrentLimit")
        VBusItem { id: currentLimitIsAdjustable; bind: Utils.path(inverterService, "/Ac/ActiveIn/CurrentLimitIsAdjustable") }
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
//////// incorporate VE.Direct inverter
        readOnly:
        {
            if (isMulti)
                return !modeIsAdjustable.valid || modeIsAdjustable.value !== 1
            else if (isInverter)
                return false
            else
                return true
        }
        // disable mouse area if can't make the adjustment
        visible: !readOnly
        buttonColor: "#979797"
        color: containsMouse && !editMode ? "#d3d3d3" : "#A8A8A8"
        bind: Utils.path(inverterService, "/Mode")
        VBusItem { id: modeIsAdjustable; bind: Utils.path(inverterService,"/ModeIsAdjustable") }
    }
}
