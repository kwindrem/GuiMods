///// Enhanced Grid Parallel Overview for GuiMods

// TODO:
// alternator params, gauge? and power limit in menu
// fuel cell params, gauge? and power limit in menu
// check flow directions
// tile colors
// power values
// gauges
// discover DC meter services * calculate power values
//	wind gen
//	AC charger
//	DC charger
//	Alternator - include Alternator services and DC Meter subvariant alternator

// sum DC meter services for specific MeterMode

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0
import "timeToGo.js" as TTG

OverviewPage {
	id: root
 
    property real touchTargetOpacity: 0.3
	property variant sys: theSystem
	property string systemPrefix: "com.victronenergy.system"
	property bool hasAcOutSystem: _hasAcOutSystem.value === 1
    property color detailColor: "#b3b3b3"
 
    property int inOutTileHeight: (root.height - topOffset - bottomOffset - 3 * 5) / 4
    property int inOutTileWidth: 145
    property int touchArea: 40
    VBusItem { id: timeToGo;  bind: Utils.path(systemPrefix, "/Dc/Battery/TimeToGo") }

    property int numberOfMultis: 0
    property int numberOfInverters: 0
    property int numberOfAlternators: 0
    property int numberOfWindGens: 0
    property int numberOfAcChargers: 0
    property int numberOfDcDcChargers: 0
    property string inverterService: ""
    property bool isMulti: true //////////////// numberOfMultis === 1
    property bool combineAcLoads: false ///////////////_combineAcLoads.valid && _combineAcLoads.value === 1
    property variant outputLoad: combineAcLoads ? sys.acLoad : sys.acOutLoad

    property bool hasInverter: isMulti || numberOfInverters === 1
    property bool hasLoadsOnOutput: hasInverter
    property bool hasAcInput: isMulti || hasPvOnInput
	property bool debugLoadsOnInput: true /////////////// debug
    property bool hasLoadsOnInput: hasAcInput && ! combineAcLoads && debugLoadsOnInput ///////////(! loadsOnInputItem.valid || loadsOnInputItem.value === 1)
	property bool hasPvOnInput: true /////////////sys.pvOnGrid.power.valid
    property bool hasPvOnOutput: true //////////////// sys.pvOnAcOut.power.valid
	property bool hasPvCharger: true ////////////sys.pvCharger.power.valid
    property bool hasDcSystem: true //////////// hasDcSystemItem.valid && hasDcSystemItem.value > 0
    property bool hasAlternator: true /////////numberOfAlternators > 0
    property bool hasFuelCell: true /////////////////////fuelCellPowerItem.valid
    property bool hasWindGen: true //////////numberOfWindGens > 0
    property bool hasAcCharger: true ///////////numberOfAcChargers > 0
    property bool hasDcDcCharger: true /////numberOfDcDcChargers > 0

    property bool showAcInput: false
    property bool showLoadsOnOutput: false
    property bool showLoadsOnInput: false
    property bool showPvOnGrid: false
    property bool showPvOnOutput: false
    property bool showPvCharger: false
    property bool showAlternator: false
    property bool showFuelCell: false
    property bool showDcSystem: false
    property bool showWindGen: false
    property bool showAcCharger: false
    property bool showDcDcCharger: false

    property bool favorDcCoupled: false /////////////////////// get from user pref

    property int showCount: 0 ///////////////////////////// debug
    
    property bool showTargets: helpTimer.running

    property int bottomOffset: 45 ////////////showTanksTemps ? 45 : 5
    property int topOffset: showTanksTemps ? 1 : 5
    property string settingsBindPreffix: "com.victronenergy.settings"
    property string pumpBindPreffix: "com.victronenergy.pump.startstop0"
    property int numberOfTemps: 0

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

    VBusItem { id: ignoreAcInput; bind: Utils.path(inverterService, "/Ac/State/IgnoreAcIn1") }

    property string guiModsPrefix: "com.victronenergy.settings/Settings/GuiMods"
    VBusItem { id: showGaugesItem; bind: Utils.path(guiModsPrefix, "/ShowGauges") }
    property bool showGauges: showGaugesItem.valid ? showGaugesItem.value === 1 ? true : false : false
    VBusItem { id: showTanksItem; bind: Utils.path(guiModsPrefix, "/ShowEnhancedFlowOverviewTanks") }
    property bool showTanksEnable: showTanksItem.valid ? showTanksItem.value === 1 ? true : false : false
    VBusItem { id: showTempsItem; bind: Utils.path(guiModsPrefix, "/ShowEnhancedFlowOverviewTemps") }
    property bool showTempsEnable: showTempsItem.valid ? showTempsItem.value === 1 ? true : false : false

    VBusItem { id: showInactiveTiles; bind: Utils.path(guiModsPrefix, "/ShowInactiveFlowTiles") }
    property real disabledTileOpacity: ! showInactiveTiles.valid || showInactiveTiles.value === 1 ? 0.3 : showInactiveTiles.value === 2 ? 1.0 : 0.0

    VBusItem { id: fuelCellPowerItem; bind: Utils.path(systemPrefix, "/Dc/FuelCell/Power") }

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

    Component.onCompleted:
    { 
		discoverServices ()
		prioritizeTiles ()
		helpTimer.running = true
		flowDisableTimer.running = true
	}

	// timer disables flow lines while things settle
	property bool showFlow: root.active && ! flowDisableTimer.running
    Timer {
        id: flowDisableTimer
        running: false
        repeat: false
        interval: 200
        triggeredOnStart: true
    }

	onHasAcInputChanged: prioritizeLeftTiles ()
	onHasPvOnInputChanged: prioritizeLeftTiles ()
	onHasLoadsOnInputChanged: prioritizeLeftTiles ()
	onHasPvChargerChanged: prioritizeLeftTiles ()
	onHasAlternatorChanged: prioritizeLeftTiles ()
	onHasDcDcChargerChanged: prioritizeLeftTiles ()
	onHasAcChargerChanged: prioritizeLeftTiles ()
	onHasLoadsOnOutputChanged: prioritizeRightTiles ()
	onHasPvOnOutputChanged: prioritizeRightTiles ()
	onHasFuelCellChanged: prioritizeRightTiles ()
	onHasWindGenChanged: prioritizeRightTiles ()
	onHasDcSystemChanged: prioritizeRightTiles ()
	onFavorDcCoupledChanged: prioritizeTiles ()

	function prioritizeLeftTiles ()
	{
		flowDisableTimer.running = true
		var tileCount = 0
		if (hasAcInput) { showAcInput = true; tileCount += 1 } else showAcInput = false
		if (hasPvCharger) { showPvCharger = true; tileCount += 1 } else showPvCharger = false
		if ( favorDcCoupled )
		{
			if (tileCount < 4 && hasAlternator) { showAlternator = true; tileCount += 1 } else showAlternator = false
			if (tileCount < 4 && hasDcDcCharger) { showDcDcCharger = true; tileCount += 1 } else showDcDcCharger = false
			if (tileCount < 4 && hasAcCharger) { showAcCharger = true; tileCount += 1 } else showAcCharger = false
			if (tileCount < 4 && hasPvOnInput) { showPvOnGrid = true; tileCount += 1 } else showPvOnGrid = false
			if (tileCount < 4 && hasLoadsOnInput) { showLoadsOnInput = true; tileCount += 1 } else showLoadsOnInput = false
		}
		else
		{
			if (tileCount < 4 && hasPvOnInput) { showPvOnGrid = true; tileCount += 1 } else showPvOnGrid = false
			if (tileCount < 4 && hasLoadsOnInput) { showLoadsOnInput = true; tileCount += 1 } else showLoadsOnInput = false
			if (tileCount < 4 && hasAlternator) { showAlternator = true; tileCount += 1 } else showAlternator = false
			if (tileCount < 4 && hasDcDcCharger) { showDcDcCharger = true; tileCount += 1 } else showDcDcCharger = false
			if (tileCount < 4 && hasAcCharger) { showAcCharger = true; tileCount += 1 } else showAcCharger = false
		}
	}

	function prioritizeRightTiles ()
	{
		flowDisableTimer.running = true
		var tileCount = 0
		if (hasLoadsOnOutput) { showLoadsOnOutput = true; tileCount += 1 } else showLoadsOnOutput = false
		if ( favorDcCoupled )
		{
			if (tileCount < 4 && hasFuelCell) { showFuelCell = true; tileCount += 1 } else showFuelCell = false
			if (tileCount < 4 && hasWindGen) { showWindGen = true; tileCount += 1 } else showWindGen = false
			if (tileCount < 4 && hasDcSystem) { showDcSystem = true; tileCount += 1 } else showDcSystem = false
			if (tileCount < 4 && hasPvOnOutput) { showPvOnOutput = true; tileCount += 1 } else showPvOnOutput = false
		}
		else
		{
			if (tileCount < 4 && hasPvOnOutput) { showPvOnOutput = true; tileCount += 1 } else showPvOnOutput = false
			if (tileCount < 4 && hasFuelCell) { showFuelCell = true; tileCount += 1 } else showFuelCell = false
			if (tileCount < 4 && hasWindGen) { showWindGen = true; tileCount += 1 } else showWindGen = false
			if (tileCount < 4 && hasDcSystem) { showDcSystem = true; tileCount += 1 } else showDcSystem = false
		}
	}
	function prioritizeTiles ()
	{
		prioritizeLeftTiles ()
		prioritizeRightTiles ()
	}

	title: qsTr("Overview")

    VBusItem {
        id: _hasAcOutSystem
        bind: "com.victronenergy.settings/Settings/SystemSetup/HasAcOutSystem"
    }
    VBusItem { id: loadsOnInputItem; bind: "com.victronenergy.settings/Settings/GuiMods/ShowEnhancedFlowLoadsOnInput" }
    VBusItem { id: _combineAcLoads; bind: "com.victronenergy.settings/Settings/GuiMods/EnhancedFlowCombineLoads" }
 
	OverviewBox {
		id: acInBox
        visible: showAcInput
		width: inOutTileWidth
		height: inOutTileHeight
		title:
		{
			if (ignoreAcInput.valid && ignoreAcInput.value == 1)
				return qsTr ("AC In Ignored")
			else
				return getAcSourceName(sys.acSource)
		}
		titleColor: "#E74c3c"
		color: "#C0392B"
		anchors {
			top: root.top; topMargin: topOffset
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

	OverviewSolarInverter {
		id: pvInverterOnGrid
		title: qsTr("PV on Input")
		width: inOutTileWidth
		height: inOutTileHeight
		visible: showPvOnGrid
        showInverterIcon: false
        showInverterLogo: showPvOnGrid
		values: TileText {
			y: 11
			text: sys.pvOnGrid.power.format(0)
			font.pixelSize: 17
            visible: showPvOnGrid
		}
		anchors {
			top: showAcInput ? acInBox.bottom : root.top 
			topMargin: showAcInput ? 5 : topOffset
			left: acInBox.left
		}
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
            show: showGauges && showPvOnGrid
        }
	}

	OverviewBox {
		id: acLoadBox
		title: qsTr("Loads on Input")
		color: "#27AE60"
		titleColor: "#2ECC71"
		width: inOutTileWidth
		height: inOutTileHeight
        visible: showLoadsOnInput
		anchors {
			top: showPvOnGrid ? pvInverterOnGrid.bottom : acInBox.bottom
			topMargin: 5
			left: acInBox.left
		}

		values:	OverviewAcValuesEnhancedGP {
			connection: sys.acInLoad
            visible: showLoadsOnInput
		}
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
            show: showGauges && showLoadsOnInput
        }
	}

    // check inverter to see if AC out 2 exists and hide noncritical loads if so
    VBusItem { id: inverterOut2Item; bind: Utils.path(root.inverterService, "/Ac/Out/L2/V") }


	OverviewBox {
		id: acChargerBox
		title: qsTr ("AC Charger") 
		color: "#157894" //////////////////////////
		titleColor: "#419FB9" ///////////////////////
		height: inOutTileHeight
		width: inOutTileWidth
		visible: showAcCharger
		anchors {
			left: acInBox.left
            bottom:
            {
				if (showDcDcCharger)
					return dcDcChargerBox.top
				else if (showAlternator)
					return alternatorBox.top
				else if (showPvCharger)
					return blueSolarCharger.top
				else
					return root.bottom
			}
			bottomMargin:
			{
				if (showAlternator && showPvCharger && showDcDcCharger)
					return 4
				else if (showAlternator || showPvCharger || showDcDcCharger)
					return 5
				else
					return bottomOffset
			}
		}

		values:
		{
			"--------" /////////////////////
		}
        PowerGauge
        {
            id: acChargerGauge
            width: parent.width
            height: 15
            anchors
            {
                top: parent.top; topMargin: 18
                horizontalCenter: parent.horizontalCenter
            }
            connection: undefined ////////////////////////////
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/AcOutputMaxPower"
            show: showGauges && showAlternator
        }
	}

	OverviewBox {
		id: dcDcChargerBox
		title: qsTr ("DC-DC Charger") 
		color: "#157894" //////////////////////////
		titleColor: "#419FB9" ///////////////////////
		height: inOutTileHeight
		width: inOutTileWidth
		visible: showDcDcCharger
		anchors {
			left: acInBox.left
            bottom:
            {
				if (showAlternator)
					return alternatorBox.top
				else if (showPvCharger)
					return blueSolarCharger.top
				else
					return root.bottom
			}
			bottomMargin:
			{
				if (showAlternator || showPvCharger)
					return 5
				else
					return bottomOffset
			}
		}

		values:
		{
			"--------" /////////////////////
		}
        PowerGauge
        {
            id: dcDcChargerGauge
            width: parent.width
            height: 15
            anchors
            {
                top: parent.top; topMargin: 18
                horizontalCenter: parent.horizontalCenter
            }
            connection: undefined ////////////////////////////
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/AcOutputMaxPower"
            show: showGauges && showAlternator
        }
	}

	OverviewBox {
		id: alternatorBox
		title: qsTr ("Alternator") 
		color: "#157894" //////////////////////////
		titleColor: "#419FB9" ///////////////////////
		height: inOutTileHeight
		width: inOutTileWidth
		visible: showAlternator
		anchors {
			left: acInBox.left
			bottom: showPvCharger ? blueSolarCharger.top : root.bottom
			bottomMargin: showPvCharger ? 5 : bottomOffset
		}

		values:
		{
			"--------" /////////////////////
		}
        PowerGauge
        {
            id: alternatorGauge //////////////////////////
            width: parent.width
            height: 15
            anchors
            {
                top: parent.top; topMargin: 18
                horizontalCenter: parent.horizontalCenter
            }
            connection: undefined ////////////////////////////
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/AcOutputMaxPower"
            show: showGauges && showAlternator
        }
	}

    OverviewSolarChargerEnhanced {
		id: blueSolarCharger
		title: qsTr("PV Charger")
		width: inOutTileWidth
		height: inOutTileHeight
		visible: showPvCharger
		
		showChargerIcon: false

		anchors {
			left: acInBox.left
            bottom: parent.bottom; bottomMargin: bottomOffset
		}

		values: TileText {
			y: 12
			text: sys.pvCharger.power.format(0)
			font.pixelSize: 17
		}
		// moved sun icon here from OverviewSolarChager so it can be put below text, etc
        MbIcon {
            iconId: "overview-sun"
            anchors {
                bottom: parent.bottom
                right: parent.right; rightMargin: 2
            }
            opacity: 0.5
        }

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
            show: showGauges && showPvCharger
        }
	}


	OverviewBox {
		id: acOutputBox
		title: combineAcLoads ? qsTr ("AC Loads") : qsTr ("Loads on Output") 
		color: "#27AE60"
		titleColor: "#2ECC71"
		height: inOutTileHeight
		width: inOutTileWidth
		visible: showLoadsOnOutput
		anchors {
			right: root.right; rightMargin: 5
			top: root.top; topMargin: topOffset
		}

		values:	OverviewAcValuesEnhancedGP {
			connection: outputLoad
            visible: showLoadsOnOutput
		}
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
            show: showGauges && showLoadsOnOutput
        }
	}

	MultiEnhancedGP {
		id: multi
		iconId: "overview-inverter-short"
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: acInBox.top
		}
        inverterService: root.inverterService
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

	Battery {
		id: battery

		soc: sys.battery.soc.valid ? sys.battery.soc.value : 0
		height: 99
		width: 145

		anchors {
			bottom: parent.bottom; bottomMargin: bottomOffset;
			horizontalCenter: parent.horizontalCenter
		}
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
            TileText
            {
                font.pixelSize: 17
                text: timeToGo.valid ? TTG.formatTimeToGo (timeToGo) : " "
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
                text: sys.battery.voltage.format(2) + "  " + sys.battery.current.format(1)
            }
            TileText {
                text: sys.battery.power.format(0)
                font.pixelSize: 17
                height: 19
            }
		}
	}

	OverviewSolarInverter {
		id: pvInverterOnAcOut
		title: qsTr("PV on Output")
		width: inOutTileWidth
		height: inOutTileHeight
		showInverterIcon: false
        showInverterLogo: showPvOnOutput
        visible: showPvOnOutput

		values: TileText {
			y: 11
			text: sys.pvOnAcOut.power.format(0)
			font.pixelSize: 17
            visible: showPvOnOutput
		}
		anchors {
            top: showLoadsOnOutput ? acOutputBox.bottom : root.top
            topMargin: showLoadsOnOutput ? 5 : topOffset
			right: parent.right; rightMargin: 5
		}
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
            show: showGauges && showPvOnOutput
        }
	}


    OverviewBox
    {
        id: fuelCellBox
        width: inOutTileWidth
        height: inOutTileHeight
        visible: showFuelCell
		color: "#157894" //////////////////////////
		titleColor: "#419FB9" ///////////////////////
        title: qsTr ("Fuel Cell")
         anchors
         {
            right: root.right; rightMargin: 5
            bottom:
            {
				if (showWindGen)
					return windGenBox.top
				else if (showDcSystem)
					return dcSystemBox.top
				else
					return root.bottom
			}
			bottomMargin:
			{
				if (showWindGen || showDcSystem)
					return 5
				else
					return bottomOffset
			}
        }
		values: TileText {
            text: fuelCellPowerItem.text ////////// may need to format locally: value.toFixed (0) + "W"
            font.pixelSize: 17
            visible: showFuelCell
            anchors
            {
                bottom: parent.bottom; bottomMargin: 0
                horizontalCenter: parent.horizontalCenter
            }
        }
        PowerGauge
        {
            id: fuelCellGauge
            width: parent.width
            height: 10
            anchors
            {
                top: parent.top; topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            connection: fuelCellPowerItem
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/FuelCellMaxPower" //////////
            show: showGauges && showFuelCell
        }
    }


    OverviewBox
    {
        id: windGenBox
        width: inOutTileWidth
        height: inOutTileHeight
        visible: showWindGen
		color: "#157894" //////////////////////////
		titleColor: "#419FB9" ///////////////////////
        title: qsTr ("Wind Gen")
		anchors
		{
            right: root.right; rightMargin: 5
            bottom: showDcSystem ? dcSystemBox.top : root.bottom; bottomMargin: showDcSystem ? 5 : bottomOffset
        }
		values: TileText {
            text: "--------" ////////// may need to format locally: value.toFixed (0) + "W"
            font.pixelSize: 17
            visible: showFuelCell
            anchors
            {
                bottom: parent.bottom; bottomMargin: 0
                horizontalCenter: parent.horizontalCenter
            }
        }
        PowerGauge
        {
            id: windGenGauge
            width: parent.width
            height: 10
            anchors
            {
                top: parent.top; topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            connection: undefined ////////////////////////
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/WindGenMaxPower" //////////
            show: showGauges && showFuelCell
        }
    }

     VBusItem {
        id: hasDcSystemItem
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
        visible: showDcSystem
        title: qsTr ("DC System")
         anchors {
            right: root.right; rightMargin: 5
            bottom: parent.bottom; bottomMargin: bottomOffset
        }
		values: TileText {
            text: sys.dcSystem.power.text
            font.pixelSize: 17
            visible: showDcSystem
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
            show: showGauges && showDcSystem
        }
    }

    Timer {
        id: wallClock
        running: timeFormat != ""
        repeat: true

        interval: 1000
        triggeredOnStart: true
        onTriggered: time = Qt.formatDateTime(new Date(), timeFormat)

        property string time
    }
	// display detail targets and help message when first displayed.
    Timer {
        id: helpTimer
        running: false
        repeat: false
        interval: 5000
        triggeredOnStart: true
    }
    TileText
    {
        text: wallClock.time
        color: "black"
        width: inOutTileWidth
        wrapMode: Text.WordWrap
        font.pixelSize: showTargets ? 12 : 18
        anchors
        {
			verticalCenter: batteryMultiConnector.verticalCenter
            horizontalCenter: root.horizontalCenter; horizontalCenterOffset: -6
        }
        show: wallClock.running && ! showTargets
    }

	// move ESS reason to Battery details page

	// invisible item to connection all AC input connections to..
	Item {
		id: acInBus
		height: 10
		anchors {
			left: acInBox.right;
			right: battery.left
			top: multi.top; topMargin: multi.height / 2 + 10
			bottom: pvInverterOnGridConnection.bottom
		}
	}

	OverviewConnection {
		id: multiAcInFlow
		ballCount: 1
		path: straight
		active: showFlow && ( hasAcInput || showPvOnGrid || showLoadsOnInput )
		value: flow(sys.acInput ? sys.acInput.power : undefined)
		startPointVisible: false
		endPointVisible: true

		anchors {
			left: acInBus.horizontalCenter
			right: multi.left; rightMargin: -8
			bottom: acInBus.top
		}
	}

	// AC source power flow
	OverviewConnection {
		id: acSource
		ballCount: 1
		path: corner
		active: showFlow && hasAcInput
		value: -flow(sys.acInput ? sys.acInput.power : undefined)
		startPointVisible: true
		endPointVisible: false

		anchors {
			left: acInBox.right; leftMargin: -8
			right: acInBus.horizontalCenter
			top: acInBox.bottom; topMargin: -8
			bottom: acInBus.top
		}
	}

	// Coupled AC sources
	OverviewConnection {
		id: coupledAcConnection

		property VBusItem coupled: VBusItem {
			property double loadsOnInputPower: sys.acInLoad.power.valid ? sys.acInLoad.power.value : 0
			property double gridPower: showPvOnGrid ? sys.pvOnGrid.power.value : 0
			value: gridPower + pvPower
		}
		ballCount: 3
		path: straight
		active: showFlow && (showLoadsOnInput && showPvOnGrid)
		value: flow(coupled)
		startPointVisible: false
		endPointVisible: false

		anchors {
			right: acInBus.horizontalCenter
			top: acInBus.top
			bottom: acInBus.bottom
		}
	}

	// Grid inverter power flow
	OverviewConnection {
		id: pvInverterOnGridConnection
		ballCount: 3
		path: showLoadsOnInput ? straight : corner
		active: showFlow && showPvOnGrid
		value: flow(sys.pvOnGrid ? sys.pvOnGrid.power : undefined)
		startPointVisible: true
		endPointVisible: false

		anchors {
			left: pvInverterOnGrid.right; leftMargin: -8
			right: acInBus.horizontalCenter
			top: pvInverterOnGrid.bottom; topMargin: -8
			bottom: showLoadsOnInput ? pvInverterOnGrid.bottom : multiAcOutConnection.verticalCenter
			bottomMargin: showLoadsOnInput ? 8 : 0
		}
	}

	// power to loads on input
	OverviewConnection {
		id: loadConnection
		ballCount: 1
		path: corner
		active: showFlow && showLoadsOnInput
		value: -flow(sys.acInLoad.power)
		startPointVisible: true
		endPointVisible: false

		anchors {
			left: acLoadBox.right; leftMargin: -8
			right: acInBus.horizontalCenter
			top:  acLoadBox.bottom; topMargin: -8
			bottom: showPvOnGrid ? acInBus.bottom : acInBus.top
		}
	}

    // invisible item to connection all AC output connections to..
    Item {
        id: acOutNode
        height: 6
        anchors {
            left: multi.right
            right: acOutputBox.left
            verticalCenter: acInBus.top
        }
    }

	// AC out connection
	OverviewConnection {
		id: multiAcOutConnection

		property double pvInverterOnAcOutPower: showPvOnOutput && sys.pvOnAcOut.power.valid ? sys.pvOnAcOut.power.value : 0
		property double acOutLoad: sys.acOutLoad.power.valid ? sys.acOutLoad.power.value : 0
		property VBusItem vebusAcOutPower: VBusItem { value: multiAcOutConnection.acOutLoad - multiAcOutConnection.pvInverterOnAcOutPower }

		ballCount: 1
		path: straight
		active: showFlow && (showLoadsOnOutput || showPvOnOutput)
		value: flow(vebusAcOutPower)
		endPointVisible: false

		anchors {
			left: multi.right; leftMargin: -8
            right: acOutNode.horizontalCenter
			top:  acOutNode.verticalCenter
		}
	}

	// loads on output conenction
	OverviewConnection {
		id: acOutBoxConnection

		ballCount: 1
		path: corner
		active: showFlow && showLoadsOnOutput
		value: flow(sys.acOutLoad.power)
		startPointVisible: true
		endPointVisible: false

		anchors {
			right: acOutNode.horizontalCenter
            left: acOutputBox.left; leftMargin: 8
            top: acOutputBox.bottom; topMargin: -8
            bottom: acOutNode.verticalCenter
		}
	}

	// PV Inverter on AC out connection
	OverviewConnection {
		id: pvOnAcOutConnection

		ballCount: 3
		path: corner
		active: showFlow && showPvOnOutput
		value: flow(sys.pvOnAcOut.power)
		startPointVisible: true
		endPointVisible: false

		anchors {
			left: pvInverterOnAcOut.left; leftMargin: 8
            top: pvInverterOnAcOut.bottom; topMargin: -8
            right: acOutNode.horizontalCenter
            /////////////////////rightMargin: 0.5 // makes this line up with others
            bottom: acOutNode.verticalCenter
		}
	}

	// DC connection multi to battery
	OverviewConnection {
		id: batteryMultiConnector
		ballCount: 1
		path: straight
		active: showFlow
		value: flow(sys.vebusDc.power)
		startPointVisible: true
		endPointVisible: true

		anchors {
			right: multi.right; rightMargin: 25
			top:  multi.bottom; topMargin: -8
			bottom: battery.top; bottomMargin: -15
		}
	}

    // Battery to DC left bus
    OverviewConnection {
        ballCount: 1
        path: straight
        active: showFlow && ( showPvCharger || showAlternator || showDcDcCharger || showAcCharger)
        value: -Utils.sign(noNoise(sys.pvCharger.power))/////// + noNoise(alternator)
        startPointVisible: false
        endPointVisible: true

        anchors {
            left: dcLeftConnection.horizontalCenter
            right: battery.left; rightMargin: -8
            top: dcLeftConnection.verticalCenter
        }
    }

	// AC charger to DC left bus
	OverviewConnection {
		ballCount: 1
		path: corner
		active: showFlow && showAcCharger
		value: 0 //////////////flow(ac charger power) 
		endPointVisible: false
        anchors
        {
            left: acChargerBox.right; leftMargin: -8
            top: acChargerBox.bottom; topMargin: -8
            right: dcLeftConnection.horizontalCenter
            rightMargin: 0.1 // makes this line up with others
            bottom:
            {
				if (showDcDcCharger)
					return dcDcChargerConnection.verticalCenter
				else if (showAlternator && ! showPvCharger)
					return alternatorConnection.verticalCenter
				else
					return dcLeftConnection.verticalCenter
			}
		}
	}

	// DC-DC charger to DC left bus
	property bool dcDcChargerConnectionIsStraight: (showPvCharger || showAlternator) && showAcCharger
	OverviewConnection
	{
		id: dcDcChargerConnection
		ballCount: 1
		path: dcDcChargerConnectionIsStraight ? straight : corner
		active: showFlow && showDcDcCharger
		value: 0 ///////////////flow(dc dc charger)
		endPointVisible: false
        anchors
        {
            left: dcDcChargerBox.right; leftMargin: -8
            top: dcDcChargerBox.bottom; topMargin: -8
            right: dcLeftConnection.horizontalCenter
            rightMargin: 0.1 // makes this line up with others
            bottom:
            {
				if (dcDcChargerConnectionIsStraight)
					return dcDcChargerBox.bottom
				else if (showAlternator)
					return alternatorConnection.top
				else
					return dcLeftConnection.verticalCenter
			}
            bottomMargin: dcDcChargerConnectionIsStraight ? 8 : 0
        }
	}

	// Alternator to DC left bus
	property bool alternatorConnectionIsStraight: showPvCharger && (showDcDcCharger || showAcCharger)
	OverviewConnection
	{
		id: alternatorConnection
		ballCount: 1
		path: alternatorConnectionIsStraight ?  straight: corner
		active: showFlow && showAlternator
		value: 0 ////////////////flow(alternator) 
		endPointVisible: false
        anchors
        {
            left: alternatorBox.right; leftMargin: -8
            top: alternatorBox.bottom; topMargin: -8
            right: dcLeftConnection.horizontalCenter
            rightMargin: 0.1 // makes this line up with others
            bottom: alternatorConnectionIsStraight ? alternatorBox.bottom : dcLeftConnection.verticalCenter
            bottomMargin: alternatorConnectionIsStraight ? 8 : 0
        }
	}

    OverviewConnection
    {
		id: dcLeftBridge1
        ballCount: 1
        path: straight
        active: showFlow && showPvCharger && showAlternator && ( showDcDcCharger || showAcCharger )
        value: 0 //////////////////-flow ( AC charger + DC-DC charger + Alternator) ///////////////////////////////////
        startPointVisible: false
        endPointVisible: false
        anchors
        {
			right: dcLeftConnection.horizontalCenter
            top: alternatorConnection.top
            bottom: dcLeftConnection.verticalCenter
            rightMargin: 0.1 // makes this line up with others
        }
    }

    OverviewConnection
    {
		id: dcLeftBridge2
        ballCount: 1
        path: straight
        active: showFlow && (showPvCharger || showAlternator) && showDcDcCharger && showAcCharger
        value: 0 //////////////////-flow ( AC charger + DC-DC charger) ///////////////////////////////////
        startPointVisible: false
        endPointVisible: false
        anchors
        {
            right: dcLeftConnection.horizontalCenter
            top: dcDcChargerConnection.top
            bottom: showPvCharger && showAlternator ? alternatorConnection.top : dcLeftConnection.verticalCenter
            rightMargin: 0.1 // makes this line up with others
        }
    }


	// Solar charger to DC left bus
	OverviewConnection
	{
		ballCount: 1
		path: corner
		active: showFlow && showPvCharger
		value: flow(sys.pvCharger.power)
		endPointVisible: false
        anchors
        {
            left: blueSolarCharger.right; leftMargin: -8
            top: blueSolarCharger.bottom; topMargin: -8
            right: dcLeftConnection.horizontalCenter
            rightMargin: 0.1 // makes this line up with others
            bottom: dcLeftConnection.verticalCenter
        }
	}
    // DC right bus wind gen to fuel cell
    OverviewConnection {
		id: dcRightBridge
        ballCount: 1
        path: straight
        active: showFlow && showDcSystem && showWindGen && showFuelCell
        value: 0 //////////////////-flow ( fuel cell power + wind gen power) ///////////////////////////////////
        startPointVisible: false
        endPointVisible: false
        anchors {////////////////////////////
            right: dcRightConnection.horizontalCenter
            top: windConnection.verticalCenter
            bottom: dcRightConnection.verticalCenter
            rightMargin: 0.1 // makes this line up with others
        }
    }


	// Battery to DC right bus
	OverviewConnection {
		ballCount: 1
		path: straight
		active: showFlow && ( showDcSystem || showWindGen || showFuelCell )
		value: Utils.sign (noNoise (sys.dcSystem.power)) ////// + noNoise (fuel cell) + noNoise (wind gen)
		startPointVisible: false

		anchors {
			left: dcRightConnection.horizontalCenter;
			top: dcRightConnection.verticalCenter
			right: battery.right; rightMargin: 10
		}
	}

    // DC right bus to fuel cell
    OverviewConnection {
		id: fuelCellConnection
        ballCount: 1
        path: corner
        active: showFlow && showFuelCell
        value: -flow (fuelCellPowerItem.value)
        endPointVisible: false
        anchors {
            left: fuelCellBox.left; leftMargin: 8
            top: fuelCellBox.bottom; topMargin: -8
            right: dcRightConnection.horizontalCenter
            bottom: showWindGen && showDcSystem ? windConnection.top : dcRightConnection.verticalCenter
            rightMargin: 0.1 // makes this line up with others
        }
    }

    // DC right bus to wind gen
    OverviewConnection {
		id: windConnection
        ballCount: 1
        path: showFuelCell && showDcSystem ? straight : corner
        active: showFlow && showWindGen
        value: -flow (sys.dcSystem.power) ///////////////////////////////////
        endPointVisible: false
        anchors {
            left: windGenBox.left; leftMargin: 8
            top: windGenBox.bottom; topMargin: -8
            right: dcRightConnection.horizontalCenter
            bottom: showFuelCell && showDcSystem ? windGenBox.bottom : dcRightConnection.verticalCenter ///////////////////
            bottomMargin: showFuelCell && showDcSystem ? 8 : 0
            rightMargin: 0.1 // makes this line up with others
        }
    }

    // DC right bus to DC System
    OverviewConnection
    {
		id: dcSystemConnection
        ballCount: 1
        path: corner
        active: showFlow && showDcSystem
        value: -flow (sys.dcSystem.power)
        endPointVisible: false
        anchors
        {
            left: dcSystemBox.left; leftMargin: 8
            top: dcSystemBox.bottom; topMargin: -8
            right: dcRightConnection.horizontalCenter
            bottom: dcRightConnection.verticalCenter
            rightMargin: 0.1 // makes this line up with others
        }
    }

	Item {
		id: dcLeftConnection
		height: 6
		anchors {
			left: blueSolarCharger.right
			right: battery.left
			top: battery.bottom; topMargin: -32 - 3
		}
	}
	Item {
        id: dcRightConnection
		height: dcLeftConnection.height
		width: 6
        anchors {
            left: battery.right
            right: dcSystemBox.left
			verticalCenter: dcLeftConnection.verticalCenter
        }
    }

    // Synchronise tank name text scroll start
    Timer
    {
        id: scrollTimer
        interval: 15000
        repeat: true
        running: showFlow && root.compact
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
        case DBusService.DBUS_SERVICE_TEMPERATURE_SENSOR:
            numberOfTemps++
            tempsModel.append({serviceName: service.name})
            break;;

        case DBusService.DBUS_SERVICE_MULTI:
            numberOfMultis++
            if (numberOfMultis === 1)
                inverterService = service.name;
            break;;
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
        enabled: parent.active && showLoadsOnInput
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailLoadsOnInput.qml",
                    {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets && showLoadsOnInput
        }
    }
    MouseArea
    {
        id: acLoadsOnOutputTarget
        anchors.centerIn: acOutputBox
        enabled: parent.active && showLoadsOnOutput
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailLoadsOnOutput.qml",
                    {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets && showLoadsOnOutput
        }
    }
    MouseArea
    {
        id: pvOnInputTarget
        anchors.centerIn: pvInverterOnGrid
        enabled: parent.active && showPvOnGrid
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailPvInverter.qml",
                    {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets && showPvOnGrid
        }
    }
    MouseArea    
    {
        id: pvOnOutputTarget
        anchors.centerIn: pvInverterOnAcOut
        enabled: parent.active && showPvOnOutput
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailPvInverter.qml",
                    {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets && showPvOnOutput
        }
    }
   MouseArea
    {
        id: pvChargerTarget
        anchors.centerIn: blueSolarCharger
        enabled: parent.active && showPvCharger
        height: touchArea; width: touchArea
        onClicked: { rootWindow.pageStack.push ("/opt/victronenergy/gui/qml/DetailPvCharger.qml",
                    {backgroundColor: detailColor} ) }
        Rectangle
        {
            color: "black"
            anchors.fill: parent
            radius: width * 0.2
            opacity: touchTargetOpacity
            visible: showTargets && showPvCharger
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
    MouseArea
    {
        id: dcTarget
        anchors.centerIn: dcSystemBox
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
            visible: showTargets && showDcSystem
        }
    }

    // help message shown when menu is first drawn
    Rectangle
    {
        id: helpBox
        color: "white"
        width: multi.width
        height: 32
        opacity: 0.7
        anchors
        {
			verticalCenter: batteryMultiConnector.verticalCenter
            horizontalCenter: root.horizontalCenter
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


//////// debug
	property int debugButonHeight: (bottomOffset / 2) - 1
	property int debugButonWidth: (root.width / 7) - 1
	Row
	{
        spacing: 1
        anchors {horizontalCenter: parent.horizontalCenter; bottom: root.bottom}
        Column
        {
			spacing: 1
			MouseArea
			{
				enabled: true
				height: debugButonHeight ; width: debugButonWidth
				onClicked: hasAcInput = !hasAcInput
				Rectangle
				{
					color: hasAcInput ? "black" : "gray"
					anchors.fill: parent
				}
				TileText { text: "AC In" }
			}
			MouseArea
			{
				enabled: true
				height: debugButonHeight ; width: debugButonWidth
				onClicked: combineAcLoads = !combineAcLoads
				Rectangle
				{
					color: combineAcLoads ? "black" : "gray"
					anchors.fill: parent
				}
				TileText { text: "Comb Ld" }
			}
        }
        Column
        {
			spacing: 1
			MouseArea
			{
				enabled: true
				height: debugButonHeight ; width: debugButonWidth
				onClicked: debugLoadsOnInput = !debugLoadsOnInput
				Rectangle
				{
					color: debugLoadsOnInput ? "black" : "gray"
					anchors.fill: parent
				}
				TileText { text: "Load In" }
			}
			MouseArea
			{
				enabled: true
				height: debugButonHeight ; width: debugButonWidth
				onClicked: hasPvOnInput = !hasPvOnInput
				Rectangle
				{
					color: hasPvOnInput ? "black" : "gray"
					anchors.fill: parent
				}
				TileText { text: "PV In" }
			}
		}
        Column
        {
			spacing: 1
			MouseArea
			{
				enabled: true
				height: debugButonHeight ; width: debugButonWidth
				onClicked: hasLoadsOnOutput = !hasLoadsOnOutput
				Rectangle
				{
					color: hasLoadsOnOutput ? "black" : "gray"
					anchors.fill: parent
				}
				TileText { text: "Load Out" }
			}
			MouseArea
			{
				enabled: true
				height: debugButonHeight ; width: debugButonWidth
				onClicked: hasPvOnOutput = !hasPvOnOutput
				Rectangle
				{
					color: hasPvOnOutput ? "black" : "gray"
					anchors.fill: parent
				}
				TileText { text: "Pv Out" }
			}
		}
        Column
        {
			spacing: 1
			MouseArea
			{
				enabled: true
				height: debugButonHeight ; width: debugButonWidth
				onClicked: hasAlternator = !hasAlternator
				Rectangle
				{
					color: hasAlternator ? "black" : "gray"
					anchors.fill: parent
				}
				TileText { text: "Alt" }
			}
			MouseArea
			{
				enabled: true
				height: debugButonHeight ; width: debugButonWidth
				onClicked: hasPvCharger = !hasPvCharger
				Rectangle
				{
					color: hasPvCharger ? "black" : "gray"
					anchors.fill: parent
				}
				TileText { text: "Pv Chg" }
			}
		}
        Column
        {
			spacing: 1
			MouseArea
			{
				enabled: true
				height: debugButonHeight ; width: debugButonWidth
				onClicked: hasDcDcCharger = !hasDcDcCharger
				Rectangle
				{
					color: hasDcDcCharger ? "black" : "gray"
					anchors.fill: parent
				}
				TileText { text: "Dc Chg" }
			}
			MouseArea
			{
				enabled: true
				height: debugButonHeight ; width: debugButonWidth
				onClicked: hasAcCharger = !hasAcCharger
				Rectangle
				{
					color: hasAcCharger ? "black" : "gray"
					anchors.fill: parent
				}
				TileText { text: "Ac Chg" }
			}
		}
        Column
        {
			spacing: 1
			MouseArea
			{
				enabled: true
				height: debugButonHeight ; width: debugButonWidth
				onClicked: hasFuelCell = !hasFuelCell
				Rectangle
				{
					color: hasFuelCell ? "black" : "gray"
					anchors.fill: parent
				}
				TileText { text: "FC" }
			}
			MouseArea
			{
				enabled: true
				height: debugButonHeight ; width: debugButonWidth
				onClicked: hasWindGen = !hasWindGen
				Rectangle
				{
					color: hasWindGen ? "black" : "gray"
					anchors.fill: parent
				}
				TileText { text: "Wind" }
			}
		}
        Column
        {
			spacing: 1
			MouseArea
			{
				enabled: true
				height: debugButonHeight ; width: debugButonWidth
				onClicked: hasDcSystem = !hasDcSystem
				Rectangle
				{
					color: hasDcSystem ? "black" : "gray"
					anchors.fill: parent
				}
				TileText { text: "DC Sys" }
			}
			MouseArea
			{
				enabled: true
				height: debugButonHeight ; width: debugButonWidth
				onClicked: favorDcCoupled = !favorDcCoupled
				Rectangle
				{
					color: favorDcCoupled ? "black" : "gray"
					anchors.fill: parent
				}
				TileText { text: "Dc Pri" }
			}
		}
	}
}
