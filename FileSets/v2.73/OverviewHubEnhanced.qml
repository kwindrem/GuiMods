////// MODIFIED to show:
//////  tanks in a row along bottom
//////  PV voltage and current and DC power current (up to 2 MPPTs with tanks and temps or 3 without)
//////  PV inverter power (up to 2 with tanks and temps or 3 without)
//////  voltage, current, frequency in AC tiles (plus current limit for AC input)
//////  time of day
//////  current in DC Loads
//////  remaining time in Battery tile
//////  bar graphs on AC in/out and Multi
//////  detail pages for all tiles
//////  bar gauge on PV Charger tile
//////  add support for VE.Direct inverters

import QtQuick 1.1
import "utils.js" as Utils
////// ADDED to show tanks
import com.victron.velib 1.0
import "timeToGo.js" as TTG
import "enhancedFormat.js" as EnhFmt

OverviewPage {
	id: root

	property variant sys: theSystem

	property string systemPrefix: "com.victronenergy.system"
	property string guiModsPrefix: "com.victronenergy.settings/Settings/GuiMods"
	VBusItem { id: vebusService; bind: Utils.path(systemPrefix, "/VebusService") }
	property bool isMulti: vebusService.valid
	property string veDirectInverterService: ""
	property string inverterService: vebusService.valid ? vebusService.value : veDirectInverterService
	
	VBusItem { id: replaceAcInItem; bind: Utils.path(guiModsPrefix, "/ReplaceInactiveAcIn") }
	property bool hasAlternator: sys.alternator.power.valid
	property bool replaceAcIn: replaceAcInItem.valid && replaceAcInItem.value == 1 && hasAlternator && (sys.acSource == 0 || sys.acSource == 240)
	property bool showAcInput: ((isMulti || sys.acInput.power.valid) && ! replaceAcIn) || showAllTiles
	property bool showAlternator: !showAcInput && hasAlternator
	property double alternatorFlow: showAlternator ? noNoise (sys.alternator.power) : 0
	property bool showAcLoads: isMulti || sys.acLoad.power.valid || veDirectInverterService != ""
	property bool showDcSystem: (hasDcSystemItem.valid && hasDcSystemItem.value > 0) || showAllTiles
	property bool hasAcSolarOnAcIn1: sys.pvOnAcIn1.power.valid
	property bool hasAcSolarOnAcIn2: sys.pvOnAcIn2.power.valid
	property bool hasAcSolarOnIn: hasAcSolarOnAcIn1 || hasAcSolarOnAcIn2
	property bool hasAcSolarOnOut: sys.pvOnAcOut.power.valid
	property bool hasAcSolar: hasAcSolarOnIn || hasAcSolarOnOut
	property bool hasDcSolar: sys.pvCharger.power.valid
	property bool hasDcAndAcSolar: hasAcSolar && hasDcSolar
	property bool showDcAndAcSolar: hasDcAndAcSolar || showAllTiles
	property bool showDcSolar: hasDcSolar || showAllTiles
	property bool showAcSolar: hasAcSolar || showAllTiles
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
	property string pvChargerPrefix4: ""
	property string pvChargerPrefix5: ""
	property string pvChargerPrefix6: ""
	property string pvChargerPrefix7: ""
	property int numberOfPvChargers: 0
	property int pvChargerRows: showTanksTemps ? 4 : 7
	property int pvRowsPerCharger: Math.max ( 1, Math.min (pvChargerRows / numberOfPvChargers, 3))
	property bool pvChargerCompact: pvRowsPerCharger < 3 ? true : false
	property bool pvShowDetails: pvRowsPerCharger >= 2 ? true : false
	
//////// add for PV INVERTER power
	property string pvInverterPrefix1: ""
	property string pvInverterPrefix2: ""
	property string pvInverterPrefix3: ""
	property int numberOfPvInverters: 0

//////// add for alternator - alternator replaces AC in if AC in is not present
	property string alternatorPrefix1: ""
	property string alternatorPrefix2: ""
	property int numberOfAlternators: 0
	VBusItem { id: alternatorName1;  bind: Utils.path(alternatorPrefix1, "/CustomName") }
	VBusItem { id: alternatorPower1; bind: Utils.path(alternatorPrefix1, "/Dc/0/Power") }
	VBusItem { id: alternatorVoltage1; bind: Utils.path(alternatorPrefix1, "/Dc/0/Voltage") }
	VBusItem { id: alternatorCurrent1; bind: Utils.path(alternatorPrefix1, "/Dc/0/Current") }
	VBusItem { id: alternatorName2;  bind: Utils.path(alternatorPrefix2, "/CustomName") }
	VBusItem { id: alternatorPower2; bind: Utils.path(alternatorPrefix2, "/Dc/0/Power") }

//////// added for control show/hide gauges, tanks and temps from menus
	VBusItem { id: showGaugesItem; bind: Utils.path(guiModsPrefix, "/ShowGauges") }
	property bool showGauges: showGaugesItem.valid ? showGaugesItem.value === 1 ? true : false : false
	VBusItem { id: showTanksItem; bind: Utils.path(guiModsPrefix, "/ShowEnhancedFlowOverviewTanks") }
	property bool showTanksEnable: showTanksItem.valid ? showTanksItem.value === 1 ? true : false : false
	VBusItem { id: showTempsItem; bind: Utils.path(guiModsPrefix, "/ShowEnhancedFlowOverviewTemps") }
	property bool showTempsEnable: showTempsItem.valid ? showTempsItem.value === 1 ? true : false : false

//////// added to show/dim tiles
	VBusItem { id: showInactiveTilesItem; bind: Utils.path(guiModsPrefix, "/ShowInactiveFlowTiles") }
	property real disabledTileOpacity: (showInactiveTiles && showInactiveTilesItem.value === 1) ? 0.3 : 1
	property bool showInactiveTiles: showInactiveTilesItem.valid && showInactiveTilesItem.value >= 1

	VBusItem { id: showBatteryTempItem; bind: Utils.path(guiModsPrefix, "/ShowBatteryTempOnFlows") }
	property bool showBatteryTemp: showBatteryTempItem.valid && showBatteryTempItem.value == 1

	// for debug, ignore validity checks so all tiles and their flow lines will show
	property bool showAllTiles: showInactiveTilesItem.valid && showInactiveTilesItem.value == 3

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

//////// add to display individual PV charger power
	VBusItem { id: pvName1;  bind: Utils.path(pvChargerPrefix1, "/CustomName") }
	VBusItem { id: pvPower1; bind: Utils.path(pvChargerPrefix1, "/Yield/Power") }
	VBusItem { id: pvVoltage1;  bind: Utils.path(pvChargerPrefix1, "/Pv/V") }
	VBusItem { id: pvCurrent1; bind: Utils.path(pvChargerPrefix1, "/Pv/I") }
	VBusItem { id: pv1NrTrackers; bind: Utils.path(pvChargerPrefix1, "/NrOfTrackers") }
	VBusItem { id: pvName2;  bind: Utils.path(pvChargerPrefix2, "/CustomName") }
	VBusItem { id: pvPower2; bind: Utils.path(pvChargerPrefix2, "/Yield/Power") }
	VBusItem { id: pvVoltage2;  bind: Utils.path(pvChargerPrefix2, "/Pv/V") }
	VBusItem { id: pvCurrent2; bind: Utils.path(pvChargerPrefix2, "/Pv/I") }
	VBusItem { id: pv2NrTrackers; bind: Utils.path(pvChargerPrefix2, "/NrOfTrackers") }
	VBusItem { id: pvName3;  bind: Utils.path(pvChargerPrefix3, "/CustomName") }
	VBusItem { id: pvPower3; bind: Utils.path(pvChargerPrefix3, "/Yield/Power") }
	VBusItem { id: pvVoltage3;  bind: Utils.path(pvChargerPrefix3, "/Pv/V") }
	VBusItem { id: pvCurrent3; bind: Utils.path(pvChargerPrefix3, "/Pv/I") }
	VBusItem { id: pv3NrTrackers; bind: Utils.path(pvChargerPrefix3, "/NrOfTrackers") }
	VBusItem { id: pvName4;  bind: Utils.path(pvChargerPrefix4, "/CustomName") }
	VBusItem { id: pvPower4; bind: Utils.path(pvChargerPrefix4, "/Yield/Power") }
	VBusItem { id: pvName5;  bind: Utils.path(pvChargerPrefix5, "/CustomName") }
	VBusItem { id: pvPower5; bind: Utils.path(pvChargerPrefix5, "/Yield/Power") }
	VBusItem { id: pvName6;  bind: Utils.path(pvChargerPrefix6, "/CustomName") }
	VBusItem { id: pvPower6; bind: Utils.path(pvChargerPrefix6, "/Yield/Power") }
	VBusItem { id: pvName7;  bind: Utils.path(pvChargerPrefix7, "/CustomName") }
	VBusItem { id: pvPower7; bind: Utils.path(pvChargerPrefix7, "/Yield/Power") }

	VBusItem { id: timeToGo;  bind: Utils.path("com.victronenergy.system","/Dc/Battery/TimeToGo") }

//////// add to display PV Inverter power
	VBusItem { id: pvInverterPower1; bind: Utils.path(pvInverterPrefix1, "/Ac/Power") }
	VBusItem { id: pvInverterL1Power1; bind: Utils.path(pvInverterPrefix1, "/Ac/L1/Power") }
	VBusItem { id: pvInverterL2Power1; bind: Utils.path(pvInverterPrefix1, "/Ac/L2/Power") }
	VBusItem { id: pvInverterL3Power1; bind: Utils.path(pvInverterPrefix1, "/Ac/L3/Power") }
	VBusItem { id: pvInverterName1; bind: Utils.path(pvInverterPrefix1, "/CustomName") }
	VBusItem { id: pvInverterPower2; bind: Utils.path(pvInverterPrefix2, "/Ac/Power") }
	VBusItem { id: pvInverterName2; bind: Utils.path(pvInverterPrefix2, "/CustomName") }
	VBusItem { id: pvInverterPower3; bind: Utils.path(pvInverterPrefix3, "/Ac/Power") }
	VBusItem { id: pvInverterName3; bind: Utils.path(pvInverterPrefix3, "/CustomName") }

//////// add to display AC input ignored
	VBusItem { id: ignoreAcInput1; bind: Utils.path(inverterService, "/Ac/State/IgnoreAcIn1") }
	VBusItem { id: ignoreAcInput2; bind: Utils.path(inverterService, "/Ac/State/IgnoreAcIn2") }
	VBusItem { id: acActiveInput; bind: Utils.path(inverterService, "/Ac/ActiveIn/ActiveInput") }

	VBusItem { id: hasDcSystemItem; bind: "com.victronenergy.settings/Settings/SystemSetup/HasDcSystem" }

	Component.onCompleted: { discoverServices(); showHelp () }

	title: qsTr("Simple Overview")

	OverviewBox {
		id: acInBox
		titleColor: "#E74c3c"
		color: "#C0392B"
		opacity: showAcInput ? 1 : disabledTileOpacity
		visible: showAcInput || showInactiveTiles
		width: 148
		height: showStatusBar ? 100 : 120
		title:
		{
			// input 1 is active
			if (acActiveInput.value == 0)
			{
				if (ignoreAcInput1.valid && ignoreAcInput1.value == 1)
					return qsTr ("AC In 1 Ignored")
				else
					return getAcSourceName(sys.acSource)
			}
			// input 2 is active
			else if (acActiveInput.value == 1)
			{
				if (ignoreAcInput2.valid && ignoreAcInput2.value == 1)
					return qsTr ("AC In 2 Ignored")
				else
					return getAcSourceName(sys.acSource)
			}
			else
				return "no input"
		}
		anchors {
			top: multi.top
			left: parent.left; leftMargin: 10
		}

		values:	OverviewAcValuesEnhanced {
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
			useInputCurrentLimit: true
			maxForwardPowerParameter: ""
			maxReversePowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxFeedInPower"
			show: showGauges && showAcInput
		}
		DetailTarget { id: acInputTarget; detailsPage: "DetailAcInput.qml" }
	}

	//// add alternator if AC input not present
	OverviewBox {
		id: alternatorBox
 		title: qsTr ("Alternator") 
		color: "#157894"
		titleColor: "#419FB9"
		opacity: showAlternator ? 1 : disabledTileOpacity
		visible: showAlternator || showInactiveTiles && ! acInBox.visible
		width: 148
		height: showStatusBar ? 100 : 120
		anchors.fill: acInBox
		values: Column
		{
			width: parent.width
			TileText
			{
				text: " "
				font.pixelSize: 6
			}
			TileText
			{
				text: EnhFmt.formatVBusItem (sys.alternator.power, "W")
				font.pixelSize: 19
			}
			TileText
			{
				text: alternatorName1.valid ? alternatorName1.text : "-"
				visible: showAlternator && numberOfAlternators >= 1
			}
			TileText
			{
				text:  EnhFmt.formatVBusItem (alternatorPower1, "W")
				font.pixelSize: 15
				visible: showAlternator && numberOfAlternators > 1
			}
			TileText {
				text: EnhFmt.formatVBusItem (alternatorVoltage1, "V")
				font.pixelSize: 15
				visible: showAlternator && numberOfAlternators == 1
			}
			TileText {
				text: EnhFmt.formatVBusItem (alternatorCurrent1, "A")
				font.pixelSize: 15
				visible: showAlternator && numberOfAlternators == 1
			}
			TileText
			{
				text: alternatorName2.valid ? alternatorName2.text : "-"
				visible: showAlternator && numberOfAlternators >= 2
			}
			TileText
			{
				text:  EnhFmt.formatVBusItem (alternatorPower1, "W")
				font.pixelSize: 15
				visible: showAlternator && numberOfAlternators >= 2
			}
		}

		PowerGauge
		{
			id: alternatorBar
			width: parent.width
			height: 12
			anchors
			{
				top: parent.top; topMargin: 16
				horizontalCenter: parent.horizontalCenter
			}
			connection: sys.alternator
			maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxAlternatorPower"
			visible: showGauges && showAlternator
		}
		DetailTarget { id: alternatorTarget; detailsPage: "DetailAlternator.qml" }
	}

	MultiEnhanced {
		id: multi
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top; topMargin: 3
		}
		inverterService: root.inverterService
////// add power bar graph
		PowerGaugeMulti
		{
			id: multiBar
			width: multi.width
			height: 12
			anchors
			{
				top: parent.top; topMargin: 23
				horizontalCenter: parent.horizontalCenter
			}
			inverterService: root.inverterService
			show: showGauges
		}
		DetailTarget { id: multiTarget;  detailsPage: "DetailInverter.qml"; width: 60; height: 60 }
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
		visible: showAcLoads || showInactiveTiles
		opacity: showAcLoads ? 1 : disabledTileOpacity
		title: qsTr("AC Loads")
		color: "#27AE60"
		titleColor: "#2ECC71"
		width: 148
		height: showStatusBar ? 80 : 102

		anchors {
			right: parent.right; rightMargin: 10
			top: multi.top
		}

		values: OverviewAcValuesEnhanced {
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
			maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/AcOutputMaxPower"
			show: showGauges && showAcLoads
		}
		DetailTarget { id: loadsOnOutputTarget;  detailsPage: "DetailLoadsCombined.qml" }
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
                text: EnhFmt.formatVBusItem (sys.battery.voltage, "V  ", 2)
						+ EnhFmt.formatVBusItem (sys.battery.current, "A")
			}
			TileText {
				text: timeToGo.valid ? qsTr ("Remain: ") + TTG.formatTimeToGo (timeToGo) : qsTr (" ")
			}
		}
		DetailTarget { id: batteryTarget;  detailsPage: "DetailBattery.qml" }
	}

	VBusItem { id: dcSystemNameItem; bind: Utils.path(settingsBindPreffix, "/Settings/GuiMods/CustomDcSystemName") }

	OverviewBox {
		id: dcSystemBox
////// wider to make room for current
		width: multi.width + 20
		height: 45
		opacity: showDcSystem ? 1 : disabledTileOpacity
		visible: showDcSystem || showInactiveTiles
		title: dcSystemNameItem.valid && dcSystemNameItem.value != "" ? dcSystemNameItem.value : qsTr ("DC System")

		anchors {
			horizontalCenter: multi.horizontalCenter
			horizontalCenterOffset: 2
////// MODIFIED to show tanks
			bottom: parent.bottom; bottomMargin: showTanksTemps ? bottomOffset + 3 : 5
		}

		values:
		[
			TileText
			{
				width: parent.width
				anchors
				{
					horizontalCenter: parent.horizontalCenter
					bottom: parent.bottom; bottomMargin: 0
				}
	////// modified to show current
				text:
				{
					if (showDcSystem)
					{
						var current = ""
						if (sys.dcSystem.power.valid && sys.battery.voltage.valid)
							current = " " + EnhFmt.formatValue (sys.dcSystem.power.value / sys.battery.voltage.value, "A")
						return EnhFmt.formatVBusItem (sys.dcSystem.power) + current
					}
					else
						return "--"
				}
			}
		]
		PowerGauge
		{
			id: dcSystemGauge
			width: parent.width
			height: 8
			anchors
			{
				top: parent.top; topMargin: 19
				left: parent.left; leftMargin: 18
				right: parent.right
			}
			connection: sys.dcSystem
			maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/DcSystemMaxLoad"
			maxReversePowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/DcSystemMaxCharge"
			showLabels: true
			show: showGauges && showDcSystem

		}
		DetailTarget { id: dcSystemTarget;  detailsPage: "DetailDcSystem.qml" }
	}

	property int pvOffset1: 27
	property int pvRowSpacing: 16
	property int pvOffset2: pvOffset1 + pvRowSpacing * pvRowsPerCharger
	property int pvOffset3: pvOffset2 + pvRowSpacing * pvRowsPerCharger
	property int pvOffset4: pvOffset3 + pvRowSpacing * pvRowsPerCharger
	property int pvOffset5: pvOffset4 + pvRowSpacing * pvRowsPerCharger
	property int pvOffset6: pvOffset5 + pvRowSpacing * pvRowsPerCharger
	property int pvOffset7: pvOffset6 + pvRowSpacing * pvRowsPerCharger

