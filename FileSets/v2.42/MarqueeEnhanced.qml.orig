import QtQuick 1.1

Rectangle {
	id: marquee

	height: _text.paintedHeight + 5
	clip: true
	color: "transparent"

	property alias text: _text.text
	property alias interval: marqueeTimer.interval
	property alias fontSize: _text.font.pixelSize
	property alias textColor: _text.color
	property alias scroll: marqueeTimer.running

	Text {
		id: _text
		font.pixelSize: 13
		color: "#fff"
		width: parent.width
		anchors.verticalCenter: parent.verticalCenter
		horizontalAlignment: scroll ? Text.AlignLeft : Text.AlignHCenter
	}

	Timer {
		id: marqueeTimer
		interval: 100
		repeat: true
		running: _text.paintedWidth > marquee.width
		onTriggered: moveText()
		onRunningChanged: if (!running) _text.x = 0
	}

	function moveText() {
		if (_text.x + _text.paintedWidth < 0)
			_text.x = marquee.width
		_text.x -= 2;
	}
}
