////// modified to show voltage, current and frequency in flow overview
// only displays values for sys.acInput and sys.acLoad
// because other connections don't have related parameters
// may not support paralleled Multis/Quatros
////// modified to show power bar graphs


import QtQuick 1.1

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
            text: root.connection ? root.connection.power.format(0) : ""
////// modified to show power bar graphs
			font.pixelSize: 19
            height: 21
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
            visible: phaseCount === 2 || phaseCount === 3 && root.height >= 90
            font.pixelSize: 8
        }
        TileText {
            text:
            {
                if (root.connection.l1AndL2OutShorted)
                    "L2 included in L1"
                else
                    "L2:" + powerL2 () + voltageL2 (" ") + currentL2 (" ")            
            }
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
            visible: phaseCount === 2 && root.height >= 90
            font.pixelSize: 11
        }
        // frequency and input current limit single leg
        TileText {
            text: frequency ()
            font.pixelSize: 15
            visible: phaseCount === 1 && root.connection == sys.acInput
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
        return spacer + root.connection.voltageL1.format(0)
    }
    function voltageL2 (spacer)
    {
        if (root.connection.splitPhaseL2PassthruDisabled)
            return "--"
        else
            return spacer + root.connection.voltageL2.format(0)
    }
    function voltageL3 (spacer)
    {
        return spacer + root.connection.voltageL3.format(0)
    }
    function currentL1 (spacer)
    {
        var current
        var label
        var valueText
        current = root.connection.currentL1
        if (current >= 1000)
            valueText = current.format(0)
        else
            valueText = current.format(1)

        return spacer + valueText;
    }
    function currentL2 (spacer)
    {
        if (root.connection.splitPhaseL2PassthruDisabled)
            return "--"
        else
        {
            var current
            current = root.connection.currentL2
            return current >= 1000 ? spacer + current.format(0) : spacer + current.format(1)
        }
    }
    function currentL3 (spacer)
    {
        var current
        current = root.connection.currentL3
        return current >= 1000 ? spacer + current.format(0) : spacer + current.format(1)
    }
    function frequency ()
    {
        if (root.connection.frequencyL1.valid)
            return root.connection.frequencyL1.format(1)
        else
            return ""
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
        if (root.connection.splitPhaseL2PassthruDisabled)
            return "--"
        else
            return root.connection ? root.connection.powerL2.format(0) : "";
    }
    function powerL3 ()
    {
        return root.connection ? root.connection.powerL3.format(0) : "";
    }
}
