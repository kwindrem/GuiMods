//// For GuiMods GUI
//
// formats values to varying resolution depending on the value
// the global variable killowattThreshold specifies the transition between units an K units
// item is a VBusItem
// unit is an optional string ("W", "A", "V", etc appended to the value
// if unit is omitted, VBusItem unit is used
// to disable the VBusItem unit specify "", or some other value
// note if you need to specify a threshold, you must also specify a unit !

// functions that take a value can be used when a VBusItem doesn't provide the value
// if no unit is provided, no unit is displayed
// for value > 1000, only K is then displayed

// the ...Abs versions always display a postive number
//	used when a direction indicator is also displayed

function formatValue (value, unit)
{
	if (unit == undefined)
		unit = ""

	var threshold
	if (sys.kilowattThreshold == undefined)
		threshold = 1000
	else
		threshold = sys.kilowattThreshold

	if (threshold == 0 || (value >= 0 && value < threshold) || (value < 0 && value > threshold))
	{
		if (value >= 100 || value <= -100)
			return value.toFixed (0) + " " + unit
		else
			return value.toFixed (1) + " " + unit
	}
	else if (value >= 10000 || value <= -10000)
		return (value/1000).toFixed (1) + " K" + unit
	else
		return (value/1000).toFixed (2) + " K" + unit
}

function formatValueAbs (value, unit)
{
	if (unit == undefined)
		unit = ""
	if ( value < 0)
		value = -value
	return formatValue (value, unit)
}

function formatVBusItem (item, unit)
{
	if (item.valid)
	{
		if (unit == undefined)
			unit = item.unit
		return formatValue (item.value, unit)
	}
	else
		return ""
}

function formatVBusItemAbs (item, unit)
{
	var value
	if (item.valid)
	{
		if (unit == undefined)
			unit = item.unit
		return formatValueAbs (item.value, unit)
	}
	else
		return ""
}
