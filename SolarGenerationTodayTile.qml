import QtQuick 2.1

BarTodayTile {
	id: powerTodayTile
	titleText: (app.pluginWarning.length <1)? qsTr("Solar vandaag"): app.pluginWarning
	lowerRectColor: dimmableColors.graphSolar
	upperRectColor: dimmableColors.graphSolarSelected
	
	onClicked: {
		stage.openFullscreen(app.solarPanelScreenUrl)
	}
	dayUsage : app.todayValue
	valueText : parseFloat(app.todayValue/1000).toFixed(1) + " kWh"
	avgDayValue : app.dayAvgValue
}


