////// MODIFIED to hide Blue Solar icon

import QtQuick 1.1

Item {
	id: root

	default property alias values: blueSolarChargerBox.values
	property alias title: blueSolarChargerBox.title
	property bool showChargerIcon: true

	width: 155
	height: 115

	Image {
		id: blueSolarChargerIcon

		source: "image://theme/overview-bluesolar-charger"
		width: showChargerIcon ? sourceSize.width : 0
		height: showChargerIcon ? sourceSize.height : 0
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

	Image {
		anchors {
			bottom: blueSolarChargerBox.bottom; bottomMargin: 3
			right: blueSolarChargerBox.right; rightMargin: 3
		}
		source: "image://theme/overview-sun"
////// MODIFIED to hide Blue Solar icon
		visible: true
	}

	Image {
		anchors {
			bottom: blueSolarChargerBox.bottom; bottomMargin: 3
			left: parent.left; leftMargin: 2
		}
		source: "image://theme/overview-victron-logo-small"
////// MODIFIED to hide Blue Solar icon
		visible: false
	}
}
