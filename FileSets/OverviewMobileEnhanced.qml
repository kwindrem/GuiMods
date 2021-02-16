// Enhancements to OverviewMobile screen

// This version supports Venus versions 2.4, 2.5 and 2.60
// Removed logo and added AC INPUT and SYSTEM tiles originally displayed on other overviews
// Added voltage, current and frequency to AC INPUT and AC LOADS tiles
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

// Includes changes to handle SeeLevel NMEA2000 tank sensor:
// Ignore the real incoming tank dBus service because it's information changes
// Changes in TileText.qml are also part of the TankRepeater  package

// Search for //////// TANK REPEATER to find changes

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
    property int numberOfMultis: 0
    property string vebusPrefix: ""
    
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

                running: true
                repeat: true
                interval: 1000
                triggeredOnStart: true
//////// change time to 12 hour format
                onTriggered: time = Qt.formatDateTime(new Date(), "h:mm ap")

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
                    text: wallClock.time
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
                        bind: hasSystemState?Utils.path(systemPrefix, "/SystemState/State"):Utils.path(sys.vebusPrefix, "/State")
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
                            return "> 10d"
                        }
                        
                        VBusItem {
                            id: timeToGo
                            bind: Utils.path("com.victronenergy.system","/Dc/Battery/TimeToGo")
                        }
                    }
                ]
            } // end Tile BATTERY

	Tile {
	    title: qsTr("DC SYSTEM")
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
	    text: hasDcSys.value === 1 ? sys.dcSystem.power.format(0) : "none"
		},
		TileText {
                    text: !sys.dcSystem.power.valid ? "---" :
                          sys.dcSystem.power.value < 0 ? qsTr("to battery") : qsTr("from battery")
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
                    text: numberOfPvChargers === 1 ? pvVoltage.text + " " + pvCurrent.text : ""
                    visible: sys.pvCharger.power.valid
                }
            ]
	} // end Tile PV CHARGER

