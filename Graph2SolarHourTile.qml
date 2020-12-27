import QtQuick 2.1

HourTile {
	id: root
	hourTileTitle: qsTr("Zonnepanelen in uren")
	values: app.rollingfiveminuteValues
	dataType: "electricity"
	maxValue: (app.maxRollingY)
	//maxValue:500
	isSolar: true
	startTime: app.twoHoursEarlier
	endTime:  app.now
	graphColor: dimmableColors.graphSolar
	timeTextsVisible: (app.maxRollingY > 0)
}
