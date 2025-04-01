// GuiMods Enhancements to OverviewMobile screen

// Removed logo and added AC INPUT and SYSTEM tiles originally displayed on other overviews
// Added voltage, current and frequency to AC INPUT and AC LOADS tiles
// Added source (Grid, Generator, Shore Power) to AC INPUT tile
// Replaced to/from battery with current in DC SYSTEM tile
// DC SYSTEM tile title now reflects direction: "DC LOADS, DC CHARGER"
// Rearranged tiles to match a left to right signal flow : sources on left, loads on right
// Standardized "info" tile sizes to 1 or 1.5 wide x 1 or 2 high
// infoArea defines usable space for info tiles and all tiles are a child of infoArea
// (makes repositioning easier than when they were in separate column objects)
// Large text for main paremeter in each tile has been reduced in size to allow more parameters without
// expanding tile height (30 to 22)
// merged SYSTEM and STATUS tiles
// removed speed from STATUS to reduce tile height
// hide "reason" text if it's blank to save space
// changed clock to 12-hour format
// Capitialized battery state: "Idle", "Charging", "Discharging"
// errors and notificaitons in SYSTEM/STATUS tile may push clock off bottom of tile
// Tile content for items that are not present are made invisible - tile remains in place
// that is  no height adjustments when a tile provides no information
// Adjust button widths so that pump button fits within tank column
// Hide pump button when not enabled giving more room for tanks
// Add temperature sensors to tanks column
// add control of VE.Direct inverters

// Includes changes to handle SeeLevel NMEA2000 tank sensor:
// Ignore the real incoming tank dBus service because it's information changes
// Changes in TileText.qml are also part of the TankRepeater  package

// Search for //////// to find changes

import QtQuick 2
import com.victron.velib 1.0
import "utils.js" as Utils
import "timeToGo.js" as TTG
import "enhancedFormat.js" as EnhFmt

