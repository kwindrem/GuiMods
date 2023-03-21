////// add bold
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
	property variant textHorizontalAlignment: Text.AlignHCenter
    property alias bold: _text.font.bold
	property bool scroll: true
    property bool longName: text != "" && _text.paintedWidth > marquee.width

    function doScroll()
    {
        if (longName)
            marqueeTimer.running = true
    }

	Text {
		id: _text
		font.pixelSize: 13
		color: "#fff"
		width: parent.width
		anchors.verticalCenter: parent.verticalCenter
		// use spcified alignment unless name won't fit or are scrolling, then align left
        horizontalAlignment: longName && scroll ? Text.AlignLeft : textHorizontalAlignment
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
