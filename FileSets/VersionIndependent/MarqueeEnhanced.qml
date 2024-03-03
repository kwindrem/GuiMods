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
        horizontalAlignment: textHorizontalAlignment
        visible: ! longName
    }

    // double incoming text so the scroll fills in past the end of the string
    Text {
        id: _textToDisplay
        text: _text.text + "..." + _text.text
        font.pixelSize: 13
        color: _text.color
        font.bold: _text.font.bold
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        // use spcified alignment unless name won't fit or are scrolling, then align left
        horizontalAlignment: Text.AlignLeft
        visible: longName
    }


	Timer {
		id: marqueeTimer
		interval: 100
		repeat: true
		running: _text.paintedWidth > marquee.width && scroll
		onTriggered: moveText()
        onRunningChanged: if (!running) _textToDisplay.x = 0
	}

	function moveText()
	{
        if (_textToDisplay.x + _text.paintedWidth <= 2)
        {
            _textToDisplay.x = 0 ////marquee.width
            if (! scroll)
                marqueeTimer.running = false
        }
        else
            _textToDisplay.x -= 2
    }
}
