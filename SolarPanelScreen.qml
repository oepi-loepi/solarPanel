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
		id: inverterText
		text:  (app.inverterCount>1)? "Omvormer 1: " + app.selectedInverter +   "   Omvormer 2: " + app.selectedInverter2 + "   Totaal: " +  parseInt(app.totalValue/1000) + " kWh" : "Omvormer: " + app.selectedInverter + "   Totaal: " +  parseInt(app.totalValue/1000) + " kWh"
		font.pixelSize: isNxt? 20:16
		font.family:  qfont.bold.name
		anchors {
            horizontalCenter: parent.horizontalCenter
			top: dateText.bottom
			topMargin: isNxt? 10:8
        }
		color : "grey"
		visible : app.pluginWarning.length <1
	}

	Text{
		id: panelText
		text:  "Huidig: " + app.currentPower + " Watt   Vandaag: " +  parseFloat(app.todayValue/1000).toFixed(1) + " kWh   Teruglevering: " + parseFloat(parseInt(parseInt(app.totalPowerProductionNt) + parseInt(app.totalPowerProductionLt)) /1000).toFixed(1) + " kWh"
		font.pixelSize: isNxt? 20:16
		font.family:  qfont.bold.name
		anchors {
            	horizontalCenter: parent.horizontalCenter
			top: inverterText.bottom
			topMargin: isNxt? 6:5
        }
		color :  "grey" 
		visible : app.pluginWarning.length <1
	}


	
	Text{
		id: panelWarningText1
		text: app.pluginWarning
		font.pixelSize: app.pluginWarningisNxt? 40:32
		font.family:  qfont.bold.name
		anchors {
            horizontalCenter: parent.horizontalCenter
			top: dateText.bottom
			topMargin: isNxt? 10:8
        }
		color : "red"
		visible : !(app.pluginWarning.length <1)
	}
	
	Text{
		id: panelWarningText2
		text: "Ga rechtsboven naar Instellingen"
		font.pixelSize: isNxt? 40:32
		font.family:  qfont.bold.name
		anchors {
            horizontalCenter: parent.horizontalCenter
			top: panelWarningText1.bottom
			topMargin: isNxt? 10:8
        }
		color : "red"
		visible : panelWarningText1.visible
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
		//barColor : "blue"
		barColor :dimmableColors.graphSolar
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
		barColor2 : "green"
		dataValues2: app.fiveminuteValuesProd
		visible: (app.pluginWarning.length <1)
		
		showSunbars : true
		sunBarColor : "purple"
		sunrisePerc  : app.sunrisePerc
		sunsetPerc  : app.sunsetPerc
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
		color : "green"
		visible: (app.pluginWarning.length <1)
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
		color : "black"
		visible: (app.pluginWarning.length <1)
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
		//color : "blue"
		color :dimmableColors.graphSolar
		visible: (app.pluginWarning.length <1)
	}
	
	Text{
		id: txt2
		text: "Solar"
		font.pixelSize: isNxt? 15:12
		font.family: qfont.regular.name
		anchors {
            verticalCenter: rect1.verticalCenter
            left : rect2.right
            leftMargin : isNxt? 10:8
        }
		color : "black"
		visible: (app.pluginWarning.length <1)
	}
	
}




