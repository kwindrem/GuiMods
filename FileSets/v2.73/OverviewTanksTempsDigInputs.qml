//// New overview page for tanks, temps and digital inputs
//// part of GuiMods
//// based on tank/temps column in mobile overview

import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils
import "timeToGo.js" as TTG

OverviewPage {
    title: qsTr("Tanks & Temps & Digital Inputs")
    id: root

    property variant sys: theSystem
    property string systemPrefix: "com.victronenergy.system"
    property string settingsBindPreffix: "com.victronenergy.settings"
    property string pumpBindPreffix: "com.victronenergy.pump.startstop0"

	property int numberOfTanks: tankModel.rowCount
    property real tanksHeight: root.height
    property real minTankHeight: 21	// use for temps also
    property real maxTankHeight: 80	// use for temps also
    property real tankTileHeight: Math.min (Math.max (tanksHeight / numberOfTanks, minTankHeight), maxTankHeight)
    property bool tanksCompact: numberOfTanks > 6

    property int numberOfTemps: 0
    property real tempsHeight: root.height
    property real tempsTileHeight: Math.min (Math.max (tempsHeight / numberOfTemps, minTankHeight), maxTankHeight)
    property bool tempsCompact: numberOfTemps > 6

	property int tankWidth: parent.width / 3
    property int tempsWidth: tankWidth
    property int digInWidth: tankWidth

    property int numberOfDigIn: 0
    property real digInHeight: root.height
    property real digInTileHeight: Math.min (Math.max (digInHeight / numberOfDigIn, minTankHeight), maxTankHeight)

    Component.onCompleted: { discoverServices() }

    // Synchronise name text scroll start
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
            left: root.left
        }
        height: root.tanksHeight
        width: root.tankWidth
        interactive: root.tankTileHeight * count > (tanksColum.height + 1) ? true : false

        model: TankModel { id: tankModel }
        delegate: TileTankEnhanced {
            // Without an intermediate assignment this will trigger a binding loop warning.
            property variant theService: DBusServices.get(buddy.id)
            service: theService
            width: tanksColum.width
            height: root.tankTileHeight
            pumpBindPrefix: root.pumpBindPreffix
            compact: root.tanksCompact
            Connections {
                target: scrollTimer
                onTriggered: doScroll()
            }
        }
        Tile {
            title: numberOfTanks == 0 ? qsTr ("no tanks") : qsTr("Tanks")
            anchors.fill: parent
			color: "#b3b3b3"
            values: TileText {
                text: qsTr("")
                width: parent.width
                wrapMode: Text.WordWrap
            }
            z: -1
        }
    }

    ListView {
        id: tempsColumn

        anchors {
            top: root.top
            left: tanksColum.right
        }
        height: root.tempsHeight
        width: root.tempsWidth
		// make list flickable if more tiles than will fit completely
        interactive: root.tankTileHeight * count > (tempsColumn.height + 1) ? true : false

        model: tempsModel
        delegate: TileTemp
        {
            width: tempsColumn.width
            height: root.tempsTileHeight
            compact: root.tempsCompact
            Connections
            {
                target: scrollTimer
                onTriggered: doScroll()
            }
        }
        Tile
        {
            title: numberOfTemps == 0 ? qsTr ("no temps") : qsTr("Temps")
            anchors.fill: parent
			color: "#b3b3b3"
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

    ListView {
        id: digInputsColumn

        anchors {
            top: root.top
            right: root.right
        }
        height: root.digInHeight
        width: root.digInWidth
        interactive: false

        model: digInModel
        delegate: TileDigIn
        {
            width: digInputsColumn.width
            height: root.digInTileHeight
        }
        Tile
        {
            title: numberOfDigIn == 0 ? qsTr ("no digital inputs") : qsTr("Digital Inputs")
            anchors.fill: parent
			color: "#b3b3b3"
            values: TileText
            {
                text: qsTr("")
                width: parent.width
                wrapMode: Text.WordWrap
            }
            z: -1
        }
    }
    ListModel { id: digInModel }


	// When new service is found add resources as appropriate
	Connections {
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
		case DBusService.DBUS_SERVICE_DIGITAL_INPUT:
		case DBusService.DBUS_SERVICE_PULSE_COUNTER:
			numberOfDigIn++
            digInModel.append({serviceName: service.name})
            break;;
       }
    }

    // Check available services to find tank sesnsors
    function discoverServices()
    {
        numberOfTemps = 0
        tempsModel.clear()
        numberOfDigIn = 0
        digInModel.clear()
        for (var i = 0; i < DBusServices.count; i++)
                addService(DBusServices.at(i))
    }
/////////////////////////////////// remove this on newer versions
	// TANK REPEATER - add to hide the service for the physical sensor
    VBusItem { id: incomingTankName;
        bind: Utils.path(settingsBindPreffix, "/Settings/Devices/TankRepeater/IncomingTankService") }
	// TANK REPEATER - end add

}
