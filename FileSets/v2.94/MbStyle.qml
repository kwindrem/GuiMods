import QtQuick 1.1

/*
 * common style properties
 */
QtObject {
	property VBusItem darkMode: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }

	property bool isCurrentItem

	// Default MbItem size
	property int itemHeight: 35

	// Default font and size for e.g. the menus
	property string fontFamily: "DejaVu Sans Condensed"
	property int fontPixelSize: 16

	property string borderColor: darkMode.value == 0 ? "#ddd" : "#4b4b4b"
	property string backgroundColor: darkMode.value == 0 ? (isCurrentItem ? '#4790d0' : 'transparent') : (isCurrentItem ? '#234468' : '#202020')
	property string backgroundColorService: darkMode.value == 0 ? (isCurrentItem ? "#2969a1" : '#ffe9b7') : (isCurrentItem ? "#234468" : '#7f745b')
	property string backgroundColorComponent: borderColor

	// Text mainly used for description etc.
	property string textColor: darkMode.value == 0 ? "#000000" : "#fdfdfd"
	property string textColorSelected: darkMode.value == 0 ? "#FFFFFF" : "#fdfdfd"

	// Color typically used for values
	property string valueColor: darkMode.value == 0 ? "#333333" : "#fdfdfd"
	property int valueHorizontalAlignment: Text.AlignRight
	property string color2: darkMode.value == 0 ? "#333333" : "#fdfdfd"

	property int marginDefault: 8
	// margin between MbItem border and components for bottom / top
	property int marginItemVertical: 3
	// margin from the "sides", typically left / right
	property int marginItemHorizontal: 8
	// prefered left / right text margin within text components
	property int marginTextHorizontal: 5

	property real opacityEnabled: 1.0
	property real opacityDisabled: 0.5
}
