//////// MODIFIED to:
////////    use common flow overview for all systems
////////    all source and load tiles: gauge plus total power (no individual leg values, no voltage, etc)
//////  tanks and temps in a row along bottom
//////  time of day
//////  detail popups for all tiles
//////  remaining time in Battery tile

import QtQuick 1.1
import "utils.js" as Utils
////// ADDED to show tanks
import com.victron.velib 1.0

OverviewPage {
	id: root
 
    property real touchTargetOpacity: 0.3
	property variant sys: theSystem
	property bool hasAcOutSystem: _hasAcOutSystem.value === 1
    property color detailColor: "#b3b3b3"
 
 //////
    property int inOutTileHeight: (root.height - bottomOffset - 3 * 5) / 4
    property int inOutTileWidth: 145
    property int touchArea: 40
    VBusItem { id: timeToGo;  bind: Utils.path("com.victronenergy.system","/Dc/Battery/TimeToGo") }

//////// add for VE.Direct inverters
    property int numberOfMultis: 0
    property int numberOfInverters: 0
    property string inverterService: ""
    property bool isMulti: numberOfMultis === 1
    property bool hasInverter: isMulti || numberOfInverters === 1
    property bool hasAcInput: isMulti || hasPvOnGrid
    property bool combineAcLoads: _combineAcLoads.valid && _combineAcLoads.value === 1
    property variant outputLoad: combineAcLoads ? sys.acLoad : sys.acOutLoad
    property bool hasLoadsOnInput: hasAcInput &&! combineAcLoads && (! showLoadsOnInput.valid || showLoadsOnInput.value === 1)
    property bool hasLoadsOnOutput: hasInverter
    property bool hasPvOnGrid: sys.pvOnGrid.power.valid
    property bool hasPvOnOutput: sys.pvOnAcOut.power.valid
    property bool hasPvCharger: sys.pvCharger.power.valid
    property bool hasDcSystem: hasDcSys.value > 0
    
    property bool showTargets: helpTimer.running

////// ADDED to show tanks
    property int bottomOffset: showTanksTemps ? 45 : 5
    property string settingsBindPreffix: "com.victronenergy.settings"
    property string pumpBindPreffix: "com.victronenergy.pump.startstop0"
    property int numberOfTemps: 0
//////// added/modified for control show/hide gauges, tanks and temps from menus
    property int tankCount: showTanksEnable ? tankModel.rowCount : 0
    property int tempCount: showTempsEnable ? numberOfTemps : 0
    property int tankTempCount: tankCount + tempCount
    property bool showTanks: showTanksEnable ? showStatusBar ? false : tankCount > 0 ? true : false : false
    property bool showTemps: showTempsEnable ? showStatusBar ? false : tempCount > 0 ? true : false : false
    property bool showTanksTemps: showTanks || showTemps
    property int compactThreshold: 45   // height below this will be compacted vertically
    property int batteryHeight: 91
    property bool compact: showTanks && showTemps && tankTempCount > 4
    property int tanksHeight: compact ? 22 : 45

    property string guiModsPrefix: "com.victronenergy.settings/Settings/GuiMods"
    VBusItem { id: showGaugesItem; bind: Utils.path(guiModsPrefix, "/ShowGauges") }
    property bool showGauges: showGaugesItem.valid ? showGaugesItem.value === 1 ? true : false : false
    VBusItem { id: showTanksItem; bind: Utils.path(guiModsPrefix, "/ShowEnhancedFlowOverviewTanks") }
    property bool showTanksEnable: showTanksItem.valid ? showTanksItem.value === 1 ? true : false : false
    VBusItem { id: showTempsItem; bind: Utils.path(guiModsPrefix, "/ShowEnhancedFlowOverviewTemps") }
    property bool showTempsEnable: showTempsItem.valid ? showTempsItem.value === 1 ? true : false : false

    VBusItem { id: showInactiveTiles; bind: Utils.path(guiModsPrefix, "/ShowInactiveFlowTiles") }
    property real disabledTileOpacity: ! showInactiveTiles.valid || showInactiveTiles.value === 1 ? 0.3 : showInactiveTiles.value === 2 ? 1.0 : 0.0

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

    Component.onCompleted: { discoverServices(); helpTimer.running = true }

	title: qsTr("Overview")

    VBusItem {
        id: _hasAcOutSystem
        bind: "com.victronenergy.settings/Settings/SystemSetup/HasAcOutSystem"
    }
    VBusItem { id: showLoadsOnInput; bind: "com.victronenergy.settings/Settings/GuiMods/ShowEnhancedFlowLoadsOnInput" }
    VBusItem { id: _combineAcLoads; bind: "com.victronenergy.settings/Settings/GuiMods/EnhancedFlowCombineLoads" }
 
	OverviewBox {
		id: acInBox
        opacity: hasAcInput ? 1 : disabledTileOpacity
		width: inOutTileWidth
		height: inOutTileHeight
		title: getAcSourceName(sys.acSource)
		titleColor: "#E74c3c"
		color: "#C0392B"
		anchors {
			top: root.top; topMargin: 1
			left: parent.left; leftMargin: 5
		}

		values:	OverviewAcValuesEnhancedGP {
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
            id: acInGauge
            width: parent.width
            height: 15
            anchors
            {
                top: parent.top; topMargin: 18
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.acInput
            maxForwardPowerParameter: "" // handled internally - uses input current limit and AC input voltage
            maxReversePowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxFeedInPower"
            show: showGauges && hasAcInput
        }
	}

    // check inverter to see if AC out 2 exists and hide noncritical loads if so
    VBusItem { id: inverterOut2Item; bind: Utils.path(root.inverterService, "/Ac/Out/L2/V") }

	OverviewBox {
		id: acLoadBox
		title: qsTr("Loads on Input")
		color: "#27AE60"
		titleColor: "#2ECC71"
		width: inOutTileWidth
		height: inOutTileHeight
        opacity: hasLoadsOnInput ? 1: disabledTileOpacity
    

		anchors {
			left: acInBox.right
			leftMargin: 10
			top: root.top; topMargin: 1
		}

		values:	OverviewAcValuesEnhancedGP {
			connection: sys.acInLoad
            visible: hasLoadsOnInput
		}
////// add power bar graph
        PowerGauge
        {
            id: acInLoadGauge
            width: parent.width
            height: 15
            anchors
            {
                top: parent.top; topMargin: 18
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.acInLoad
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/AcOutputNonCriticalMaxPower"
            show: showGauges && hasLoadsOnInput
        }
	}

	OverviewBox {
		id: acOutputBox
		title: combineAcLoads ? qsTr ("AC Loads") : qsTr ("Loads on Output") 
		color: "#157894"
		titleColor: "#419FB9"
		height: inOutTileHeight
		width: inOutTileWidth
		opacity: hasLoadsOnOutput ? 1 : disabledTileOpacity
		anchors {
			right: root.right; rightMargin: 5
			top: root.top; topMargin: 1
		}

		values:	OverviewAcValuesEnhancedGP {
			connection: outputLoad
            visible: hasLoadsOnOutput
		}
////// add power bar graph
        PowerGauge
        {
            id: acOutLoadGauge
            width: parent.width
            height: 15
            anchors
            {
                top: parent.top; topMargin: 18
                horizontalCenter: parent.horizontalCenter
            }
            connection: outputLoad
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/AcOutputMaxPower"
            show: showGauges && hasLoadsOnOutput
        }
	}

	MultiEnhancedGP {
		id: multi
		iconId: "overview-inverter-short"
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: root.top; topMargin: inOutTileHeight + 20
		}
        inverterService: root.inverterService
////// add power bar graph
        PowerGaugeMulti
        {
            id: multiGauge
            width: multi.width
            height: 13
            anchors
            {
                top: parent.top; topMargin: 21
                horizontalCenter: parent.horizontalCenter
            }
            inverterService: root.inverterService
            show: showGauges
        }
	}

	// invisible item to connection all AC connections to..
	Item {
		id: acBus
		height: 10
		anchors {
			left: acInBox.left; leftMargin: hasAcOutSystem ? 5 : acInBox.width - 5
			right: acLoadBox.right; rightMargin: 2
			bottom: acInBox.bottom; bottomMargin: -13
		}
	}

	Battery {
		id: battery

		soc: sys.battery.soc.valid ? sys.battery.soc.value : 0
		height: 99
		width: 145

		anchors {
			bottom: parent.bottom; bottomMargin: bottomOffset;
			left:parent.left; leftMargin: 5
		}
////// add battery current bar graph
        PowerGaugeBattery
        {
            id: batteryGauge
            width: parent.width
            height: 10
            anchors
            {
                top: parent.top; topMargin: 30
                horizontalCenter: parent.horizontalCenter
            }
            show: showGauges
        }
		values: Column {
			y: 0
			width: parent.width

			TileText {
				text: sys.battery.soc.valid ? sys.battery.soc.value.toFixed(0) : "--"
				font.pixelSize: 20

				Text {
					anchors {
						bottom: parent.bottom; bottomMargin: 4
						horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: parent.paintedWidth / 2 + 5
					}
					visible: sys.battery.soc.valid
					text: "%"
					color: "white"
					font.bold: true
					font.pixelSize: 12
				}
			}
            // spacer
            TileText
            {
                text: ""
                height: 9
            }
//////// replace voltage & current with remaining time
            TileText
            {
                font.pixelSize: 17
                text: timeToGo.valid ? Utils.secondsToString(timeToGo.value) : " "
                height: 19
                anchors
                {
                    horizontalCenter: parent.horizontalCenter
                    horizontalCenterOffset: -(toGoText.paintedWidth / 2) - 3
                }
                Text
                {
                    id: toGoText
                    anchors
                    {
                        bottom: parent.bottom; bottomMargin: 0
                        horizontalCenter: parent.horizontalCenter
                        horizontalCenterOffset: (parent.paintedWidth / 2) + (paintedWidth / 2) + 2
                    }
                    visible: timeToGo.valid
                    text: qsTr ("Remaining")
                    color: "white"
                    font.pixelSize: 12
                }
            }
            TileText {
                text: sys.battery.voltage.format(1) + "  " + sys.battery.current.format(1)
            }
            TileText {
                text: sys.battery.power.format(0)
                font.pixelSize: 17
                height: 19
            }
		}
	}

	OverviewSolarInverter {
		id: pvInverterOnGrid
		title: qsTr("PV on Input")
		width: inOutTileWidth
		height: inOutTileHeight
		opacity: hasPvOnGrid ? 1 : disabledTileOpacity
        showInverterIcon: false
        showInverterLogo: hasPvOnGrid
		values: TileText {
			y: 11
			text: sys.pvOnGrid.power.format(0)
			font.pixelSize: 17
            visible: hasPvOnGrid
		}
		anchors {
			top: multi.top; topMargin: 0
			left: root.left; leftMargin: 5
		}
////// add power bar graph
        PowerGauge
        {
            id: pvInverterOnGridGauge
            width: parent.width
            height: 15
            anchors
            {
                top: parent.top; topMargin: -2
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.pvOnGrid
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/PvOnGridMaxPower"
            show: showGauges && hasPvOnGrid
        }
	}

	OverviewSolarInverter {
		id: pvInverterOnAcOut
		title: qsTr("PV on Output")
		width: inOutTileWidth
		height: inOutTileHeight
		opacity: hasPvOnOutput ? 1 : disabledTileOpacity
		showInverterIcon: false
        showInverterLogo: hasPvOnOutput

		values: TileText {
			y: 11
			text: sys.pvOnAcOut.power.format(0)
			font.pixelSize: 17
            visible: hasPvOnOutput
		}
		anchors {
            top: acOutputBox.bottom; topMargin: 5
			right: parent.right; rightMargin: 5
		}
////// add power bar graph
        PowerGauge
        {
            id: pvInverterOnAcOutGauge
            width: parent.width
            height: 15
            anchors
            {
                top: parent.top; topMargin: -2
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.pvOnAcOut
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/PvOnOutputMaxPower"
            show: showGauges && hasPvOnOutput
        }
	}

    OverviewSolarChargerEnhanced {
		id: blueSolarCharger
		title: qsTr("PV Charger")
		width: inOutTileWidth
		height: inOutTileHeight
		opacity: hasPvCharger ? 1 : disabledTileOpacity
		showChargerIcon: false

		anchors {
			right: root.right; rightMargin: 5
			top: pvInverterOnAcOut.bottom; topMargin: 5
		}

		values: TileText {
			y: 12
			text: sys.pvCharger.power.format(0)
			font.pixelSize: 17
		}

////// moved sun icon here from OverviewSolarChager so it can be put below text, etc
        MbIcon {
            iconId: "overview-sun"
            anchors {
                bottom: parent.bottom
                right: parent.right; rightMargin: 2
            }
            opacity: 0.5
        }

////// add power bar graph
        PowerGauge
        {
            id: pvChargerGauge
            width: parent.width
            height: 10
            anchors
            {
                top: parent.top; topMargin: 0
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.pvCharger
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/PvChargerMaxPower"
            show: showGauges && hasPvCharger
        }
	}

 ////// added for DC System
     VBusItem {
        id: hasDcSys
        bind: "com.victronenergy.settings/Settings/SystemSetup/HasDcSystem"
    }
     VBusItem {
        id: maxDcLoad
        bind: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/DcSystemMaxLoad"
    }
     VBusItem {
        id: maxDcCharge
        bind: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/DcSystemMaxCharge"
    }
    OverviewBox {
        id: dcSystemBox
        width: inOutTileWidth
        height: inOutTileHeight
        opacity: hasDcSystem ? 1 : 0
        title:
        {
            var dcLoad, dcCharge
            if (maxDcLoad.valid && maxDcLoad.value != 0)
                dcLoad = true
            else
                dcLoad = false
            if (maxDcCharge.valid && maxDcCharge.value != 0)
                dcCharge = true
            else
                dcCharge = false
            if (dcLoad && ! dcCharge)
                qsTr ("DC Loads")
            else if ( ! dcLoad && dcCharge)
                qsTr ("DC Charge")
            else
                qsTr ("DC System")
        }
         anchors {
            right: root.right; rightMargin: 5
////// MODIFIED to show tanks
            bottom: parent.bottom; bottomMargin: bottomOffset
        }
         values: TileText {
            text: sys.dcSystem.power.text
            font.pixelSize: 17
            visible: hasDcSystem
            anchors
            {
                bottom: parent.bottom; bottomMargin: 0
                horizontalCenter: parent.horizontalCenter
            }
        }
        PowerGauge
        {
            id: dcSystemGauge
            width: parent.width
            height: 10
            anchors
            {
                top: parent.top; topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.dcSystem
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/DcSystemMaxLoad"
            maxReversePowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/DcSystemMaxCharge"
            show: showGauges && hasDcSystem
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
////// display detail targets and help message when first displayed.
    Timer {
        id: helpTimer
        running: false
        repeat: false
        interval: 5000
        triggeredOnStart: true
    }
    TileText
    {
        text: showTargets ? "Tap tile center for detail at any time" : wallClock.time
        color: "black"
        width: inOutTileWidth
        wrapMode: Text.WordWrap
        font.pixelSize: showTargets ? 12 : 18
        anchors
        {
            bottom: root.bottom; bottomMargin: bottomOffset + (showTargets ? -1 : 2)
            horizontalCenter: root.horizontalCenter
        }
        show: wallClock.running
    }

//////// move ESS reason to Battery details page

	// AC source power flow
	OverviewConnection {
		id: acSource
		ballCount: 4
		path: corner
		active: root.active && hasAcInput
		value: flow(sys.acInput ? sys.acInput.power : undefined) * -1
		startPointVisible: false

		anchors {
			right: acInBox.left; rightMargin: -9
			left: pvInverterOnGridConnection.horizontalCenter
			bottom: acInBox.bottom; bottomMargin: 8
			top: acBus.verticalCenter
		}
	}

	// Coupled AC sources
	OverviewConnection {
		id: coupledAcConnection

		property VBusItem coupled: VBusItem {
			property double gridPower: sys.acInput.power.valid ? sys.acInput.power.value : 0
			property double pvPower: hasPvOnGrid ? sys.pvOnGrid.power.value : 0
			value: gridPower + pvPower
		}

		ballCount: 1
		path: straight
		active: root.active && (hasAcInput || hasPvOnGrid)
		value: flow(coupled)
		startPointVisible: false
		endPointVisible: false

		anchors {
			left: pvInverterOnGridConnection.right
			right: vebusConnection.left
			top: acBus.verticalCenter
			bottom: acBus.verticalCenter
		}
	}

	// Grid inverter power flow
	OverviewConnection {
		id: pvInverterOnGridConnection
		ballCount: 1
		path: straight
		active: root.active && hasPvOnGrid
		value: flow(sys.pvOnGrid ? sys.pvOnGrid.power : undefined) * -1
		startPointVisible: false

		anchors {
			top: acBus.verticalCenter
			bottom: pvInverterOnGrid.top; bottomMargin: -8
			left: pvInverterOnGrid.right; leftMargin: -8
		}
	}

	// power to loads
	OverviewConnection {
		id: loadConnection
		ballCount: 3
		path: corner
		active: root.active && hasLoadsOnInput
		value: flow(sys.acInLoad.power)
		startPointVisible: false
		endPointVisible: true

		anchors {
			right: acLoadBox.right; rightMargin: 10
			left: vebusConnection.horizontalCenter
			top: acBus.verticalCenter
			bottom: acLoadBox.bottom; bottomMargin: 8
		}
	}

	// Towards vebus system
	OverviewConnection {
		id: vebusConnection

		property VBusItem vebusAcPower: VBusItem { bind: [sys.vebusPrefix, "/Ac/ActiveIn/P"] }

		ballCount: 1
		path: straight
		active: root.active && (hasAcInput || hasPvOnGrid)
		value: flow(vebusAcPower)
		startPointVisible: false
		endPointVisible: true

		anchors {
			left: multi.left; leftMargin: 8
			top: acBus.verticalCenter
			bottom: multi.top; bottomMargin: -7
		}
	}

    // invisible item to connection all AC output connections to..
    Item {
        id: acOutNode
        height: 16
        anchors {
            left: multi.right
            right: acOutputBox.left
            top: multi.top
        }
    }

	// AC out connection
	OverviewConnection {
		id: acOutConnection

		property double pvInverterOnAcOutPower: hasPvOnOutput && sys.pvOnAcOut.power.valid ? sys.pvOnAcOut.power.value : 0
		property double acOutLoad: sys.acOutLoad.power.valid ? sys.acOutLoad.power.value : 0
		property VBusItem vebusAcOutPower: VBusItem { value: acOutConnection.acOutLoad - acOutConnection.pvInverterOnAcOutPower }

		ballCount: 1
		path: straight
		active: root.active && (hasLoadsOnOutput || hasPvOnOutput)
		value: flow(vebusAcOutPower)
		endPointVisible: false

		anchors {
			left: multi.right; leftMargin: -8
            right: acOutNode.horizontalCenter
			top:  acOutNode.verticalCenter
		}
	}

	// UPS conenction
	OverviewConnection {
		id: acOutBoxConnection

		ballCount: 1
		path: corner
		active: root.active && hasLoadsOnOutput
		value: flow(sys.acOutLoad.power) * -1
		endPointVisible: false

		anchors {
            left: acOutputBox.left; leftMargin: 9
            top: acOutputBox.bottom; topMargin: -9
			right: acOutNode.horizontalCenter
			bottom: acOutNode.verticalCenter
		}
	}

	// PV Inverter on AC out connection
	OverviewConnection {
		id: pvOnAcOutConnection

		ballCount: 1
		path: corner
		active: root.active && hasPvOnOutput
		value: flow(sys.pvOnAcOut.power)
		endPointVisible: false

		anchors {
			left: pvInverterOnAcOut.left; leftMargin: 10
            top: pvInverterOnAcOut.bottom; topMargin: -9
            right: acOutNode.horizontalCenter
            bottom: acOutNode.verticalCenter
		}
	}

	// DC connection from multi
	OverviewConnection {
		ballCount: 1
		path: straight
		active: root.active
		value: flow(sys.vebusDc.power)
		endPointVisible: false

		anchors {
			right: dcConnection.right;
			top:  multi.bottom; topMargin: -10
			bottom: dcConnection.top;
		}
	}

	// Battery to DC connection
	OverviewConnection {
		ballCount: 3
		path: straight
		active: root.active
		value: Utils.sign(noNoise(sys.pvCharger.power) + noNoise(sys.vebusDc.power) - noNoise(sys.dcSystem.power))
		startPointVisible: false

		anchors {
			left: dcConnection.left;
			top: dcConnection.verticalCenter
			right: battery.right; rightMargin: 10
		}
	}
    // DC output bus
    OverviewConnection {
        ballCount: 3
        path: straight
        active: root.active && (hasPvCharger || hasDcSystem)
        value: Utils.sign(noNoise(sys.pvCharger.power) - noNoise(sys.dcSystem.power)) * -1
        startPointVisible: false
        endPointVisible: false

        anchors {
            left: dcConnection.horizontalCenter
            right: dcConnection2.horizontalCenter
            top: dcConnection.top
        }
    }

	// Solar charger to DC output bus
	OverviewConnection {
		ballCount: 1
		path: corner
		active: root.active && hasPvCharger
		value: flow(sys.pvCharger.power)
		endPointVisible: false
        anchors {
            left: blueSolarCharger.left; leftMargin: 9
            top: blueSolarCharger.bottom; topMargin: -9
            right: dcConnection2.horizontalCenter
            bottom: dcConnection.top
        }
	}

    // DC output bus to DC System
    OverviewConnection {
        ballCount: 1
        path: corner
        active: root.active && hasDcSystem
        value: noNoise(sys.dcSystem.power) * -1
        endPointVisible: false
        anchors {
            left: dcSystemBox.left; leftMargin: 9
            top: dcSystemBox.bottom; topMargin: -9
            right: dcConnection2.horizontalCenter
            bottom: dcConnection.top
        }
    }

	Item {
		id: dcConnection
		anchors {
			horizontalCenter: multi.horizontalCenter
			top: battery.bottom; topMargin: -32
		}
	}
    Item {
        id: dcConnection2
        anchors {
            left: multi.right
            right: acOutputBox.left
            top: dcConnection.top
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
        id: tanksColum

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

        model: TankModel { id: tankModel }
        delegate: TileTankEnhanced {
            // Without an intermediate assignment this will trigger a binding loop warning.
            property variant theService: DBusServices.get(buddy.id)
            service: theService
            width: tanksColum.tileWidth
            height: root.tanksHeight
            pumpBindPrefix: root.pumpBindPreffix
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

    ListView
    {
        id: tempsColumn

        visible: showTemps
        width: compact ? root.width : root.width * tempCount / tankTempCount
        property int tileWidth: width / Math.min (count, 5.2)
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
        }
    }

    // Detect available services of interest
    function discoverServices()
    {
        numberOfTemps = 0
        numberOfMultis = 0
        numberOfInverters = 0
        tempsModel.clear()
        inverterService = ""
        for (var i = 0; i < DBusServices.count; i++)
        {
            addService(DBusServices.at(i))
        }
    }
    VBusItem { id: incomingTankName;
        bind: Utils.path(settingsBindPreffix, "/Settings/Devices/TankRepeater/IncomingTankService") }

// Details targets
    MouseArea
    {
        id: multiTarget
        anchors.centerIn: multi
        enabled: parent.active && hasInverter
        height: touchArea * 1.5; width: touchArea * 1.5
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailInverter.qml", {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets && hasInverter
        }
    }
    MouseArea
    {
        id: acInputTarget
        anchors.centerIn: acInBox
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
        id: acLoadsOnInputTarget
        anchors.centerIn: acLoadBox
        enabled: parent.active && hasLoadsOnInput
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailLoadsOnInput.qml",
                    {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets && hasLoadsOnInput
        }
    }
    MouseArea
    {
        id: acLoadsOnOutputTarget
        anchors.centerIn: acOutputBox
        enabled: parent.active && hasLoadsOnOutput
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailLoadsOnOutput.qml",
                    {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets && hasLoadsOnOutput
        }
    }
    MouseArea
    {
        id: pvOnInputTarget
        anchors.centerIn: pvInverterOnGrid
        enabled: parent.active && hasPvOnGrid
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailPvInverter.qml",
                    {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets && hasPvOnGrid
        }
    }
    MouseArea    
    {
        id: pvOnOutputTarget
        anchors.centerIn: pvInverterOnAcOut
        enabled: parent.active && hasPvOnOutput
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailPvInverter.qml",
                    {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets && hasPvOnOutput
        }
    }
   MouseArea
    {
        id: pvChargerTarget
        anchors.centerIn: blueSolarCharger
        enabled: parent.active && hasPvCharger
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailPvCharger.qml",
                    {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets && hasPvCharger
        }
    }
    MouseArea
    {
        id: batteryTarget
        anchors.centerIn: battery
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
}
