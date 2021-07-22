// This file has been modified:
//   Show mixed case text names in tile title even when not in compact display
//   A sliver of the level bar remains when the tank is empty so there is some indication of empty
//   Show actual level in addition to percentage
//   reduce tile height when needed, mainly to fit on Flow overview page
//   changes in prevous versions have been restored to stock

import QtQuick 1.1
import "utils.js" as Utils
import "tanksensor.js" as TankSensor

Tile {
	id: root

    property variant service
    property string bindPrefix: service ? service.name : ""
	property string pumpBindPrefix
	property VBusItem levelItem: VBusItem { id: levelItem; bind: Utils.path(bindPrefix, "/Level"); decimals: 0; unit: "%" }
    property VBusItem fluidTypeItem: VBusItem { id: fluidTypeItem; bind: Utils.path(bindPrefix, "/FluidType") }
    property VBusItem pumpStateItem: VBusItem { id: pumpStateItem; bind: Utils.path(pumpBindPrefix, "/State") }
    property VBusItem pumpActiveService: VBusItem { id: pumpActiveService; bind: Utils.path(pumpBindPrefix, "/ActiveTankService") }
    property alias valueBarColor: valueBar.color
    property int level: levelItem.valid ? levelItem.value : 0
    property int fullWarningLevel: ([2, 5].indexOf(fluidTypeItem.value) > -1) ? 80 : -1
    property int emptyWarningLevel: !([2, 5].indexOf(fluidTypeItem.value) > -1) ? 20 : -1
    property bool blink: true
    property bool compact: false

//// add to allow displaying remaining volume
    property VBusItem remainingItem: VBusItem { id: remainingItem; bind: Utils.path(bindPrefix, "/Remaining"); decimals: 0 }
    property VBusItem volumeUnit: VBusItem { bind: "com.victronenergy.settings/Settings/System/VolumeUnit" }
//// small tile height threshold
    property bool squeeze: height < 50

//// modified to truncate tank name to 1 word if compact is true or 2 words if not
//// and to replace "Waste" with "Gray"
    property VBusItem customNameItem: VBusItem { id: customNameItem; bind: Utils.path(bindPrefix, "/CustomName") }
    property VBusItem shortenTankNames: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/ShortenTankNames" }
    property string tankName: truncateTankName ()

    function truncateTankName ()
    {
        if (customNameItem.valid && customNameItem.value != "")
            return customNameItem.value
        else if (service && shortenTankNames.valid && shortenTankNames.value == 1)
        {
            var stringList = service ? service.description.split (" ") : "???"
            if (stringList[0] == "Waste")
                        stringList[0] = "Gray"
                    if (compact || stringList.count < 2)
                        return stringList[0]
                    else
                        return stringList[0] + " " + stringList[1]
        }
        else
            return service ? service.description : "???"
    }

    function formatLevelText ()
    {
        var levelText
        var remainingText
        
        
         remainingItem.valid ? remainingItem.value : 0
        if (levelItem.valid)
            levelText = levelItem.text
        else
            levelText = "?"

        if (remainingItem.valid)
            remainingText = TankSensor.formatVolume(volumeUnit.value, remainingItem.value)
        else
            remainingText = "?"

        return levelText + " " + remainingText
    }

///// modified to keep mixed case names
    title: compact ? "" : tankName
    color: TankSensor.info(fluidTypeItem.value).color

	Timer {
		interval: 1000
		running: pumpActiveService.value === bindPrefix && pumpStateItem.value === 1
		repeat: true
		onTriggered: blink = !blink
		onRunningChanged: if (!running) blink = true
	}

	function doScroll()
	{
		tankText.doScroll()
	}

	function warning()
	{
		if (fullWarningLevel != -1 && level >= fullWarningLevel)
			return true
		if (emptyWarningLevel != -1 && level <= emptyWarningLevel)
			return true
		return false
	}

	values: Item {
		width: root.width - 10
//// modified to squeeze bar height if space is tight
        height: compact ? root.height : squeeze ? 17 : 21

		Marquee {
			id: tankText
//// modified to give bar more horizontal space
            width: Math.max (Math.floor (parent.width * 0.3 ), 44)
			height: compact ? 13 : parent.height
			text: compact ? tankName : ""
			textHorizontalAlignment: Text.AlignLeft
			visible: compact
			scroll: false
			anchors {
//// modified to give move bar over title's line if space is tight
                verticalCenter: parent.verticalCenter; verticalCenterOffset: compact ? -9 : squeeze ? -4 : 0
			}
		}

		Rectangle {
			color: "#95a5a6"
			border { width:1; color: "white" }
			width: root.width - 10 -  (compact ? tankText.width + 3 : 0)
			height: compact ? 13 : parent.height
			anchors {
//// modified to give move bar over title's line if space is tight
                verticalCenter: parent.verticalCenter; verticalCenterOffset: compact ? -9 : squeeze ? -4 : 0
				right: parent.right
			}

			Rectangle {
				id: valueBar
//// modified to always show a sliver of a bar even if tank is empty
                width: Math.max (level / 100 * parent.width - 2, 2)
				height: parent.height - 1
				color: warning() ? "#e74c3c" : "#34495e"
				opacity: blink ? 1 : 0.5
				anchors {
					verticalCenter: parent.verticalCenter;
					left: parent.left; leftMargin: 1
				}
			}

			Text {
				font.pixelSize: 12
				font.bold: true
//// include actual level in display
				text: formatLevelText ()
				anchors.centerIn: parent
				color: "white"
			}
		}
	}
}
