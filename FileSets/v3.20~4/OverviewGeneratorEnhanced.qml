// GuiMods enhanced generator overview
// This file has been modified to:
//	add Auto Start display and control
//	show voltage, current, frequency, and power gauge in AC input tile
//	show the generator running state inside the icon top left
// 	show a warning when the generator digital input and expected generator state disagree
//	move current run time to separate tile
 
import QtQuick 1.1
import "utils.js" as Utils
import "enhancedFormat.js" as EnhFmt

OverviewPage {
	id: root
 
	property string settingsBindPrefix
	property string bindPrefix
	property variant sys: theSystem
//////// added to show alternator in place of inactive genset
    property string guiModsPrefix: "com.victronenergy.settings/Settings/GuiMods"
    VBusItem { id: replaceAcInItem; bind: Utils.path(guiModsPrefix, "/ReplaceInactiveAcIn") }
    property bool hasAlternator: sys.alternator.power.valid
    property bool showAlternator: replaceAcInItem.valid && replaceAcInItem.value == 1 && hasAlternator && ! sys.genset.power.valid
    property bool showAcIn: ! showAlternator     
    
	property string icon: "overview-generator"
	property VBusItem state: VBusItem { bind: Utils.path(bindPrefix, "/State") }
	property VBusItem error: VBusItem { bind: Utils.path(bindPrefix, "/Error") }
	property VBusItem runningTime: VBusItem { bind: Utils.path(bindPrefix, "/Runtime") }
	property VBusItem runningBy: VBusItem { bind: Utils.path(bindPrefix, "/RunningByConditionCode") }
	VBusItem totalAcummulatedTime: VBusItem { bind: Utils.path(settingsBindPrefix, "/AccumulatedTotal") }
	VBusItem totalAccumulatedTimeOffset: VBusItem { bind: Utils.path(settingsBindPrefix, "/AccumulatedTotalOffset") }
	property VBusItem quietHours: VBusItem { bind: Utils.path(bindPrefix, "/QuietHours") }
	property VBusItem testRunDuration: VBusItem { bind: Utils.path(settingsBindPrefix, "/TestRun/Duration") }
	property VBusItem nextTestRun: VBusItem { bind: Utils.path(bindPrefix, "/NextTestRun") }
	property VBusItem skipTestRun: VBusItem { bind: Utils.path(bindPrefix, "/SkipTestRun") }

	property VBusItem todayRuntime: VBusItem { bind: Utils.path(bindPrefix, "/TodayRuntime") }
	property VBusItem manualTimer: VBusItem { bind: Utils.path(bindPrefix, "/ManualStartTimer") }
	property VBusItem autoStart: VBusItem { bind: Utils.path(settingsBindPrefix, "/AutoStartEnabled") }

	property bool errors: ! state.valid || state.value == 10

    property VBusItem externalOverrideItem: VBusItem { bind: Utils.path(bindPrefix, "/ExternalOverride") }
    property bool externalOverride: externalOverrideItem.valid && externalOverrideItem.value == 1 && ! errors
    property VBusItem runningState: VBusItem { bind: Utils.path(bindPrefix, "/GeneratorRunningState") }

    VBusItem { id: showGaugesItem; bind: Utils.path(guiModsPrefix, "/ShowGauges") }
    property bool showGauges: showGaugesItem.valid ? showGaugesItem.value === 1 ? true : false : false
	property bool editMode: autoRunTile.editMode || manualTile.editMode

    VBusItem { id: serviceInterval; bind: Utils.path(settingsBindPrefix, "/ServiceInterval") }
    VBusItem { id: serviceCounterItem; bind: Utils.path(bindPrefix, "/ServiceCounter") }
    property bool showServiceInfo: serviceCounterItem.valid && serviceInterval.valid && serviceInterval.value > 0
	property bool serviceOverdue: showServiceInfo && serviceCounterItem.value < 0

	title: qsTr("Generator")

	property bool autoStartSelected: false

    Component.onCompleted:
    { 
		setFocusManual ()
	}

	Keys.forwardTo: [keyHandler]
	Item
	{
		id: keyHandler
		Keys.onUpPressed:
		{ 
			setFocusAuto ()
			event.accepted = true
		}
		Keys.onDownPressed:
		{ 
			setFocusManual ()
			event.accepted = true			
		}
		// prevents page changes while timers are running
		//// Keys.onReturnPressed: event.accepted = manualTile.startCountdown || autoRunTile.startCountdown
		//// Keys.onEscapePressed: event.accepted = manualTile.startCountdown || autoRunTile.startCountdown
	}

	function setFocusManual ()
	{
		autoStartSelected = false
	}

	function setFocusAuto ()
	{
		autoStartSelected = true
	}

	function formatTime (time)
	{
		if (time >= 3600)
			return (time / 3600).toFixed(0) + " h"
		else
			return (time / 60).toFixed(0) + " m"
	}

	function stateDescription()
	{
		if (!state.valid)
			return qsTr ("")
		else if (state.value === 10)
		{
			switch(error.value)
			{
			case 1:
				return qsTr("Error: Remote switch control disabled")
			case 2:
				return qsTr("Error: Generator in fault condition")
			case 3:
				return qsTr("Error: Generator not detected at AC input")
			default:
				return qsTr("Error")
			}
		}
		else
		{
			var condition = ""
			var running = true
			var manual = false
			switch (runningBy.value)
			{
			case 0:	// stopped
				condition = ""
				running = false
				break;;
			case 1:
				manual = true
				condition = ""
				break;;
			case 2:
				condition = qsTr("Test run")
				break;;
			case 3:
				condition = qsTr("Loss of communication")
				break;;
			case 4:
				condition = qsTr("SOC")
				break;;
			case 5:
				condition = qsTr("AC load")
				break;;
			case 6:
				condition = qsTr("Battery current")
				break;;
			case 7:
				condition = qsTr("Battery voltage")
				break;;
			case 8:
				condition = qsTr("Inverter temperature")
				break;;
			case 9:
				condition = qsTr("Inverter overload")
				break;;
			default:
				condition = qsTr("???")
				break;;
			}

			if (externalOverride)
			{
				if (running && ! manual)
					return qsTr ("auto pending: ") + condition
				else
					return " "
			}
			else if (manual)
			{
				if (manualTimer.valid && manualTimer.value > 0)
					return qsTr("Timed run")
				else
					return qsTr("Manual run")
			}
			else if (running)
				return qsTr ("auto run: ") + condition
			else
				return " "
		}
	}

	function getNextTestRun()
	{
		if ( ! root.state.valid)
			return ""
		if (!nextTestRun.value)
			return qsTr("No test run programmed")

		var todayDate = new Date()
		var nextDate = new Date(nextTestRun.value * 1000)
		var nextDateEnd = new Date(nextDate.getTime())
		var message = ""
		// blank "next run" if test run is active
		if (runningBy.value == 2)
			return " "
		else if (todayDate.getDate() == nextDate.getDate() && todayDate.getMonth() == nextDate.getMonth())
		{
			message = qsTr("Next test run today %1").arg(
						Qt.formatDateTime(nextDate, "hh:mm").toString())
		}
		else
		{
			message = qsTr("Next test run on %1").arg(
						Qt.formatDateTime(nextDate, "dd/MM/yyyy").toString())
						nextDateEnd.setSeconds(testRunDuration.value)		}

		if (skipTestRun.value === 1)
			message += qsTr(" \(skipped\)")

		return message
	}

	Tile {
		id: imageTile
		width: 180
		height: 136
		MbIcon {
			id: generator
			iconId: icon
			anchors.centerIn: parent
		}
		anchors { top: parent.top; left: parent.left }
        values: [
                // spacer
                TileText {
                    width: imageTile.width - 5
                    text: " "
                    font.pixelSize: 62
                },
                TileText {
                    width: imageTile.width - 5
                    text: runningState.valid ? runningState.value == "R" ? "Running " : runningState.value == "S" ? "Stopped " : "" : ""
                }
        ]
	}

	Tile {
		id: statusTile
		height: imageTile.height
		color: "#4789d0"
		anchors { top: parent.top; left: imageTile.right; right: root.right }
		title: qsTr("STATUS")
		values: [
            TileText
            {
                width: statusTile.width - 5
                color: externalOverride ? "yellow" : "white"
				text:
				{
					var runPrefix
					var message
					if ( ! root.state.valid)
						return qsTr ("Generator not connected")
					else if (root.state.value === 2)
						runPrefix = qsTr("Warming up for ")
					else
						runPrefix = qsTr ("Running for ")
					if (!root.state.valid)
						message = ""
					else if (externalOverride)
						message = qsTr("External Override - stopped")
					else if (root.state.value === 3)
						message = qsTr("Cool-down")
					else if (root.state.value === 4)
						message = qsTr("Stopping")
					else if (runningBy.value == 0)
						message = qsTr ("Stopped")
					else if ( ! runningTime.valid)
						message = runPrefix + "??"
					else
					{
						message = runPrefix + formatTime (runningTime.value) 
						if (manualTimer.valid && manualTimer.value > 0)
							message += qsTr ("  ends in ") + formatTime (manualTimer.value)
					}
					return message
				}
            },
			Rectangle
			{
				width: parent.width
				height: 3
				color: "transparent"
			},
			TileTextMultiLine
			{
				text: stateDescription()
				width: statusTile.width - 5
			},
			Rectangle
			{
				width: parent.width
				height: 3
				color: "transparent"
			},
			TileText
			{
				text: qsTr("\nQuiet hours");
				width: statusTile.width - 5
				font.bold: runningBy.valid && runningBy.value != 0
				color: font.bold ? "yellow" : "white"
				visible: quietHours.value === 1
			},
			Rectangle
			{
				width: parent.width
				height: 3
				color: "transparent"
			},
			TileTextMultiLine
			{
				width: statusTile.width - 5
				text: getNextTestRun()
			}
		]
	}

	Tile {
		id: acInTile
		title: qsTr("GENERATOR POWER")
		width: 150
		height: 136
		color: "#82acde"
		anchors { top: imageTile.bottom; left: parent.left }
		visible: showAcIn
		values:
		[
			OverviewAcValuesEnhanced { connection: sys.genset },
			TileText
			{
				width: acInTile.width - 5
				text: qsTr ("--")
				font.pixelSize: 22
				visible: !sys.genset.power.valid
			}			
		]
////// add power bar graph
        PowerGauge
        {
            id: acInBar
            width: parent.width
            height: 12
            anchors
            {
                top: parent.top; topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
			connection: sys.genset
			useInputCurrentLimit: true
            maxForwardPowerParameter: ""
            maxReversePowerParameter: ""
            visible: showGauges
        }
	}
//////// added to show alternator in place of AC generator
	Tile {
		id: alternatorTile
		title: qsTr("ALTERNATOR POWER")
		color: "#157894"
		anchors.fill: acInTile
		visible: showAlternator
		values:
		[
			TileText
			{
				text: EnhFmt.formatVBusItem (sys.alternator.power, "W")
				font.pixelSize: 22
			}
		]
////// add power bar graph
        PowerGauge
        {
            id: alternatorGauge
            width: parent.width
            height: 12
            anchors
            {
                top: parent.top; topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            connection: sys.alternator
            maxForwardPowerParameter: "com.victronenergy.settings/Settings/GuiMods/GaugeLimits/MaxAlternatorPower"
            visible: showGauges && showAlternator
        }
	}

	Tile {
		id: runTimeTile
		title: qsTr("RUN TIMES")
		width: 140
		anchors { top: acInTile.top; bottom: parent.bottom; left: acInTile.right }
		values: [
			TileText
			{
				width: runTimeTile.width - 5
				text: qsTr ("Today")
			},
			TileText {
				width: runTimeTile.width - 5
				text: todayRuntime.valid ? formatTime (todayRuntime.value) : "--"
			},
			Rectangle
			{
				width: parent.width
				height: 3
				color: "transparent"
			},
			TileText
			{
				width: runTimeTile.width - 5
				text: qsTr ("Accumulated")
			},
			TileText
			{
				width: runTimeTile.width - 5
				text:
				{
					if ( ! totalAcummulatedTime.valid)
						return "--"
					else if (totalAccumulatedTimeOffset.valid )
						return formatTime (totalAcummulatedTime.value - totalAccumulatedTimeOffset.value)
					else
						return formatTime (totalAcummulatedTime.value)
				}
			},
			Rectangle
			{
				width: parent.width
				height: 3
				color: "transparent"
			},
			TileText
			{
				width: runTimeTile.width - 5
				visible: showServiceInfo
				color: serviceOverdue ? "red" : "white"
				text: serviceOverdue ? qsTr ("Service OVERDUE") : qsTr ("Service in")
			},
			TileText
			{
				width: runTimeTile.width - 5
				visible: showServiceInfo
				color: serviceOverdue ? "red" : "white"
				text: formatTime (Math.abs (serviceCounterItem.value))
			}
		]
	}

	TileAutoRunEnhanced
	{
		id: autoRunTile
		bindPrefix: root.bindPrefix
		focus: root.active && autoStartSelected
		connected: state.valid
		tileHeight: acInTile.height / 2
		anchors {
			bottom: parent.bottom; bottomMargin: tileHeight
			left: runTimeTile.right
			right: parent.right
		}
	}

	TileManualStartEnhanced
	{
		id: manualTile
		bindPrefix: root.bindPrefix
		focus: root.active && ! autoStartSelected
		connected: state.valid
		tileHeight: acInTile.height / 2
		anchors {
			bottom: parent.bottom
			left: runTimeTile.right
			right: parent.right
		}
	}

	// mouse areas must be AFTER their associated objects so those objects can catch mouse events
	// rejected by these areas
	// mouse targets need to be disabled while changes are pending
	MouseArea {
		id: autoRunTarget
		anchors.fill: autoRunTile
		enabled: root.active && ! editMode
		onPressed:
		{
			if ( ! root.autoStartSelected )
			{
				setFocusAuto ()
				mouse.accepted = true
			}
			else
			{
				mouse.accepted = false
			}
		} 
	}
	MouseArea {
		id: manualStartTarget
		anchors.fill: manualTile
		enabled: root.active && ! editMode
		onPressed:
		{
			if ( root.autoStartSelected )
			{
				setFocusManual ()
				mouse.accepted = true
			}
			else
			{
				mouse.accepted = false
			}
		}
	}
}
