import QtQuick 1.1

Item {
	id: root

	width: 145
	height: 101

	property VBusItem darkMode: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }
	property real soc: 80
	property string color: darkMode.value == 0 ? "#4789d0" : "#234468"
	property string emptyColor: darkMode.value == 0 ? "#1abc9c" : "#0d5e4e"
	property alias values: _values.children

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
		border {width: 2; color: darkMode.value == 0 ? "white" : "#202020"}
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
			color: darkMode.value == 0 ? "#ffffff" : "#202020"
			opacity: 0.06
		}
	}

	MbIcon {
		source: getBatteryLogo()
		anchors {
			right: parent.right; rightMargin: 4
			bottom: parent.bottom; bottomMargin: 4
		}

		function getBatteryLogo()
		{
			var pid = sys.batteryProductId.value
			var logo = ""

			if (pid === 0xB014)
				logo = "image://theme/overview-battery-freedomwon"

			return logo
		}
	}

	Text {
		text: "-"
		font.pixelSize: 13; font.bold: true
		anchors.centerIn: leftTerminal
		anchors.verticalCenterOffset: 12
		color: darkMode.value == 0 ? "#fff" : "#e1e1e1"
	}

	Text {
		text: "+"
		font.pixelSize: 13; font.bold: true
		anchors.centerIn: rightTerminal
		anchors.verticalCenterOffset: 12
		color: darkMode.value == 0 ? "#fff" : "#e1e1e1"
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
