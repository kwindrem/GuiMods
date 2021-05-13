////// MODIFIED to hide Blue Solar icon
import QtQuick 1.1

Item {
	id: root

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
		titleColor: "#F4B350"
		color: "#F39C12"

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
////// MODIFIED to hide Blue Solar icon
		display: true
	}

	MbIcon {
		anchors {
			bottom: blueSolarChargerBox.bottom; bottomMargin: 3
			left: parent.left; leftMargin: 2
		}
		iconId: "overview-victron-logo-small"
////// MODIFIED to hide Blue Solar icon
		display: false
	}
}
