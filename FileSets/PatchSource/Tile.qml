import QtQuick 1.1

Rectangle {
	id: root

////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/Gui/ColorScheme" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 0

	color: "#009ec6"
	border.width: 2
////// GuiMods — DarkMode
	border.color: !darkMode ? "#fff" : "#202020"
	clip: true

	property string title
	property alias values: column.children
	property bool readOnly: true
	property bool editable: false
	property bool editMode: false
	property bool isCurrentItem: ListView.isCurrentItem
	property int contentHeight: column.y + column.height
	property bool show: true

	Text {
		id: titleField
		font.pixelSize: 13
		text: title
////// GuiMods — DarkMode
		color: !darkMode ? "white" : "#ddd"
		height: text === "" ? 0 : paintedHeight
		anchors {
			top: parent.top; topMargin: 5
			left: parent.left; leftMargin: 5
		}
	}

	Rectangle {
		id: titleLine
		width: parent.width - 10
		height: 1
		visible: title !== ""
////// GuiMods — DarkMode
		color: !darkMode ? "white" : "#ddd"
		anchors {
			top: titleField.bottom
			left: titleField.left
		}
	}

	Column {
		id: column
		anchors {
			top: titleLine.bottom; topMargin: 3
			horizontalCenter: parent.horizontalCenter
		}
	}

	MbIcon {
		id: editIcon
		iconId: root.isCurrentItem ? "icon-tile-edit-active" : "icon-tile-edit"
		visible: (root.isCurrentItem || root.focus) && root.editable && !editMode
		anchors { right: parent.right; bottom: column.bottom; margins: 3}
	}
}
