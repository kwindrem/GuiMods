import QtQuick 1.1
import Qt.labs.components.native 1.0
import com.victron.velib 1.0

MbItem {
	id: root
	cornerMark: !readOnly && !spinbox.enabled

////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 1

	property string description
	property bool readOnly: !userHasWriteAccess
	property VBusItem item: VBusItem {
		isSetting: true
		decimals: 1
		step: 0.5
	}
	property bool useVirtualKeyboard
	property variant spinboxToolbarHandler: editMode ? _spinboxToolbarHandler : navigationHandler
	default property alias values: container.data

	editMode: spinbox.enabled
	height: keyboard.y + keyboard.height + 1
	toolbarHandler: spinboxToolbarHandler

	ToolbarHandler {
		id: _spinboxToolbarHandler
		property string leftIcon: "icon-toolbar-cancel"
		property string rightIcon: "icon-toolbar-ok"
		property string rightText: ""

		function leftAction()
		{
			cancel()
		}

		function rightAction()
		{
			save()
		}
	}

	signal exitEditMode(bool changed, variant newValue)
	signal maxValueReached()
	signal minValueReached()

	Item {
		id: verticalCentered
		height: root.defaultHeight
		width: root.width

		MbTextDescription {
			id: name
			anchors {
				left: parent.left; leftMargin: style.marginDefault
				verticalCenter: parent.verticalCenter
			}

			isCurrentItem: root.ListView.isCurrentItem
			text: root.description
			opacity: item.valid ? style.opacityEnabled : style.opacityDisabled
		}

		Item {
			id: container
			width: childrenRect.width
			height: childrenRect.height
			anchors {
				right: graytag.left; rightMargin: style.marginDefault
				verticalCenter: parent.verticalCenter
			}
		}

		MbBackgroundRect {
			id: graytag
////// GuiMods — DarkMode
			color: !darkMode ? (!spinbox.enabled ? "#ddd": "#fff") : (!spinbox.enabled ? "#4b4b4b": "#747474")
			height: spinbox.height + 6
			width:  spinbox.width  + unit.width + 10
////// GuiMods — DarkMode
			border.color: !darkMode ? "#ddd" : "#4b4b4b"
			border.width: spinbox.enabled ? 1 : 0
			anchors {
				right: parent.right; rightMargin: style.marginDefault
				verticalCenter: parent.verticalCenter
			}
		}

		MbTextValue {
			id: unit

			text: root.item.unit
			anchors {
				right: parent.right; rightMargin: style.marginDefault + 5
				verticalCenter: spinbox.verticalCenter
			}
		}

		SpinBox {
			id: spinbox

			color: style.color2
			font.pixelSize: name.font.pixelSize
			font.family: name.font.family
			font.bold: false
			minimumValue: item.min
			maximumValue: item.max
			stepSize: item.step
			enabled: false
			greyed: item.valid
			numOfDecimals: item.decimals
			anchors {
				right: unit.left
				verticalCenter: parent.verticalCenter
			}

			/* note: these functions break binding hence the Binding item below */
			Keys.onRightPressed: { if (value === maximumValue) maxValueReached(); spinbox.up(event.isAutoRepeat); }
			Keys.onLeftPressed: { if (value === minimumValue) minValueReached(); spinbox.down(event.isAutoRepeat); }
			Keys.onUpPressed: { if (value === maximumValue) maxValueReached(); spinbox.up(event.isAutoRepeat); }
			Keys.onDownPressed: { if (value === minimumValue) minValueReached(); spinbox.down(event.isAutoRepeat); }

			/* Focus is removed to ignore keypresses */
			Keys.onSpacePressed: save(false)
			Keys.onReturnPressed: save(false)
			Keys.onEscapePressed: cancel()
		}

		MouseArea {
			anchors {
				fill: spinbox
				leftMargin: -20
				rightMargin: -20
			}

			onPressed: handleMouseClick(true)
		}
	}

	Keyboard {
		id: keyboard
		anchors.top: verticalCentered.bottom
		anchors.topMargin: -1
		width: root.width
		active: spinbox.enabled && useVirtualKeyboard
		layout: "KeyboardLoaderPlusMin.qml"
		onAnimatingChanged: listview.positionViewAtIndex(currentIndex, ListView.Contain)
	}

	/* binding is done explicitly to reenable binding after edit */
	Binding {
		target: spinbox
		property: "value"
		value: item.value
		when: item.valid && !spinbox.enabled
	}

	function edit(isMouse)
	{
		if (item.valid && !readOnly)
		{
			useVirtualKeyboard = isMouse === true
			spinbox.enabled = true
			spinbox.focus = true
		}
	}

	function save() {
		var newValue = spinbox.value
		item.setValue(spinbox.value)
		focus = true;
		spinbox.enabled = false
		exitEditMode(true, newValue)
	}

	function cancel() {
		focus = true
		spinbox.enabled = false
		exitEditMode(false, undefined)
	}
}
