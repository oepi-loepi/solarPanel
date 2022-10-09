
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
		text: "Stroom nu"
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
		id: source
		text: "Van de zon: " + parseInt(app.currentPower) + " W / het net: " + parseInt(app.currentUsage) + " W"
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
		id: prod
		text: "Terug net: " + parseInt(app.currentPowerProd) + " W / Totaal: " + parseFloat(parseInt(parseInt(app.totalPowerProductionNt) + parseInt(app.totalPowerProductionLt)) /1000).toFixed(1) + " kWh"
		anchors {
			top: source.bottom
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: isNxt? 16:12
		font.family: qfont.bold.name
		color : dimState?  dimmableColors.clockTileColor : colors.clockTileColor
    }
	
}