//////// add AC INPUT tile
        Tile {
            title: qsTr("AC INPUT")
            id: acInputTile
            anchors { left: parent.left; bottom: parent.bottom }
            width: root.infoWidth2Column
            height: root.infoTileHeight
            color: "#82acde"
//////// add voltage and current
            VBusItem { id: inVoltage; bind: Utils.path(vebusPrefix, "/Ac/ActiveIn/L1/V") }
            VBusItem { id: inCurrent; bind: Utils.path(vebusPrefix, "/Ac/ActiveIn/L1/I") }
            VBusItem { id: inFrequency; bind: Utils.path(vebusPrefix, "/Ac/ActiveIn/L1/F") }
            values: [
                TileText {
                    text: sys.acInput.power.uiText
                    font.pixelSize: 22
                },
//////// add voltage and current
                TileText {
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
            VBusItem { id: outVoltage; bind: Utils.path(vebusPrefix, "/Ac/Out/L1/V") }
            VBusItem { id: outCurrent; bind: Utils.path(vebusPrefix, "/Ac/Out/L1/I") }
            VBusItem { id: outFrequency; bind: Utils.path(vebusPrefix, "/Ac/Out/L1/F") }

            values: [
                TileText {
                    text: sys.acLoad.power.uiText
                    font.pixelSize: 22
                },
//////// add voltage and current
                TileText {
                    text: outVoltage.text + "  " + outCurrent.text + "  " + outFrequency.text
                }
            ]
        }

    } // end ListView infoArea

    ListView {
        id: tanksColum

        property int tankTileHeight: Math.ceil(height / Math.max(count, 2))
//////// change - group layout parameters in one place
        width: root.tankWidth
        interactive: false // static tiles

		model: tanksModel
		delegate: TileTank {
			width: tanksColum.width
			height: tanksColum.tankTileHeight
			pumpBindPrefix: root.pumpBindPreffix
		}

		anchors {
			top: root.top
			bottom: pumpButton.pumpEnabled ? acModeButton.top : acModeButton.bottom
			right: root.right
		}

		Tile {
			title: qsTr("TANKS")
			anchors.fill: parent
			values: TileText {
				text: qsTr("No tanks found")
				width: parent.width
				wrapMode: Text.WordWrap
			}
			z: -1
		}
	}

	ListModel {
		id: tanksModel
	}

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

	TileSpinBox {
        title: qsTr("AC CURRENT LIMIT")
		id: acCurrentButton

		anchors.bottom: parent.bottom
		anchors.left: parent.left
		isCurrentItem: (buttonIndex == 0)
		focus: root.active && isCurrentItem

		bind: Utils.path(vebusPrefix, "/Ac/ActiveIn/CurrentLimit")
		color: containsMouse && !editMode ? "#d3d3d3" : "#A8A8A8"
		width: show ? root.infoWidth2Column : 0
		fontPixelSize: 14
		unit: "A"
		readOnly: currentLimitIsAdjustable.value !== 1 || numberOfMultis > 1
		buttonColor: "#979797"

		VBusItem { id: currentLimitIsAdjustable; bind: Utils.path(vebusPrefix, "/Ac/ActiveIn/CurrentLimitIsAdjustable") }

		Keys.onSpacePressed: showErrorToast(event)

		function editIsAllowed() {
			if (numberOfMultis > 1) {
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
		property variant texts: { 4: qsTr("OFF"), 3: qsTr("ON"), 1: qsTr("CHARGER ONLY"), 2: qsTr("INVERTER ONLY") }
		property int value: mode.valid ? mode.value : 3
        property int shownValue: applyAnimation2.running ? applyAnimation2.pendingValue : value

		isCurrentItem: (buttonIndex == 1)
		focus: root.active && isCurrentItem

		editable: true
		readOnly: !modeIsAdjustable.valid || modeIsAdjustable.value !== 1 || numberOfMultis > 1
		width: root.infoWidth2Column
		height: buttonRowHeight
		color: acModeButtonMouseArea.containsPressed ? "#d3d3d3" : "#A8A8A8"
		title: qsTr("AC MODE")

		values: [
			TileText {
                text: modeIsAdjustable.valid && numberOfMultis === 1 ? qsTr("%1").arg(acModeButton.texts[acModeButton.shownValue]) : qsTr("NOT AVAILABLE")
			}
		]

		VBusItem { id: mode; bind: Utils.path(vebusPrefix, "/Mode") }
		VBusItem { id: modeIsAdjustable; bind: Utils.path(vebusPrefix,"/ModeIsAdjustable") }

		Keys.onSpacePressed: edit()

		function edit() {
			if (!mode.valid)
				return

			if (numberOfMultis > 1) {
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

            switch (shownValue) {
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
            onCompleted: if (!acModeButton.reset) mode.setValue(acModeButton.value)

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
		height: buttonRowHeight
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

	function addService(service)
	{
		var name = service.name
		if (service.type === DBusService.DBUS_SERVICE_TANK) {
//////// TANK REPEATER - add to hide the service for the physical sensor
            if (name !== incomingTankServiceName) // hide incoming N2K tank dBus object
//////// TANK REPEATER - end add
                tanksModel.append({serviceName: service.name})
		}
        if (service.type === DBusService.DBUS_SERVICE_MULTI) {
            numberOfMultis++
            if (vebusPrefix === "")
                vebusPrefix = name;
        }
//////// add for PV CHARGER voltage and current display
        if (service.type === DBusService.DBUS_SERVICE_SOLAR_CHARGER) {
            numberOfPvChargers++
            if (pvChargerPrefix === "")
                pvChargerPrefix = name;
        }
	}

	// Check available services to find tank sesnsors
//////// also adds info for Muitls and PV Chargers
	function discoverTanks()
	{
//////// TANK REPEATER - add this
        incomingTankServiceName = incomingTankName.valid ? incomingTankName.value : ""
//////// TANK REPEATER - end add this
		tanksModel.clear()
		for (var i = 0; i < DBusServices.count; i++) {
			if (DBusServices.at(i).type === DBusService.DBUS_SERVICE_TANK) {
				addService(DBusServices.at(i))
			}
            if (DBusServices.at(i).type === DBusService.DBUS_SERVICE_MULTI) {
                addService(DBusServices.at(i))
            }
//////// add for PV CHARGER voltage and current display
            if (DBusServices.at(i).type === DBusService.DBUS_SERVICE_SOLAR_CHARGER) {
                addService(DBusServices.at(i))
            }
		}
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

	VBusItem { id: dmc; bind: Utils.path(vebusPrefix, "/Devices/Dmc/Version") }
	VBusItem { id: bms; bind: Utils.path(vebusPrefix, "/Devices/Bms/Version") }

//////// TANK REPEATER - add to hide the service for the physical sensor
    property string incomingTankServiceName: ""
    VBusItem { id: incomingTankName;
        bind: Utils.path(settingsBindPreffix, "/Settings/Devices/TankRepeater/IncomingTankService") }
//////// TANK REPEATER - end add
}
