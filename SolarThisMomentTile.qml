import QtQuick 2.1
import qb.components 1.0

Tile {
	id: powerMeter

	property real valueProduced: app.currentPower !== undefined ? app.currentPower : NaN

	QtObject {
		id: p

		property int animationIndex: 0
	}

	onClicked: stage.openFullscreen(app.solarPanelScreenUrl)

	onValueProducedChanged: {
		if (isNaN(valueProduced) || valueProduced === 0)
			p.animationIndex = 0;
	}

	Text {
		id: tileTitle
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
		text: qsTr("Solar this moment")
	}

	Image {
		id: panelImage
		source: "image://scaled/apps/graph/drawables/PanelsDots0" + (dimState ? "Dim" : "") + ".svg"
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(50 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(72 * horizontalScaling)
		}
	}

	Rectangle {
		id: dotBig
		height: Math.round(12 * verticalScaling)
		width: height
		radius: height / 2
		color: dimmableColors.graphSolarThisMomentDot
		anchors {
			top: dotMedium.bottom
			topMargin: Math.round(3 * verticalScaling)
			left: dotMedium.right
			leftMargin: Math.round(3 * horizontalScaling)
		}
		visible: p.animationIndex >= 3
	}

	Rectangle {
		id: dotMedium
		height: Math.round(8 * verticalScaling)
		width: height
		radius: height / 2
		color: dimmableColors.graphSolarThisMomentDot
		anchors {
			top: dotSmall.bottom
			topMargin: Math.round(3 * verticalScaling)
			left: dotSmall.right
			leftMargin: Math.round(3 * horizontalScaling)
		}
		visible: p.animationIndex >= 2 && p.animationIndex <= 4
	}

	Rectangle {
		id: dotSmall
		height: Math.round(5 * verticalScaling)
		width: height
		radius: height / 2
		color: dimmableColors.graphSolarThisMomentDot
		anchors {
			top: panelImage.top
			topMargin: 0
			left: panelImage.left
			leftMargin: 0
		}
		visible: p.animationIndex >= 1 && p.animationIndex <= 3
	}

	Text {
		id: tileValue
		anchors {
			baseline: parent.bottom
			baselineOffset: designElements.vMarginNeg16
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileText
		}
		color: dimmableColors.tileTextColor
		text: isNaN(valueProduced) ? "-" : qsTr("%1 Watt").arg(valueProduced)
	}

	Timer {
		id: animationTimer
		interval: 400
		repeat: true
		running: valueProduced > 0
		onTriggered: p.animationIndex = (p.animationIndex + 1) % 6
	}
}
