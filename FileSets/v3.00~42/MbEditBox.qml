import QtQuick 1.1
import Qt.labs.components.native 1.0
import com.victron.velib 1.0

MbItem {
	id: root
	cornerMark: !readonly && !editMode
	height: expanded.y + expanded.height + 1

////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 1

	property alias maximumLength: ti.maximumLength
	property variant tmpValue
	property string matchString: "0123456789 abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#$%^&*()-_=+[]{}\;:|/.,<>?"
	property string ignoreChars
	property bool readonly: !userHasWriteAccess
	property bool overwriteMode: false
	property VBusItem item: VBusItem { text: valueToText(value) }
	property string invalidText: ""
	property string description
	property bool enableSpaceBar: false
	property bool useVirtualKeyboard
	property alias numericOnlyLayout: virtualKeyboard.numericOnlyLayout
	property alias textInput: ti
	property alias leftRightText: buttonExplanation.leftRightText
	property alias upDownText: buttonExplanation.upDownText
	property alias centerText: buttonExplanation.centerText
	property alias unit: _unitText.text

	// internal
	property string _editText

	signal editDone(string newValue)

	NumberAnimation {
		id: blink
		target: textInput
		property: "opacity"
		from: textInput.opacity
		to: !textInput.opacity
		loops: 5
		duration: 350
		onCompleted: textInput.opacity = 1
	}

	function restoreOriginalText() {
		item.setValue(tmpValue)
	}

	function valueToText(value) {
		return (value === undefined ? invalidText : value)
	}

	function editTextToValue() {
		return _editText.trim()
	}

	function getEditText(value) {
		return item.text
	}

	function validate(newText, pos) {
		return newText
	}

	function save() {
		var newValue = editTextToValue()
		if (newValue === null) {
			blink.running = true
		} else {
			editMode = false
			root.focus = true
			item.setValue(newValue)
			root.editDone(newValue)
		}
	}

	function cancel() {
		if (editMode) {
			editMode = false
			root.focus = true
			item.setValue(tmpValue)
		}
	}

	function edit(isMouse) {
		if (!readonly && !editMode) {
			useVirtualKeyboard = isMouse === true
			ti.focus = true
			_editText = getEditText()
			tmpValue = item.value
			editMode = true
			ti.cursorPosition = 0;
		}
	}

	function isEditablePosition(pos)
	{
		if (pos === undefined)
			pos = textInput.cursorPosition

		return pos >= 0 && pos < textInput.text.length && ignoreChars.indexOf(textInput.text[pos]) < 0
	}

	function setValueAtPosition(position, value, insert, moveCursor) {
		if (insert) {
			if (_editText.length >= maximumLength)
				return
		} else {
			if (!isEditablePosition(position))
				return
		}

		// check for supported characters
		if (matchString.indexOf(value) < 0)
			return

		var newText = setValueAt(_editText, position, value, insert);
		newText = validate(newText, position)
		if (newText === null)
			return

		// assign new text, and place the cursor at the right position
		_editText = newText;
		setCursorPosition(position, moveCursor)
	}

	function setCursorPosition(position, direction) {
		if (direction)
			position += direction

		while (position >= 0 && position < textInput.text.length) {
			if (!direction || ignoreChars.indexOf(textInput.text[position]) < 0) {
				textInput.cursorPosition = position
				return
			}
			position += direction
		}
		if (!overwriteMode && position === textInput.text.length)
			textInput.cursorPosition = position
	}

	function wrapAround(pos) {
		return matchString.length
	}

	function cursorUpOrDown(direction) {
		if (!overwriteMode && textInput.cursorPosition === _editText.length && _editText.length < maximumLength)
			_editText += " "

		if (!isEditablePosition())
			return

		var chr = _editText.charAt(textInput.cursorPosition)
		var wrap = wrapAround(textInput.cursorPosition)
		var index = (matchString.indexOf(chr) + wrap + direction) % wrap;
		setValueAtPosition(textInput.cursorPosition, matchString[index])
	}

	function cursorLeftOrRight(direction) {
		// add and eat spaces at the beginning and end when not in overwriteMode
		if (!overwriteMode) {
			if (textInput.cursorPosition === 0) {
				if (direction === -1 && _editText.length < maximumLength) {
					setValueAtPosition(0, " ", true)
					return
				}
				if (direction === 1 && _editText.charAt(0) === " ") {
					setValueAtPosition(textInput.cursorPosition, "")
					return
				}
			}

			if (textInput.cursorPosition === _editText.length) {
				if (direction === -1 && _editText.charAt(textInput.cursorPosition - 1) === " ") {
					setValueAtPosition(textInput.cursorPosition - 1, "")
					return
				}
				if (direction === 1 && _editText.length < maximumLength) {
					setValueAtPosition(textInput.cursorPosition, " ", true, 1)
					return
				}
			}
		}

		setCursorPosition(textInput.cursorPosition, direction)
	}

	function keyPressed(event) {
		event.accepted = true

		switch (event.key) {
		case Qt.Key_Backspace:
			if (overwriteMode || overwriteMode)
				cursorLeftOrRight(-1)
			else
				setValueAtPosition(textInput.cursorPosition - 1, '')
			return

		case Qt.Key_Delete:
			if (overwriteMode || overwriteMode)
				return
			setValueAtPosition(textInput.cursorPosition, '')
			return

		default:
			if (event.text === "")
				return
		}

		setValueAtPosition(textInput.cursorPosition, event.text, !overwriteMode, 1)
	}

	// javascript lacks a char replace for strings, spell it out
	function setValueAt(str, index, character, insert) {
		return str.substr(0, index) + character + str.substr(index + (insert === true ? 0 : 1));
	}

	MbTextDescription {
		id: name
		height: defaultHeight

		anchors {
			left: parent.left;
			leftMargin: style.marginDefault
			top: parent.top
		}
		verticalAlignment: Text.AlignVCenter
		text: root.description
		isCurrentItem: root.ListView.isCurrentItem || editMode
	}

	Item {
		id: inputItem

		property real cursorWidth: 8.0
		height: defaultHeight
		anchors {
			right: parent.right
			top: parent.top
		}

		MbBackgroundRect {
			id: greytag
////// GuiMods — DarkMode
			color: !darkMode ? (editMode ? "#fff": "#ddd") : (editMode ? "#747474": "#4b4b4b")
			width: ti.width + 2 * style.marginDefault
			height: ti.height + 6
////// GuiMods — DarkMode
			border.color: !darkMode ? "#ddd" : "#4b4b4b"
			border.width: editMode ? 1 : 0
			anchors.centerIn: ti
		}

		// Optional unit at the right. It will remain gray, also in edit mode
		MbBackgroundRect {
			id: rightSide
			anchors.right: parent.right; anchors.rightMargin: style.marginDefault
			anchors.verticalCenter: ti.verticalCenter
			width: (_unitText.width ? _unitText.width + style.marginDefault : 0)
			height: greytag.height

			Text {
				id: _unitText
				font.pixelSize: root.style.fontPixelSize
				anchors.verticalCenter: parent.verticalCenter
			}
		}

		Text {
			id: ti
			anchors{
				right: rightSide.left
				// If there is a unit, make the two round boxes overlap..
				rightMargin: _unitText.width ? 0 : root.style.marginDefault
				top: parent.top
				topMargin: (defaultHeight - height) / 2
			}

////// GuiMods — DarkMode
			color: !darkMode ? "#000000" : "#fdfdfd"

			text: editMode ? _editText : item.text
			// When editing the it is nice to have a fix with font, so when changing
			// digits the text does change in length all the time. However this fonts
			// has an zero with a dot in it, with looks inconsitent with the regular
			// font. So only use the fixed with font when editing.
			font.family: editMode ? "DejaVu Sans Mono" : root.style.fontFamily
			font.pixelSize: root.style.fontPixelSize

			property int maximumLength: 20
			property int cursorPosition

			Item {
				id: cursorItem

				anchors {
					left: ti.left
					// The vePlatform.measureText can be off by one, which normally doesn't matter but causes
					// a wobbling cursor when at the end. So ti.paintedWidth when at the end instead.
					leftMargin: (
						ti.cursorPosition === _editText.length ?
						ti.paintedWidth :
						vePlatform.measureText(ti.font.family, ti.font.pixelSize, ti.text, 0, ti.cursorPosition)
					)
					top: ti.top
					bottom: ti.bottom
				}
				width: (ti.cursorPosition < ti.text.length ?
						vePlatform.measureText(ti.font.family, ti.font.pixelSize, ti.text, ti.cursorPosition, 1) :
						6)

				Rectangle {
					anchors.top: cursorItem.top
					anchors.topMargin: -1
					width: cursorItem.width
					height: parent.parent.focus ? 2 : 0
					border.color: "black"
					border.width: 2
				}

				Rectangle {
					anchors.bottom: cursorItem.bottom
					anchors.bottomMargin: -2
					width: cursorItem.width
					height: parent.parent.focus ? 2 : 0
					border.color: "black"
					border.width: 2
				}
			}

			Keys.onPressed: keyPressed(event)

			Keys.onSpacePressed: {
				if (root.enableSpaceBar || root.useVirtualKeyboard) {
					event.accepted = false;
					return
				}

				save()
			}

			Keys.onReturnPressed: save()
			Keys.onEscapePressed: cancel()
			Keys.onUpPressed: cursorUpOrDown(1)
			Keys.onDownPressed: cursorUpOrDown(-1)
			Keys.onRightPressed: cursorLeftOrRight(1)
			Keys.onLeftPressed: cursorLeftOrRight(-1)
		}

		MouseArea {
			anchors {
				left: ti.left
				right: inputItem.right
				top: ti.top
				bottom: ti.bottom
			}

			onPressed: {
				if (editMode) {
					var n = vePlatform.hitTestText(ti.font.family, ti.font.pixelSize, ti.text, mouseX)
					// The position after the last one can be selected so backspace works.
					// Since it is not a editable position, check this first.
					if (!overwriteMode && n === textInput.text.length) {
						ti.cursorPosition = n
						return
					}
					// Don't select the other uneditable positions
					if (!isEditablePosition(n))
						return
					ti.cursorPosition = n
				} else {
					handleMouseClick();
				}
			}
		}
	}

	Item {
		id: expanded
		height: childrenRect.height
		anchors.top: inputItem.bottom
		anchors.topMargin: -1

		Keyboard {
			id: virtualKeyboard

			overwriteMode: root.overwriteMode
			width: root.width
			active: editMode && root.useVirtualKeyboard
			onAnimatingChanged: {
				if (!animating)
					listview.positionViewAtIndex(currentIndex, ListView.Contain)
			}
		}

		MbButtonExplanation {
			id: buttonExplanation

			width: root.width
			shown: editMode && !root.useVirtualKeyboard
			leftRightText: qsTr("Select position")
			upDownText: qsTr("Select character")
			centerText: enableSpaceBar ? qsTr("Add space") : qsTr("Apply changes")

			onAnimatingChanged: {
				if (!animating)
					listview.positionViewAtIndex(currentIndex, ListView.Contain)
			}
		}
	}
}
