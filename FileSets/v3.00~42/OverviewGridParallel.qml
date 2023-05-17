import QtQuick 1.1
import "utils.js" as Utils

OverviewPage {
	id: root

////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 1

	property variant sys: theSystem
	property bool hasAcOutSystem: _hasAcOutSystem.value === 1

	title: qsTr("Overview")

	VBusItem {
		id: _hasAcOutSystem
		bind: "com.victronenergy.settings/Settings/SystemSetup/HasAcOutSystem"
	}

	OverviewBox {
		id: acInBox

		width: 148
		height: 100
		title: getAcSourceName(sys.acSource)
		titleColor: !darkMode ? "#E74c3c" : "#73261E"
		color: !darkMode ? "#C0392B" : "#601C15"
		anchors {
			top: root.top; topMargin: 1
			left: parent.left; leftMargin: 5
		}

		values:	OverviewAcValues {
			connection: sys.acInput
		}

		MbIcon {
			iconId: getAcSourceIcon(sys.acSource)
			anchors {
				bottom: parent.bottom
				left: parent.left; leftMargin: 2
			}
			opacity: 0.5
		}
	}

	OverviewBox {
		id: acLoadBox
		title: qsTr("AC Loads")
		color: !darkMode ? "#27AE60" : "#135730"
		titleColor: !darkMode ? "#2ECC71" : "#176638"
		width: 148
		height: 100

		anchors {
			left: acInBox.right
			leftMargin: hasAcOutSystem ? 10 : 174
			top: root.top; topMargin: 1
		}

		values:	OverviewAcValues {
			connection: sys.acInLoad
		}
	}

	OverviewBox {
		id: acOutputBox
		title: qsTr("Critical Loads")
		color: !darkMode ? "#157894" : "#0a3c4a"
		titleColor: !darkMode ? "#419FB9" : "#204f5c"
		height: 100
		width: 148
		visible: hasAcOutSystem
		anchors {
			right: root.right; rightMargin: 5
			top: root.top; topMargin: 17
		}

		values:	OverviewAcValues {
			connection: sys.acOutLoad
		}
	}

	Multi {
		id: multi
		iconId: "overview-inverter-short"
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: root.bottom; bottomMargin: 39
		}
	}

	// invisible item to connection all AC connections to..
	Item {
		id: acBus
		height: 10
		anchors {
			left: acInBox.left; leftMargin: hasAcOutSystem ? 5 : acInBox.width - 5
			right: acLoadBox.right; rightMargin: 2
			bottom: acInBox.bottom; bottomMargin: -15
		}
	}

	Battery {
		id: battery

		soc: sys.battery.soc.valid ? sys.battery.soc.value : 0
		height: pvInverterOnGrid.visible ? 81 : 101
		width: 145

		anchors {
			bottom: parent.bottom; bottomMargin: 5;
			left:parent.left; leftMargin: 5
		}
		values: Column {
			y: pvInverterOnGrid.visible ? 0 : 8
			width: parent.width

			TileText {
				text: sys.battery.soc.valid ? sys.battery.soc.value.toFixed(0) : "--"
				font.pixelSize: 30

				Text {
					anchors {
						bottom: parent.bottom; bottomMargin: 4
						horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: parent.paintedWidth / 2 + 5
					}
					visible: sys.battery.soc.valid
					text: "%"
					color: "white"
					font.bold: true
					font.pixelSize: 12
				}
			}
			TileText {
				text: sys.battery.power.format(0)
			}
			TileText {
				text: sys.battery.voltage.format(1) + "   " + sys.battery.current.format(1)
			}
		}
	}

	// PV inverter on AC in, AC Output ignored
	OverviewSolarInverter {
		id: pvInverterOnGridNoAcOut
		title: qsTr("PV Inverter")
		width: 154
		height: 100
		visible: sys.pvOnGrid.power.valid && !hasAcOutSystem
		showInverterIcon: false
		values: TileText {
			y: 2
			text: sys.pvOnGrid.power.format(0)
			font.pixelSize: 25
		}
		anchors {
			top: root.top; topMargin: 1
			horizontalCenter: root.horizontalCenter
		}
	}

	OverviewSolarInverter {
		id: pvInverterOnGrid
		title: qsTr("PV Inverter")
		width: 148
		height: 60
		visible: sys.pvOnGrid.power.valid && hasAcOutSystem
		showInverterIcon: false
		values: TileText {
			y: 2
			text: sys.pvOnGrid.power.format(0)
			font.pixelSize: 20
		}
		anchors {
			bottom: battery.top; bottomMargin: 5
			left: root.left; leftMargin: 5
		}
	}

	OverviewSolarInverter {
		id: pvInverterOnAcOut
		title: qsTr("PV Inverter")
		width: 148
		height: 60
		visible: sys.pvOnAcOut.power.valid
		showInverterIcon: false

		values: TileText {
			y: 2
			text: sys.pvOnAcOut.power.format(0)
			font.pixelSize: 20
		}
		anchors {
			bottom: blueSolarCharger.top; bottomMargin: 5
			right: parent.right; rightMargin: 5
		}
	}

	OverviewSolarCharger {
		id: blueSolarCharger
		title: qsTr("PV Charger")
		width: 148
		height: 60
		visible: sys.pvCharger.power.valid
		showChargerIcon: false

		anchors {
			right: root.right; rightMargin: 5
			bottom: root.bottom; bottomMargin: 5;
		}

		values: TileText {
			y: 2
			text: sys.pvCharger.power.format(0)
			font.pixelSize: 20
		}
	}

	OverviewEssReason {
		anchors {
			bottom: parent.bottom; bottomMargin: 5
			horizontalCenter: parent.horizontalCenter
		}
	}

	// AC source power flow
	OverviewConnection {
		id: acSource
		ballCount: 4
		path: corner
		active: root.active && hasAcOutSystem
		value: flow(sys.acInput ? sys.acInput.power : undefined) * -1
		startPointVisible: false

		anchors {
			right: acInBox.left; rightMargin: -9
			left: pvInverterOnGridConnection.horizontalCenter
			bottom: acInBox.bottom; bottomMargin: 8
			top: acBus.verticalCenter
		}
	}

	// Coupled AC sources
	OverviewConnection {
		id: coupledAcConnection

		property VBusItem coupled: VBusItem {
			property double gridPower: sys.acInput.power.valid ? sys.acInput.power.value : 0
			property double pvPower: sys.pvOnGrid.power.valid ? sys.pvOnGrid.power.value : 0
			value: gridPower + pvPower
		}

		ballCount: 1
		path: straight
		active: root.active && hasAcOutSystem
		value: flow(coupled)
		startPointVisible: false
		endPointVisible: false

		anchors {
			left: pvInverterOnGridConnection.right
			right: vebusConnection.left
			top: acBus.verticalCenter
			bottom: acBus.verticalCenter
		}
	}

	// AC source power flow, ignored AC output
	OverviewConnection {
		id: acSourceNoAcOut
		ballCount: 5
		path: corner
		active: root.active && !hasAcOutSystem
		value: acSource.value
		startPointVisible: false

		anchors {
			right: acInBox.left; rightMargin: -9
			left: pvInverterOnGridConnectionNoAcOut.horizontalCenter
			bottom: acInBox.bottom; bottomMargin: 8
			top: acBus.verticalCenter
		}
	}

	// Coupled AC sources, ignored AC output
	OverviewConnection {
		id: coupledAcConnectionNoAcOut

		ballCount: 1
		path: straight
		active: root.active && !hasAcOutSystem
		value: coupledAcConnection.value
		startPointVisible: false
		endPointVisible: false

		anchors {
			left: pvInverterOnGridConnectionNoAcOut.right
			right: vebusConnection.left
			top: acBus.verticalCenter
			bottom: acBus.verticalCenter
		}
	}

	// Grid inverter power flow, ignored AC output
	OverviewConnection {
		id: pvInverterOnGridConnectionNoAcOut
		ballCount: 1
		path: straight
		active: root.active && pvInverterOnGridNoAcOut.visible
		value: flow(sys.pvOnGrid ? sys.pvOnGrid.power : undefined)
		startPointVisible: true
		endPointVisible: false

		anchors {
			top: pvInverterOnGridNoAcOut.bottom; topMargin: -8
			bottom: acBus.verticalCenter
			left: pvInverterOnGridNoAcOut.left; leftMargin: 8
			right: pvInverterOnGridNoAcOut.left; rightMargin: -8
		}
	}

	// Grid inverter power flow
	OverviewConnection {
		id: pvInverterOnGridConnection
		ballCount: 1
		path: straight
		active: root.active && pvInverterOnGrid.visible
		value: flow(sys.pvOnGrid ? sys.pvOnGrid.power : undefined) * -1
		startPointVisible: false

		anchors {
			top: acBus.verticalCenter
			bottom: pvInverterOnGrid.top; bottomMargin: -8
			left: pvInverterOnGrid.right; leftMargin: -8
		}
	}

	// power to loads
	OverviewConnection {
		id: loadConnection
		ballCount: hasAcOutSystem ? 3 : 5
		path: corner
		active: root.active
		value: flow(sys.acInLoad.power)
		startPointVisible: false
		endPointVisible: true

		anchors {
			right: acLoadBox.right; rightMargin: hasAcOutSystem ? 10 : acLoadBox.width - 10
			left: vebusConnection.horizontalCenter
			top: acBus.verticalCenter
			bottom: acLoadBox.bottom; bottomMargin: 8
		}
	}

	// Towards vebus system
	OverviewConnection {
		id: vebusConnection

		property VBusItem vebusAcPower: VBusItem { bind: [sys.vebusPrefix, "/Ac/ActiveIn/P"] }

		ballCount: 1
		path: straight
		active: root.active
		value: flow(vebusAcPower)
		startPointVisible: false
		endPointVisible: true

		anchors {
			left: multi.left; leftMargin: 8
			top: acBus.verticalCenter
			bottom: multi.top; bottomMargin: -7
		}
	}

	// AC out connection
	OverviewConnection {
		id: acOutConnection

		property double pvInverterOnAcOutPower: sys.pvOnAcOut.power.valid ? sys.pvOnAcOut.power.value : 0
		property double acOutLoad: sys.acOutLoad.power.valid ? sys.acOutLoad.power.value : 0
		property VBusItem vebusAcOutPower: VBusItem { value: acOutConnection.acOutLoad - acOutConnection.pvInverterOnAcOutPower }

		ballCount: 1
		path: straight
		active: root.active && (hasAcOutSystem || pvInverterOnAcOut.visible)
		value: flow(vebusAcOutPower)
		endPointVisible: false

		anchors {
			left: multi.right; leftMargin: -8
			right: acOutBoxConnection.left
			top:  multi.top; topMargin: 8
		}
	}

	// UPS conenction
	OverviewConnection {
		id: acOutBoxConnection

		ballCount: 1
		path: straight
		active: root.active && hasAcOutSystem
		value: flow(sys.acOutLoad.power)
		startPointVisible: false

		anchors {
			left: acOutputBox.left; leftMargin: 10
			top: acOutConnection.verticalCenter
			bottom: acOutputBox.bottom; bottomMargin: 9
		}
	}

	// PV Inverter on AC out connection
	OverviewConnection {
		id: pvOnAcOutConnection

		ballCount: 1
		path: straight
		active: root.active && pvInverterOnAcOut.visible
		value: flow(sys.pvOnAcOut.power)
		endPointVisible: false

		anchors {
			left: acOutBoxConnection.left
			bottom: acOutConnection.verticalCenter
			top: pvInverterOnAcOut.top; topMargin: 8
		}
	}

	// DC connection from multi
	OverviewConnection {
		ballCount: 1
		path: straight
		active: root.active
		value: flow(sys.vebusDc.power)
		endPointVisible: false

		anchors {
			right: dcConnection.right;
			top:  multi.bottom; topMargin: -10
			bottom: dcConnection.top;
		}
	}

	// Battery to DC connection
	OverviewConnection {
		ballCount: 3
		path: straight
		active: root.active
		value: Utils.sign(noNoise(sys.pvCharger.power) + noNoise(sys.vebusDc.power))
		startPointVisible: false

		anchors {
			left: dcConnection.left;
			top: dcConnection.verticalCenter
			right: battery.right; rightMargin: 10
		}
	}

	// Solar charger to DC connection
	OverviewConnection {
		ballCount: 3
		path: straight
		active: root.active && blueSolarCharger.visible
		value: flow(sys.pvCharger.power)
		endPointVisible: false

		anchors {
			right: dcConnection.right;
			top: dcConnection.top
			left: blueSolarCharger.left; leftMargin: 10
		}
	}

	Item {
		id: dcConnection
		anchors {
			horizontalCenter: multi.horizontalCenter
			top: multi.bottom; topMargin: 10
		}
	}
}
