import QtQuick 1.1

MbEditBox {
	id: root

////// GuiMods — DarkMode
	property VBusItem darkModeItem: VBusItem { bind: "com.victronenergy.settings/Settings/GuiMods/DarkMode" }
	property bool darkMode: darkModeItem.valid && darkModeItem.value == 1

	property string format: "yyyy-MM-dd hh:mm"
	property bool utc: false

	ignoreChars: "-: "
	matchString: "0123456789"
	maximumLength: format.length
	overwriteMode: true
	numericOnlyLayout: true
	upDownText: qsTr("Select number")
////// GuiMods — DarkMode
	textInput.color: editMode ? (vePlatform.secondsFromString(_editText, format) !== -1 ? (!darkMode ? "#000000" : "#fdfdfd") : "red") : (!darkMode ? "#000000" : "#fdfdfd")

	// note: overwritten by MbEditBoxTime!
	function getTimeSeconds(str) {
		return vePlatform.secondsFromString(str, format)
	}

	function editTextToValue() {
		var value = getTimeSeconds(_editText)
		return (value === -1 ? null : value)
	}

	function valueToText(value) {
		if (utc)
			return vePlatform.formatDateTimeUtc(value, format)
		return Qt.formatDateTime(new Date(value * 1000), format)
	}

	// make sure the time of days keeps below 24:00
	function validateHours(str, pos) {
		if (format[pos] === 'h' && format[pos + 1] === 'h' && str[pos] === '2' && str[pos + 1] > 3)
			str = setValueAt(str, pos + 1, '3', false);
		return str;
	}

	function validate(newText, pos) {
		var wrap = wrapAround(pos)

		if ((newText[pos] - '0') >= wrap) {
			var text = qsTr("Only numbers up to %1 are valid on this location").arg(wrap - 1)
			toast.createToast(text, 3000)
			return null
		}

		// respect the minimum value. Note: instead of declining the change the minimum value
		// is forced. The reason for that is that if e.g. 00:10 is decremented with a minimum
		// of one minute it becomes 00:01 instead of silently refusing the change.
		var ret = validateHours(newText, pos)
		if (item.min && getTimeSeconds(ret) < item.min)
			return valueToText(item.min)

		return ret
	}

	// some digit in e.g. time/data loop earlier than 0..9
	function wrapAround(pos) {
		switch (format[pos]) {
		// mm goes till 59
		case 'm':
			if (format[pos + 1] === 'm')
				return 6;
			break
		// hours till 23
		case 'h':
			if (format[pos + 1] === 'h')
				return 3;
			if (format[pos - 1] === 'h')
				return _editText[pos - 1] === '2' ? 4 : matchString.length
			break
		// days up to 31
		case 'd':
			if (format[pos + 1] === 'd')
				return 4;
			if (format[pos - 1] === 'd')
				return _editText[pos - 1] === '3' ? 2 : matchString.length;
			break;
		// months till 12
		case 'M':
			if (format[pos + 1] === 'M')
				return 2;
			if (format[pos - 1] === 'M')
				return _editText[pos - 1] === '1' ? 3 : matchString.length
			break
		}
		return matchString.length
	}
}
