/////// new menu for all Gui Mods Power Gauges

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

MbPage {
	id: root
	title: qsTr("Gui Mods Power Gauges")
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
            description: qsTr ("Inverter max continuous power (greed-yellow)")
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
            description: qsTr ("Max system AC output power")
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
            description: qsTr ("Max PV power")
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
    }
}
