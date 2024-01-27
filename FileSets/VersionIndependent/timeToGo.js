// converts time to go in seconds to an appropriate display
// min : sec for values less than 1 hour
// hour : min for values > 1 hour, < 1 day
// days : hours for values > 1 day
// Utils.secondsToString does not format the time properly - sometimes
// this code is copied from MbItemTimeSpan used in PageBattery.qml which seems to work
function formatTimeToGo (item)
{
	if (!item.valid)
		return "--"

	var secs = Math.round(item.value)
	var days = Math.floor(secs / 86400);
	var hours = Math.floor((secs - (days * 86400)) / 3600);
	var minutes = Math.floor((secs - (hours * 3600)) / 60);
	var seconds = Math.floor(secs - (minutes * 60));

	if (days > 0)
		return qsTr("%1d %2h").arg(days).arg(hours);
	else if (hours > 0)
		return qsTr("%1h %2m").arg(hours).arg(minutes);
	else if (minutes > 0)
		return qsTr("%1m %2s").arg(minutes).arg(seconds);
	else
		return qsTr("%1s").arg(seconds);
}
