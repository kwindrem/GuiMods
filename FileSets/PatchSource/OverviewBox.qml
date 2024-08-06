import QtQuick 1.1

SvgRectangle {
	id: root

////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/Gui/ColorScheme" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 0

	radius: 6
	width: 110
	height: 110
////// GuiMods — DarkMode
	color: !darkMode ? "#16a185" : "#0B5042"
	clip: true // hides an off by one pixel offset

	property string title
////// GuiMods — DarkMode
	property string titleColor: !darkMode ? "#1abc9c" : "#136050"
	property alias values: _values.children

	SvgRectangle {
		id: header
		width: parent.width
		height: 20
		radius: root.radius
		color: titleColor

		// prevent rounded corners at the bottom
		SvgRectangle {
			height: parent.height / 2
			width: parent.width
			color: parent.color
			anchors.top: parent.verticalCenter
		}

		Text {
			text: title
			font {pixelSize: 14; bold: true}
////// GuiMods — DarkMode
			color: !darkMode ? "white" : "#e1e1e1"
			anchors.centerIn: parent
		}
	}

	Item {
		id: _values
		anchors {
			top: header.bottom;
			bottom: root.bottom
			left: root.left
			right: root.right
		}
	}
}
