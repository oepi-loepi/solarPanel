import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: solarPanelMonthScreen
	
	property int monthnumber
	property bool prevYear : false
	
	onShown: {    
		var d = new Date()
		monthnumber = parseInt(Qt.formatDate (d,"M"))
    }
	
////////////////////////////////////////////////////DAY//////////////////////////////////////////////
	
	SolarBarGraph {
        id: monthbarGraph
        anchors {
            bottom: parent.bottom
            bottomMargin:  isNxt? 40:32
            left : parent.left
            leftMargin : isNxt? 10:8
        }
        height:  isNxt? parent.height-50:parent.height-50
        width: isNxt? parent.width - 40:parent.width - 40
		
	titleText: prevYear? "Vorig jaar in kWh" : "Dit jaar in kWh"
	titleFont: qfont.bold.name
	titleSize: isNxt ? 20 : 16
	showTitle: true
	backgroundcolor : "lightgrey"
	axisColor : "black"
    barColor : "blue"
	lineXaxisvisible : true
 	textXaxisColor : "red"
	stepXtext: 1
	valueFont: qfont.regular.name
	valueSize: isNxt ? 16 : 12
	valueTextColor : "black"
	showValuesOnBar : true
	levelColor :"red"
	levelTextColor : "blue"
	showLevels  : true
	showValuesOnLevel : true
	specialBarColor :"red"
	specialBarIndex  : monthnumber
	showSpecialBar : true
	dataValues: prevYear? app.prevYearMonthValues: app.monthValues
  }
  
   NewTextLabel {
		id: selText
		width: isNxt ? 200 : 160  
		height: isNxt ? 40:32
		buttonActiveColor: "lightgreen"
		buttonHoverColor: "blue"
		enabled : true
		textColor : "black"
		buttonText:  prevYear?  "Dit jaar" : "Vorig jaar"
		anchors {
           bottom: monthbarGraph.top
		   bottomMargin: isNxt? -30:-25
           left : monthbarGraph.left
		   leftMargin : prevYear? monthbarGraph.width - width : isNxt ? 30 : 25
        }
		onClicked: {
			prevYear = !prevYear
		}
	}

}




