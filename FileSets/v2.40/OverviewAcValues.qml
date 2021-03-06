////// modified to show voltage, current and frequency in flow overview
// only displays values for sys.acInput and sys.acLoad
// because other connections don't have related parameters
// may not support paralleled Multis/Quatros
////// modified to show power bar graphs


import QtQuick 1.1

Item {
	id: root
	width: parent.width

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
            text: root.connection ? root.connection.power.format(0) : ""
////// modified to show power bar graphs
			font.pixelSize: 19
            height: 23
            visible: phaseCount >= 1
		}

        // voltage for single leg
        TileText {
            text: voltageL1 ("")
            visible: phaseCount === 1
            font.pixelSize: 15
        }
        // current for single leg
        TileText {
            text: currentL1 ("")
            font.pixelSize: 15
            visible: phaseCount === 1
        }

        // power, voltage and current for multiple legs
        TileText {
            text: "L1:" + powerL1 () + voltageL1 (" ") + currentL1 (" ")
            visible: phaseCount >= 2
            font.pixelSize: 11
        }
        // spacer to avoid connection dot
        TileText {
            text: ""
            visible: phaseCount >= 2 && parrent.height >= 120
            font.pixelSize: 11
        }
        TileText {
            text: "L2:" + powerL2 () + voltageL2 (" ") + currentL2 (" ")
            visible: phaseCount >= 2
            font.pixelSize: 11
        }
        TileText {
            text: "L3:" + powerL3 () + voltageL3 (" ") + currentL3 (" ")
            visible: phaseCount >= 3
            font.pixelSize: 11
        }
        // spacer
        TileText {
            text: ""
            visible: phaseCount === 2 && parrent.height >= 120
            font.pixelSize: 11
        }
        // frequency and input current limit single leg
        TileText {
            text: frequency ()
            font.pixelSize: 15
            visible: phaseCount === 1
        }
        TileText {
            text: currentLimit ("")
            font.pixelSize: 15
            visible: phaseCount === 1 && root.connection == sys.acInput
        }
        // frequency and input current limit for multiple legs
        TileText {
            text: frequency () + currentLimit (" ")
            font.pixelSize: 11
            visible: phaseCount >= 2
        }
    }
    function voltageL1 (spacer)
    {
        switch (root.connection)
        {
            case sys.acInput:   return spacer + root.connection.inVoltageL1.format(0);
            case sys.acLoad:    return spacer + root.connection.outVoltageL1.format(0);
            default:            return "";
        }
    }
    function voltageL2 (spacer)
    {
        switch (root.connection)
        {
            case sys.acInput:   return spacer + root.connection.inVoltageL2.format(0);
            case sys.acLoad:    return spacer + root.connection.outVoltageL2.format(0);
            default:            return "";
        }
    }
    function voltageL3 (spacer)
    {
        switch (root.connection)
        {
            case sys.acInput:   return spacer + root.connection.inVoltageL3.format(0);
            case sys.acLoad:    return spacer + root.connection.outVoltageL3.format(0);
            default:            return "";
        }
    }
    function currentL1 (spacer)
    {
        var current
        switch (root.connection)
        {
            case sys.acInput:
                current = root.connection.inCurrentL1
                return current >= 1000 ? spacer + current.format(0) : spacer + current.format(1);
            case sys.acLoad: 
                current = root.connection.outCurrentL1
                return current >= 1000 ? spacer + current.format(0) : spacer + current.format(1);
            default:
                return "";
        }
    }
    function currentL2 (spacer)
    {
        var current
        switch (root.connection)
        {
            case sys.acInput:
                current = root.connection.inCurrentL2
                return current >= 1000 ? spacer + current.format(0) : spacer + current.format(1);
            case sys.acLoad: 
                current = root.connection.outCurrentL2
                return current >= 1000 ? spacer + current.format(0) : spacer + current.format(1);
            default:
                return "";
        }
    }
    function currentL3 (spacer)
    {
        var current
        switch (root.connection)
        {
            case sys.acInput:
                current = root.connection.inCurrentL3
                return current >= 1000 ? spacer + current.format(0) : spacer + current.format(1);
            case sys.acLoad: 
                current = root.connection.outCurrentL3
                return current >= 1000 ? spacer + current.format(0) : spacer + current.format(1);
            default:
                return "";
        }
    }
    function frequency ()
    {
        switch (root.connection)
        {
            case sys.acInput:   return root.connection.inFrequencyL1.format(1);
            case sys.acLoad:    return root.connection.outFrequencyL1.format(1);
            default:            return "";
        }
    }
    function currentLimit (spacer)
    {
        switch (root.connection)
        {
            case sys.acInput:
                return spacer + "Limit: " + root.connection.inCurrentLimit.format(1);
            default:
                return "";
        }
    }
    function powerL1 ()
    {
        return root.connection ? root.connection.powerL1.format(0) : "";
    }
    function powerL2 ()
    {
        return root.connection ? root.connection.powerL2.format(0) : "";
    }
    function powerL3 ()
    {
        return root.connection ? root.connection.powerL3.format(0) : "";
    }
}
