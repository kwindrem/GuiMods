// for GuiMods
// for GuiMods -- a special case of Button
// adds a highlight so user knows which button will be pressed
// when the hard "space" button is pressed

import QtQuick 1.1

Item {
	id: buttonContainer

	property string baseColor
	property string pressedColor
	property string text
	property string iconSource
	property alias radius: innerRectangle.radius
	property alias content: loader.sourceComponent
	property bool enablePressAndHold
	property bool highlight: false
	property string highlightColor: "black"

	signal clicked()

	MouseArea {
		id: mouseArea
		anchors.fill: buttonContainer
		onClicked: buttonContainer.clicked()
		onPressAndHold: if (enablePressAndHold) timer.start()
		onReleased: timer.stop()
	}

	// Repeated click on longpress
	Timer {
		id: timer
		interval: 40
		running: false
		repeat: true
		onTriggered: buttonContainer.clicked()
	}

	Rectangle
	{
		id: highlight
		anchors.centerIn: parent
		width: parent.width + 6
		height: parent.height + 6

		color: highlightColor
		radius: 2
		visible: parent.highlight
	}

	// The purpose of this inner rectangle is to draw the rounded corners, but we want the mouse area to
	// be the whole (rectangular) button to catch the touches. This also allows disabling the button but
	// keep the layout constant.
	Rectangle {
		id: innerRectangle
		anchors.fill: buttonContainer
		color: (mouseArea.containsMouse && mouseArea.pressed) ? buttonContainer.pressedColor : buttonContainer.baseColor
		radius: 2

		Loader {
			id: loader
			anchors.centerIn: innerRectangle
		}
	}
}
