import QtQuick 1.1

Item {
	id: root

	width: 145
	height: 101

	property real soc: 80
////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 1
	property string color: !darkMode ? "#4789d0" : "#234468"
	property string emptyColor: !darkMode ? "#1abc9c" : "#0d5e4e"

	property alias values: _values.children
	property bool preferRenewable: sys.preferRenewableEnergy.valid
	property bool renewableOverride: preferRenewable
			&& (sys.preferRenewableEnergy.value === 0 || sys.acSource == 2)


	SvgRectangle {
		id: leftTerminal
		width: 12
		height: 8
		radius: 3
		color: soc < 100 ? emptyColor : root.color
		anchors {
			left: root.left; leftMargin: 12
		}
		x: 12
	}

	SvgRectangle {
		id: rightTerminal
		width: 12
		height: 8
		radius: 3
		color: soc < 100 ? emptyColor : root.color
		anchors {
			right: root.right; rightMargin: 12
		}
	}

	Rectangle {
		id: background

		// NOTE: to remove the bottom of the terminals
////// GuiMods — DarkMode
		border {width: 2; color: !darkMode ? "white" : "#202020"}
		height: root.height - leftTerminal.height
		width: root.width
		y: leftTerminal.height - 1

		SvgRectangle {
			height: parent.height
			width: parent.width
			color: root.emptyColor
			radius: 3
		}

		SvgRectangle {
			id: filledPart
			width: root.width
			height: soc * background.height / 100
			color: root.color
			anchors.bottom: parent.bottom
			radius: 3
		}

		SvgRectangle {
			height: parent.height
			width: parent.width * 0.7
			anchors.centerIn: parent
////// GuiMods — DarkMode
			color: !darkMode ? "#ffffff" : "#202020"
			opacity: 0.06
		}
	}

	MbIcon {
		iconId: getBatteryLogo()
		anchors {
			right: parent.right; rightMargin: 4
			bottom: parent.bottom; bottomMargin: 4
		}

		function getBatteryLogo()
		{
			var pid = sys.batteryProductId.value
			var logo = ""

			if (pid === 0xB014)
				logo = "overview-battery-freedomwon"

			return logo
		}
	}

	Rectangle {
		height: 30
		width: 25
		visible: preferRenewable
		color: renewableOverride ? "#b84b00" : "transparent"
		clip: true
		anchors {
			top: background.top
			topMargin: 13
		}

		MbIcon {
			iconId: "double-arrow-up"
			visible: renewableOverride
			anchors {
				verticalCenter: parent.verticalCenter
				horizontalCenter: parent.horizontalCenter
			}
		}
		MbIcon {
			iconId:
			{
				if (renewableOverride)
				{
					if (sys.acSource == 2)
						return "overview-generator-background"
					else
						return "overview-tower-background"
				}
				else if (darkMode)
					return "overview-renewable-light"
				else
					return "overview-renewable"
			}
			height: parent.height * 0.9
			width: parent.width * 0.8
			fillMode: Image.PreserveAspectFit
			anchors {
				horizontalCenter: parent.horizontalCenter
				verticalCenter: parent.verticalCenter
			}
		}
	}

	Text {
		text: "-"
		font.pixelSize: 13; font.bold: true
		anchors.centerIn: leftTerminal
		anchors.verticalCenterOffset: 12
////// GuiMods — DarkMode
		color: !darkMode ? "#fff" : "#e1e1e1"
	}

	Text {
		text: "+"
		font.pixelSize: 13; font.bold: true
		anchors.centerIn: rightTerminal
		anchors.verticalCenterOffset: 12
////// GuiMods — DarkMode
		color: !darkMode ? "#fff" : "#e1e1e1"
	}

	Item {
		id: _values
		anchors {
			top: background.top;
			bottom: root.bottom
			left: root.left
			right: root.right
		}
	}
}
