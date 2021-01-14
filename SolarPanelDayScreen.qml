import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: solarPanelDayScreen
	
	property int daynumber
	property bool prevmonth : false
	
	onShown: {    
		var d = new Date()
		daynumber = parseInt(Qt.formatDate (d,"d"))
    }
	
////////////////////////////////////////////////////DAY//////////////////////////////////////////////
	
	SolarBarGraph {
        id: daybarGraph
        anchors {
            bottom: parent.bottom
            bottomMargin: isNxt?  40:32
            left : parent.left
            leftMargin : isNxt? 10:8
        }

	height:  isNxt? parent.height-50 :  parent.height-40
	width: isNxt? parent.width - 40 : parent.width - 32
	titleText: prevmonth? "Vorige maand in kWh":  "Deze maand in kWh"
	titleFont: qfont.bold.name
	titleSize: isNxt ? 20 : 16
	showTitle: true
	backgroundcolor : "lightgrey"
	axisColor : "black"
    barColor : "blue"
	lineXaxisvisible : true
 	textXaxisColor : "red"
	stepXtext: 2
	valueFont: qfont.regular.name
	valueSize: isNxt ? 16 : 12
	valueTextColor : "black"
	showValuesOnBar : true
	levelColor :"red"
	levelTextColor : "blue"
	showLevels  : true
	showValuesOnLevel : true
	specialBarColor :"red"
	specialBarIndex  : daynumber
	showSpecialBar : true
	dataValues:  prevmonth? app.prevMonthDayValues : app.dayValues
	
  }
  
  NewTextLabel {
		id: selText
		width: isNxt ? 200 : 160  
		height: isNxt ? 40:32
		buttonActiveColor: "lightgreen"
		buttonHoverColor: "blue"
		enabled : true
		textColor : "black"
		buttonText:  prevmonth?  "Deze Maand" : "Vorige Maand"
		anchors {
           bottom: daybarGraph.top
		   bottomMargin: isNxt? -30:-25
           left : daybarGraph.left
		   leftMargin : prevmonth? daybarGraph.width - width : isNxt ? 30 : 25
        }
		onClicked: {
			prevmonth = !prevmonth
		}
	}
	
}




