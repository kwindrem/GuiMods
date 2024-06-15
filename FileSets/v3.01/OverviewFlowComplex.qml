///// Enhanced DC Coupled / AC Coupled Overview for GuiMods

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0
import "timeToGo.js" as TTG
import "enhancedFormat.js" as EnhFmt

OverviewPage {
	id: root

////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 1

	VBusItem { id: flowOverviewItem; bind: Utils.path(settingsPrefix, "/Settings/GuiMods/FlowOverview") }
	property bool dcCoupled: flowOverviewItem.valid && flowOverviewItem.value == 2

    VBusItem { id: showInactiveTilesItem; bind: Utils.path(guiModsPrefix, "/ShowInactiveFlowTiles") }
    property real disabledTileOpacity: (showInactiveTiles && showInactiveTilesItem.value === 1) ? 0.3 : 1
    property bool showInactiveTiles: showInactiveTilesItem.valid && showInactiveTilesItem.value >= 1
    property bool showInactiveFlow: showInactiveTilesItem.valid && showInactiveTilesItem.value == 3

	property variant sys: theSystem
	property string systemPrefix: "com.victronenergy.system"
	property string settingsPrefix: "com.victronenergy.settings"
    property color detailColor: "#b3b3b3"
	property real laneWidth: (root.width - inOutTileWidth * 2 - battery.width) / 3

    property int inOutTileHeight: (root.height - topOffset - bottomOffset - 3 * 5) / 4
    property int inOutTileWidth: 145
    VBusItem { id: timeToGo;  bind: Utils.path(systemPrefix, "/Dc/Battery/TimeToGo") }

	VBusItem { id: vebusService; bind: Utils.path(systemPrefix, "/VebusService") }
    property bool isMulti: vebusService.valid
    property string veDirectInverterService: ""
    property string inverterService: vebusService.valid ? vebusService.value : veDirectInverterService

    property bool combineAcLoads: dcCoupled || _combineAcLoads.valid && _combineAcLoads.value === 1
    property variant outputLoad: combineAcLoads ? sys.acLoad : sys.acOutLoad

	// for debug, ignore validity checks so all tiles and their flow lines will show
    property bool showAllTiles: showInactiveTilesItem.valid && showInactiveTilesItem.value == 3

	property bool hasInverter: false
	property bool showInverter: hasInverter || showAllTiles

    property bool showLoadsOnOutput: showInverter || outputLoad.power.valid
    property bool showAcInput: isMulti || sys.acInput.power.valid || showAllTiles
	property bool hasLoadsOnInput: showAcInput && ! combineAcLoads && (! loadsOnInputItem.valid || loadsOnInputItem.value === 1)
    property bool showLoadsOnInput: !dcCoupled && hasLoadsOnInput
	property bool hasPvOnInput: sys.pvOnGrid.power.valid
	property bool showPvOnInput: (!dcCoupled || !hasAcCharger) && hasPvOnInput
	property bool hasPvOnOutput: sys.pvOnAcOut.power.valid
    property bool showPvOnOutput: (!dcCoupled || !hasFuelCell) && hasPvOnOutput
	property bool showPvCharger: sys.pvCharger.power.valid
    property bool showDcSystem: (hasDcSystemItem.valid && hasDcSystemItem.value > 0) || showAllTiles
    property bool showAlternator: (dcCoupled || !hasLoadsOnInput) && sys.alternator.power.valid
	property bool hasFuelCell: sys.fuelCell.power.valid
    property bool showFuelCell: (dcCoupled || !hasPvOnOutput) && hasFuelCell
    property bool showWindGen: sys.windGenerator.power.valid
	property bool hasAcCharger: sys.acCharger != undefined && sys.acCharger.power.valid
    property bool showAcCharger: (dcCoupled  || !hasPvOnInput) && hasAcCharger

	VBusItem { id: motorDrivePowerItem; bind: Utils.path(systemPrefix, "/Dc/MotorDrive/Power") }
    property bool showMotorDrive: (dcCoupled || !hasLoadsOnInput) && ! showAlternator && motorDrivePowerItem.valid

    property int bottomOffset: showTanksTemps ? 45 : 5
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

    VBusItem { id: ignoreAcInput1; bind: Utils.path(inverterService, "/Ac/State/IgnoreAcIn1") }
    VBusItem { id: ignoreAcInput2; bind: Utils.path(inverterService, "/Ac/State/IgnoreAcIn2") }
    VBusItem { id: acActiveInput; bind: Utils.path(inverterService, "/Ac/ActiveIn/ActiveInput") }

    property string guiModsPrefix: "com.victronenergy.settings/Settings/GuiMods"
    VBusItem { id: showGaugesItem; bind: Utils.path(guiModsPrefix, "/ShowGauges") }
    property bool showGauges: showGaugesItem.valid ? showGaugesItem.value === 1 ? true : false : false
    VBusItem { id: showTanksItem; bind: Utils.path(guiModsPrefix, "/ShowEnhancedFlowOverviewTanks") }
    property bool showTanksEnable: showTanksItem.valid ? showTanksItem.value === 1 ? true : false : false
    VBusItem { id: showTempsItem; bind: Utils.path(guiModsPrefix, "/ShowEnhancedFlowOverviewTemps") }
    property bool showTempsEnable: showTempsItem.valid ? showTempsItem.value === 1 ? true : false : false

	VBusItem { id: hasDcSystemItem;  bind: "com.victronenergy.settings/Settings/SystemSetup/HasDcSystem" }

    VBusItem { id: timeFormatItem; bind: Utils.path(guiModsPrefix, "/TimeFormat") }
    property string timeFormat: getTimeFormat ()

	property double acInputFlow: showAcInput ? noNoise (sys.acInput.power) : 0
	property VBusItem vebusAcPower: VBusItem { bind: [sys.vebusPrefix, "/Ac/ActiveIn/P"] }
	property double multiAcInputFlow: isMulti ? -noNoise (vebusAcPower) : 0
	property double pvOnInputFlow: showPvOnInput ? noNoise (sys.pvOnGrid.power) : 0
	property double loadsOnInputFlow: sys.acInLoad.power.valid ? -noNoise (sys.acInLoad.power) : 0
	property double pvInverterOnAcOutFlow: showPvOnOutput && sys.pvOnAcOut.power.valid ? noNoise (sys.pvOnAcOut.power) : 0
	property double acOutLoadFlow: sys.acOutLoad.power.valid ? -noNoise (sys.acOutLoad.power) : 0

	property double pvChargerFlow: showPvCharger ? noNoise (sys.pvCharger.power) : 0
	property double dcSystemFlow: showDcSystem ? -noNoise (sys.dcSystem.power) : 0
	property double alternatorFlow: showAlternator ? noNoise (sys.alternator.power) : 0
	property double motorDriveFlow: showMotorDrive ? noNoise (motorDrivePowerItem) : 0
	property double inverterDcFlow: showInverter ? noNoise (sys.vebusDc.power) : 0
	property double batteryFlow: noNoise (sys.battery.power)
	property double windGenFlow: noNoise (sys.windGenerator.power)
	property double acChargerFlow: noNoise (sys.acCharger.power)
	property double fuelCellFlow: noNoise (sys.fuelCell.power)

    VBusItem { id: showBatteryTempItem; bind: Utils.path(guiModsPrefix, "/ShowBatteryTempOnFlows") }
    property bool showBatteryTemp: showBatteryTempItem.valid && showBatteryTempItem.value == 1


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
		showHelp ()
	}

	title: dcCoupled ? qsTr("DC Coupled overview") :  qsTr("AC Coupled overview")

    VBusItem { id: loadsOnInputItem; bind: "com.victronenergy.settings/Settings/GuiMods/ShowEnhancedFlowLoadsOnInput" }
    VBusItem { id: _combineAcLoads; bind: "com.victronenergy.settings/Settings/GuiMods/EnhancedFlowCombineLoads" }

	OverviewBox {
		id: acInBox
        opacity: showAcInput ? 1 : disabledTileOpacity
        visible: showAcInput || showInactiveTiles
		width: inOutTileWidth
		height: inOutTileHeight
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
////// GuiMods — DarkMode
		titleColor: !darkMode ? "#E74c3c" : "#73261E"
		color: !darkMode ? "#C0392B" : "#601C15"
		anchors {
			top: root.top; topMargin: topOffset
			left: parent.left; leftMargin: 5
		}
		values: TileText {
			y: 13
			text: EnhFmt.formatVBusItem (sys.acInput.power)
			font.pixelSize: 17
            visible: showAcInput
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
			useInputCurrentLimit: true
            maxForwardPowerParameter: ""
            maxReversePowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxFeedInPower"
            visible: showGauges && showAcInput
        }
		DetailTarget { id: acInputTarget; detailsPage: "DetailAcInput.qml" }
	}

	OverviewBox
	{
		id: pvInverterOnInput
////// GuiMods — DarkMode
		titleColor: !darkMode ? "#F4B350" : "#7A5928"
		color: !darkMode ? "#F39C12" : "#794E09"
		title: qsTr("PV on Input")
		width: inOutTileWidth
		height: inOutTileHeight
		visible: showPvOnInput || (showInactiveTiles && !dcCoupled)
        opacity: showPvOnInput ? 1 : disabledTileOpacity
		MbIcon
		{
			source:
			{
				var ids = sys.pvInvertersProductIds.text
				if (ids.indexOf(0xA142) > -1)
					return "image://theme/overview-fronius-logo"
				return ""
			}
            visible: showPvOnInput
            opacity: 0.3
            anchors {
                bottom: parent.bottom
                left: parent.left
				margins: 2
			}
		}
		values: TileText {
			y: 11
			text: EnhFmt.formatVBusItem (sys.pvOnGrid.power)
			font.pixelSize: 17
            visible: showPvOnInput
		}
		anchors {
			top: acInBox.bottom
			topMargin: 5
			left: acInBox.left
		}
        PowerGauge
        {
            id: pvInverterOnInputGauge
            width: parent.width
            height: 15
            anchors
            {
                top: parent.top; topMargin: 18
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.pvOnGrid
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/PvOnGridMaxPower"
            visible: showGauges && showPvOnInput
        }
		DetailTarget { id: pvOnInputTarget; detailsPage: "DetailPvInverter.qml" }
	}

	OverviewBox {
		id: acLoadOnInputBox
		title: qsTr("AC In Loads")
////// GuiMods — DarkMode
		color: !darkMode ? "#27AE60" : "#135730"
		titleColor: !darkMode ? "#2ECC71" : "#176638"
		width: inOutTileWidth
		height: inOutTileHeight
        opacity: showLoadsOnInput ? 1 : disabledTileOpacity
		visible: showLoadsOnInput || (showInactiveTiles && !dcCoupled)
		anchors {
			top: pvInverterOnInput.bottom
			topMargin: 5
			left: acInBox.left
		}
		values: TileText {
			y: 13
			text: EnhFmt.formatVBusItem (sys.acInLoad.power)
			font.pixelSize: 17
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
            visible: showGauges && showLoadsOnInput
        }
		DetailTarget { id: acLoadsOnInputTarget; detailsPage: "DetailLoadsOnInput.qml" }
	}

    // check inverter to see if AC out 2 exists and hide noncritical loads if so
    VBusItem { id: inverterOut2Item; bind: Utils.path(root.inverterService, "/Ac/Out/L2/V") }

	OverviewBox {
		id: acOutputBox
		title: combineAcLoads ? qsTr ("AC Loads") : qsTr ("AC Out Loads")
////// GuiMods — DarkMode
		color: !darkMode ? "#27AE60" : "#135730"
		titleColor: !darkMode ? "#2ECC71" : "#176638"
		height: inOutTileHeight
		width: inOutTileWidth
        opacity: showLoadsOnOutput ? 1 : disabledTileOpacity
		visible: showLoadsOnOutput || showInactiveTiles
		anchors {
			right: root.right; rightMargin: 5
			top: root.top; topMargin: topOffset
		}

        values: TileText {
			y: 13
			text: EnhFmt.formatVBusItem (outputLoad.power)
			font.pixelSize: 17
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
            visible: showGauges && showLoadsOnOutput
        }
		DetailTarget { id: acLoadsOnOutputTarget; detailsPage: "DetailLoadsOnOutput.qml" }
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

	MultiEnhancedGP {
		id: multi
		iconId: "overview-inverter-short"
		visible: showInverter
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
                horizontalCenter: multi.horizontalCenter
            }
            inverterService: root.inverterService
			visible: showGauges && showInverter
        }
		DetailTarget { id: multiTarget; detailsPage: "DetailInverter.qml"; width: 60; height: 60 }
	}
    TileText
    {
        text: wallClock.time
		color: showInverter || darkMode ? "white" : "black"
        width: inOutTileWidth
        wrapMode: Text.WordWrap
        font.pixelSize: 16
        anchors
        {
			bottom: multi.bottom; bottomMargin: 1
            horizontalCenter: multi.horizontalCenter;
            horizontalCenterOffset: multiDcConnector.active ? -10 : 0
        }
        visible: wallClock.running
    }

	Battery {
		id: battery

		soc: sys.battery.soc.valid ? sys.battery.soc.value : 0
		height: 99
		width: 145

		anchors {
			bottom: parent.bottom; bottomMargin: bottomOffset;
			right: acOutputBox.left; rightMargin: laneWidth
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
            visible: showGauges
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
                text: EnhFmt.formatVBusItem (sys.battery.voltage, "V  ", 2)
						+ EnhFmt.formatVBusItem (sys.battery.current, "A")
            }
            TileText {
                text: EnhFmt.formatVBusItem (sys.battery.power)
                font.pixelSize: 17
                height: 19
            }
		}
		DetailTarget { id: batteryTarget; detailsPage: "DetailBattery.qml" }
	}

	OverviewBox
	{
		id: pvInverterOnAcOut
////// GuiMods — DarkMode
		titleColor: !darkMode ? "#F4B350" : "#7A5928"
		color: !darkMode ? "#F39C12" : "#794E09"
		title: qsTr("PV on Output")
		width: inOutTileWidth
		height: inOutTileHeight
        opacity: showPvOnOutput ? 1 : disabledTileOpacity
		visible: showPvOnOutput || (showInactiveTiles && !dcCoupled)
		MbIcon
		{
			source:
			{
				var ids = sys.pvInvertersProductIds.text
				if (ids.indexOf(0xA142) > -1)
					return "image://theme/overview-fronius-logo"
				return ""
			}
            visible: showPvOnOutput
            opacity: 0.3
            anchors {
                bottom: parent.bottom
                right: parent.right
				margins: 2
			}
		}

		values: TileText {
			y: 11
			text: EnhFmt.formatVBusItem (sys.pvOnAcOut.power)
			font.pixelSize: 17
            visible: showPvOnOutput
		}
		anchors {
            top: acOutputBox.bottom
            topMargin: 5
			right: acOutputBox.right
		}
        PowerGauge
        {
            id: pvInverterOnAcOutGauge
            width: parent.width
            height: 15
            anchors
            {
                top: parent.top; topMargin: 18
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.pvOnAcOut
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/PvOnOutputMaxPower"
            visible: showGauges && showPvOnOutput
        }
		DetailTarget { id: pvOnOutputTarget; detailsPage: "DetailPvInverter.qml" }
	}

    OverviewBox
    {
        id: acChargerBox
        title: qsTr ("AC Charger")
////// GuiMods — DarkMode
		color: !darkMode ? "#157894" : "#0a3c4a"
		titleColor: !darkMode ? "#419FB9" : "#204f5c"
		height: inOutTileHeight
		width: inOutTileWidth
        opacity: showAcCharger ? 1 : disabledTileOpacity
		visible: showAcCharger || (showInactiveTiles && dcCoupled)
		anchors
		{
            left: root.left; leftMargin: 5
            bottom: alternatorBox.top; bottomMargin: 5
        }
		values: TileText {
            text: EnhFmt.formatVBusItem (sys.acCharger.power)
            font.pixelSize: 17
            visible: showAcCharger
            anchors
            {
                bottom: parent.bottom; bottomMargin: 0
                horizontalCenter: parent.horizontalCenter
            }
        }
        PowerGauge
        {
            id: acChargerGauge
            width: parent.width
            height: 10
            anchors
            {
                top: parent.top; topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.acCharger
            reversePower: true
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxAcChargerPower"
            visible: showGauges && showAcCharger
        }
		DetailTarget { id: acChargerTarget; detailsPage: "DetailAcCharger.qml" }
    }

    OverviewBox
    {
        id: alternatorBox
        title: qsTr ("Alternator")
////// GuiMods — DarkMode
		color: !darkMode ? "#157894" : "#0a3c4a"
		titleColor: !darkMode ? "#419FB9" : "#204f5c"
		height: inOutTileHeight
		width: inOutTileWidth
        opacity: showAlternator ? 1 : disabledTileOpacity
		visible: showAlternator || (showInactiveTiles && dcCoupled)
		anchors
		{
            left: root.left; leftMargin: 5
            bottom: pvChargerBox.top; bottomMargin: 5
        }
		values: TileText {
            text: EnhFmt.formatVBusItem (sys.alternator.power)
            font.pixelSize: 17
            visible: showAlternator
            anchors
            {
                bottom: parent.bottom; bottomMargin: 0
                horizontalCenter: parent.horizontalCenter
            }
        }
        PowerGauge
        {
            id: alternatorGauge
            width: parent.width
            height: 10
            anchors
            {
                top: parent.top; topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.alternator
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxAlternatorPower"
            visible: showGauges && showAlternator
        }
		DetailTarget { id: alternatorTarget; detailsPage: "DetailAlternator.qml" }
    }

    OverviewBox
    {
        id: motorDriveBox
        title: qsTr ("Motor Drive")
////// GuiMods — DarkMode
		color: !darkMode ? "#157894" : "#0a3c4a"
		titleColor: !darkMode ? "#419FB9" : "#204f5c"
		height: inOutTileHeight
		width: inOutTileWidth
        opacity: showMotorDrive ? 1 : disabledTileOpacity
		visible: showMotorDrive
		anchors
		{
            left: root.left; leftMargin: 5
            bottom: pvChargerBox.top; bottomMargin: 5
        }
		values: TileText {
            text: EnhFmt.formatVBusItem (motorDrivePowerItem)
            font.pixelSize: 17
            visible: showMotorDrive
            anchors
            {
                bottom: parent.bottom; bottomMargin: 0
                horizontalCenter: parent.horizontalCenter
            }
        }
        PowerGauge
        {
            id: motorDriveGauge
            width: parent.width
            height: 10
            anchors
            {
                top: parent.top; topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            connection: motorDrivePowerItem
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxMotorDriveLoad"
            maxReversePowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxMotorDriveCharge"
            visible: showGauges && showMotorDrive
            showLabels: true
        }
		DetailTarget { id: motorDriveTarget; detailsPage: "DetailMotorDrive.qml" }
    }

    VBusItem { id: dcSystemNameItem; bind: Utils.path(settingsPrefix, "/Settings/GuiMods/CustomDcSystemName") }

    OverviewBox {
        id: dcSystemBox
        width: inOutTileWidth
        height: inOutTileHeight
        opacity: showDcSystem ? 1 : disabledTileOpacity
		visible: showDcSystem || showInactiveTiles
        title: dcSystemNameItem.valid && dcSystemNameItem.value != "" ? dcSystemNameItem.value : qsTr ("DC System")
		anchors
		{
			right: root.right; rightMargin: 5
            bottom: parent.bottom
            bottomMargin: bottomOffset
		}
		values: TileText {
            text: EnhFmt.formatVBusItem (sys.dcSystem.power)
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
            showLabels: true
            visible: showGauges && showDcSystem
        }
		DetailTarget { id: dcSystemTarget; detailsPage: "DetailDcSystem.qml" }
    }

    OverviewBox {
        id: fuelCellBox
////// GuiMods — DarkMode
		color: !darkMode ? "#157894" : "#0a3c4a"
		titleColor: !darkMode ? "#419FB9" : "#204f5c"
        width: inOutTileWidth
        height: inOutTileHeight
        opacity: showFuelCell ? 1 : disabledTileOpacity
		visible: showFuelCell || (showInactiveTiles && dcCoupled)
        title: qsTr ("Fuel Cell")
        anchors {
            left: windGenBox.left
            bottom: windGenBox.top; bottomMargin: 5
        }
		values: TileText {
            text: EnhFmt.formatVBusItem (sys.fuelCell.power)
            font.pixelSize: 17
            visible: fuelCellBox.visible
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
            connection: sys.fuelCell
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxFuelCellPower"
            visible: showGauges && fuelCellBox.visible
        }
		DetailTarget { id: fuelCellTarget; detailsPage: "DetailFuelCell.qml" }
    }

    OverviewBox {
        id: windGenBox
////// GuiMods — DarkMode
		color: !darkMode ? "#157894" : "#0a3c4a"
		titleColor: !darkMode ? "#419FB9" : "#204f5c"
        width: inOutTileWidth
        height: inOutTileHeight
        opacity: showWindGen ? 1 : disabledTileOpacity
		visible: showWindGen || showInactiveTiles
        title: qsTr ("Wind Generator")
		anchors
		{
            right: dcSystemBox.right
            bottom: dcSystemBox.top; bottomMargin: 5
        }
		values: TileText {
            text: EnhFmt.formatVBusItem (sys.windGenerator.power)
            font.pixelSize: 17
            visible: showWindGen
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
            connection: sys.windGenerator
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxWindGenPower"
            visible: showGauges && showWindGen
        }
		DetailTarget { id: windGenTarget; detailsPage: "DetailWindGen.qml" }
    }

    OverviewBox {
		id: pvChargerBox
		title: qsTr("PV Charger")
////// GuiMods — DarkMode
		titleColor: !darkMode ? "#F4B350" : "#7A5928"
		color: !darkMode ? "#F39C12" : "#794E09"
		width: inOutTileWidth
		height: inOutTileHeight
        opacity: showPvCharger ? 1 : disabledTileOpacity
		visible: showPvCharger || showInactiveTiles
		anchors
		{
            left: root.left; leftMargin: 5
            bottom: parent.bottom; bottomMargin: bottomOffset
        }
		values: TileText {
			y: 12
			text: EnhFmt.formatVBusItem (sys.pvCharger.power)
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
                top: parent.top; topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.pvCharger
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/PvChargerMaxPower"
            visible: showGauges && showPvCharger
        }
		DetailTarget { id: pvChargerTarget; detailsPage: "DetailPvCharger.qml" }
	}

	// move ESS reason to Battery details page

	// invisible item to connection all AC input connections to..
	Item {
		id: acInBus
		width: laneWidth
		anchors {
			left: acInBox.right;
			top: multi.top; topMargin: multi.height / 2 + 10
			bottom: pvInverterOnInput.bottom; bottomMargin: 8
		}
	}
	Item {
		id: dcLaneLeft
		width: laneWidth
		anchors {
			right: battery.left;
			top: multi.top; topMargin: multi.height / 2 + 10
			bottom: dcSystemBox.bottom; bottomMargin: 8
		}
	}
	Item {
		id: dcLaneRight
		width: laneWidth * 0.8
		anchors {
			left: battery.right;

			top: dcLaneLeft.top
			bottom: dcLaneLeft.bottom
		}
	}
	Item {
		id: dcLaneTop
		anchors {
			left: battery.left
			right: battery.right
			top: multi.bottom;
			bottom: battery.top
		}
	}

	OverviewConnection {
		id: multiAcInFlow
		ballCount: 1
		path: straight
		active: root.active && ( showAcInput || showPvOnInput || showLoadsOnInput )
		value: -Utils.sign (multiAcInputFlow)
		startPointVisible: false
		endPointVisible: true

		anchors {
			left: acInBus.horizontalCenter; leftMargin: -0.5
			right: multi.left; rightMargin: -8
			bottom: acInBus.top
		}
	}

	// AC source power flow
	OverviewConnection {
		id: acSource
		ballCount: 1
		path: corner
		active: root.active && showAcInput
		value: Utils.sign (acInputFlow)
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
		ballCount: 1
		path: straight
		active: root.active && ((showLoadsOnInput && showPvOnInput) || (!dcCoupled && showInactiveFlow))
		value: -Utils.sign (pvOnInputFlow + loadsOnInputFlow)
		startPointVisible: false
		endPointVisible: false

		anchors {
			right: acInBus.horizontalCenter
            rightMargin: 0.5 // makes this line up with others
			top: acInBus.top
			bottom: acInBus.bottom
		}
	}

	// Grid inverter power flow
	OverviewConnection {
		id: pvInverterOnInputConnection
		ballCount: showLoadsOnInput ? 1 : 2
		path: showLoadsOnInput || (!dcCoupled && showInactiveFlow) ? straight : corner
		active: root.active && (showPvOnInput || (!dcCoupled && showInactiveFlow))
		value: Utils.sign (pvOnInputFlow)
		startPointVisible: true
		endPointVisible: false

		anchors {
			left: pvInverterOnInput.right; leftMargin: -8
			right: acInBus.horizontalCenter
			top: pvInverterOnInput.bottom; topMargin: -8
			bottom: showLoadsOnInput || (!dcCoupled && showInactiveFlow) ? pvInverterOnInput.bottom : multiAcInFlow.verticalCenter
			bottomMargin: showLoadsOnInput || (!dcCoupled && showInactiveFlow) ? 8 : 0
		}
	}

	// power to loads on input
	OverviewConnection {
		id: loadsOnInput
		ballCount: 1
		path: corner
		active: root.active && (showLoadsOnInput || (!dcCoupled && showInactiveFlow))
		value: Utils.sign (loadsOnInputFlow)
		startPointVisible: true
		endPointVisible: false

		anchors {
			left: acLoadOnInputBox.right; leftMargin: -8
			right: acInBus.horizontalCenter
            rightMargin: 0.5 // makes this line up with others
			top:  acLoadOnInputBox.top; topMargin: 8
			bottom: showPvOnInput|| (!dcCoupled && showInactiveFlow) ? acInBus.bottom : acInBus.top
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

		ballCount: 1
		path: straight
		active: root.active && ((showLoadsOnOutput || showPvOnOutput) || (!dcCoupled && showInactiveFlow))
		value: -Utils.sign (acOutLoadFlow + pvInverterOnAcOutFlow)
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
		active: root.active && (showLoadsOnOutput || (!dcCoupled && showInactiveFlow))
		value: Utils.sign (acOutLoadFlow)
		startPointVisible: true
		endPointVisible: false

		anchors {
			right: acOutNode.horizontalCenter
            rightMargin: -0.5 // makes this line up with others
            left: acOutputBox.left; leftMargin: 8
            top: acOutputBox.bottom; topMargin: -8
            bottom: acOutNode.verticalCenter
		}
	}

	// PV Inverter on AC out connection
	OverviewConnection {
		id: pvOnAcOutConnection

		ballCount: 2
		path: corner
		active: root.active && (showPvOnOutput || (!dcCoupled && showInactiveFlow))
		value: Utils.sign (pvInverterOnAcOutFlow)
		startPointVisible: true
		endPointVisible: false

		anchors {
			left: pvInverterOnAcOut.left; leftMargin: 8
            top: pvInverterOnAcOut.bottom; topMargin: -8
            right: acOutNode.horizontalCenter
            bottom: acOutNode.verticalCenter
		}
	}

    // invisible summing point for all DC connections
    Item {
        id: dcNode
        height: 10
        width: 10
        anchors {
            horizontalCenter: batteryDcConnector.horizontalCenter
            verticalCenter: dcLaneTop.verticalCenter
        }
    }

	// DC bus segments
	OverviewConnection {
		id: dcBus1
		ballCount: 1
		path: straight
		active: root.active && ((showAlternator || showMotorDrive || showPvCharger) || (dcCoupled && showInactiveFlow))
		value: -Utils.sign (alternatorFlow + motorDriveFlow + pvChargerFlow)
		startPointVisible: false
		endPointVisible: false

		anchors {
			right: dcLaneLeft.horizontalCenter
            rightMargin: 0.5 // makes this line up with others
			bottom: alternatorConnection.verticalCenter
			top: dcLaneTop.verticalCenter
		}
	}
	OverviewConnection {
		id: dcBus2
		ballCount: 1
		path: straight
		active: root.active && ((showAlternator || showMotorDrive || showAcCharger || showPvCharger) || (dcCoupled && showInactiveFlow))
		value: Utils.sign (alternatorFlow + motorDriveFlow + pvChargerFlow + acChargerFlow)
		startPointVisible: false
		endPointVisible: false

		anchors {
			left: dcLaneLeft.horizontalCenter
			right: dcBus3.left
			bottom: dcLaneTop.verticalCenter
		}
	}
	OverviewConnection {
		id: dcBus3
		ballCount: 2
		path: straight
		active: root.active && ((showInverter || showFuelCell || showWindGen || showDcSystem) || showInactiveFlow)
		value: -Utils.sign (inverterDcFlow + fuelCellFlow + windGenFlow + dcSystemFlow)
		startPointVisible: false
		endPointVisible: false

		anchors {
			left: batteryDcConnector.horizontalCenter
			right: multiDcConnector.horizontalCenter
			bottom: dcLaneTop.verticalCenter
		}
	}
	OverviewConnection {
		id: dcBus4
		ballCount: 1
		path: straight
		active: root.active && ((showFuelCell || showWindGen || showDcSystem) || showInactiveFlow)
		value: -Utils.sign (fuelCellFlow + windGenFlow + dcSystemFlow)
		startPointVisible: false
		endPointVisible: false

		anchors {
			left: multiDcConnector.horizontalCenter
			right: dcLaneRight.horizontalCenter
			bottom: dcLaneTop.verticalCenter
		}
	}
	OverviewConnection {
		id: dcBus5
		ballCount: 1
		path: straight
		active: root.active && ((showWindGen || showDcSystem) || showInactiveFlow)
		value: -Utils.sign (windGenFlow + dcSystemFlow)
		startPointVisible: false
		endPointVisible: false

		anchors {
			left: dcLaneRight.horizontalCenter
			top: dcLaneTop.verticalCenter
			bottom: windGenConnection.verticalCenter
		}
	}


	// DC connection multi to bus
	OverviewConnection {
		id: multiDcConnector
		ballCount: 1
		path: straight
		active: root.active && (showInverter || showInactiveFlow)
		value: Utils.sign (inverterDcFlow)
		startPointVisible: true
		endPointVisible: false

		anchors {
			right: multi.right; rightMargin: 25
			top:  multi.bottom; topMargin: -8
			bottom: dcLaneTop.verticalCenter
		}
	}
	// DC connection battery to bus
	OverviewConnection {
		id: batteryDcConnector
		ballCount: 1
		path: straight
		active: root.active && ((sys.battery.soc.valid || showDcSystem) || (dcCoupled && showInactiveFlow))
		value: -Utils.sign (batteryFlow)
		startPointVisible: true
		endPointVisible: false

		anchors {
			left: battery.left; leftMargin: 35
			top:  battery.top; topMargin: 15
			bottom: dcLaneTop.verticalCenter
		}
	}

	// AC charger to DC bus
	OverviewConnection
	{
		id: acChargerConnection
		ballCount: 1
		path: corner
		active: root.active && (showAcCharger || (dcCoupled && showInactiveFlow))
		value: Utils.sign (acChargerFlow)
		startPointVisible: true
		endPointVisible: false
        anchors
        {
            left: acChargerBox.right; leftMargin: -8
            top: acChargerBox.bottom; topMargin: -8
            right: dcLaneLeft.horizontalCenter
            bottom: dcLaneTop.verticalCenter
        }
	}

	// Alternator to bus
	OverviewConnection
	{
		id: alternatorConnection
		ballCount: 1
		path: straight
		active: root.active && (showAlternator || showMotorDrive || (dcCoupled && showInactiveFlow))
		value: Utils.sign (alternatorFlow + motorDriveFlow)
		startPointVisible: true
		endPointVisible: false
        anchors
        {
            left: alternatorBox.right; leftMargin: -8
            top: alternatorBox.bottom; topMargin: -8
            right: dcLaneLeft.horizontalCenter
        }
	}

    // DC system to DC bus
    OverviewConnection
    {
		id: dcSystemConnection
        ballCount: 2
        path: corner
        active: root.active && (showDcSystem || (dcCoupled && showInactiveFlow))
		value: Utils.sign (dcSystemFlow)
        endPointVisible: false
        anchors
        {
            left: dcSystemBox.left; leftMargin: 8
            top: dcSystemBox.bottom; topMargin: -8
            right: dcLaneRight.horizontalCenter
            rightMargin: -0.5 // makes this line up with others
            bottom: windGenConnection.verticalCenter
        }
    }


	// other DC connection to DC right bus
	OverviewConnection
	{
		id: fuelCellConnection
		ballCount: 2
		path: corner
		active: root.active && (showFuelCell || (dcCoupled && showInactiveFlow))
		value: Utils.sign (fuelCellFlow)
		startPointVisible: true
		endPointVisible: false
        anchors
        {
            left: fuelCellBox.left; leftMargin: 8
            top: fuelCellBox.bottom; topMargin: -8
            right: dcLaneRight.horizontalCenter
            rightMargin: -0.5 // makes this line up with others
            bottom: dcLaneTop.verticalCenter
        }
	}

	// Wind Gen DC right bus
	OverviewConnection
	{
		id: windGenConnection
		ballCount: 1
		path: straight
		active: root.active && (showWindGen || showInactiveFlow)
		value: Utils.sign (windGenFlow)
		startPointVisible: true
		endPointVisible: false
        anchors
        {
            left: windGenBox.left; leftMargin: 8
            top: windGenBox.bottom; topMargin: -8
            right: dcLaneRight.horizontalCenter
        }
	}

	// Solar charger to DC right bus
	OverviewConnection
	{
		id: pvChargerConnection
		ballCount: 2
		path: corner
		active: root.active && (showPvCharger || showInactiveFlow)
		value: Utils.sign (pvChargerFlow)
		startPointVisible: true
		endPointVisible: false
        anchors
        {
            left: pvChargerBox.right; leftMargin: -8
            top: pvChargerBox.bottom; topMargin: -8
            right: dcLaneLeft.horizontalCenter
            bottom: alternatorConnection.top
        }
	}

    // Synchronise tank name text scroll start
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
            title: qsTr("tanks")
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

	// hack to get value(s) from within a loop inside a function when service is changing
	property string tempServiceName: ""
	property VBusItem temperatureItem: VBusItem { bind: Utils.path(tempServiceName, "/Dc/0/Temperature") }

    function addService(service)
    {
        switch (service.type)
        {
        case DBusService.DBUS_SERVICE_TEMPERATURE_SENSOR:
            numberOfTemps++
            tempsModel.append({serviceName: service.name})
            break;;

        case DBusService.DBUS_SERVICE_MULTI:
			hasInverter = true
			root.tempServiceName = service.name
			if (temperatureItem.valid && showBatteryTemp)
			{
				numberOfTemps++
				tempsModel.append({serviceName: service.name})
			}
            break;;
		case DBusService.DBUS_SERVICE_MULTI_RS:
			hasInverter = true
			break;;

		case DBusService.DBUS_SERVICE_INVERTER:
			hasInverter = true
			if (veDirectInverterService == "")
				veDirectInverterService = service.name;
			break;;
        case DBusService.DBUS_SERVICE_BATTERY:
			root.tempServiceName = service.name
			if (temperatureItem.valid && showBatteryTemp)
			{
				numberOfTemps++
				tempsModel.append({serviceName: service.name})
			}
            break;;
        }
    }

    // Detect available services of interest
    function discoverServices()
    {
        numberOfTemps = 0
        tempsModel.clear()
		veDirectInverterService = ""
		hasInverter = false
        for (var i = 0; i < DBusServices.count; i++)
        {
            addService(DBusServices.at(i))
        }
    }
    VBusItem { id: incomingTankName;
        bind: Utils.path(settingsBindPreffix, "/Settings/Devices/TankRepeater/IncomingTankService") }

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
			verticalCenter: dcLaneTop.verticalCenter
            horizontalCenter: root.horizontalCenter
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
	property variant targetList:
	[
		acInputTarget, pvOnInputTarget, acLoadsOnInputTarget,
		acChargerTarget, alternatorTarget, motorDriveTarget, pvChargerTarget,
		multiTarget, batteryTarget,
		acLoadsOnOutputTarget, pvOnOutputTarget, fuelCellTarget, windGenTarget, dcSystemTarget
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