////// replaced OverviewSolarCharger with OverviewBox
	OverviewBox {
		id: pvChargerBox
		title: qsTr("PV Charger")
		titleColor: "#F4B350"
		color: "#F39C12"
		visible: hasDcSolar || showInactiveTiles
		opacity: hasDcSolar ? 1 : disabledTileOpacity

////// MODIFIED to show tanks & provide extra space if not
		height:
		{
			var availableHeight = root.height - 3 - acLoadBox.height - 5 - (showTanksTemps ? bottomOffset + 3 : 5)
			if (showDcAndAcSolar)
				return ((availableHeight - 5) / 2) + 4
			else if (showDcSolar)
				return availableHeight
			else
				return 0
		}
		width: 148

		anchors {
			right: root.right; rightMargin: 10
			bottom: parent.bottom; bottomMargin: showTanksTemps ? bottomOffset + 3 : 5
		}

////// moved sun icon here from OverviewSolarChager so it can be put below text, etc
		MbIcon {
			iconId: "overview-sun"
			anchors {
				bottom: parent.bottom
				right: parent.right; rightMargin: 2
			}
			opacity: 0.5
			visible: ! showDcAndAcSolar
		}

//////// modified to add power for individual PV charger info
		values: 
		[
			TileText {
				y: 8
				text: EnhFmt.formatVBusItem (sys.pvCharger.power)
				font.pixelSize: 19
			},
			MarqueeEnhanced
			{
				y: pvOffset1
				id: pv1Name
				// ofset left margin for this row if showing tanks/temps
				width:
				{
					if (pvChargerCompact)
					{
						if (showTanksTemps)
							return ((parent.width / 2) - 15)
						else
							return ((parent.width / 2) - 5)
					}
					else
						return (parent.width - 10)
				}
				anchors.left: parent.left; anchors.leftMargin: (showTanksTemps && pvChargerCompact) ? 15 : 5
				height: 15
				text: pvName1.valid ? pvName1.value : "pv 1"
				textHorizontalAlignment: pvChargerCompact ? Text.AlignLeft : Text.AlignHCenter
				fontSize: 15
				Connections { target: scrollTimer; onTriggered: pv1Name.doScroll() }
				scroll: false
				visible: numberOfPvChargers >= 1 && ! showDcAndAcSolar
			},
			TileText {
				y: pvOffset1 + (pvChargerCompact ? 0 : pvRowSpacing)
				text: EnhFmt.formatVBusItem (pvPower1, "W")
				horizontalAlignment: pvChargerCompact ? Text.AlignRight : Text.AlignHCenter
				anchors.right: parent.right; anchors.rightMargin: 5
				font.pixelSize: 15
				visible: numberOfPvChargers >= 1 && ! showDcAndAcSolar
			},
			TileText {
				y: pvOffset1 + pvRowSpacing * (pvChargerCompact ? 1 : 2)
				text:
				{
					var voltageText, currentText
					if (root.numberOfPvChargers < 1)
						return " "
					else
					{
						if (pv1NrTrackers.valid && pv1NrTrackers.value > 1)
							return qsTr ("multiple trackers")
						else if (pvVoltage1.valid)
							voltageText = EnhFmt.formatVBusItem (pvVoltage1, "V")
						else
							voltageText = "??V"
						if (pvCurrent1.valid)
							currentText = EnhFmt.formatVBusItem (pvCurrent1, "A")
						else if (pvPower1.valid)
							currentText =  EnhFmt.formatValue ((pvPower1.value / pvVoltage1.value), "A")
						else
							currentText = "??A"
						return voltageText + " " + currentText
					}
				}
				font.pixelSize: 15
				visible: pvShowDetails && numberOfPvChargers >= 1
			},
			MarqueeEnhanced
			{
				y: pvOffset2
				id: pv2Name
				width: pvChargerCompact ? ((parent.width / 2) - 5) : parent.width - 10
				anchors.left: parent.left; anchors.leftMargin: 5
				height: 15
				text: pvName2.valid ? pvName2.value : "pv 2"
				textHorizontalAlignment: pvChargerCompact ? Text.AlignLeft : Text.AlignHCenter
				fontSize: 15
				Connections { target: scrollTimer; onTriggered: pv2Name.doScroll() }
				scroll: false
				visible: numberOfPvChargers >= 2 && ! showDcAndAcSolar
			},
			TileText {
				y: pvOffset2 + (pvChargerCompact ? 0 : pvRowSpacing)
				text: EnhFmt.formatVBusItem (pvPower2, "W")
				horizontalAlignment: pvChargerCompact ? Text.AlignRight : Text.AlignHCenter
				anchors.right: parent.right; anchors.rightMargin: 5
				font.pixelSize: 15
				visible: numberOfPvChargers >= 2 && ! showDcAndAcSolar
			},
			TileText {
				y: pvOffset2 + pvRowSpacing * (pvChargerCompact ? 1 : 2)
				text:
				{
					var voltageText, currentText
					if (root.numberOfPvChargers < 2)
						return " "
					else
					{
						if (pv2NrTrackers.valid && pv2NrTrackers.value > 1)
							return qsTr ("multiple trackers")
						else if (pvVoltage2.valid)
							voltageText = EnhFmt.formatVBusItem (pvVoltage2,  "V")
						else
							voltageText = "??V"
						if (pvCurrent2.valid)
							currentText = EnhFmt.formatVBusItem (pvCurrent2, "A")
						else if (pvPower2.valid)
							currentText =  EnhFmt.formatValue ((pvPower2.value / pvVoltage2.value), "A")
						else
							currentText = "??A"
						return voltageText + " " + currentText
					}
				}
				font.pixelSize: 15
				visible: pvShowDetails && numberOfPvChargers >= 2
			},
			MarqueeEnhanced
			{
				y: pvOffset4
				id: pv4Name
				// ofset left margin for this row if NOT showing tanks/temps
				width:
				{
					if (pvChargerCompact)
					{
						if (! showTanksTemps)
							return ((parent.width / 2) - 15)
						else
							return ((parent.width / 2) - 5)
					}
					else
						return (parent.width - 10)
				}
				anchors.left: parent.left; anchors.leftMargin: ( ! showTanksTemps && pvChargerCompact) ? 15 : 5
				height: 15
				text: pvName4.valid ? pvName4.value : "pv 4"
				textHorizontalAlignment: pvChargerCompact ? Text.AlignLeft : Text.AlignHCenter
				fontSize: 15
				Connections { target: scrollTimer; onTriggered: pv4Name.doScroll() }
				scroll: false
				visible: numberOfPvChargers >= 4 && ! showDcAndAcSolar
			},
			TileText {
				y: pvOffset4 + (pvChargerCompact ? 0 : pvRowSpacing)
				text: EnhFmt.formatVBusItem (pvPower4, "W")
				anchors.right: parent.right; anchors.rightMargin: 5
				horizontalAlignment: pvChargerCompact ? Text.AlignRight : Text.AlignHCenter
				font.pixelSize: 15
				visible: numberOfPvChargers >= 4 && ! showDcAndAcSolar
			},
			MarqueeEnhanced
			{
				y: pvOffset5
				id: pv5Name
				width: pvChargerCompact ? ((parent.width / 2) - 5) : parent.width - 10
				anchors.left: parent.left; anchors.leftMargin: 5
				height: 15
				text: pvName5.valid ? pvName5.value : "pv 5"
				textHorizontalAlignment: pvChargerCompact ? Text.AlignLeft : Text.AlignHCenter
				fontSize: 15
				Connections { target: scrollTimer; onTriggered: pv5Name.doScroll() }
				scroll: false
				visible: numberOfPvChargers >= 5 && pvChargerRows >= 5 && ! showDcAndAcSolar
			},
			TileText {
				y: pvOffset5 + (pvChargerCompact ? 0 : pvRowSpacing)
				text: EnhFmt.formatVBusItem (pvPower5, "W")
				anchors.right: parent.right; anchors.rightMargin: 5
				horizontalAlignment: pvChargerCompact ? Text.AlignRight : Text.AlignHCenter
				font.pixelSize: 15
				visible: numberOfPvChargers >= 5 && pvChargerRows >= 5 && ! showDcAndAcSolar
			},
			MarqueeEnhanced
			{
				y: pvOffset6
				id: pv6Name
				width: pvChargerCompact ? ((parent.width / 2) - 5) : parent.width - 10
				anchors.left: parent.left; anchors.leftMargin: 5
				height: 15
				text: pvName6.valid ? pvName6.value : "pv 6"
				textHorizontalAlignment: pvChargerCompact ? Text.AlignLeft : Text.AlignHCenter
				fontSize: 15
				Connections { target: scrollTimer; onTriggered: pv6Name.doScroll() }
				scroll: false
				visible: numberOfPvChargers >= 6 && pvChargerRows >= 6 && ! showDcAndAcSolar
			},
			TileText {
				y: pvOffset6 + (pvChargerCompact ? 0 : pvRowSpacing)
				text: EnhFmt.formatVBusItem (pvPower6, "W")
				anchors.right: parent.right; anchors.rightMargin: 5
				horizontalAlignment: pvChargerCompact ? Text.AlignRight : Text.AlignHCenter
				font.pixelSize: 15
				visible: numberOfPvChargers >= 6 && pvChargerRows >= 6 && ! showDcAndAcSolar
			},
  			MarqueeEnhanced
			{
				y: pvOffset7
				id: pv7Name
				width: pvChargerCompact ? ((parent.width / 2) - 5) : parent.width - 10
				anchors.left: parent.left; anchors.leftMargin: 5
				height: 15
				text: pvName7.valid ? pvName7.value : "pv 7"
				textHorizontalAlignment: pvChargerCompact ? Text.AlignLeft : Text.AlignHCenter
				fontSize: 15
				Connections { target: scrollTimer; onTriggered: pv6Name.doScroll() }
				scroll: false
				visible: numberOfPvChargers >= 7 && pvChargerRows >= 7 && ! showDcAndAcSolar
			},
			TileText {
				y: pvOffset7 + (pvChargerCompact ? 0 : pvRowSpacing)
				text: EnhFmt.formatVBusItem (pvPower7, "W")
				anchors.right: parent.right; anchors.rightMargin: 5
				horizontalAlignment: pvChargerCompact ? Text.AlignRight : Text.AlignHCenter
				font.pixelSize: 15
				visible: numberOfPvChargers >= 7 && pvChargerRows >= 7 && ! showDcAndAcSolar
			}
		]
////// add power bar graph
		PowerGauge
		{
			id: pvChargerBar
			width: parent.width - (showDcAndAcSolar && ! showTanksTemps ? 20 : 0)
			height: 10
			anchors
			{
				top: parent.top; topMargin: 19
				right: parent.right; rightMargin: 0.5
			}
			connection: sys.pvCharger
			maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/PvChargerMaxPower"
			show: showGauges && showDcSolar
		}
		DetailTarget { id: pvChargerTarget;  detailsPage: "DetailPvCharger.qml" }
	}

