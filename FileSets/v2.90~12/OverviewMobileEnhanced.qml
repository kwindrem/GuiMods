// Enhancements to OverviewMobile screen

// This version supports Venus versions 2.4, 2.5 and 2.60
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

import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils
import "timeToGo.js" as TTG

OverviewPage {
    title: qsTr("Mobile")
    id: root

    property color detailColor: "#b3b3b3"
    property real touchTargetOpacity: 0.3
    property int touchArea: 40
    property bool showTargets: helpTimer.running

    property variant sys: theSystem
    property string settingsBindPreffix: "com.victronenergy.settings"
    property string pumpBindPreffix: "com.victronenergy.pump.startstop0"
    property variant activeNotifications: NotificationCenter.notifications.filter(
                                              function isActive(obj) { return obj.active} )
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
    property real tanksTempsHeight: root.height - (pumpButton.pumpEnabled ? pumpButton : 0)
    property real tanksHeight: tankModel.rowCount > 0 ? tanksTempsHeight * tankModel.rowCount / tankTempCount : 0
    property real tempsHeight: tanksTempsHeight - tanksHeight
    property real minimumTankHeight: 21
    property real maxTankHeight: 80
    property real tankTileHeight: Math.min (Math.max (tanksTempsHeight / tankTempCount, minimumTankHeight), maxTankHeight)

    property bool compact: tankTempCount > (pumpButton.pumpEnabled ? 5 : 6)

    property int numberOfMultis: 0
    property string multiPrefix: ""
//////// add for VE.Direct inverters
    property int numberOfInverters: 0
    property string inverterService: ""
    property bool isMulti: numberOfMultis === 1
    property bool isInverter: numberOfMultis === 0 && numberOfInverters === 1
    property bool hasAcInput: isMulti
    VBusItem { id: _hasAcOutSystem; bind: "com.victronenergy.settings/Settings/SystemSetup/HasAcOutSystem" }
    property bool hasAcOutSystem: _hasAcOutSystem.value === 1
    
    // Keeps track of which button on the bottom row is active
    property int buttonIndex: 0

//////// add for system state
    property bool hasSystemState: _systemState.valid

//////// add for SYSTEM tile and voltage, power and frequency values
    property string systemPrefix: "com.victronenergy.system"
    property VBusItem _systemState: VBusItem { bind: Utils.path(systemPrefix, "/SystemState/State") }
//////// add for PV CHARGER voltage and current
    property string pvChargerPrefix: ""
    property int numberOfPvChargers: 0

 
 //////// standard tile sizes
 //////// positions are left, center, right and top, center, bottom of infoArea
    property int tankWidth: 130

    property int statusHeight: 170
	property int acTileHeight: height - statusHeight
    
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

    Component.onCompleted: { discoverServices(); helpTimer.running = true }

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
		height: root.statusHeight
		color: "#4789d0"


//////// relorder to give priority to errors
		values: [
			TileText {
				text: systemName.valid && systemName.value !== "" ? systemName.value : sys.systemType.valid ? sys.systemType.value.toUpperCase() : ""
				font.pixelSize: 20
				wrapMode: Text.WordWrap
				width: statusTile.width
			},
			TileText {
				text: wallClock.running ? wallClock.time : ""
				font.pixelSize: 20
			},
			TileText {
				id: reasonText
				text: qsTr(systemState.text)

				SystemState {
					id: systemState
					bind: hasSystemState?Utils.path(systemPrefix, "/SystemState/State"):Utils.path(inverterService, "/State")
				}
			},

//////// combine SystemReason with notifications
			MarqueeEnhanced {
				text:
				{
					if (activeNotifications.length === 0)
						return systemReasonMessage.text
					else
						return notificationText() + " || " + systemReasonMessage.text
				}
				width: statusTile.width
				height: reasonText.height
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
					if (speedUnit.value === "km/h")
						return (speed.value * 3.6).toFixed(1) + speedUnit.value
					if (speedUnit.value === "mph")
						return (speed.value * 2.236936).toFixed(1) + speedUnit.value
					if (speedUnit.value === "kt")
						return (speed.value * (3600/1852)).toFixed(1) + speedUnit.value
					return speed.value.toFixed(2) + "m/s"
				}
			},
			TileText
			{
				text: inverterMode.valid ? inverterMode.text : "--"
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
			show: showGauges
		}
	} // end Tile STATUS

