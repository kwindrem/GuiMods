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

OverviewPage {
    title: qsTr("Mobile")
    id: root

    property variant sys: theSystem
    property string settingsBindPreffix: "com.victronenergy.settings"
    property string pumpBindPreffix: "com.victronenergy.pump.startstop0"
    property variant activeNotifications: NotificationCenter.notifications.filter(
											  function isActive(obj) { return obj.active} )
    property string noAdjustableByDmc: qsTr("This setting is disabled when a Digital Multi Control " +
											"is connected. If it was recently disconnected execute " +
											"\"Redetect system\" that is avalible on the inverter menu page.")
    property string noAdjustableByBms: qsTr("This setting is disabled when a VE.Bus BMS " +
											"is connected. If it was recently disconnected execute " +
											"\"Redetect system\" that is avalible on the inverter menu page.")
    property string noAdjustableTextByConfig: qsTr("This setting is disabled. " +
										   "Possible reasons are \"Overruled by remote\" is not enabled or " +
										   "an assistant is preventing the adjustment. Please, check " +
										   "the inverter configuration with VEConfigure.")

//////// added to keep track of tanks and temps
    property int numberOfTanks: 0
    property int numberOfTemps: 0
    property int tankTempCount: numberOfTanks + numberOfTemps
    property real tanksTempsHeight: root.height - (pumpButton.pumpEnabled ? buttonRowHeight : 0)
    property real tanksHeight: numberOfTanks > 0 ? tanksTempsHeight * numberOfTanks / tankTempCount : 0
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
    property bool isMulti: numberOfMultis > 0
    property bool isInverter: !isMulti && numberOfInverters > 0
    
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
    property int infoTilesCount: 3
    property int buttonRowHeight: 45    // must match TileSpinBox height used on AC CURRENT LIMIT
    property int tankWidth: 130

    property int infoTileHeight: Math.ceil((height - buttonRowHeight) / infoTilesCount)
    property int infoTile2High: (infoTileHeight * 2) - 1
    
    property int infoWidth: width - tankWidth
    property int infoWidth3Column: infoWidth / 3
    property int infoWidth2Column: infoWidth / 2

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

	Component.onCompleted: discoverTanks()

    ListView {
        id: infoArea
        interactive: false // static tiles

        anchors {
            left: parent.left
            right: tanksColum.left
			top: parent.top;
			bottom: acModeButton.top;
        }

//////// copied SYSTEM from OverviewTiles.qml & combined SYSTEM and STATUS tiles
        Tile {
            title: qsTr("STATUS")
            id: statusTile
            anchors { left: parent.left; top: parent.top }
            width: root.infoWidth3Column
            height: root.infoTile2High
            color: "#4789d0"

            VBusItem{
                id: systemName
                bind: Utils.path(settingsBindPreffix, "/Settings/SystemSetup/SystemName")
            }

            Timer {
                id: wallClock
                running: timeFormat != ""
                repeat: true
                interval: 1000
                triggeredOnStart: true
//////// change time to 12 hour format
                onTriggered: time = Qt.formatDateTime(new Date(), timeFormat)
                property string time
            }
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
//////// spacer to separate Multi mode from system name
                TileText {
                    text: " "
                    font.pixelSize: 4
                },
                TileText {
                    text: qsTr(systemState.text)

                    SystemState {
                        id: systemState
                        bind: hasSystemState?Utils.path(systemPrefix, "/SystemState/State"):Utils.path(inverterService, "/State")
                    }
                },

//////// combine SystemReason with notifications
                Marquee {
                    text:
                    {
                        if (activeNotifications.length === 0)
                            return systemReasonMessage.text
                        else
                            return notificationText() + " || " + systemReasonMessage.text
                    }
                    width: statusTile.width
                    interval: 100
                    SystemReasonMessage {
                        id: systemReasonMessage
                    }
                }
//////// remove speed to make more room
            ]
        } // end Tile STATUS

        Tile {
            title: qsTr("BATTERY")
            id: batteryTile
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top }
            width: root.infoWidth3Column
            height: root.infoTile2High

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
                        text: sys.battery.voltage.format(1) + "   " + sys.battery.current.format(1)
                    },
                    TileText {
                        text: qsTr("Remaining:")
                    },
                    TileText {
                        text: {
                            if (timeToGo.valid)
                                return Utils.secondsToString(timeToGo.value)
                            else
                                return "∞"
                        }
                        
                        VBusItem {
                            id: timeToGo
                            bind: Utils.path("com.victronenergy.system","/Dc/Battery/TimeToGo")
                        }
                    }
                ]
            } // end Tile BATTERY

	Tile {  // DC SYSTEM
////// use title to reflect load or source from DC system
	    title: qsTr(hasDcSys.value != 1 ? "NO DC SYSTEM": 
                !sys.dcSystem.power.valid ? "NO DC POWER" : sys.dcSystem.power.value >= 0 ? "DC LOADS" : "DC CHARGER")
	    id: dcSystem
	    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
	    width: root.infoWidth3Column
	    height: root.infoTileHeight
	    color: "#16a085"

	    VBusItem {
		id: hasDcSys
		bind: Utils.path(settingsBindPreffix, "/Settings/SystemSetup/HasDcSystem")
	    }

	    values: [
		TileText {
		    font.pixelSize: 22
            text: sys.dcSystem.power.format(0)
            visible: hasDcSys.value === 1
		},
		TileText {
                    text: !sys.dcSystem.power.valid ? "---" :
////// replace to/from battery with current
                         (sys.dcSystem.power.value / sys.battery.voltage.value).toFixed(1) + "A"
                    visible: hasDcSys.value === 1
                }
            ]
	} // end Tile DC SYSTEM

	Tile {
	    id: solarTile
	    title: qsTr("PV CHARGER")
	    anchors { right: parent.right; top: parent.top }
	    width: root.infoWidth3Column
	    height: root.infoTileHeight
	    color: "#2cc36b"
//////// add voltage and current
	    VBusItem { id: pvCurrent; bind: Utils.path(pvChargerPrefix, "/Pv/I") }
	    VBusItem { id: pvVoltage;  bind: Utils.path(pvChargerPrefix, "/Pv/V") }
	    values: [
            TileText {
                font.pixelSize: 22
                text: sys.pvCharger.power.valid ? sys.pvCharger.power.uiText : "none"
            },
    //////// add voltage and current
            TileText {
                text: numberOfPvChargers > 0 ? pvVoltage.text + " " + pvCurrent.text : ""
                visible: numberOfPvChargers > 0 && pvVoltage.valid && pvCurrent.valid
            }
        ]
	} // end Tile PV CHARGER

