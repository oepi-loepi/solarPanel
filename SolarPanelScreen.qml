import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: solarPanelTodayScreen
	
	onShown: {    
		addCustomTopRightButton("Instellingen")
    }
	
	onCustomButtonClicked: {
		stage.openFullscreen(app.solarPanelConfigScreenUrl)
	}
	
	
	Text{
		id: dateText
		text: app.succesTime
		font.pixelSize: isNxt? 20:16
		font.family:  qfont.bold.name
		anchors {
            horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: isNxt? 4:3
        }
		color : "grey"
	}
	
	Text{
		id: panelText
		text: "Omvormer: " + app.selectedInverter + "     Huidig: " + app.currentPower + " Watt" +  "     Totaal: " +  parseInt(app.totalValue/1000) + " kWh"
		font.pixelSize: isNxt? 25:20
		font.family:  qfont.bold.name
		anchors {
            horizontalCenter: parent.horizontalCenter
			top: dateText.bottom
			topMargin: isNxt? 10:8
        }
		color : "grey"
	}
	

	
////////////////////////////////////////////////////DAY//////////////////////////////////////////////
	
	SolarBarGraph {
        id: todaybarGraph
        anchors {
            bottom: parent.bottom
            bottomMargin: isNxt? 80:64
            left : parent.left
            leftMargin : isNxt? 10:8
        }
        height:  isNxt? parent.height-200 : parent.height-160
        width: isNxt?  parent.width - 40 : parent.width - 32
		
		isAreaGraph : true
		hourGridColor: "red"
		titleText: "   Vandaag in Watt"
		titleFont: qfont.bold.name
		titleSize: isNxt ? 20 : 16
		showTitle: true
		backgroundcolor : "lightgrey"
		axisColor : "black"
		barColor : "blue"
		lineXaxisvisible : true
		textXaxisColor : "red"
		stepXtext: 3
		valueFont: qfont.regular.name
		valueSize: isNxt ? 16 : 12
		valueTextColor : "black"
		showValuesOnBar : false
		levelColor :"red"
		levelTextColor : "blue"
		showLevels  : true
		showValuesOnLevel : true
		showSpecialBar : false
		dataValues:  app.fiveminuteValues
		
		isStacked : true
		specialBarColor2 :"green"
		specialBarIndex2  : 0
		showSpecialBar2 : false
		barColor2 : "yellow"
		dataValues2: app.fiveminuteValuesProd
	}
	
	Rectangle{
		id: rect1
		anchors {
            bottom: parent.bottom
            bottomMargin: isNxt? 10:8
            left : parent.left
            leftMargin : isNxt? 100:80
        }
        height:  isNxt? 20: 16
        width: isNxt?  40 : 32
		color : "yellow"
	}
	
	Text{
		id: txt1
		text: "Teruglevering"
		font.pixelSize: isNxt? 15:12
		font.family: qfont.regular.name
		anchors {
            verticalCenter: rect1.verticalCenter
            left : rect1.right
            leftMargin : isNxt? 10:8
        }
		color : "yellow"
	}
	
	
	Rectangle{
		id: rect2
		anchors {
            verticalCenter: rect1.verticalCenter
            left :  txt1.right
            leftMargin : 100
        }
        height:  isNxt? 20: 16
        width: isNxt?  40 : 32
		color : "blue"
	}
	
	Text{
		id: txt2
		text: "Zonnepanelen"
		font.pixelSize: isNxt? 15:12
		font.family: qfont.regular.name
		anchors {
            verticalCenter: rect1.verticalCenter
            left : rect2.right
            leftMargin : isNxt? 10:8
        }
		color : "blue"
	}
	
}




