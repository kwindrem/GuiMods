////// modified to show voltage, current and frequency in flow overview
// probably doesn't support paralleled Multis/Quatros


import QtQuick 1.1

Item {
	id: root
	width: parent.width

	// NOTE: data is taken by qml, hence it is called connection
	property variant connection
 
    property variant phaseCount: root.connection !== undefined && root.connection.phaseCount.valid ? root.connection.phaseCount.value : 0
    property variant l1voltage: root.connection == sys.acInput ? root.connection.inVoltageL1 : root.connection.outVoltageL1
    property variant l2voltage: root.connection == sys.acInput ? root.connection.inVoltageL2 : root.connection.outVoltageL2
    property variant l3voltage: root.connection == sys.acInput ? root.connection.inVoltageL3 : root.connection.outVoltageL3
    property variant l1current: root.connection == sys.acInput ? root.connection.inCurrentL1 : root.connection.outCurrentL1
    property variant l2current: root.connection == sys.acInput ? root.connection.inCurrentL2 : root.connection.outCurrentL2
    property variant l3current: root.connection == sys.acInput ? root.connection.inCurrentL3 : root.connection.outCurrentL3

	Column {
		y: 0

		width: parent.width
		spacing: 0

        // total power
		TileText {
			text: root.connection ? root.connection.power.format(0) : ""
			font.pixelSize: 25
			height: 27
		}

        // voltage for single leg
        TileText {
            text: l1voltage.format(0)
            visible: phaseCount === 1
            font.pixelSize: 15
        }
        // current for single leg
        TileText {
            text: l1current.format(1)
            font.pixelSize: 15
            visible: phaseCount === 1
        }

        // power, voltage and current for multiple legs
        TileText {
            text: l1current.value >= 1000
                ? "L1:" + root.connection.powerL1.format(0) + " " + l1voltage.format(0) + " " + l1current.format(0)
                : "L1: " + root.connection.powerL1.format(0) + " " + l1voltage.format(0) + " " + l1current.format(1)
            visible: phaseCount >= 2
            font.pixelSize: 11
        }
        // spacer to avoid connection dot
        TileText {
            text: ""
            visible: phaseCount >= 2
            font.pixelSize: 11
        }
        TileText {
            text: l1current.value >= 1000
                ? "L2:" + root.connection.powerL2.format(0) + " " + l2voltage.format(0) + " " + l2current.format(0)
                : "L2: " + root.connection.powerL2.format(0) + " " + l2voltage.format(0) + " " + l2current.format(1)
            visible: phaseCount >= 2
            font.pixelSize: 11
        }
        TileText {
            text: l1current.value >= 1000
                ? "L3:" + root.connection.powerL3.format(0) + " " + l3voltage.format(0) + " " + l3current.format(0)
                : "L3: " + root.connection.powerL3.format(0) + " " + l3voltage.format(0) + " " + l3current.format(1)
            visible: phaseCount >= 3
            font.pixelSize: 11
        }
        // spacer
        TileText {
            text: ""
            visible: phaseCount === 2
            font.pixelSize: 11
        }
        // frequency and input current limit single leg
        TileText {
            text: root.connection == sys.acInput
                ? root.connection.inFrequencyL1.format(1)
                : root.connection.outFrequencyL1.format(1)
            font.pixelSize: 15
            visible: phaseCount === 1
        }
        TileText {
            text: "Limit: " + root.connection.inCurrentLimit.format(1)
            font.pixelSize: 15
            visible: phaseCount === 1 && root.connection == sys.acInput
        }
        // frequency and input current limit for multiple legs
        TileText {
            text: root.connection == sys.acInput
                ? root.connection.inFrequencyL1.format(1) + " Limit: " + root.connection.inCurrentLimit.format(1)
                : root.connection.outFrequencyL1.format(1)
            font.pixelSize: 11
            visible: phaseCount >= 2
        }
    }
}
