import QtQuick 1.1

Text {
////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 1

	font.pixelSize: 14
	color: !darkMode ? "white" : "#e1e1e1"
	width: parent.width
	horizontalAlignment: Text.AlignHCenter
}
