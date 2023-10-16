import QtQuick 1.1

// NOTE: centers around the circle it midpoint
// width and height are bogus!
Item {
	id: root

////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 1

	property real radius: 5.5
	property alias color: ball.color
	property int connectionSize: 7
	property int connectionLength: 9
	property alias rotation: connection.rotation

	Rectangle {
		id: connection

		transformOrigin: Item.Left
////// GuiMods — DarkMode
		color: !darkMode ? "white" : "#202020"
		width: root.radius + connectionLength
		height: connectionSize
		anchors {
			verticalCenter: ball.verticalCenter
			left: ball.horizontalCenter
		}
	}

	Circle {
		id: ball
		radius: root.radius
////// GuiMods — DarkMode
		color: !darkMode ? "#4789d0" : "#386ca5"
		x: -radius
		y: -radius

		border {
			width: 2
////// GuiMods — DarkMode
			color: !darkMode ? "white" : "#202020"
		}
	}
}
