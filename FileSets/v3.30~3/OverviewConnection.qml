import QtQuick 1.1

/*
 * This qml Item creates a line with moving balls on it representing a
 * power flow in the overview. The line can be made up of an arbitary
 * amount of straight line segments. The paths is drawn from (0,0) to
 * (width, height) so it can simply be anchored to the points you want
 * to connect. Since this item can have negative height and width the
 * wording (top, left) and (right, bottom) is a bit weird, since they
 * can be two arbitrary points, but so be it.
 *
 * This item is a bit weird anyway, first of all, since Path is an array,
 * and qml arrays are weird in qt quick 1.1, it is not possible to bind
 * to its contents. Hence the onCompleted events are used to assign them
 * by value.
 *
 * Secondly, this item is slow! To deal with that a bit, the contents is
 * only drawn when active is true. So the item can first be layout and
 * its contents only layouted once.
 */

Item {
	id: root

////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 1

	property Path path: emptyPath

	property Path straight: Path {
				PathLine {x: 0; y: 0}
				PathLine {x: width; y: height}
			}
	property Path corner: Path {
				PathLine {x: 0; y: 0}
				PathLine {x: width; y: 0}
				PathLine {x: width; y: height}
			}
	property Path emptyPath: Path {}

	property bool active
	property int ballCount: 4
////// GuiMods — DarkMode
	property color ballColor: !darkMode ? "#4789d0" : "#386ca5"
	property real ballDiameter: lineWidth * 2 + 1
////// GuiMods — DarkMode
	property color lineColor: !darkMode ? "#4789d0" : "#386ca5"
	property int lineWidth: 3
	property int value
	property bool startPointVisible: true
	property bool endPointVisible: true

	// internal
	property int lineSegments
	property Path activePath: active ? path : emptyPath

	visible: active

	function update() {
		if (activePath === emptyPath) {
			lineSegments = 0
			return
		}

		var newValue = activePath.pathElements.length - 1

		if (lineSegments == newValue)
			lineSegments = newValue - 1;
		lineSegments = newValue

		startPoint.update()
		endPoint.update()
	}

	onActivePathChanged: update()
	onHeightChanged: update()
	onWidthChanged: update()

	// end points of the path
	OverviewConnectionEnd {
		id: startPoint
		visible: active && startPointVisible
		connectionSize: ballDiameter

		// assign this otherwise qml will warn it is unbindable
		function update() {
			rotation = Math.atan2(activePath.pathElements[1].y, activePath.pathElements[1].x) * (180 / Math.PI)
		}
	}

	OverviewConnectionEnd {
		id: endPoint
		visible: active && endPointVisible
		x: root.width
		y: root.height
		connectionSize: ballDiameter

		function update() {
			var dx = activePath.pathElements[lineSegments].x - activePath.pathElements[lineSegments - 1].x
			var dy = activePath.pathElements[lineSegments].y - activePath.pathElements[lineSegments - 1].y
			rotation = 180 + Math.atan2(dy, dx) * (180 / Math.PI)
		}
	}

	// Draw foreground lines on top of that
	Repeater {
		id: lines
		model: lineSegments

		Line {
			lineWidth: root.lineWidth
			color: lineColor

			// assign this otherwise qml will warn it is unbindable
			Component.onCompleted: {
				from = activePath.pathElements[index]
				to = activePath.pathElements[index + 1]
			}
		}
	}

	// moving balls over the lines
	PathView {
		id: ballsPath
		model: active ? ballCount : 0
		interactive: false
		path: activePath
		visible: value != 0
		offset: active && value < 0 ? 1 - mover.pos : mover.pos

		delegate: Circle {
			color: ballColor
			radius: root.ballDiameter / 2
		}
	}
}
