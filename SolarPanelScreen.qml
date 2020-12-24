import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: solarPanelScreen
	
	property int daynumber
	property int monthnumber
	
	onShown: {    
		var d = new Date()
		daynumber = parseInt(Qt.formatDate (d,"d"))
		monthnumber = parseInt(Qt.formatDate (d,"M"))
		addCustomTopRightButton("Instellingen")
	}

	onCustomButtonClicked: {
			if (app.solarPanelConfigScreen) {app.solarPanelConfigScreen.show()};
	}


	Grid {
		columns: 2
		spacing: 2
		
		anchors {
            top: parent.top
            topMargin: isNxt? 30: 25
			left : daybarGraph.left 
            leftMargin : daybarGraph.valueSize*3
        }
		Text { color: "black";font.pixelSize: isNxt ? 18:14; font.family: qfont.regular.name ;text: "Inverter :" }
		Text { color: "black";font.pixelSize: isNxt ? 18:14; font.family: qfont.regular.name ;text: app.selectedInverter }
		Text { color: "black";font.pixelSize: isNxt ? 18:14; font.family: qfont.regular.name ;text: "Huidig : "}
		Text { color: "black";font.pixelSize: isNxt ? 18:14; font.family: qfont.regular.name ;text: app.currentPower + " Watt" }
		Text { color: "black";font.pixelSize: isNxt ? 18:14; font.family: qfont.regular.name ;text: "Vandaag : "  }
		Text { color: "black";font.pixelSize: isNxt ? 18:14; font.family: qfont.regular.name ;text: app.todayValue + " kWh" }
		Text { color: "black";font.pixelSize: isNxt ? 18:14; font.family: qfont.regular.name ;text: "Maand : " ; visible: (app.selectedInverter.toLowerCase()!="sma")}
		Text { color: "black";font.pixelSize: isNxt ? 18:14; font.family: qfont.regular.name ;text: app.monthValue + " kWh" ; visible: (app.selectedInverter.toLowerCase()!="sma") }
		Text { color: "black";font.pixelSize: isNxt ? 18:14; font.family: qfont.regular.name ;text: "Jaar : " ; visible: (app.selectedInverter.toLowerCase()!="kostal piko") }
		Text { color: "black";font.pixelSize: isNxt ? 18:14; font.family: qfont.regular.name ;text: app.yearValue + " kWh" ; visible: (app.selectedInverter.toLowerCase()!="kostal piko")}
		Text { color: "black";font.pixelSize: isNxt ? 18:14; font.family: qfont.regular.name ;text: "Totaal : "; visible: (app.selectedInverter.toLowerCase()!="sma")}
		Text { color: "black";font.pixelSize: isNxt ? 18:14; font.family: qfont.regular.name ;text: app.totalValue + " kWh" ; visible: (app.selectedInverter.toLowerCase()!="sma")}
	}

////////////////////////////////////////////////////HOUR//////////////////////////////////////////////
	SolarBarGraph {
        id: hourbarGraph
        anchors {
            top: parent.top
            topMargin: isNxt? 30:25
            right : parent.right
            rightMargin : isNxt? 30:25
        }
        height:  isNxt? parent.height/2 - 70 :  parent.height/2 - 56
        width: isNxt? parent.width/2 - 50 : parent.width/2 - 40
	
		isAreaGraph : true
		//manualMax: app.maxWattage
		hourGridColor: "red"
		titleText:"Vandaag in Watt"
		titleFont: qfont.bold.name
		titleSize: isNxt ? 16 : 12
		showTitle: true
		backgroundcolor : "white"
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
		specialBarColor :"red"
		specialBarIndex  : daynumber
		showSpecialBar : false
		dataValues: app.fiveminuteValues
		onClicked: {
				stage.openFullscreen(app.solarPanelTodayScreenUrl)
		}	
	}
////////////////////////////////////////////////////DAY//////////////////////////////////////////////
	SolarBarGraph {
        id: daybarGraph
        anchors {
            bottom: parent.bottom
            bottomMargin:  isNxt? 30:25
            left : parent.left
            leftMargin :  isNxt?  10:8
        }
       height:  isNxt? parent.height/2 - 70 :  parent.height/2 - 56
        width: isNxt? parent.width/2 - 50 : parent.width/2 - 40
		
		titleText:"Dagen in kWh"
		titleFont: qfont.bold.name
		titleSize: isNxt ? 16 : 12
		showTitle: true
		backgroundcolor : "white"
		axisColor : "black"
		barColor : "blue"
		lineXaxisvisible : true
		textXaxisColor : "red"
		stepXtext: 5
		valueFont: qfont.regular.name
		valueSize: isNxt ? 16 : 12
		valueTextColor : "black"
		showValuesOnBar : false
		levelColor :"red"
		levelTextColor : "blue"
		showLevels  : true
		showValuesOnLevel : true
		specialBarColor :"red"
		specialBarIndex  : daynumber
		showSpecialBar : true
		dataValues: app.dayValues
		
		onClicked: {
				stage.openFullscreen(app.solarPanelDayScreenUrl)
		}
	}

//////////////////////////////MONTH////////////////////////////////////////
 	
	SolarBarGraph {
        id: monthGraph
        anchors {
            bottom: parent.bottom
            bottomMargin:  isNxt? 30:25
            right : parent.right
            rightMargin : isNxt? 30:25
        }
       height:  isNxt? parent.height/2 - 70 :  parent.height/2 - 56
        width: isNxt? parent.width/2 - 50 : parent.width/2 - 40
		
		titleText:"Maanden in kWh"
		titleFont: qfont.bold.name
		titleSize: isNxt ? 16 : 12
		showTitle: true
		backgroundcolor : "white"
		axisColor : "black"
		barColor : "blue"
		lineXaxisvisible : true
		textXaxisColor : "red"
		stepXtext: 5
		valueFont: qfont.regular.name
		valueSize: isNxt ? 16 : 12
		valueTextColor : "black"
		showValuesOnBar : false
		levelColor :"red"
		levelTextColor : "blue"
		showLevels  : true
		showValuesOnLevel : true
		specialBarColor :"red"
		specialBarIndex  : monthnumber
		showSpecialBar : true
		dataValues: app.monthValues
		
		onClicked: {
				stage.openFullscreen(app.solarPanelMonthScreenUrl)
		}	
	}
}




