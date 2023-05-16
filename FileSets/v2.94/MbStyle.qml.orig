import QtQuick 1.1

/*
 * common style properties
 */
QtObject {
	property bool isCurrentItem

	// Default MbItem size
	property int itemHeight: 35

	// Default font and size for e.g. the menus
	property string fontFamily: "DejaVu Sans Condensed"
	property int fontPixelSize: 16

	property string borderColor: "#ddd"
	property string backgroundColor: isCurrentItem ? '#4790d0' : 'transparent'
	property string backgroundColorService: isCurrentItem ? "#2969a1" : '#ffe9b7'
	property string backgroundColorComponent: borderColor

	// Text mainly used for description etc.
	property string textColor: "#000000"
	property string textColorSelected: "#FFFFFF"

	// Color typically used for values
	property string valueColor: "#333333"
	property int valueHorizontalAlignment: Text.AlignRight
	property string color2: "#333333"

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
