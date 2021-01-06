import QtQuick 2.1

BarTodayTile {
	id: powerTodayTile
	titleText: qsTr("Productie vandaag")
	isPowerTile: true
	lowerRectColor: dimmableColors.graphSolar
	upperRectColor: dimmableColors.graphSolarSelected
	dayUsage: app.todayValue
	valueText: valueText = (isNaN(app.todayValue) ? "-" : parseFloat(app.todayValue/1000).toFixed(2) + " kW" )
	avgDayValue: 10
	onClicked: stage.openFullscreen(app.solarPanelScreenUrl)
}
