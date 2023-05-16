import QtQuick 1.1

Rectangle {
	id: root

	property VBusItem darkMode: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }
	default property alias values: pvInverterBox.values
	property alias title: pvInverterBox.title
	property bool showInverterIcon: true

	width: 155
	height: 115
	color: "transparent"
	clip: true

	MbIcon {
		id: pvInverterIcon
		iconId: getDeviceIcon()
		visible: showInverterIcon && getDeviceIcon() !== ""
		anchors.bottom: parent.bottom
	}

	OverviewBox {
		id: pvInverterBox

		height: root.height
		title: qsTr("PV Power")
		titleColor: darkMode.value == 0 ? "#F4B350" : "#7A5928"
		color: darkMode.value == 0 ? "#F39C12" : "#794E09"

		anchors {
			bottom: parent.bottom
			left: pvInverterIcon.left; leftMargin: pvInverterIcon.visible ? 32 : 0
			right: parent.right
		}

		MbIcon {
			iconId: getDeviceLogo()
			visible: !showInverterIcon
			anchors {
				bottom: parent.bottom
				left: parent.left
				margins: 2
			}
		}
	}

	function getDeviceIcon()
	{
		var ids = sys.pvInvertersProductIds.text
		if (ids.indexOf(0xA142) > -1)
			return "overview-pvinverter-fronius"
		return ""
	}

	function getDeviceLogo()
	{
		var ids = sys.pvInvertersProductIds.text
		if (ids.indexOf(0xA142) > -1)
			return "overview-fronius-logo"
		return ""
	}
}
