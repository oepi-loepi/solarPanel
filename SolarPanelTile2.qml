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
            id: today
            text: "Vandaag: " + app.todayValue + " kWh"
			color: !dimState ? "black" : "white"
            anchors {
                top: parent.top
                topMargin: 2
                left: parent.left
                leftMargin : 2
            }
            font.pixelSize: isNxt? 15:12
            font.family: qfont.regular.name
			visible: (app.enableSleep||!dimState )
    }

    Text {
            id: maand
            text: "Mnd: " + parseInt(app.monthValue) + " kWh"
			color: !dimState ? "black" : "white"
            anchors {
                top: parent.top
                topMargin: 2
                right: parent.right
                rightMargin : 2
            }
            font.pixelSize: isNxt? 15 : 12
            font.family: qfont.regular.name
			visible: (app.enableSleep||!dimState )
    }
	
	 Text {
            id: curPower
            text: "Opbr.: " + app.currentPower + " W"
			color: !dimState ? "black" : "white"
            anchors {
                top: maand.bottom
                topMargin: 4
                horizontalCenter: parent.horizontalCenter
            }
            font.pixelSize: isNxt? 25:20
            font.family: qfont.bold.name
			visible: (app.enableSleep||!dimState )
    }

	Text {
            id: curProdPower
            text: "Lev.: " + app.currentPowerProd + " W"
	    color: !dimState ? "black" : "white"
            anchors {
                top: curPower.bottom
                topMargin: 3
                horizontalCenter: parent.horizontalCenter
            }
            font.pixelSize: isNxt? 25:20
            font.family: qfont.bold.name
			visible: (app.enableSleep||!dimState )
    }

	Text {
            id: curUsagePower
            text: "Verbruik: " + app.currentUsage + " W"
	    color: !dimState ? "black" : "white"
            anchors {
                top: curProdPower.bottom
                topMargin: 3
                horizontalCenter: parent.horizontalCenter
            }
            font.pixelSize: isNxt? 25:20
            font.family: qfont.bold.name
			visible: (app.enableSleep||!dimState )
    }



}