Tile {
	title: qsTr("BATTERY")
	id: batteryTile
	anchors { horizontalCenter: infoArea.horizontalCenter; top: infoArea.top }
	width: root.infoWidth3Column
	height: root.statusHeight

	values: [
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
			},
			TileText {
				text: sys.battery.voltage.format(2) + "   " + sys.battery.current.format(1)
			},
			TileText {
				text: qsTr("Remaining:")
			},
			TileText {
				text: timeToGo.valid ? TTG.formatTimeToGo (timeToGo) : "∞"
				
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
			anchors
			{
				top: parent.top; topMargin: 20
				horizontalCenter: parent.horizontalCenter
			}
			show: showGauges
		}
	} // end Tile BATTERY

	Tile {  // DC SYSTEM
////// use title to reflect load or source from DC system
	    title: qsTr("DC SYSTEM")
	    id: dcSystem
	    anchors { right: infoArea.right; bottom: infoArea.bottom; bottomMargin: root.acTileHeight }
	    width: root.infoWidth3Column
	    height: 70
	    color: "#16a085"

	    VBusItem {
		id: hasDcSys
		bind: Utils.path(settingsBindPreffix, "/Settings/SystemSetup/HasDcSystem")
	    }

	    values: [
			TileText {
				font.pixelSize: 22
				text: sys.dcSystem.power.format(0)
				visible: sys.dcSystem.power.valid
			},
			TileText {
						text: !sys.dcSystem.power.valid ? "---" :
	////// replace to/from battery with current
							 (sys.dcSystem.power.value / sys.battery.voltage.value).toFixed(1) + "A"
						visible: sys.dcSystem.power.valid
			}
		]
	} // end Tile DC SYSTEM

	Tile {
	    id: solarTile
	    title: qsTr("PV CHARGER")
	    anchors { right: infoArea.right; top: infoArea.top }
	    width: root.infoWidth3Column
	    height: root.statusHeight - dcSystem.height
	    color: "#2cc36b"
	    values: [
            TileText {
                font.pixelSize: 22
                text: sys.pvCharger.power.valid ? sys.pvCharger.power.text : "none"
            },
    //////// add voltage and current
            TileText {
                text: showPvVI ? pvVoltage.value.toFixed(1) + "V" + " "
						+ (pvPower.value / pvVoltage.value).toFixed(1) + "A" : ""
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
            show: showGauges && sys.pvCharger.power.valid
        }
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
		VBusItem { id: inVoltage; bind: Utils.path(inverterService, "/Ac/ActiveIn/L1/V") }
		VBusItem { id: inCurrent; bind: Utils.path(inverterService, "/Ac/ActiveIn/L1/I") }
		VBusItem { id: inFrequency; bind: Utils.path(inverterService, "/Ac/ActiveIn/L1/F") }
		VBusItem { id: currentLimit; bind: Utils.path(inverterService, "/Ac/ActiveIn/CurrentLimit") }
		values: [
			TileText {
				visible: isMulti
				text: sys.acInput.power.text
				font.pixelSize: 20
				
			},
//////// add voltage and current
			TileText {
				visible: isMulti
				text: inVoltage.text + "  " + inCurrent.text + "  " + inFrequency.text
			},
			TileText
			{
				text: qsTr ("Limit: ") + currentLimit.text
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
			maxForwardPowerParameter: "" // handled internally - uses input current limit and AC input voltage
			maxReversePowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxFeedInPower"
			show: showGauges && hasAcInput
		}
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
				text: sys.acLoad.power.text
				font.pixelSize: 22
			},
//////// add voltage and current - no frequency for VE.Direct inverter
			TileText {
				text: isMulti ? outVoltage.text + "  " + outCurrent.text + "  " + outFrequency.text
						: isInverter ? outVoltage.text + "  " + outCurrent.text : ""
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
			show: showGauges && hasAcOutSystem
		}
	}

    // Synchronise tank name text scroll start
    Timer {
        id: scrollTimer
        interval: 15000
        repeat: true
//////// modified to control compact differently
        running: root.active && root.compact
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

	Keys.forwardTo: [keyHandler]

	Item {
		id: keyHandler
		Keys.onLeftPressed: {
			if (buttonIndex > 0)
				buttonIndex--

			event.accepted = true
		}

		Keys.onRightPressed: {
            var lastButton = pumpButton.pumpEnabled ? 2 : 1
            ++buttonIndex
            if (buttonIndex > lastButton)
				buttonIndex = lastButton

			event.accepted = true
		}
	}

	Tile {
        id: pumpButton

        anchors.right: parent.right
        anchors.bottom: parent.bottom

        property variant texts: [ qsTr("AUTO"), qsTr("ON"), qsTr("OFF")]
        property int value: 0
        property bool reset: false
        property bool pumpEnabled: pumpRelay.value === 3
        isCurrentItem: (buttonIndex == 2)
        focus: root.active && isCurrentItem

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

        Keys.onSpacePressed: edit()

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
                buttonIndex = 2
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
            onCompleted: if (!pumpButton.reset) pump.setValue(pumpButton.value)
		}
	}

	// When new service is found add resources as appropriate
	Connections {
		target: DBusServices
		onDbusServiceFound: addService(service)
	}

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
            if (pvChargerPrefix === "")
                pvChargerPrefix = service.name;
            break;;
        }
    }

    // Check available services to find tank sesnsors
