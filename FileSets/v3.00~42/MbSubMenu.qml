import QtQuick 1.1
import Qt.labs.components.native 1.0
import com.victron.velib 1.0

MbItem {
	id: root
	width: pageStack ? pageStack.currentPage.width : 0

	property VBusItem darkMode: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }

	property string description
	property VBusItem item: VBusItem {}
	property string iconId: "icon-toolbar-enter"
	property bool check: false
	property bool indent: false
	default property alias values: _values.data

	MbTextDescription {
		id: checkText
		anchors {
			left: parent.left; leftMargin: style.marginDefault
			verticalCenter: parent.verticalCenter
		}
		width: root.indent ? 9 : 0
		text: root.check ? "√" : " "
	}

	MbTextDescription {
		id: name
		anchors {
			left: checkText.right; leftMargin: root.indent ? checkText.width : 0
			verticalCenter: parent.verticalCenter
		}
		text: root.description
	}

	MbRow {
		id: _values

		anchors {
			right: icon.left; rightMargin: style.marginDefault / 2
			verticalCenter: parent.verticalCenter
		}

		Repeater {
			id: repeater
			model: root.item.value && root.item.value.constructor === Array ? root.item.value.length : 1

			MbTextBlock {
				item.text: repeater.model === 1 ? root.item.text : root.item.value[index]
				opacity: item.text !== item.invalidText
			}
		}
	}

	MbIcon {
		id: icon

		display: hasSubpage
		anchors {
			right: root.right; rightMargin: style.marginDefault
			verticalCenter: parent.verticalCenter
		}
		iconId: root.iconId ? root.iconId + (root.ListView.isCurrentItem || darkMode.value ? "-active" : "") : ""
	}
}
