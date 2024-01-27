import QtQuick 1.1

Text {
	id: root

	property alias item: vItem
	property alias bind: vItem.bind
	property int value: item.valid ? item.value : 0
	property string onColor: "#fff930"
	property string offColor: "black"
	property bool pulse: false
	property bool isOn: false

	horizontalAlignment: Text.AlignHCenter
	font.pixelSize: 12
	color: isOn ? onColor : offColor
	font.bold: true

	onValueChanged: {
		switch (value) {
		case 0 :
			state = "off"
			break;
		case 1:
			state = "on"
			break;
		case 2:
			state = "blink"
			break;
		case 3:
			state = "blinkInverted"
			break;
		}
	}

	VBusItem { id: vItem }

	Timer {
		id: _timer
		interval: 500
		running: item.value > 0
		repeat: true
		onTriggered: pulse = !pulse
	}

	states: [
			State {
				name: "off"
				PropertyChanges { target: root; color : offColor }
			},
			State {
				name: "on"
				PropertyChanges { target: root; color : onColor }
			},
			State {
				name: "blink"
				PropertyChanges { target: root; color: pulse ? onColor : offColor }
			},
			State {
				name: "blinkInverted"
				PropertyChanges { target: root; isOn: !pulse ? onColor : offColor }
			}
		]
}

