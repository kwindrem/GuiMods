import QtQuick 1.1

Item {
	id: root

////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 1

	default property alias values: blueSolarChargerBox.values
	property alias title: blueSolarChargerBox.title
	property bool showChargerIcon: true

	width: 155
	height: 115

	MbIcon {
		id: blueSolarChargerIcon

		iconId: "overview-bluesolar-charger"
		anchors.bottom: root.bottom
		visible: showChargerIcon
	}

	OverviewBox {
		id: blueSolarChargerBox

		height: root.height
		title: qsTr("PV Power")
////// GuiMods — DarkMode
		titleColor: !darkMode ? "#F4B350" : "#7A5928"
		color: !darkMode ? "#F39C12" : "#794E09"

		anchors {
			bottom: root.bottom
			left: blueSolarChargerIcon.left; leftMargin: showChargerIcon ? 43 : 0
			right: parent.right
		}
	}

	MbIcon {
		anchors {
			bottom: blueSolarChargerBox.bottom; bottomMargin: 3
			right: blueSolarChargerBox.right; rightMargin: 3
		}
		iconId: "overview-sun"
		display: showChargerIcon
	}

	MbIcon {
		anchors {
			bottom: blueSolarChargerBox.bottom; bottomMargin: 3
			left: parent.left; leftMargin: 2
		}
		iconId: "overview-victron-logo-small"
		display: !showChargerIcon
	}
}
