/////// new menu for package version display

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

MbPage {
	id: root
	title: qsTr("Package Versions")
    property string bindPrefix: "com.victronenergy.settings/Settings/GuiMods"
    VBusItem { id: checkingPackageItem; bind: Utils.path(bindPrefix, "/CheckingPackage") }
    property string checkingPackage: checkingPackageItem.valid ? checkingPackageItem.value : ""

	model: VisualItemModel
    {
        MbItemOptions
        {
            id: autoUpdate
            description: qsTr ("Automatic Git Hub updates")
            bind: Utils.path (bindPrefix, "/GitHubAutoUpdate")
            possibleValues:
            [
                MbOption { description: "Normal"; value: 1 },
                MbOption { description: "Fast one pass then Normal"; value: 2 },
                MbOption { description: "Check packages once"; value: 3 },
                MbOption { description: "Disabled"; value: 0 }
            ]
            writeAccessLevel: User.AccessUser
        }
        MbItemText
        {
            text: checkingPackage
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            show: checkingPackage != ""
        }
        MbItemValue
        {
            description: qsTr("SetupHelper")
            item.bind: Utils.path(root.bindPrefix, "/PackageVersions/SetupHelper")
            show: item.valid
        }
        MbItemValue
        {
            description: qsTr("GuiMods")
            item.bind: Utils.path(root.bindPrefix, "/PackageVersions/GuiMods")
            show: item.valid
        }
        MbItemValue
        {
            description: qsTr("GeneratorConnector")
            item.bind: Utils.path(root.bindPrefix, "/PackageVersions/GeneratorConnector")
            show: item.valid
        }
        MbItemValue
        {
            description: qsTr("RpiDisplaySetup")
            item.bind: Utils.path(root.bindPrefix, "/PackageVersions/RpiDisplaySetup")
            show: item.valid
        }
        MbItemValue
        {
            description: qsTr("RpiGpioSetup")
            item.bind: Utils.path(root.bindPrefix, "/PackageVersions/RpiGpioSetup")
            show: item.valid
        }
        MbItemValue
        {
            description: qsTr("TankRepeater")
            item.bind: Utils.path(root.bindPrefix, "/PackageVersions/TankRepeater")
            show: item.valid
        }
        MbItemValue
        {
            description: qsTr("VeCanSetup")
            item.bind: Utils.path(root.bindPrefix, "/PackageVersions/VeCanSetup")
            show: item.valid
        }
    }
}
