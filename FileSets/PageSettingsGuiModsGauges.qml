/////// new menu for all Gui Mods Power Gauges

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

MbPage {
	id: root
	title: qsTr("Gui Mods power gauges")
    property string bindPrefixGuiMods: "com.victronenergy.settings/Settings/GuiMods"

	model: VisualItemModel
    {
         MbSwitch
        {
            id: showGauges
            bind: Utils.path(bindPrefixGuiMods, "/ShowGauges")
            name: qsTr("Show power gauges")
            writeAccessLevel: User.AccessUser
        }

        MbEditBox
        {
            description: qsTr ("Inverter peak power (gauge max)")
            maximumLength: 6
            item.bind: Utils.path (bindPrefixGuiMods, "/GaugeLimits/PeakPower")
            matchString: "0123456789"
            numericOnlyLayout: true
            overwriteMode: false
            unit: "W"
            enableSpaceBar: true
            show: showGauges.checked
            writeAccessLevel: User.AccessInstaller
        }
        MbEditBox
        {
            description: qsTr ("Inverter caution power (yellow-red)")
            maximumLength: 6
            item.bind: Utils.path (bindPrefixGuiMods, "/GaugeLimits/CautionPower")
            matchString: "0123456789"
            numericOnlyLayout: true
            overwriteMode: false
            unit: "W"
            enableSpaceBar: true
            show: showGauges.checked
            writeAccessLevel: User.AccessInstaller
        }
        MbEditBox
        {
            description: qsTr ("Inverter max continuous power (green-yellow)")
            maximumLength: 6
            item.bind: Utils.path (bindPrefixGuiMods, "/GaugeLimits/ContiuousPower")
            matchString: "0123456789"
            numericOnlyLayout: true
            overwriteMode: false
            unit: "W"
            enableSpaceBar: true
            show: showGauges.checked
            writeAccessLevel: User.AccessInstaller
        }
        MbEditBox
        {
            description: qsTr ("Max power Loads on Output / Combined Loads")
            maximumLength: 6
            item.bind: Utils.path (bindPrefixGuiMods, "/GaugeLimits/AcOutputMaxPower")
            matchString: "0123456789"
            numericOnlyLayout: true
            overwriteMode: false
            unit: "W"
            enableSpaceBar: true
            show: showGauges.checked
            writeAccessLevel: User.AccessInstaller
        }
        MbEditBox
        {
            description: qsTr ("Max power Loads on Input")
            maximumLength: 6
            item.bind: Utils.path (bindPrefixGuiMods, "/GaugeLimits/AcOutputNonCriticalMaxPower")
            matchString: "0123456789"
            numericOnlyLayout: true
            overwriteMode: false
            unit: "W"
            enableSpaceBar: true
            show: showGauges.checked
            writeAccessLevel: User.AccessInstaller
        }
        MbEditBox
        {
            description: qsTr ("Max power Grid feed-in")
            maximumLength: 6
            item.bind: Utils.path (bindPrefixGuiMods, "/GaugeLimits/MaxFeedInPower")
            matchString: "0123456789"
            numericOnlyLayout: true
            overwriteMode: false
            unit: "W"
            enableSpaceBar: true
            show: showGauges.checked
            writeAccessLevel: User.AccessInstaller
        }
        MbEditBox
        {
            description: qsTr ("Max power Multi/Quattro Charger")
            maximumLength: 6
            item.bind: Utils.path (bindPrefixGuiMods, "/GaugeLimits/MaxChargerPower")
            matchString: "0123456789"
            numericOnlyLayout: true
            overwriteMode: false
            unit: "W"
            enableSpaceBar: true
            show: showGauges.checked
            writeAccessLevel: User.AccessInstaller
        }
        MbEditBox
        {
            description: qsTr ("Max power PV Charger")
            maximumLength: 6
            item.bind: Utils.path (bindPrefixGuiMods, "/GaugeLimits/PvChargerMaxPower")
            matchString: "0123456789"
            numericOnlyLayout: true
            overwriteMode: false
            unit: "W"
            enableSpaceBar: true
            show: showGauges.checked
            writeAccessLevel: User.AccessInstaller
        }
        MbEditBox
        {
            description: qsTr ("Max power PV inverter on AC Input")
            maximumLength: 6
            item.bind: Utils.path (bindPrefixGuiMods, "/GaugeLimits/PvOnGridMaxPower")
            matchString: "0123456789"
            numericOnlyLayout: true
            overwriteMode: false
            unit: "W"
            enableSpaceBar: true
            show: showGauges.checked
            writeAccessLevel: User.AccessInstaller
        }
        MbEditBox
        {
            description: qsTr ("Max power PV inverter on AC Output")
            maximumLength: 6
            item.bind: Utils.path (bindPrefixGuiMods, "/GaugeLimits/PvOnOutputMaxPower")
            matchString: "0123456789"
            numericOnlyLayout: true
            overwriteMode: false
            unit: "W"
            enableSpaceBar: true
            show: showGauges.checked
            writeAccessLevel: User.AccessInstaller
        }
        MbEditBox
        {
            description: qsTr ("Max battery discharge current")
            maximumLength: 6
            item.bind: Utils.path (bindPrefixGuiMods, "/GaugeLimits/BatteryMaxDischargeCurrent")
            matchString: "0123456789"
            numericOnlyLayout: true
            overwriteMode: false
            unit: "A"
            enableSpaceBar: true
            show: showGauges.checked
            writeAccessLevel: User.AccessInstaller
        }
        MbEditBox
        {
            description: qsTr ("Max battery charge current")
            maximumLength: 6
            item.bind: Utils.path (bindPrefixGuiMods, "/GaugeLimits/BatteryMaxChargeCurrent")
            matchString: "0123456789"
            numericOnlyLayout: true
            overwriteMode: false
            unit: "A"
            enableSpaceBar: true
            show: showGauges.checked
            writeAccessLevel: User.AccessInstaller
        }
        MbEditBox
        {
            description: qsTr ("Max DC System load power")
            maximumLength: 6
            item.bind: Utils.path (bindPrefixGuiMods, "/GaugeLimits/DcSystemMaxLoad")
            matchString: "0123456789"
            numericOnlyLayout: true
            overwriteMode: false
            unit: "W"
            enableSpaceBar: true
            show: showGauges.checked
            writeAccessLevel: User.AccessInstaller
        }
        MbEditBox
        {
            description: qsTr ("Max DC System charger power")
            maximumLength: 6
            item.bind: Utils.path (bindPrefixGuiMods, "/GaugeLimits/DcSystemMaxCharge")
            matchString: "0123456789"
            numericOnlyLayout: true
            overwriteMode: false
            unit: "W"
            enableSpaceBar: true
            show: showGauges.checked
            writeAccessLevel: User.AccessInstaller
        }
        MbEditBox
        {
            description: qsTr ("Max Alternator power")
            maximumLength: 6
            item.bind: Utils.path (bindPrefixGuiMods, "/GaugeLimits/MaxAlternatorPower")
            matchString: "0123456789"
            numericOnlyLayout: true
            overwriteMode: false
            unit: "W"
            enableSpaceBar: true
            show: showGauges.checked
            writeAccessLevel: User.AccessInstaller
        }
        MbEditBox
        {
            description: qsTr ("Max Wind Generator power")
            maximumLength: 6
            item.bind: Utils.path (bindPrefixGuiMods, "/GaugeLimits/MaxWindGenPower")
            matchString: "0123456789"
            numericOnlyLayout: true
            overwriteMode: false
            unit: "W"
            enableSpaceBar: true
            show: showGauges.checked
            writeAccessLevel: User.AccessInstaller
        }
        MbEditBox
        {
            description: qsTr ("Max Fuel Cell power")
            maximumLength: 6
            item.bind: Utils.path (bindPrefixGuiMods, "/GaugeLimits/MaxFuelCellPower")
            matchString: "0123456789"
            numericOnlyLayout: true
            overwriteMode: false
            unit: "W"
            enableSpaceBar: true
            show: showGauges.checked
            writeAccessLevel: User.AccessInstaller
        }
        MbEditBox
        {
            description: qsTr ("Max Motor Drive load power")
            maximumLength: 6
            item.bind: Utils.path (bindPrefixGuiMods, "/GaugeLimits/MaxMotorDriveLoad")
            matchString: "0123456789"
            numericOnlyLayout: true
            overwriteMode: false
            unit: "W"
            enableSpaceBar: true
            show: showGauges.checked
            writeAccessLevel: User.AccessInstaller
        }
        MbEditBox
        {
            description: qsTr ("Max Motor Drive charge power")
            maximumLength: 6
            item.bind: Utils.path (bindPrefixGuiMods, "/GaugeLimits/MaxMotorDriveCharge")
            matchString: "0123456789"
            numericOnlyLayout: true
            overwriteMode: false
            unit: "W"
            enableSpaceBar: true
            show: showGauges.checked
            writeAccessLevel: User.AccessInstaller
        }
    }
}
