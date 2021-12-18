//////// Modified for GuiMods2
//////// allows hiding the Fronius Logo
//////// moves logo to the right side of the tile and make it translucent

import QtQuick 1.1

Rectangle {
	id: root

	default property alias values: pvInverterBox.values
	property alias title: pvInverterBox.title
    property bool showInverterIcon: true
    property bool showInverterLogo: true

	width: 155
	height: 115
	color: "transparent"
	clip: true

	Image {
		id: pvInverterIcon
		source: getDeviceIcon()
		width: sourceSize.width
		height: sourceSize.height
		visible: showInverterIcon && getDeviceIcon() !== ""
		anchors.bottom: parent.bottom
	}

	OverviewBox {
		id: pvInverterBox

		height: root.height
		title: qsTr("PV Power")
		titleColor: "#F4B350"
		color: "#F39C12"

		anchors {
			bottom: parent.bottom
			left: pvInverterIcon.left; leftMargin: pvInverterIcon.visible ? 32 : 0
			right: parent.right
		}

		Image {
			source: getDeviceLogo()
			visible: !showInverterIcon && showInverterLogo
            opacity: 0.3
			anchors {
				bottom: parent.bottom
				right: parent.right
				margins: 2
			}
		}
	}

	function getDeviceIcon()
	{
		var ids = sys.pvInvertersProductIds.text
		if (ids.indexOf(0xA142) > -1)
			return "image://theme/overview-pvinverter-fronius"
		return ""
	}
	function getDeviceLogo()
	{
		var ids = sys.pvInvertersProductIds.text
		if (ids.indexOf(0xA142) > -1)
			return "image://theme/overview-fronius-logo"
		return ""
	}
}