////// replaced OverviewSolarInverter with OverviewBox
	OverviewBox {
		id: pvInverter
		title: qsTr("PV Inverter")
		titleColor: "#F4B350"
		color: "#F39C12"
		visible: hasAcSolar || showInactiveTiles
		opacity: hasAcSolar ? 1 : disabledTileOpacity

////// MODIFIED to show tanks & provide extra space if not
		height:
		{
			var availableHeight = root.height - 3 - acLoadBox.height -5
			availableHeight -= (showTanksTemps ? bottomOffset + 3 : 5)
			if (showDcAndAcSolar)
				availableHeight -= pvChargerBox.height + 5
			if (showAcSolar)
				return availableHeight
			else
				return 0
		}
		width: 148

		anchors {
			right: root.right; rightMargin: 10;
			bottom: showDcAndAcSolar ? pvChargerBox.top : root.bottom
			bottomMargin: showDcAndAcSolar ? 5 : showTanksTemps ? bottomOffset + 3 : 5
		}

		values:
		[
			TileText {
				id: coupledPvAc

				property double pvInverterOnAcOut: sys.pvOnAcOut.power.valid ? sys.pvOnAcOut.power.value : 0
				property double pvInverterOnAcIn1: sys.pvOnAcIn1.power.valid ? sys.pvOnAcIn1.power.value : 0
				property double pvInverterOnAcIn2: sys.pvOnAcIn2.power.valid ? sys.pvOnAcIn2.power.value : 0
				property bool powerValid: sys.pvOnAcOut.power.valid || sys.pvOnAcIn1.power.valid || sys.pvOnAcIn2.power.valid

				y: 10
				text: powerValid ? EnhFmt.formatValue (pvInverterOnAcOut + pvInverterOnAcIn1 + pvInverterOnAcIn2, "W") : ""
				font.pixelSize: 19
				visible: showAcSolar
			},
//////// add individual PV inverter powers
			TileText {
				y: 31
				text: pvInverterName1.valid ? pvInverterName1.text : "-"
				visible: !showDcAndAcSolar && numberOfPvInverters >= 2
			},
			TileText {
				y: 47
				text: EnhFmt.formatVBusItem (pvInverterPower1, "W")
				font.pixelSize: 15
				visible: !showDcAndAcSolar && numberOfPvInverters >= 2
			},
			TileText {
				y: 63
				text: pvInverterName2.valid ? pvInverterName2.text : "-"
				visible: !showDcAndAcSolar && numberOfPvInverters >= 2
			},
			TileText {
				y: 77
				text: EnhFmt.formatVBusItem (pvInverterPower2, "W")
				font.pixelSize: 15
				visible: !showDcAndAcSolar && numberOfPvInverters >= 2
			},
			TileText {
				y: 93
				text: pvInverterName3.valid ? pvInverterName3.text : "-"
				visible: !showDcAndAcSolar && numberOfPvInverters >=3 && ! showTanksTemps
			},
			TileText {
				y: 107
				text: EnhFmt.formatVBusItem (pvInverterPower3, "W")
				font.pixelSize: 15
				visible: !showDcAndAcSolar && numberOfPvInverters >=3 && ! showTanksTemps
			},
			  TileText {
				y: 31
				text: qsTr ("L1: ") + EnhFmt.formatVBusItem (pvInverterL1Power1, "W")
				visible: !showDcAndAcSolar && numberOfPvInverters == 1 && pvInverterL1Power1.valid && (pvInverterL2Power1.valid || pvInverterL3Power1.valid)
			},
			  TileText {
				y: 47
				text: qsTr ("L2: ") + EnhFmt.formatVBusItem (pvInverterL2Power1, "W")
				visible: !showDcAndAcSolar && numberOfPvInverters == 1 && pvInverterL2Power1.valid
			},
			  TileText {
				y: 63
				text: qsTr ("L3: ") + EnhFmt.formatVBusItem (pvInverterL3Power1, "W")
				visible: !showDcAndAcSolar && numberOfPvInverters == 1 && pvInverterL3Power1.valid
			}
		]
////// add power bar graph
////// only shows one of possibly 3 PV inverter locations !!!!!!!!!!!!!!!!!!!!!
		PowerGauge
		{
			id: pvInverterBar
			width: parent.width
			height: 12
			anchors
			{
				top: parent.top; topMargin: 19
				horizontalCenter: parent.horizontalCenter
			}
			maxForwardPowerParameter:
			{
				if (hasAcSolarOnOut)
					return "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/PvOnOutputMaxPower"
				else
					return "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/PvOnGridMaxPower"
			}
			connection: hasAcSolarOnOut ? sys.pvOnAcOut : hasAcSolarOnAcIn1 ? sys.pvOnAcIn1 : sys.pvOnAcIn2
			visible: showGauges && showAcSolar && !showDcAndAcSolar
		}
		DetailTarget { id: pvInverterTarget;  detailsPage: "DetailPvInverter.qml" }
	}

	OverviewConnection {
		id: acInToMulti
		visible: showAcInput
		ballCount: 2
		path: straight
		active: root.active
		value: flow(sys.acInput ? sys.acInput.power : 0)

		anchors {
			left: acInBox.right; leftMargin: -10
			right: multi.left; rightMargin: -10; bottom: acInBox.bottom; bottomMargin: 25
		}
	}

	OverviewConnection {
		id: multiToAcLoads
		ballCount: 2
		path: straight
		active: root.active && ( showAcLoads || showAllTiles )
		value: flow(sys.acLoad.power)

		anchors {
			left: multi.right; leftMargin: -10;
			right: acLoadBox.left; rightMargin: -10
			bottom: acLoadBox.bottom; bottomMargin: 8
		}
	}

	OverviewConnection {
		id: pvInverterToMulti
		ballCount: 3
		path: corner
		active: root.active && showAcSolar
		value: Utils.sign(noNoise(sys.pvOnAcOut.power) + noNoise(sys.pvOnAcIn1.power) + noNoise(sys.pvOnAcIn2.power))

		anchors {
			left: pvInverter.left; leftMargin: 8
			top: pvInverter.verticalCenter; topMargin: showDcAndAcSolar ? 10 : 0
			right: multi.horizontalCenter; rightMargin: -20
			bottom: multi.bottom; bottomMargin: 10
		}
	}

	// invisible anchor point to connect the chargers to the battery
	Item {
		id: dcConnect
		anchors {
			left: multi.horizontalCenter; leftMargin: showAcSolar ? -20  : 0
			bottom: dcSystemBox.top; bottomMargin: showDcAndAcSolar ? 7 : 10
		}
	}

	OverviewConnection
	{
		id: dcBus2
		ballCount: 2
		path: straight
		active: root.active
		value: -Utils.sign (noNoise (sys.pvCharger.power) + noNoise (sys.vebusDc.power))
		startPointVisible: false
		endPointVisible: false

		anchors {
			right: dcConnect.left
			top: dcConnect.top

			left: multi.left; leftMargin: -10
			bottom: dcConnect.top
		}
	}

	OverviewConnection
	{
		id: alternatorToDcBus2
		ballCount: 3
		path: corner
		active: root.active && showAlternator
		value: Utils.sign (alternatorFlow)
		endPointVisible: false
		anchors
		{
			left: alternatorBox.right; leftMargin: -10
			top: alternatorBox.bottom; topMargin: -15

			right: dcBus2.left
			bottom: dcBus2.bottom
		}
	}

	OverviewConnection {
		id: multiToDcConnect
		ballCount: showTanksTemps ? 2 : 4
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
		id: pvChargerBoxDcConnect
		ballCount: 3
		path: straight
		active: root.active && showDcSolar
		value: -flow(sys.pvCharger.power)
		startPointVisible: false

		anchors {
			left: dcConnect.left
			top: dcConnect.top

			right: pvChargerBox.left; rightMargin: -8
			bottom: dcConnect.top;
		}
	}

	OverviewConnection {
		id: batteryToDcBus2
		ballCount: 1
		path: straight
		active: root.active
		value: Utils.sign(noNoise(sys.pvCharger.power) + noNoise(sys.vebusDc.power) + alternatorFlow)
		startPointVisible: false

		anchors {
			left: dcBus2.left
			top: dcBus2.top

			right: battery.right; rightMargin: 10
			bottom: dcBus2.top
		}
	}

	OverviewConnection {
		id: batteryToDcSystem
		ballCount: 2
		path: straight
		active: root.active && showDcSystem
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
			top: multi.bottom; topMargin: 7
			horizontalCenter: parent.horizontalCenter
		}
	}

