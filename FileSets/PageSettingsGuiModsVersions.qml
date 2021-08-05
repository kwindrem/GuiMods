/////// new menu for package version display

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

MbPage {
	id: root
	title: qsTr("Package Versions")
    property string bindPrefix: "com.victronenergy.settings/Settings/GuiMods/PackageVersions"

	model: VisualItemModel
    {
        MbItemText
        {
            text: qsTr("uninstalled packages show versions in ()")
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignCenter
        }
        MbItemValue
        {
            description: qsTr("SetupHelper")
            item.bind: Utils.path(root.bindPrefix, "/SetupHelper")
            show: item.valid
        }
        MbItemValue
        {
            description: qsTr("GuiMods")
            item.bind: Utils.path(root.bindPrefix, "/GuiMods")
            show: item.valid
        }
        MbItemValue
        {
            description: qsTr("GeneratorConnector")
            item.bind: Utils.path(root.bindPrefix, "/GeneratorConnector")
            show: item.valid
        }
        MbItemValue
        {
            description: qsTr("RpiDisplaySetup")
            item.bind: Utils.path(root.bindPrefix, "/RpiDisplaySetup")
            show: item.valid
        }
        MbItemValue
        {
            description: qsTr("RpiGpioSetup")
            item.bind: Utils.path(root.bindPrefix, "/RpiGpioSetup")
            show: item.valid
        }
        MbItemValue
        {
            description: qsTr("TankRepeater")
            item.bind: Utils.path(root.bindPrefix, "/TankRepeater")
            show: item.valid
        }
        MbItemValue
        {
            description: qsTr("VeCanSetup")
            item.bind: Utils.path(root.bindPrefix, "/VeCanSetup")
            show: item.valid
        }
    }
}