//////// add AC INPUT tile
        Tile {
            title: {
                if (isInverter)
                    return qsTr ("No AC Input")
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
            id: acInputTile
            anchors { left: parent.left; bottom: parent.bottom }
            width: root.infoWidth2Column
            height: root.infoTileHeight
            color: "#82acde"
//////// add voltage and current
            VBusItem { id: inVoltage; bind: Utils.path(inverterService, "/Ac/ActiveIn/L1/V") }
            VBusItem { id: inCurrent; bind: Utils.path(inverterService, "/Ac/ActiveIn/L1/I") }
            VBusItem { id: inFrequency; bind: Utils.path(inverterService, "/Ac/ActiveIn/L1/F") }
            values: [
                TileText {
                    visible: isMulti
                    text: sys.acInput.power.uiText
                    font.pixelSize: 22
                },
//////// add voltage and current
                TileText {
                    visible: isMulti
                    text: inVoltage.text + "  " + inCurrent.text + "  " + inFrequency.text
                }
            ]
        }

        Tile {
            title: qsTr("AC LOADS")
            id: acLoadsTile
            anchors { right: parent.right; bottom: parent.bottom}
            width: root.infoWidth2Column
            height: root.infoTileHeight
            color: "#e68e8a"
//////// add voltage and current
            VBusItem { id: outVoltage; bind: Utils.path(inverterService, "/Ac/Out/L1/V") }
            VBusItem { id: outCurrent; bind: Utils.path(inverterService, "/Ac/Out/L1/I") }
            VBusItem { id: outFrequency; bind: Utils.path(inverterService, "/Ac/Out/L1/F") }

            values: [
                TileText {
                    text: sys.acLoad.power.uiText
                    font.pixelSize: 22
                },
//////// add voltage and current - no frequency for VE.Direct inverter
                TileText {
                    text: isMulti ? outVoltage.text + "  " + outCurrent.text + "  " + outFrequency.text
                            : isInverter > 0 ? outVoltage.text + "  " + outCurrent.text : ""
                }
            ]
        }
    } // end ListView infoArea

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

        model: tanksModel
        delegate: TileTank {
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
    ListModel { id: tanksModel }

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

	MouseArea {
		anchors.fill: parent
		enabled: parent.active
		onPressed: mouse.accepted = acCurrentButton.expanded
		onClicked: acCurrentButton.cancel()
	}

//////// add for VE.Direct inverters - no current limit
    Tile
    {
        title: qsTr("AC CURRENT LIMIT")
        id: acCurrentButtonDisabled
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        color: "#A8A8A8"
        visible: isInverter
        width: root.infoWidth2Column
        height: buttonRowHeight
        values:
        [
            TileText
            {
                text: qsTr("NOT AVAILABLE")
            }
        ]
    }

	TileSpinBox {
        title: qsTr("AC CURRENT LIMIT")
		id: acCurrentButton
        visible: !isInverter

		anchors.bottom: parent.bottom
		anchors.left: parent.left
		isCurrentItem: (buttonIndex == 0)
		focus: root.active && isCurrentItem

		bind: Utils.path(inverterService, "/Ac/ActiveIn/CurrentLimit")
		color: containsMouse && !editMode ? "#d3d3d3" : "#A8A8A8"
		width: show ? root.infoWidth2Column : 0
		fontPixelSize: 14
		unit: "A"
		readOnly: isMulti || currentLimitIsAdjustable.value !== 1
		buttonColor: "#979797"

		VBusItem { id: currentLimitIsAdjustable; bind: Utils.path(inverterService, "/Ac/ActiveIn/CurrentLimitIsAdjustable") }

		Keys.onSpacePressed: showErrorToast(event)

		function editIsAllowed() {
			if (isMulti) {
				toast.createToast(qsTr("It is not possible to change this setting when there are more than one inverter connected."), 5000)
				return false
			}

			if (currentLimitIsAdjustable.value === 0) {
				if (dmc.valid) {
					toast.createToast(noAdjustableByDmc, 5000)
					return false
				}
				if (bms.valid) {
					toast.createToast(noAdjustableByBms, 5000)
					return false
				}
				if (!dmc.valid && !bms.valid) {
					toast.createToast(noAdjustableTextByConfig, 5000)
					return false
				}
			}

			return true
		}

		function showErrorToast(event) {
			editIsAllowed()
			event.accepted = true
		}
	}

	Tile {
		id: acModeButton
		anchors.left: acCurrentButton.right
		anchors.bottom: parent.bottom
  //////// add VE.Direct inverter modes      
        property variant texts: { 4: qsTr("OFF"), 3: qsTr("ON"), 1: qsTr("CHARGER ONLY"), 2: qsTr("INVERTER ONLY") }
        property variant inverterTexts: { 4: qsTr("OFF"), 2: qsTr("ON"), 5: qsTr("ECO") }
		property int value: mode.valid ? mode.value : 3
        property int shownValue: applyAnimation2.running ? applyAnimation2.pendingValue : value

		isCurrentItem: (buttonIndex == 1)
		focus: root.active && isCurrentItem

		editable: true
        readOnly:
        {
            if (isMulti)
                return !modeIsAdjustable.valid || modeIsAdjustable.value !== 1
            else if (isInverter)
                return false
            else
                return true
        }
		width: root.infoWidth2Column
		height: buttonRowHeight
		color: acModeButtonMouseArea.containsPressed ? "#d3d3d3" : "#A8A8A8"
		title: qsTr("AC MODE")

		values: [
			TileText {
                text:
                {
                    if (isMulti)
                    {
                        if (modeIsAdjustable.valid)
                            return qsTr("%1").arg(acModeButton.texts[acModeButton.shownValue])
                        else
                            return qsTr("NOT AVAILABLE")
                    }
                    else if (isInverter)
                    {
                            return qsTr("%1").arg(acModeButton.inverterTexts[acModeButton.shownValue])
                    }
                    else
                        return qsTr("NOT AVAILABLE")
                }
            }
		]

		VBusItem { id: mode; bind: Utils.path(inverterService, "/Mode") }
		VBusItem { id: modeIsAdjustable; bind: Utils.path(inverterService,"/ModeIsAdjustable") }

		Keys.onSpacePressed: edit()

		function edit() {
			if (!mode.valid)
				return

			if (isMulti) {
				toast.createToast(qsTr("It is not possible to change this setting when there are more than one inverter connected."), 5000)
				return
			}


			if (modeIsAdjustable.value === 0) {
				if (dmc.valid)
					toast.createToast(noAdjustableByDmc, 5000)
				if (bms.valid)
					toast.createToast(noAdjustableByBms, 5000)
				if (!dmc.valid && !bms.valid)
					toast.createToast(noAdjustableTextByConfig, 5000)
				return
			}

//////// add/modified for VE.Direct inverter
            // Multi/Quatro (inverter/charger)
            if (isMulti)
            {
                switch(shownValue) {
                case 4:
                    applyAnimation2.pendingValue = 3
                    break;
                case 3:
                    applyAnimation2.pendingValue = 1
                    break;
                case 1:
     //////// modify to add inverter only (was = 4)
                    applyAnimation2.pendingValue = 2
                    break;
    //////// add case 2 (inverter only)
                case 2:
                    applyAnimation2.pendingValue = 4
                    break;
                }
            }
            // VE.Direct inverter
            else if (isInverter)
            {
                switch(shownValue)
                {
                // On (and Inverter Only) to Eco
                case 2:
                case 3:
                    applyAnimation2.pendingValue = 5
                    break;
                // Off to On
                case 4:
                    applyAnimation2.pendingValue = 2
                    break;
                // ay other state to Off
                default:
                    applyAnimation2.pendingValue = 4
                    break;
                }
            }

            applyAnimation2.restart()
		}

		MouseArea {
			id: acModeButtonMouseArea
			anchors.fill: parent
			property bool containsPressed: containsMouse && pressed
			onClicked:  {
				buttonIndex = 1
				parent.edit()
			}
		}

		Rectangle {
			id: timerRect2
			height: 2
			width: acModeButton.width * 0.8
			visible: applyAnimation2.running
			anchors {
				bottom: parent.bottom; bottomMargin: 5
				horizontalCenter: parent.horizontalCenter
			}
		}

		SequentialAnimation {
			id: applyAnimation2
            property int pendingValue

            NumberAnimation {
				target: timerRect2
				property: "width"
				from: 0
				to: acModeButton.width * 0.8
				duration: 3000
			}

			ColorAnimation {
				target: acModeButton
				property: "color"
				from: "#A8A8A8"
				to: "#4789d0"
				duration: 200
			}

			ColorAnimation {
				target: acModeButton
				property: "color"
				from: "#4789d0"
				to: "#A8A8A8"
				duration: 200
			}
			PropertyAction {
				target: timerRect2
				property: "width"
				value: 0
			}
            ScriptAction { script: mode.setValue(applyAnimation2.pendingValue) }

            PauseAnimation { duration: 1000 }
		}
	}

	Tile {
        id: pumpButton

        anchors.left: acModeButton.right
        anchors.bottom: parent.bottom

        property variant texts: [ qsTr("AUTO"), qsTr("ON"), qsTr("OFF")]
        property int value: 0
        property bool reset: false
        property bool pumpEnabled: pumpRelay.value === 3
        isCurrentItem: (buttonIndex == 2)
        focus: root.active && isCurrentItem

        title: qsTr("PUMP")
        width: show && pumpEnabled ? root.tankWidth : 0
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

	// When new service is found check if is a tank sensor
	Connections {
		target: DBusServices
		onDbusServiceFound: addService(service)
	}

//////// rewrite to use switch in place of if statements
    function addService(service)
    {
        switch (service.type)
        {
        case DBusService.DBUS_SERVICE_TANK:
            // hide incoming N2K tank dBus object if TankRepeater is running
            if ( ! incomingTankName.valid || incomingTankName.value !== service.name)
            {
                numberOfTanks++
                tanksModel.append({serviceName: service.name})
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
            if (pvChargerPrefix === "")
                pvChargerPrefix = service.name;
            break;;
        }
    }

    // Check available services to find tank sesnsors
//////// rewrite to always call addService, removing redundant service type checks
    function discoverTanks()
    {
        numberOfTemps = 0
        numberOfPvChargers = 0
        numberOfMultis = 0
        numberOfInverters = 0
        inverterService = ""
        tanksModel.clear()
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
}
