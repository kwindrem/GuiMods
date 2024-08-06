import QtQuick 1.1

Rectangle {
	id: root

////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/Gui/ColorScheme" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 0

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
////// GuiMods — DarkMode
		titleColor: !darkMode ? "#F4B350" : "#7A5928"
		color: !darkMode ? "#F39C12" : "#794E09"

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
