////// modified to hide individual leg values
// only displays values for sys.acInput and sys.acLoad
// because other connections don't have related parameters
////// modified to show power bar graphs


import QtQuick 1.1

Item {
	id: root
    width: parent.width
    height: parent.height

	// NOTE: data is taken by qml, hence it is called connection
	property variant connection

	Column {
////// modified to show power bar graphs
		y: 13

		width: parent.width
		spacing: 0

        // total power
		TileText {
            text: root.connection ? root.connection.power.format(0) : ""
////// modified to show power bar graphs
			font.pixelSize: 17
            height: 21
		}
    }
}
