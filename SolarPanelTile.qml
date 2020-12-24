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
			color: !dimState? "black" : "white"
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
			color: !dimState? "black" : "white"
            anchors {
                top: parent.top
                topMargin: 2
                right: parent.right
                rightMargin : 2
            }
            font.pixelSize: isNxt? 15:12
            font.family: qfont.regular.name
			visible: (app.enableSleep||!dimState )
    }
	
	 Text {
            id: curPower
            text: app.currentPower + " W"
			color: !dimState? "black" : "white"
            anchors {
                top: maand.bottom
                topMargin: 2
                horizontalCenter: parent.horizontalCenter
            }
            font.pixelSize:  isNxt?  30:25
            font.family: qfont.bold.name
			visible: (app.enableSleep||!dimState )
    }

	SolarBarGraph {
        id: hourbarGraph
        anchors {
            bottom: parent.bottom
			bottomMargin: isNxt? 30:25
			left:parent.left
			//horizontalCenter: parent.horizontalCenter
        }
        height:  isNxt? 90:72
        width: isNxt? parent.width - 20 : parent.width - 16
	
		isAreaGraph : true
		//manualMax: app.maxWattage
		hourGridColor: !dimState? "grey" : "lightgrey"
		showTitle: false
		backgroundcolor : "transparent"
		axisColor :  !dimState? "grey" : "lightgrey"
		barColor :!dimState? "black" : "white"
		lineXaxisvisible : true
		textXaxisColor : !dimState? "grey" : "lightgrey"
		stepXtext: 3
		valueFont: qfont.regular.name
		valueSize: isNxt ? 12 : 9
		valueTextColor : !dimState? "grey" : "lightgrey"
		showValuesOnBar : false
		levelColor :!dimState? "grey" : "lightgrey"
		levelTextColor : !dimState? "grey" : "lightgrey"
		showLevels  : true
		showValuesOnLevel : true
		dataValues: app.fiveminuteValues
		onClicked: {
			stage.openFullscreen(app.solarPanelScreenUrl)
		}
		visible: (app.enableSleep||!dimState )
	}
}



