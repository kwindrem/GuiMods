////// modified to show voltage, current and frequency in flow overview
// only displays values for sys.acInput and sys.acLoad
// because other connections don't have related parameters
////// modified to show power bar graphs


import QtQuick 1.1
import "enhancedFormat.js" as EnhFmt

Item {
	id: root
	width: parent.width
	height: parent.height

	// NOTE: data is taken by qml, hence it is called connection
	property variant connection

    property int phaseCount: root.connection !== undefined && root.connection.phaseCount.valid ? root.connection.phaseCount.value : 0

	Column {
////// modified to show power bar graphs
		y: 6

		width: parent.width
		spacing: 0

        // total power
		TileText {
            text: EnhFmt.formatVBusItem (root.connection.power)
////// modified to show power bar graphs
			font.pixelSize: 19
            height: 21
            visible: phaseCount >= 1
		}

        // voltage for single leg
        TileText {
            text: EnhFmt.formatVBusItem (root.connection.voltageL1, "V")
            visible: phaseCount === 1
            font.pixelSize: 15
        }
        // current for single leg
        TileText {
            text: EnhFmt.formatVBusItem (root.connection.currentL1, "A")
            font.pixelSize: 15
            visible: phaseCount === 1
        }

        // power, voltage and current for multiple legs
        TileText {
            text: "L1:" + EnhFmt.formatVBusItem (root.connection.powerL1, "W")
				+ " " + EnhFmt.formatVBusItem (root.connection.voltageL1, "V")
				+ " " + EnhFmt.formatVBusItem (root.connection.currentL1, "A")
            visible: phaseCount >= 2
            font.pixelSize: 11
        }
        // spacer to avoid connection dot
        TileText {
            text: ""
            visible: phaseCount === 2 || phaseCount === 3 && root.height >= 90
            font.pixelSize: 8
        }
        TileText {
            text:
            {
				if (root.connection.l1AndL2OutShorted)
					return "L2 included in L1"
				else
				{
					return "L2:" + EnhFmt.formatVBusItem (root.connection.powerL2, "W")
						+ " " + EnhFmt.formatVBusItem (root.connection.voltageL2, "V")
						+ " " + EnhFmt.formatVBusItem (root.connection.currentL2, "A")
				}
			}
            visible: phaseCount >= 2
            font.pixelSize: 11
        }
        TileText {
            text: "L3:" + EnhFmt.formatVBusItem (root.connection.powerL3, "W")
				+ " " + EnhFmt.formatVBusItem (root.connection.voltageL3, "V")
				+ " " + EnhFmt.formatVBusItem (root.connection.currentL3, "A")
            visible: phaseCount >= 3
            font.pixelSize: 11
        }
        // spacer
        TileText {
            text: ""
            visible: phaseCount === 2 && root.height >= 90
            font.pixelSize: 11
        }
        TileText {
            text: EnhFmt.formatVBusItem (root.connection.frequency, "Hz")
            font.pixelSize: phaseCount >= 2 ? 11 : 15
            visible: phaseCount === 1 || root.connection != sys.acInput
        }
        TileText {
            text: qsTr("Limit: ") + EnhFmt.formatVBusItem (root.connection.inCurrentLimit)
            font.pixelSize: 15
            visible: phaseCount === 1 && root.connection == sys.acInput
        }
        // frequency and input current limit for multiple legs
        TileText {
            text: EnhFmt.formatVBusItem (root.connection.frequency, "Hz")
				+ " " + EnhFmt.formatVBusItem (root.connection.inCurrentLimit)
            font.pixelSize: 11
            visible: phaseCount >= 2 && root.connection == sys.acInput
        }
    }
}
