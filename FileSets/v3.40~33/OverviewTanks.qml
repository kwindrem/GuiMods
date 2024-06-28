import QtQuick 1.1
import com.victron.velib 1.0
import "utils.js" as Utils
import "tanksensor.js" as TankSensor

OverviewPage {
	id: root

////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 1

	property int numberOfTanks: tanks.all.rowCount
	property int visibleTanks: tanks.rowCount
	property int maxTanksPerPage: 10
	property bool showAllTanksPage: numberOfTanks > 0 && numberOfTanks <= maxTanksPerPage
	property int currentIndex
	property int availableFluidTypes

	title: qsTr("Tanks")
	clip: true

	ListModel { id: fluidModel }

	property TankModel tanks: TankModel {
		all.onRowCountChanged: fluidTypesChanged()
		all.onDataChanged: fluidTypesChanged()
	}

	Component.onCompleted: fluidTypesChanged()

	// Background image when searching for tanks
	Image {
		id: loadingBackground
		source: "image://theme/overview-tanks-loading"
		anchors.fill: parent
		visible: numberOfTanks === 0
	}

	Text {
		text: qsTr("No tanks found")
////// GuiMods — DarkMode
		color: !darkMode ? "#ffffff" : "#e1e1e1"
		font.pixelSize: 25
		anchors.centerIn: parent
		visible: numberOfTanks === 0
	}

	ListView {
		id: titleList
		width: root.width
		height: 25
		orientation: ListView.Horizontal
		spacing: 20

		// Keep the currentItem in the middle of the listview
		highlightRangeMode: ListView.StrictlyEnforceRange
		preferredHighlightBegin: currentItem ? width / 2 - currentItem.width / 2 : 0
		preferredHighlightEnd: currentItem ? width / 2 + currentItem.width / 2 : 0

		model: fluidModel
		interactive: false
		anchors { top: parent.top; topMargin: 16 }
		currentIndex: root.currentIndex
		visible: numberOfTanks > 0

		delegate: Text {
			text: fluidName
			height: 25
			font.pixelSize: 16
////// GuiMods — DarkMode
			opacity: ListView.isCurrentItem ? 1 : (!darkMode ? 0.3 : 0.5)
			verticalAlignment: Text.AlignVCenter
			scale: ListView.isCurrentItem ? 1.25 : 1
////// GuiMods — DarkMode
			color: !darkMode ? "black" : "#e1e1e1"

			Behavior on scale {
				NumberAnimation { duration: 150 }
			}

			MouseArea {
				anchors.fill: parent
				onClicked: setCurrentIndex(model.index)
			}
		}

		// Fade the sides of the title list
		Rectangle {
			height: parent.width / 3
			width: parent.height
			y: 25
			transform: Rotation { origin.x: 0; origin.y: 0; angle: -90}
			gradient: Gradient {
////// GuiMods — DarkMode
				GradientStop { position: 0.7; color: !darkMode ? "white" : "#202020" }
				GradientStop { position: 1; color: "transparent" }
			}
		}

		Rectangle {
			height: parent.width / 3
			width: parent.height
			x: parent.width
			transform: Rotation { origin.x: 0; origin.y: 0; angle: 90}
			gradient: Gradient {
////// GuiMods — DarkMode
				GradientStop { position: 0.7; color: !darkMode ? "white" : "#202020" }
				GradientStop { position: 1; color: "transparent" }
			}
		}

		// touch buttons for selecting a tank type
		MbIcon {
////// GuiMods — DarkMode
			iconId: darkMode ? "icon-toolbar-enter" : "icon-toolbar-enter-active"
			rotation: 180
			anchors {
				left: parent.left; leftMargin: 40
				verticalCenter: parent.verticalCenter
			}

			MouseArea {
				onClicked: decreaseIndex()
				anchors {
					fill: parent; margins: -16
				}
			}
		}

		MbIcon {
////// GuiMods — DarkMode
			iconId: darkMode ? "icon-toolbar-enter" : "icon-toolbar-enter-active"
			anchors {
				right: parent.right; rightMargin: 40
				verticalCenter: parent.verticalCenter
			}

			MouseArea {
				onClicked: increaseIndex()
				anchors {
					fill: parent; margins: -16
				}
			}
		}
	}

	Flow {
		id: tanksFlow
		spacing: visibleTanks > 8 ? 10 : 15

		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: navigation.top; bottomMargin: 4
			top: titleList.bottom; topMargin: 16
		}

		Repeater {
			id: tanksRepeater
			model: tanks
			delegate: OverviewTankDelegate {
				bindPrefix: buddy.id
				width: Math.min(65, Math.max((470 / visibleTanks - tanksFlow.spacing) + tanksFlow.spacing / visibleTanks, 35))
				height: tanksFlow.height
			}
		}
	}

	Flow {
		id: navigation
		height: 41
		spacing: 15
		visible: numberOfTanks > 0

		anchors {
			bottom: parent.bottom; bottomMargin: 16
			horizontalCenter: parent.horizontalCenter
		}

		Repeater {
			model: fluidModel
			delegate: OverviewRoundButton {
				iconId: fluidIcon
				separatorLine.visible: model.index === 0 && showAllTanksPage
				onClicked: setCurrentIndex(index)
			}
		}
	}

	// This is a seperate item, to disable the default left / right action, showing the toolbar
	Item {
		Keys.onLeftPressed: decreaseIndex()
		Keys.onRightPressed: increaseIndex()
		focus: root.active
	}

	// Handle index change and set fluid type filter
	function setCurrentIndex(index)
	{
		currentIndex = (index + fluidModel.count) % fluidModel.count

		// Note: the keys can always be pressed even if fluidModel is empty, prevent
		// getting unexisting elements.
		if (fluidModel.count === 0) {
			tanks.filterRegExp = ""
		} else {
			var fluidType = fluidModel.get(currentIndex).fluidType
			tanks.filterRegExp = fluidType >= 0 ? "^" + fluidType + "$" : ""
		}
	}

	function increaseIndex()
	{
		setCurrentIndex(currentIndex + 1)
	}

	function decreaseIndex()
	{
		setCurrentIndex(currentIndex - 1)
	}

	function fluidTypesChanged()
	{
		var fluids = 0
		for (var i = 0; i < numberOfTanks; i++) {
			var val = tanks.all.getValue(i, VeQItemTableModel.ValueColumn)
			if (val !== undefined)
				fluids |= (1 << val)
		}

		if (availableFluidTypes !== fluids) {
			availableFluidTypes = fluids
			updateFluidsModel()
		}
	}

	function updateFluidsModel()
	{
		var selectedType = fluidModel.count ? fluidModel.get(currentIndex).fluidType : -1
		var index = 0

		fluidModel.clear()
		if (showAllTanksPage) {
			fluidModel.append({ fluidType: -1, fluidName: qsTr("All"), fluidIcon: "overview-tanks-all" })
			index = 1
		}

		var fluids = availableFluidTypes
		var fluidType = 0
		var typeFound = false
		while (fluids != 0) {
			if (fluids & 1) {
				var info = TankSensor.info(fluidType)
				fluidModel.append({ fluidType: fluidType, fluidName: info.name, fluidIcon: info.icon })
				if (selectedType === fluidType) {
					setCurrentIndex(index)
					typeFound = true
				}
				index++
			}
			fluids = fluids >> 1
			fluidType++
		}

		// If the selected tanks all disappeared, select all again / the first type
		if (!typeFound)
			setCurrentIndex(0)
	}
}
