//// For GuiMods GUI
//
// formats values to varying resolution depending on the value
// the global variable sys.kilowattThreshold specifies the transition between units an K units
// item is a VBusItem
// unit is an optional string ("W", "A", "V", etc appended to the value
// if unit is omitted, VBusItem unit is used
// to disable the VBusItem unit specify "", or some other value

// functions that take a value can be used when a VBusItem doesn't provide the value
// for value > 1000, only K will always be displayed even if the unit is blank

// the optional precision parameter always displays the value to the indicated number of decimal point
//		(e.g, 2 would display 12.34)
// scaling to kilo values is disabled
// you must specify a unit if precision is needed !!!

// the ...Abs versions always display a postive number
//	used when a direction indicator is also displayed

function formatValue (value, unit, precision)
{
	if (unit == undefined)
		unit = ""

	var threshold
	if (sys.kilowattThreshold == undefined)
		threshold = 1000
	else
		threshold = sys.kilowattThreshold


	if (threshold == 0 || (value >= 0 && value < threshold) || (value < 0 && value > -threshold))
	{
		if (precision != undefined)
			return value.toFixed (precision) + " " + unit
		else if (value >= 100 || value <= -100)
			return value.toFixed (0) + " " + unit
		else
			return value.toFixed (1) + " " + unit
	}
	else
	{
		if (precision != undefined)
			return value.toFixed (precision) + " " + unit
		else if (value >= 10000 || value <= -10000)
			return (value/1000).toFixed (1) + " K" + unit
		else
			return (value/1000).toFixed (2) + " K" + unit
	}
}

function formatValueAbs (value, unit, precision)
{
	if (unit == undefined)
		unit = ""
	if ( value < 0)
		value = -value
	return formatValue (value, unit, precision)
}

function formatVBusItem (item, unit, precision)
{
	if (item.valid)
	{
		if (unit == undefined)
			unit = item.unit
		return formatValue (item.value, unit, precision)
	}
	else
		return ""
}

function formatVBusItemAbs (item, unit, precision)
{
	var value
	if (item.valid)
	{
		if (unit == undefined)
			unit = item.unit
		return formatValueAbs (item.value, unit, precision)
	}
	else
		return ""
}
