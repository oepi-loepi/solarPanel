import QtQuick 2.1

BarTodayTile {
	id: productionTodayTile
	titleText: (app.pluginWarning.length <1)? qsTr("Teruglevering vandaag"): app.pluginWarning
	lowerRectColor: dimmableColors.graphSolar
	upperRectColor: dimmableColors.graphSolarSelected
	
	onClicked: {
		stage.openFullscreen(app.solarPanelScreenUrl)
	}
	dayUsage : parseInt(app.totalPowerProductionNt) + parseInt(app.totalPowerProductionLt)
	valueText : parseFloat(parseInt(parseInt(app.totalPowerProductionNt) + parseInt(app.totalPowerProductionLt)) /1000).toFixed(1) + " kWh"
	avgDayValue : app.dayAvgValue
}