OverviewPage {
    title: qsTr("Mobile")
    id: root
	focus: active

    property color detailColor: "#b3b3b3"
    property real touchTargetOpacity: 0.3
    property int touchArea: 40

    property variant sys: theSystem
    property string settingsBindPreffix: "com.victronenergy.settings"
    property string pumpBindPreffix: "com.victronenergy.pump.startstop0"
    property string noAdjustableByDmc: qsTr("This setting is disabled when a Digital Multi Control " +
                                            "is connected. If it was recently disconnected execute " +
                                            "\"Redetect system\" that is available on the inverter menu page.")
    property string noAdjustableByBms: qsTr("This setting is disabled when a VE.Bus BMS " +
                                            "is connected. If it was recently disconnected execute " +
                                            "\"Redetect system\" that is available on the inverter menu page.")
    property string noAdjustableTextByConfig: qsTr("This setting is disabled. " +
                                           "Possible reasons are \"Overruled by remote\" is not enabled or " +
                                           "an assistant is preventing the adjustment. Please, check " +
                                           "the inverter configuration with VEConfigure.")

//////// added to keep track of tanks and temps
    property int numberOfTemps: 0
    property int tankTempCount: tankModel.rowCount + numberOfTemps
    property real tanksTempsHeight: root.height - (pumpButton.pumpEnabled ? pumpButton.height : 0)
    property real tanksHeight: tankModel.rowCount > 0 ? tanksTempsHeight * tankModel.rowCount / tankTempCount : 0
    property real tempsHeight: tanksTempsHeight - tanksHeight
    property real minimumTankHeight: 21
    property real maxTankHeight: 80
    property real tankTileHeight: Math.min (Math.max (tanksTempsHeight / tankTempCount, minimumTankHeight), maxTankHeight)

    property bool compact: tankTempCount > (pumpButton.pumpEnabled ? 5 : 6)

	property string systemPrefix: "com.victronenergy.system"
	VBusItem { id: vebusService; bind: Utils.path(systemPrefix, "/VebusService") }
    property bool isMulti: vebusService.valid
    property string veDirectInverterService: ""
    property string inverterService: vebusService.valid ? vebusService.value : veDirectInverterService

    property bool isInverter: ! isMulti && veDirectInverterService != ""
    property bool hasAcInput: isMulti
    VBusItem { id: _hasAcOutSystem; bind: "com.victronenergy.settings/Settings/SystemSetup/HasAcOutSystem" }
    property bool hasAcOutSystem: _hasAcOutSystem.value === 1
    
//////// add for system state
    property bool hasSystemState: _systemState.valid

//////// add for SYSTEM tile and voltage, power and frequency values
    property VBusItem _systemState: VBusItem { bind: Utils.path(systemPrefix, "/SystemState/State") }
//////// add for PV CHARGER voltage and current
    property string pvChargerPrefix: ""
    property int numberOfPvChargers: 0

 
 //////// standard tile sizes
 //////// positions are left, center, right and top, center, bottom of infoArea
    property int tankWidth: 130

    property int upperTileHeight: 185
	property int acTileHeight: height - upperTileHeight
    
    property int infoWidth: width - tankWidth
    property int infoWidth3Column: infoWidth / 3
    property int infoWidth2Column: infoWidth / 2

//////// add for PV Charger voltage and current
	VBusItem { id: pvNrTrackers; bind: Utils.path(pvChargerPrefix, "/NrOfTrackers") }
	property bool singleTracker: ! pvNrTrackers.valid || pvNrTrackers.value == 1
	property bool showPvVI: numberOfPvChargers == 1 && singleTracker
	VBusItem { id: pvPower; bind: Utils.path(pvChargerPrefix, "/Yield/Power") }
	VBusItem { id: pvVoltage;  bind: Utils.path(pvChargerPrefix, singleTracker ? "/Pv/V" : "/Pv/0/V") }

//////// add for inverter mode in STATUS
    VBusItem { id: inverterMode; bind: Utils.path(inverterService, "/Mode") }

//////// add for gauges
    VBusItem { id: showGaugesItem; bind: Utils.path(guiModsPrefix, "/ShowGauges") }
    property bool showGauges: showGaugesItem.valid ? showGaugesItem.value === 1 ? true : false : false

//////// added to control time display
    property string guiModsPrefix: "com.victronenergy.settings/Settings/GuiMods"
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

    Component.onCompleted: { discoverServices(); showHelp () }

	// define usable space for tiles but don't show anything
    Rectangle {
        id: infoArea
		visible: false
        anchors {
            left: parent.left
            right: tanksColum.left
			top: parent.top;
			bottom: parent.bottom;
        }
	}

//////// change time to selectable 12/24 hour format
		Timer {
			id: wallClock
			running: timeFormat != ""
			repeat: true
			interval: 1000
			triggeredOnStart: true
			onTriggered: time = Qt.formatDateTime(new Date(), timeFormat)
			property string time
		}

	VBusItem { id: systemName; bind: Utils.path(settingsBindPreffix, "/Settings/SystemSetup/SystemName") }

//////// copied SYSTEM from OverviewTiles.qml & combined SYSTEM and STATUS tiles
	Tile {
		title: qsTr("STATUS")
		id: statusTile
		anchors { left: parent.left; top: parent.top }
		width: root.infoWidth3Column
		height: root.upperTileHeight - inverterTile.height
		color: "#4789d0"

//////// relorder to give priority to errors
		values: [
			TileText {
				text: systemName.valid && systemName.value !== "" ? systemName.value : sys.systemType.valid ? sys.systemType.value.toUpperCase() : ""
				font.pixelSize: 16
				wrapMode: Text.WordWrap
				width: statusTile.width - 5
			},
			TileText {
				text: wallClock.running ? wallClock.time : ""
				font.pixelSize: 15
			},
//////// SystemReason only now (Victron removed notifications around v3.60~53)
			MarqueeEnhanced {
				text:systemReasonMessage.text
				width: statusTile.width
				textHorizontalAlignment: Text.AlignHCenter
				interval: 100
				SystemReasonMessage {
					id: systemReasonMessage
				}
			},
			TileText {
				property VeQuickItem gpsService: VeQuickItem { uid: "dbus/com.victronenergy.system/GpsService" }
				property VeQuickItem speed: VeQuickItem { uid: Utils.path("dbus/", gpsService.value, "/Speed") }
				property VeQuickItem speedUnit: VeQuickItem { uid: "dbus/com.victronenergy.settings/Settings/Gps/SpeedUnit" }

				text: speed.value === undefined ? "" : getValue()
				visible: speed.value !== undefined && speedUnit.value !== undefined

				function getValue()
				{
					if (speed.value < 0.5)	// blank speed if less than about 1 MPH
						return " "
					if (speedUnit.value === "km/h")
						return (speed.value * 3.6).toFixed(1) + speedUnit.value
					if (speedUnit.value === "mph")
						return (speed.value * 2.236936).toFixed(1) + speedUnit.value
					if (speedUnit.value === "kt")
						return (speed.value * (3600/1852)).toFixed(1) + speedUnit.value
					return speed.value.toFixed(2) + "m/s"
				}
			}
		]
	} // end Tile STATUS
	Tile
	{
		title: qsTr("INVERTER")
		id: inverterTile
		anchors { left: parent.left; top: statusTile.bottom }
		width: root.infoWidth3Column
		height: 62
		color: "#4789d0"

		values: [
			TileText
			{
				text: inverterMode.valid ? inverterMode.text : "--"
			},
			TileText {
				text: qsTr(systemState.text)

				SystemState {
					id: systemState
					bind: hasSystemState?Utils.path(systemPrefix, "/SystemState/State"):Utils.path(inverterService, "/State")
				}
			}
		]
////// add power bar graph
		PowerGaugeMulti
		{
			id: multiBar
			width: parent.width - 10
			height: 8
			anchors
			{
				top: parent.top; topMargin: 20
				horizontalCenter: parent.horizontalCenter
			}
			inverterService: root.inverterService
			visible: showGauges
		}
		DetailTarget { id: multiTarget; detailsPage: "DetailInverter.qml" }
	} // end Tile INVERTER

	Tile {
		title: qsTr("BATTERY")
		id: batteryTile
		anchors { horizontalCenter: infoArea.horizontalCenter; top: infoArea.top }
		width: root.infoWidth3Column
		height: root.upperTileHeight

		values: [
			TileText // spacer
			{
				text: ""
				font.pixelSize: 6
			},
			TileText {
				text: sys.battery.soc.absFormat(0)
				font.pixelSize: 22
	//////// remove height (for consistency with other tiles)
			},
			TileText {
				text: {
					if (!sys.battery.state.valid)
						return "---"
					switch(sys.battery.state.value) {
	//////// change - capitalized words look better
						case sys.batteryStateIdle: return qsTr("Idle")
						case sys.batteryStateCharging : return qsTr("Charging")
						case sys.batteryStateDischarging : return qsTr("Discharging")
						}
					}
				},
			TileText {
//////// change to show negative for battery drain
				text: sys.battery.power.text
				font.pixelSize: 18
			},
			TileText {
				text: sys.battery.voltage.format(2)
			},
			TileText {
				text: sys.battery.current.format(1)
			},
			TileText {
				text: qsTr("Remaining:")
				visible: timeToGo.valid
			},
			TileText {
				id: timeToGoText
				text: timeToGo.valid ? TTG.formatTimeToGo (timeToGo) : " "
				visible: timeToGo.valid
				
				VBusItem {
					id: timeToGo
					bind: Utils.path("com.victronenergy.system","/Dc/Battery/TimeToGo")
				}
			}
		]
////// add battery current bar graph
		PowerGaugeBattery
		{
			id: batteryBar
			width: parent.width - 10
			height: 8
            endLabelFontSize: 14
            endLabelBackgroundColor: batteryTile.color
			anchors
			{
				top: parent.top; topMargin: 22
				horizontalCenter: parent.horizontalCenter
			}
			visible: showGauges
		}
		DetailTarget { id: batteryTarget; detailsPage: "DetailBattery.qml" }
	} // end Tile BATTERY

    VBusItem { id: dcSystemNameItem; bind: Utils.path(settingsBindPreffix, "/Settings/GuiMods/CustomDcSystemName") }

	Tile {
        title: dcSystemNameItem.valid && dcSystemNameItem.value != "" ? dcSystemNameItem.value : qsTr ("DC SYSTEM")
	    id: dcSystem
	    anchors { right: infoArea.right; bottom: infoArea.bottom; bottomMargin: root.acTileHeight }
	    width: root.infoWidth3Column
	    height: (root.upperTileHeight / 2) - 5
	    color: "#16a085"
	    values: [
			TileText { // spacer
				font.pixelSize: 6
				text: ""
			},
			TileText {
				font.pixelSize: 22
				text: EnhFmt.formatVBusItem (sys.dcSystem.power)
				visible: sys.dcSystem.power.valid
			},
	////// replace to/from battery with current
			TileText {
						text: !sys.dcSystem.power.valid ? "---" :
							EnhFmt.formatValue (sys.dcSystem.power.value / sys.battery.voltage.value, "A")
						visible: sys.dcSystem.power.valid
			}
		]
        PowerGauge
        {
            id: dcSystemGauge
            width: parent.width - 10
            height: 8
            anchors
            {
                top: parent.top; topMargin: 22
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.dcSystem
            endLabelFontSize: 12
            endLabelBackgroundColor: dcSystem.color
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/DcSystemMaxLoad"
            maxReversePowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/DcSystemMaxCharge"
            showLabels: true
            visible: showGauges && sys.dcSystem.power.valid
        }
		DetailTarget { id: dcSystemTarget; detailsPage: "DetailDcSystem.qml" }
	} // end Tile DC SYSTEM

	Tile {
	    id: solarTile
	    title: qsTr("PV CHARGER")
	    anchors { right: infoArea.right; top: infoArea.top }
	    width: root.infoWidth3Column
	    height: root.upperTileHeight - dcSystem.height
	    color: "#2cc36b"
	    values: [
            TileText {
                font.pixelSize: 22
                text: EnhFmt.formatVBusItem (sys.pvCharger.power)
            },
    //////// add voltage
            TileText {
                text:
                {
					if (showPvVI)
						return EnhFmt.formatVBusItem (pvVoltage, "V")
					else
						return ""
                }
                visible: showPvVI
            },
    //////// add current
            TileText {
                text:
                {
					if (showPvVI && pvPower.valid && pvVoltage.valid)
					{
						var voltage = pvVoltage.value
						return EnhFmt.formatValue ((pvPower.value / voltage), "A")
					}
					else
						return ""
                }
                visible: showPvVI
            }
        ]
////// add power bar graph
        PowerGauge
        {
            id: pvChargerBar
            width: parent.width - 10
            height: 8
            anchors
            {
                top: parent.top; topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.pvCharger
			maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/PvChargerMaxPower"
            visible: showGauges && sys.pvCharger.power.valid
        }
		DetailTarget { id: pvChargerTarget; detailsPage: "DetailPvCharger.qml" }
	} // end Tile PV CHARGER

//////// add to display AC input ignored
    VBusItem { id: ignoreAcInput; bind: Utils.path(inverterService, "/Ac/State/IgnoreAcIn1") }

//////// add AC INPUT tile
	Tile {
		id: acInputTile
		title: {
			if (isInverter)
				return qsTr ("No AC Input")
			else if (ignoreAcInput.valid && ignoreAcInput.value == 1)
				return qsTr ("AC In Ignored")
			else
			{
				switch(sys.acSource) {
					case 1: return qsTr("GRID")
					case 2: return qsTr("GENERATOR")
					case 3: return qsTr("SHORE POWER")
					default: return qsTr("AC INPUT")
				}
			}
		}
		anchors { left: infoArea.left; bottom: infoArea.bottom }
		width: root.infoWidth2Column
		height: root.acTileHeight
		color: "#82acde"
//////// add voltage and current
		VBusItem { id: currentLimit; bind: Utils.path(inverterService, "/Ac/ActiveIn/CurrentLimit") }
		values: [
			TileText {
				visible: isMulti
				text: EnhFmt.formatVBusItem (sys.acInput.power)
				font.pixelSize: 20
				
			},
//////// add voltage and current
			TileText {
				visible: isMulti
				text: EnhFmt.formatVBusItem (sys.acInput.voltageL1, "V") + "  " + EnhFmt.formatVBusItem (sys.acInput.currentL1, "A") + "  " + EnhFmt.formatVBusItem (sys.acInput.frequency, "Hz")
			},
			TileText
			{
				text: qsTr ("Limit: ") + EnhFmt.formatVBusItem (currentLimit, "A")
				visible: currentLimit.valid
			}
		]
////// add power bar graph
		PowerGauge
		{
			id: acInBar
			width: parent.width - 10
			height: 8
			anchors
			{
				top: parent.top; topMargin: 20
				horizontalCenter: parent.horizontalCenter
			}
			connection: sys.acInput
			useInputCurrentLimit: true
			maxForwardPowerParameter: ""
			maxReversePowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxFeedInPower"
			visible: showGauges && hasAcInput
		}
		DetailTarget { id: acInputTarget; detailsPage: "DetailAcInput.qml" }
	}

	Tile {
		title: qsTr("AC LOADS")
		id: acLoadsTile
		anchors { right: infoArea.right; bottom: infoArea.bottom}
		width: root.infoWidth2Column
		height: root.acTileHeight
		color: "#e68e8a"
//////// add voltage and current
		VBusItem { id: outVoltage; bind: Utils.path(inverterService, "/Ac/Out/L1/V") }
		VBusItem { id: outCurrent; bind: Utils.path(inverterService, "/Ac/Out/L1/I") }
		VBusItem { id: outFrequency; bind: Utils.path(inverterService, "/Ac/Out/L1/F") }

		values: [
			TileText {
				text: EnhFmt.formatVBusItem (sys.acLoad.power)
				font.pixelSize: 22
			},
//////// add voltage and current - no frequency for VE.Direct inverter
			TileText {
				text:
				{
					var lineText = ""
					if (isMulti || isInverter)
					{
						lineText = EnhFmt.formatVBusItem (outVoltage, "V") + "  " + EnhFmt.formatVBusItem (outCurrent, "A")
						if (isMulti)
							lineText += " " + EnhFmt.formatVBusItem (outFrequency, "Hz")
					}
					return lineText
				}
			}
		]
////// add power bar graph
		PowerGauge
		{
			id: acLoadBar
			width: parent.width - 10
			height: 8
			anchors
			{
				top: parent.top; topMargin: 20
				horizontalCenter: parent.horizontalCenter
			}
			connection: sys.acLoad
			maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/AcOutputMaxPower"
			visible: showGauges && hasAcOutSystem
		}
		DetailTarget { id: acLoadsOnOutputTarget; detailsPage: "DetailLoadsOnOutput.qml" }
	}

    // Synchronise tank name text scroll start
    Timer {
        id: scrollTimer
        interval: 15000
        repeat: true
        running: root.active
    }

    ListView {
        id: tanksColum

        anchors {
            top: root.top
            right: root.right
        }
        height: root.tanksHeight
        width: root.tankWidth
//////// make list flickable if more tiles than will fit completely
        interactive: root.tankTileHeight * count > (tanksColum.height + 1) ? true : false

        model: TankModel { id: tankModel }
        delegate: TileTankEnhanced {
            // Without an intermediate assignment this will trigger a binding loop warning.
            property variant theService: DBusServices.get(buddy.id)
            service: theService
            width: tanksColum.width
            height: root.tankTileHeight
            pumpBindPrefix: root.pumpBindPreffix
//////// modified to control compact differently
            compact: root.compact
            Connections {
                target: scrollTimer
                onTriggered: doScroll()
            }
        }
        Tile {
            title: qsTr("TANKS")
            anchors.fill: parent
            values: TileText {
                text: qsTr("")
                width: parent.width
                wrapMode: Text.WordWrap
            }
            z: -1
        }
    }

//////// added temperature ListView and Model
    ListView {
        id: tempsColumn

        anchors {
            top: tanksColum.bottom
            right: root.right
        }
        height: root.tempsHeight
        width: root.tankWidth
//////// make list flickable if more tiles than will fit completely
        interactive: root.tankTileHeight * count > (tempsColumn.height + 1) ? true : false

        model: tempsModel
        delegate: TileTemp
        {
            width: tempsColumn.width
            height: root.tankTileHeight
//////// modified to control compact differently
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

	Tile {
        id: pumpButton

        anchors.right: parent.right
        anchors.bottom: parent.bottom

        property variant texts: [ qsTr("AUTO"), qsTr("ON"), qsTr("OFF")]
        property int value: 0
        property bool reset: false
        property bool pumpEnabled: pumpRelay.value === 3
        isCurrentItem: false // not used by GuiMods key handler - focus shown a different way
        //focus: root.active && isCurrentItem // don't switch focus -- messes up key handler

        title: qsTr("PUMP")
        width: pumpEnabled ? root.tankWidth : 0
        height: 45
        editable: true
        readOnly: false
        color: pumpButtonMouseArea.containsPressed ? "#d3d3d3" : "#A8A8A8"

        VBusItem { id: pump; bind: Utils.path(settingsBindPreffix, "/Settings/Pump0/Mode") }
        VBusItem { id: pumpRelay; bind: Utils.path(settingsBindPreffix, "/Settings/Relay/Function") }

        values: [
            TileText {
                text: pumpButton.pumpEnabled ? qsTr("%1").arg(pumpButton.texts[pumpButton.value]) : qsTr("DISABLED")
            }
        ]

        function edit() {
            if (!pumpEnabled) {
                toast.createToast(qsTr("Pump functionality is not enabled. To enable it go to the relay settings page and set function to \"Tank pump\""), 5000)
                return
            }

            reset = true
            applyAnimation.restart()
            reset = false

            if (value < 2)
                value++
            else
                value = 0
        }

        MouseArea {
            id: pumpButtonMouseArea
            property bool containsPressed: containsMouse && pressed
            anchors.fill: parent
            onClicked: {
                parent.edit()
            }
        }

        Rectangle {
            id: timerRect
            height: 2
            width: pumpButton.width * 0.8
            visible: applyAnimation.running
            anchors {
                bottom: parent.bottom; bottomMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
        }

        SequentialAnimation {
            id: applyAnimation
            alwaysRunToEnd: false
            NumberAnimation {
                target: timerRect
                property: "width"
                from: 0
                to: pumpButton.width * 0.8
                duration: 3000
            }

            ColorAnimation {
                target: pumpButton
                property: "color"
                from: "#A8A8A8"
                to: "#4789d0"
                duration: 200
            }

            ColorAnimation {
                target: pumpButton
                property: "color"
                from: "#4789d0"
                to: "#A8A8A8"
                duration: 200
            }
            PropertyAction {
                target: timerRect
                property: "width"
                value: 0
            }
            // Do not set value if the animation is restarted by user pressing the button
            // to move between options
			onRunningChanged: if (!running && !pumpButton.reset) pump.setValue(pumpButton.value)
		}
		DetailTarget { id: pumpButtonTarget; detailsPage: "" }
	}

	// When new service is found add resources as appropriate
	Connections {
		target: DBusServices
		onDbusServiceFound: addService(service)
	}

	// hack to get value(s) from within a loop inside a function when service is changing
	property string tempServiceName: ""
	property VBusItem temperatureItem: VBusItem { bind: Utils.path(tempServiceName, "/Dc/0/Temperature") }

//////// rewrite to use switch in place of if statements
    function addService(service)
    {
        switch (service.type)
        {
//////// add for temp sensors
        case DBusService.DBUS_SERVICE_TEMPERATURE_SENSOR:
            numberOfTemps++
            tempsModel.append({serviceName: service.name})
            break;;
        case DBusService.DBUS_SERVICE_MULTI:
			root.tempServiceName = service.name
			if (temperatureItem.valid)
			{
				numberOfTemps++
				tempsModel.append({serviceName: service.name})
			}
            break;;
//////// add for VE.Direct inverters
        case DBusService.DBUS_SERVICE_INVERTER:
            if (veDirectInverterService == "")
				veDirectInverterService = service.name;
            break;;

//////// add for PV CHARGER voltage and current display
        case DBusService.DBUS_SERVICE_SOLAR_CHARGER:
            numberOfPvChargers++
            if (pvChargerPrefix === "")
                pvChargerPrefix = service.name;
            break;;
        case DBusService.DBUS_SERVICE_BATTERY:
			root.tempServiceName = service.name
			if (temperatureItem.valid)
			{
				numberOfTemps++
				tempsModel.append({serviceName: service.name})
			}
			break;;
        }
    }

    // Check available services to find tank sesnsors
//////// rewrite to always call addService, removing redundant service type checks
    function discoverServices()
    {
        numberOfTemps = 0
        numberOfPvChargers = 0
		veDirectInverterService = ""
        tempsModel.clear()
        for (var i = 0; i < DBusServices.count; i++)
                addService(DBusServices.at(i))
    }

	VBusItem { id: dmc; bind: Utils.path(inverterService, "/Devices/Dmc/Version") }
	VBusItem { id: bms; bind: Utils.path(inverterService, "/Devices/Bms/Version") }



// Details targets
////// display detail targets and help message when first displayed.
    Timer {
        id: helpTimer
        running: false
        repeat: false
        interval: 5000
        triggeredOnStart: true
    }

    // help message shown when menu is first drawn
    Rectangle
    {
        id: helpBox
        color: "white"
        width: 150
        height: 32
        opacity: 0.7
        anchors
        {
            horizontalCenter: infoArea.horizontalCenter
            verticalCenter: infoArea.verticalCenter
        }
        visible: false
    }
    TileText
    {
        text: qsTr ( "Tap tile center for detail at any time" )
        color: "black"
        anchors.fill: helpBox
        wrapMode: Text.WordWrap
        font.pixelSize: 12
        visible: helpBox.visible
    }


	//// hard key handler
	//		used to press buttons when touch isn't available
	//		UP and DOWN buttons cycle through the list of touch areas
	//		"space" button is used to simulate a touch on the area
	//		target must be highlighted so that other uses of "space"
	//		will still occur

	// list of all details touchable areas
	// pump button sets value locally, no details page
	//	so is hanelded differently
	//	it must be LAST in the list because target list index is used for special processing
	property variant targetList:
	[
		 multiTarget, batteryTarget, pvChargerTarget, dcSystemTarget,
		 acInputTarget, acLoadsOnOutputTarget, pumpButtonTarget // pump MUST BE LAST
	]

	property int selectedTarget: 0

    Timer
    {
        id: targetTimer
        interval: 5000
        repeat: false
        running: false
        onTriggered: { hideAllTargets () }
    }

	Keys.forwardTo: [keyHandler]
	Item
	{
		id: keyHandler
		Keys.onUpPressed:
		{
			nextTarget (-1)
			event.accepted = true
		}

		Keys.onDownPressed:
		{
			nextTarget (+1)
			event.accepted = true
		}
		Keys.onSpacePressed:
		{
			if (targetTimer.running)
			{
				var foo // hack to make clicked() work
				if (selectedTarget == targetList.length - 1)
					pumpButton.edit ()
				else
					bar.clicked (foo)
				event.accepted = true
			}
			else
				event.accepted = false
		}
	}
	// hack to make clicked() work
	property variant bar: targetList[selectedTarget]

	function nextTarget (increment)
	{
		// make one pass through all possible targets to find an enabled one
		// if found, that's the new selectedTarget,
		// if not selectedTarget does not change
		var newIndex = selectedTarget
		for (var i = 0; i < targetList.length; i++)
		{
			if (( ! targetTimer.running || helpBox.visible) && targetList[newIndex].enabled)
			{
				highlightSelectedTarget ()
				return
			}
			newIndex += increment
			if (newIndex >= targetList.length)
				newIndex = 0
			else if (newIndex < 0)
				newIndex = targetList.length - 1
			var includeTarget
			if (newIndex == targetList.length - 1)
				includeTarget = pumpButton.pumpEnabled
			else
				includeTarget = targetList[newIndex].enabled
			if (includeTarget)
			{
				selectedTarget = newIndex
				highlightSelectedTarget ()
				break
			}
		}
	}

	function showHelp ()
	{
		for (var i = 0; i < targetList.length; i++)
		{
			targetList[i].targetVisible = true
		}
		helpBox.visible = true
		targetTimer.restart ()
	}
	function hideAllTargets ()
	{
		for (var i = 0; i < targetList.length; i++)
			targetList[i].targetVisible = false
		helpBox.visible = false
	}
	function highlightSelectedTarget ()
	{
		for (var i = 0; i < targetList.length; i++)
		{
			if (targetList[i] == targetList[selectedTarget])
				targetList[i].targetVisible = true
			else
				targetList[i].targetVisible = false
		}
		targetTimer.restart ()
		helpBox.visible = false
	}
}
