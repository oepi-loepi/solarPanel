
import QtQuick 2.1
import qb.components 1.0

Tile {
	id: myUsageTile
        property bool dimState: screenStateController.dimmedColors


	Text {
		id: tileTitle
		anchors {
			baseline: parent.top
			baselineOffset: 30
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: !dimState? "black" : "white"
		text: "Eigen verbruik"
	}

	Text {
		id: txtBig
		text: parseInt(parseInt(app.currentPower) + parseInt(app.currentUsage) - parseInt(app.currentPowerProd)) + " W"
		color: dimmableColors.clockTileColor
		anchors {
			top: tileTitle.bottom
			topMargin: isNxt? 6:5
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: dimState ? qfont.clockFaceText : qfont.timeAndTemperatureText
		font.family: qfont.regular.name
	}

    Text {
		id: solar
		text: "Solar: " + parseInt(app.currentPower) + " W"
		anchors {
			top: txtBig.bottom
			topMargin: 2
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: isNxt? 16:12
		font.family: qfont.bold.name
		color : dimState?  dimmableColors.clockTileColor : colors.clockTileColor
    }

    Text {
		id: net
		text: "Net: " + parseInt(app.currentUsage)+ " W"
		anchors {
			top: solar.bottom
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: isNxt? 16:12
		font.family: qfont.bold.name
		color : dimState?  dimmableColors.clockTileColor : colors.clockTileColor
    }
	
	Text {
		id: prod
		text: "Prod: " + parseInt(app.currentPowerProd) + " W"
		anchors {
			top: net.bottom
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: isNxt? 16:12
		font.family: qfont.bold.name
		color : dimState?  dimmableColors.clockTileColor : colors.clockTileColor
    }
	

	
}
