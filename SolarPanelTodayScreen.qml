import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: solarPanelTodayScreen
	
	property bool yesterday : false
	
	onShown: {    

    }
	

////////////////////////////////////////////////////DAY//////////////////////////////////////////////
	
	SolarBarGraph {
        id: todaybarGraph
        anchors {
            bottom: parent.bottom
            bottomMargin: isNxt? 40:32
            left : parent.left
            leftMargin : isNxt? 10:8
        }
        height:  isNxt? parent.height-50 : parent.height-40
        width: isNxt?  parent.width - 40 : parent.width - 32
		
		isAreaGraph : true
		hourGridColor: "red"
		titleText: yesterday? "Gisteren in Watt" : "Vandaag in Watt"
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
		dataValues: yesterday? app.yesterday : app.fiveminuteValues	
	}
	
	NewTextLabel {
		id: selText
		width: isNxt ? 120 : 96 
		height: isNxt ? 40:32
		buttonActiveColor: "lightgreen"
		buttonHoverColor: "blue"
		enabled : true
		textColor : "black"
		buttonText:  yesterday? "Vandaag" : "Gisteren"
		anchors {
           bottom: todaybarGraph.top
		   bottomMargin: isNxt? -30:-25
           left : todaybarGraph.left
		   leftMargin : yesterday? todaybarGraph.width - width : isNxt ? 30 : 25
        }
		onClicked: {
			yesterday = !yesterday
		}
	}
}




