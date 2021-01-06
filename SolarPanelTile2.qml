import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0;

Tile {
    id: root 
	property bool dimState: screenStateController.dimmedColors
	
   MouseArea {
		height : parent.height/2
		width : parent.width/2
		anchors {
			top: parent.top
			left: parent.left
			leftMargin: parent.width/4
			topMargin:parent.height/4
		}
		onClicked: {
			stage.openFullscreen(app.solarPanelScreenUrl)
		}
	}

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
		color: dimmableColors.tileTitleColor
		text: "SolarPanel: " + app.selectedInverter
	}

	
	Text {
		id: curPower
		text: "Zon Nu: " + app.currentPower + " W"
		color: !dimState? "black" : "white"
		anchors {
			top: tileTitle.bottom
			topMargin: isNxt? 5:4
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: isNxt? 22:18
		font.family: qfont.bold.name
    }

	Text {
		id: dayPower

		text: "Vandaag: " + parseFloat(app.todayValue/1000).toFixed(1) + " kW"
		color: !dimState? "black" : "white"
		anchors {
			top: curPower.bottom
			topMargin: 1
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: isNxt? 22:18
		font.family: qfont.bold.name
    }


   
	Text {
		id: curProdPower
		text: "Lev.: " + app.currentPowerProd + " W"
		color: !dimState ? "black" : "white"
		anchors {
			top: dayPower.bottom
			topMargin: 1
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: isNxt? 22:18
		font.family: qfont.bold.name
		visible: (app.enableSleep||!dimState )
    }

	Text {
		id: curUsagePower
		text: "Verbruik: " + app.currentUsage + " W"
		color: !dimState ? "black" : "white"
		anchors {
			top: curProdPower.bottom
			topMargin: 1
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: isNxt? 22:18
		font.family: qfont.bold.name
		visible: (app.enableSleep||!dimState )
    }



}



