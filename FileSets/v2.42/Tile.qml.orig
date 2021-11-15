import QtQuick 1.1

Rectangle {
	id: root

	color: "#009ec6"
	border.width: 2
	border.color: "#fff"
	clip: true

	property string title
	property alias values: column.children
	property bool readOnly: true
	property bool editable: false
	property bool editMode: false
	property bool isCurrentItem: ListView.isCurrentItem
	property int contentHeight: column.y + column.height
	// property bool show // a non patched qt needs this, but cannot hide the Item

	Text {
		id: titleField
		font.pixelSize: 13
		text: title
		color: "white"
		anchors {
			top: parent.top; topMargin: 5
			left: parent.left; leftMargin: 5
		}
		Component.onCompleted: if (text === "") height = 0
	}

	Rectangle {
		id: titleLine
		width: parent.width - 10
		height: 1
		visible: title !== ""
		color: "white"
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