////// ADDED to show tanks & temps
	// Synchronise tank name text scroll start and PV Charger name scroll
	Timer
	{
		id: scrollTimer
		interval: 15000
		repeat: true
		running: root.active
	}
	ListView
	{
		id: tanksColum

		visible: showTanks
		width: compact ? root.width : root.width * tankCount / tankTempCount
		property int tileWidth: width / Math.min (count, 5.2)
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
		delegate: TileTankEnhanced {
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
	ListModel { id: tanksModel }

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

	// When new service is found add resources as appropriate
	Connections
	{
		target: DBusServices
		onDbusServiceFound: addService(service)
	}

	// hack to get value(s) from within a loop inside a function when service is changing
	property string tempServiceName: ""
	property VBusItem temperatureItem: VBusItem { bind: Utils.path(tempServiceName, "/Dc/0/Temperature") }

	function addService(service)
	{
		 switch (service.type)
		{
//////// add for temp sensors
		case (service.type === DBusService.DBUS_SERVICE_TANK):
			tanksModel.append({serviceName: service.name})
			numberOfTanks++
			break;;
//////// add for temp sensors
		case DBusService.DBUS_SERVICE_TEMPERATURE_SENSOR:
			numberOfTemps++
			tempsModel.append({serviceName: service.name})
			break;;
		case DBusService.DBUS_SERVICE_MULTI:
			root.tempServiceName = service.name
			if (temperatureItem.valid && showBatteryTemp)
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
		case DBusService.DBUS_SERVICE_MULTI_RS:
			numberOfPvChargers++
			if (numberOfPvChargers === 1)
				pvChargerPrefix1 = service.name;
			else if (numberOfPvChargers === 2)
				pvChargerPrefix2 = service.name;
			else if (numberOfPvChargers === 3)
				pvChargerPrefix3 = service.name;
			else if (numberOfPvChargers === 4)
				pvChargerPrefix4 = service.name;
			else if (numberOfPvChargers === 5)
				pvChargerPrefix5 = service.name;
			else if (numberOfPvChargers === 6)
				pvChargerPrefix6 = service.name;
			else if (numberOfPvChargers === 7)
				pvChargerPrefix7 = service.name;
			break;;

//////// add for PV INVERTER power display
		case DBusService.DBUS_SERVICE_PV_INVERTER:
			numberOfPvInverters++
			if (numberOfPvInverters === 1)
				pvInverterPrefix1 = service.name;
			else if (numberOfPvInverters === 2)
				pvInverterPrefix2 = service.name;
			else if (numberOfPvInverters === 3)
				pvInverterPrefix3 = service.name;
			break;;
		case DBusService.DBUS_SERVICE_BATTERY:
			root.tempServiceName = service.name
			if (temperatureItem.valid && showBatteryTemp)
			{
				numberOfTemps++
				tempsModel.append({serviceName: service.name})
			}
			break;;
 //////// add for alternator
		case DBusService.DBUS_SERVICE_ALTERNATOR:
			numberOfAlternators++
			if (numberOfAlternators === 1)
				alternatorPrefix1 = service.name;
			else if (numberOfAlternators === 2)
				alternatorPrefix2 = service.name;
			break;;
		}
	}

	// Detect available services of interest
	function discoverServices()
	{
		numberOfTanks = 0
		numberOfTemps = 0
		numberOfPvChargers = 0
		numberOfPvInverters = 0
		numberOfAlternators = 0
		veDirectInverterService = ""
		pvChargerPrefix1 = ""
		pvChargerPrefix2 = ""
		pvChargerPrefix3 = ""
		pvChargerPrefix4 = ""
		pvChargerPrefix5 = ""
		pvChargerPrefix6 = ""
		pvChargerPrefix7 = ""
		pvInverterPrefix1 = ""
		pvInverterPrefix2 = ""
		pvInverterPrefix3 = ""
		alternatorPrefix1 = ""
		alternatorPrefix2 = ""
		tanksModel.clear()
		tempsModel.clear()
		for (var i = 0; i < DBusServices.count; i++)
		{
			addService(DBusServices.at(i))
		}
	}

// Details targets

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
			top: multi.bottom; topMargin: 1
			horizontalCenter: root.horizontalCenter
		}
		visible: false
		TileText
		{
			text: qsTr ( "Tap tile center for detail at any time" )
			color: "black"
			anchors.fill: helpBox
			wrapMode: Text.WordWrap
			font.pixelSize: 12
			visible: parent.visible
		}
	}

	//// hard key handler
	//		used to press buttons when touch isn't available
	//		UP and DOWN buttons cycle through the list of touch areas
	//		"space" button is used to simulate a touch on the area
	//		target must be highlighted so that other uses of "space"
	//		will still occur

	// list of all details touchable areas
	property variant targetList:
	[
		acInputTarget, alternatorTarget, batteryTarget,
		multiTarget, dcSystemTarget,
		loadsOnOutputTarget, pvInverterTarget, pvChargerTarget 
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
			if (targetList[newIndex].enabled)
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
		{
			targetList[i].targetVisible = false
		}
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
		helpBox.visible = false
		targetTimer.restart ()
	}
}
