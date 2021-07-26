////// use v2.71 version which includes textHorizontalAlignment
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
	property alias textHorizontalAlignment: _text.horizontalAlignment
	property bool scroll: true

	function doScroll()
	{
		if (_text.paintedWidth > marquee.width)
			marqueeTimer.running = true
	}

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
		running: _text.paintedWidth > marquee.width && scroll
		onTriggered: moveText()
		onRunningChanged: if (!running) _text.x = 0
	}

	function moveText()
	{
		if (_text.x + _text.paintedWidth < 0)
			_text.x = marquee.width

		_text.x -= (!scroll && _text.x === 1 ? 1 : 2);

		if (!scroll && _text.x === 0)
			marqueeTimer.running = false
	}
}
