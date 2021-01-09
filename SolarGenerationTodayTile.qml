import QtQuick 2.1

BarTodayTile {
	id: powerTodayTile
	titleText: qsTr("Productie vandaag")
	lowerRectColor: dimmableColors.graphSolar
	upperRectColor: dimmableColors.graphSolarSelected
	
	onClicked: {
		stage.openFullscreen(app.solarPanelScreenUrl)
	}
	dayUsage : app.todayValue
	valueText : parseFloat(app.todayValue/1000).toFixed(1) + " kW"
	avgDayValue : (app.lastFiveDays.length>3) ?  app.dayAvgValue : 3000
}