//////// rewrite to always call addService, removing redundant service type checks
    function discoverServices()
    {
        numberOfTemps = 0
        numberOfPvChargers = 0
        numberOfMultis = 0
        numberOfInverters = 0
        inverterService = ""
        tempsModel.clear()
        for (var i = 0; i < DBusServices.count; i++)
                addService(DBusServices.at(i))
    }

	function notificationText()
	{
		if (activeNotifications.length === 0)
			return qsTr("")

		var descr = []
		for (var n = 0; n < activeNotifications.length; n++) {
			var notification = activeNotifications[n];

			var text = notification.serviceName + " - " + notification.description;
			if (notification.value !== "" )
				text += ":  " + notification.value

			descr.push(text)
		}

		return descr.join("  |  ")
	}

	VBusItem { id: dmc; bind: Utils.path(inverterService, "/Devices/Dmc/Version") }
	VBusItem { id: bms; bind: Utils.path(inverterService, "/Devices/Bms/Version") }

//////// TANK REPEATER - add to hide the service for the physical sensor
    VBusItem { id: incomingTankName;
        bind: Utils.path(settingsBindPreffix, "/Settings/Devices/TankRepeater/IncomingTankService") }
//////// TANK REPEATER - end add



// Details targets
    MouseArea
    {
        id: multiTarget
        anchors.centerIn: statusTile
        enabled: parent.active
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailInverter.qml", {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets && (isMulti || isInverter)
        }
    }
    MouseArea
    {
        id: acInputTarget
        anchors.centerIn: acInputTile
        enabled: parent.active && hasAcInput
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailAcInput.qml",
                        {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets && hasAcInput
        }
    }
    MouseArea
    {
        id: acLoadsOnOutputTarget
        anchors.centerIn: acLoadsTile
        enabled: parent.active && hasAcOutSystem
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailLoadsOnOutput.qml",
                    {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets && hasAcOutSystem
        }
    }
   MouseArea
    {
        id: pvChargerTarget
        anchors.centerIn: solarTile
        enabled: parent.active && sys.pvCharger.power.valid
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailPvCharger.qml",
                    {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets
        }
    }
    MouseArea
    {
        id: batteryTarget
        anchors.centerIn: batteryTile
        enabled: parent.active
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailBattery.qml",
                    {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets
        }
    }
    MouseArea
    {
        id: dcTarget
        anchors.centerIn: dcSystem
        enabled: parent.active
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailDcSystem.qml",
                    {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets
        }
    }
////// display detail targets and help message when first displayed.
    Timer {
        id: helpTimer
        running: false
        repeat: false
        interval: 5000
        triggeredOnStart: true
    }

    // help message shown when menu is first drawn //////////////////////////
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
        visible: showTargets
    }
    TileText
    {
        text: qsTr ( "Tap tile center for detail at any time" )
        color: "black"
        anchors.fill: helpBox
        wrapMode: Text.WordWrap
        font.pixelSize: 12
        show: showTargets
    }
}
