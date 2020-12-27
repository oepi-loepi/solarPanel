import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0;

Tile {
	id: root

	property alias hourTileTitle: hourTileTitleText.text
	/// data type used to select correct graph for onClick
	property string dataType
	/// values for areagraphcontrol to draw area graph in tile
	property variant values: []
	/// flag if smartMeter is used to show correct start/end time (5 minutes vs. 1 hour intervals)
	property bool isSmart: false
	property real maxValue: 0
	property variant startTime: isSmart ? app.hourTileStartTime1h : app.hourTileStartTime5min
	property variant endTime: isSmart ? app.hourTileEndTime1h : app.hourTileEndTime5min
	property bool isSolar: false
	property alias graphColor: areaGraph.color
	property bool timeTextsVisible: true

	onClicked: stage.openFullscreen(app.solarPanelScreenUrl)

	Text {
		id: hourTileTitleText
		anchors {
			baseline: parent.top
			baselineOffset: 30
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: dimmableColors.tileTitleColor
	}

	Item {
		id: graphItem

		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(41 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		height: Math.round(70 * verticalScaling)
		width: Math.round(130 * horizontalScaling)

		AreaGraphControl {
			id: areaGraph

			width: parent.width
			height: parent.height
			color: dimmableColors.graphTileRect
			yScale: maxValue > 0 ? height / maxValue : 0
			showNaN: false
			values: root.values
		}
	}

	Text {
		id: leftTimeText
		anchors {
			horizontalCenter: graphItem.left
			baseline: graphItem.bottom
			baselineOffset: 25
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileText
		}
		color: dimmableColors.tileTextColor
		text: i18n.dateTime(startTime, i18n.date_no | i18n.leading_0_yes | i18n.time_yes | i18n.secs_no)
		visible: timeTextsVisible
	}

	Text {
		id: rightTimeText
		anchors {
			horizontalCenter: graphItem.right
			baseline: graphItem.bottom
			baselineOffset: 25
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileText
		}
		color: dimmableColors.tileTextColor
		text: i18n.dateTime(endTime, i18n.date_no | i18n.leading_0_yes | i18n.time_yes | i18n.secs_no)
		visible: timeTextsVisible
	}
}
