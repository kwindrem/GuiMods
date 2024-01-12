// for GuiMods
// a touchable target to be attached to overview tiles
// to lead to the associated details page
// the target is also displayed to indicate which object
// can be activated by clicking the "space" button

import QtQuick 1.1

MouseArea
{
    property color detailsBackgroundColor: "#b3b3b3"
	property string detailsPage: ""
	property string detailsPath: "/opt/victronenergy/gui/qml/" + detailsPage

	property variant target: undefined
	property bool targetVisible: false

	anchors.centerIn: parent
	enabled: parent.visible
	height: 40; width: 40
	onClicked: { rootWindow.pageStack.push (detailsPath, {backgroundColor: detailsBackgroundColor} ) }
	Rectangle
	{
		id: _rect
		color: "black"
		anchors.fill: parent
		radius: width * 0.2
		opacity: 0.3
		visible: parent.enabled && parent.targetVisible
	}
}
