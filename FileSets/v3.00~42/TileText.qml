import QtQuick 1.1

Text {
	property VBusItem darkMode: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }

	font.pixelSize: 14
	color: darkMode.value == 0 ? "white" : "#e1e1e1"
	width: parent.width
	horizontalAlignment: Text.AlignHCenter
}
