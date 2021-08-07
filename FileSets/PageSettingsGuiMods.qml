/////// new menu for all Gui Mods

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

MbPage {
	id: root
	title: qsTr("Gui Mods")
    property string bindPrefixGuiMods: "com.victronenergy.settings/Settings/GuiMods"
    property string bindPrefix: "com.victronenergy.settings/Settings/Gui"

	model: VisualItemModel
    {
        MbSubMenu
        {
            description: qsTr("Package Versions and updates")
            subpage: Component { PageSettingsGuiModsVersions {} }
        }
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

        MbSwitch
        {
            id: useEnhFlowOverview
            bind: Utils.path (bindPrefixGuiMods, "/UseEnhancedFlowOverview")
            name: qsTr ("Use Enhanced Flow Overview")
            writeAccessLevel: User.AccessUser
        }

        MbSwitch
        {
            id: showTanks
            bind: Utils.path (bindPrefixGuiMods, "/ShowEnhancedFlowOverviewTanks")
            name: qsTr ("Show tanks on Flow Overview")
            show: useEnhFlowOverview.checked
            writeAccessLevel: User.AccessUser
        }
        MbSwitch
        {
            id: showTemps
            bind: Utils.path (bindPrefixGuiMods, "/ShowEnhancedFlowOverviewTemps")
            name: qsTr ("Show temperatures on Flow Overview")
            show: useEnhFlowOverview.checked
            writeAccessLevel: User.AccessUser
       }
        MbSwitch
        {
            id: shortenTankNames
            bind: Utils.path (bindPrefixGuiMods, "/ShortenTankNames")
            name: qsTr ("Shorten tank names")
            show: useEnhFlowOverview.checked || useEnhMobileOverview.checked
            writeAccessLevel: User.AccessUser
        }

        MbSpinBox {
            description: qsTr ("AC Input Limit Preset 1")
            bind: Utils.path (bindPrefixGuiMods, "/AcCurrentLimit/Preset1")
            unit: "A"
            numOfDecimals: 0
            stepSize: 1
            min: 0
            max: 999
            show: useEnhFlowOverview.checked
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
            show: useEnhFlowOverview.checked
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
            show: useEnhFlowOverview.checked
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
            show: useEnhFlowOverview.checked
            writeAccessLevel: User.AccessUser
        }

        MbItemOptions
        {
            id: tempScale
            description: qsTr ("Temperature scale")
            bind: Utils.path (bindPrefixGuiMods, "/TemperatureScale")
            show: useEnhFlowOverview.checked || useEnhMobileOverview.checked
            possibleValues:
            [
                MbOption { description: "°C"; value: 1 },
                MbOption { description: "°F"; value: 2 },
                MbOption { description: "both °C & °F"; value: 0 }
            ]
            writeAccessLevel: User.AccessUser
        }
        
        MbItemOptions
        {
            id: timeFormat
            description: qsTr ("Time format")
            bind: Utils.path (bindPrefixGuiMods, "/TimeFormat")
            show: useEnhFlowOverview.checked || useEnhMobileOverview.checked
            possibleValues:
            [
                MbOption { description: "24 hour"; value: 1 },
                MbOption { description: "12 hour AM/PM"; value: 2 },
                MbOption { description: "don't show time"; value: 0 }
            ]
            writeAccessLevel: User.AccessUser
        }
        MbSubMenu
        {
            description: qsTr("Power Gauges")
            subpage: Component { PageSettingsGuiModsGauges {} }
            show: useEnhFlowOverview.checked
        }
    }
}
