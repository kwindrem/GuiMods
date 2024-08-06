import QtQuick 1.1

Text {
////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/Gui/ColorScheme" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 0

	font.pixelSize: 14
////// GuiMods — DarkMode
	color: !darkMode ? "white" : "#e1e1e1"
	width: parent.width
	horizontalAlignment: Text.AlignHCenter
}
