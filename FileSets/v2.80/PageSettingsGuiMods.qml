/////// new menu for all Gui Mods

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

MbPage {
	id: root
	title: qsTr("Gui Mods")
    property string bindPrefixGuiMods: "com.victronenergy.settings/Settings/GuiMods"
    property string bindPrefix: "com.victronenergy.settings/Settings/Gui"

	property bool showFlowParams: flowOverview.item.valid && flowOverview.item.value >= 1
	property bool showComplexParams: flowOverview.item.valid && flowOverview.item.value >= 2
	property bool showAcCoupledParams: flowOverview.item.valid && flowOverview.item.value == 3

	model: VisualItemModel
    {
        MbSwitch
        {
            id: showTileOverview
            bind: Utils.path (bindPrefixGuiMods, "/ShowTileOverview")
            name: qsTr ("Show Tile Overview")
            writeAccessLevel: User.AccessUser
        }

        MbSwitch
        {
            id: moveSettings
            bind: Utils.path (bindPrefixGuiMods, "/MoveSettings")
            name: qsTr ("Move Settings to top of Device List")
            writeAccessLevel: User.AccessUser
        }

        MbSwitch {
            id: relayOverview
            bind: Utils.path (bindPrefixGuiMods, "/ShowRelayOverview")
            name: qsTr ("Show Relay overview")
            writeAccessLevel: User.AccessUser
        }
        MbSwitch {
            id: tanksTempsOverview
            bind: Utils.path (bindPrefixGuiMods, "/ShowTanksTempsDigIn")
            name: qsTr ("Show Tanks, Temps, Digital Input overview")
            writeAccessLevel: User.AccessUser
        }

        MbSwitch
        {
            id: useEnhGeneratorOverview
            bind: Utils.path (bindPrefixGuiMods, "/UsedEnhancedGeneratorOverview")
            name: qsTr ("Use Enhanced Generator Overview")
            writeAccessLevel: User.AccessUser
        }

        // duplicate mobile overview on/off here for convenience
        MbSwitch {
            id: mobileOverview
            bind: Utils.path (bindPrefix, "/MobileOverview")
            name: qsTr ("Show boat & motorhome overview")
            writeAccessLevel: User.AccessUser
        }
        MbSwitch
        {
            id: useEnhMobileOverview
            bind: Utils.path (bindPrefixGuiMods, "/UseEnhancedMobileOverview")
            name: qsTr ("Use Enhanced Mobile Overview")
            // When enabled set Enhanced OverviewMobile as default overview
            onClicked:
            {
                if (!checked)
                {
                    // also enable Mobile Overview when turning on use enhanced Mobile Overview
                    showMobileOverview.setValue (1)
                }
            }
            VBusItem { id: showMobileOverview; bind: Utils.path (bindPrefix, "/MobileOverview") }
            writeAccessLevel: User.AccessUser
        }

		MbItemOptions
		{
            id: flowOverview
			description: qsTr("Flow overview")
            bind: Utils.path (bindPrefixGuiMods, "/FlowOverview")
			possibleValues:
			[
				MbOption {description: qsTr("Victron stock"); value: 0},
				MbOption {description: qsTr("GuiMods simple"); value: 1},
				MbOption {description: qsTr("GuiMods DC Coupled"); value: 2},
				MbOption {description: qsTr("GuiMods AC Coupled"); value: 3}
			]
		}

        MbSwitch
        {
            id: combineLoads
            bind: Utils.path (bindPrefixGuiMods, "/EnhancedFlowCombineLoads")
            name: qsTr ("Combine AC input/ouput loads")
            show: root.showAcCoupledParams
            writeAccessLevel: User.AccessInstaller
       }
		MbSwitch
        {
            id: showLoadsOnInput
            bind: Utils.path (bindPrefixGuiMods, "/ShowEnhancedFlowLoadsOnInput")
            name: qsTr ("Show Loads On Input")
			show: root.showAcCoupledParams && ! combineLoads.checked
            writeAccessLevel: User.AccessInstaller
       }

        MbSwitch
        {
            id: showTanks
            bind: Utils.path (bindPrefixGuiMods, "/ShowEnhancedFlowOverviewTanks")
            name: qsTr ("Show tanks on Flow Overview")
			show: root.showFlowParams
            writeAccessLevel: User.AccessUser
        }
        MbSwitch
        {
            id: showTemps
            bind: Utils.path (bindPrefixGuiMods, "/ShowEnhancedFlowOverviewTemps")
            name: qsTr ("Show temperatures on Flow Overview")
			show: root.showFlowParams
            writeAccessLevel: User.AccessUser
       }
        MbSwitch
        {
            id: shortenTankNames
            bind: Utils.path (bindPrefixGuiMods, "/ShortenTankNames")
            name: qsTr ("Shorten tank names")
            writeAccessLevel: User.AccessUser
        }

         MbEditBox {
            id: dcSystemName
            description: qsTr("DC System tile name")
            item.bind: "com.victronenergy.settings/GuiMods/CustomDcSystemName"
            maximumLength: 32
            enableSpaceBar: true
        }

       MbSpinBox {
            description: qsTr ("AC Input Limit Preset 1")
            bind: Utils.path (bindPrefixGuiMods, "/AcCurrentLimit/Preset1")
            unit: "A"
            numOfDecimals: 0
            stepSize: 1
            min: 0
            max: 999
            writeAccessLevel: User.AccessUser
        }

        MbSpinBox {
            description: qsTr ("AC Input Limit Preset 2")
            bind: Utils.path (bindPrefixGuiMods, "/AcCurrentLimit/Preset2")
            unit: "A"
            numOfDecimals: 0
            stepSize: 1
            min: 0
            max: 999
            writeAccessLevel: User.AccessUser
        }

        MbSpinBox {
            description: qsTr ("AC Input Limit Preset 3")
            bind: Utils.path (bindPrefixGuiMods, "/AcCurrentLimit/Preset3")
            unit: "A"
            numOfDecimals: 0
            stepSize: 1
            min: 0
            max: 999
            writeAccessLevel: User.AccessUser
        }

        MbSpinBox {
            description: qsTr ("AC Input Limit Preset 4")
            bind: Utils.path (bindPrefixGuiMods, "/AcCurrentLimit/Preset4")
            unit: "A"
            numOfDecimals: 0
            stepSize: 1
            min: 0
            max: 999
            writeAccessLevel: User.AccessUser
        }

        MbItemOptions
        {
            id: tempScale
            description: qsTr ("Temperature scale")
            bind: Utils.path (bindPrefixGuiMods, "/TemperatureScale")
            possibleValues:
            [
                MbOption { description: "°C"; value: 1 },
                MbOption { description: "°F"; value: 2 },
                MbOption { description: qsTr("both °C & °F"); value: 0 }
            ]
            writeAccessLevel: User.AccessUser
        }
        
        MbItemOptions
        {
            id: timeFormat
            description: qsTr ("Time format")
            bind: Utils.path (bindPrefixGuiMods, "/TimeFormat")
            possibleValues:
            [
                MbOption { description: qsTr("24 hour"); value: 1 },
                MbOption { description: qsTr("12 hour AM/PM"); value: 2 },
                MbOption { description: qsTr("don't show time"); value: 0 }
            ]
            writeAccessLevel: User.AccessUser
        }
        MbItemOptions
        {
            id: inactiveFlowTiles
            description: qsTr ("Inactive Tiles on Flow Overview")
            bind: Utils.path (bindPrefixGuiMods, "/ShowInactiveFlowTiles")
            show: root.showFlowParams
            possibleValues:
            [
                MbOption { description: qsTr("Show Dimmed"); value: 1 },
                MbOption { description: qsTr("Show Full"); value: 2 },
                MbOption { description: qsTr("Hide"); value: 0 }
            ]
            writeAccessLevel: User.AccessUser
        }
        MbSubMenu
        {
            description: qsTr("Power Gauges")
            subpage: Component { PageSettingsGuiModsGauges {} }
            show: root.showFlowParams
        }
    }
}
