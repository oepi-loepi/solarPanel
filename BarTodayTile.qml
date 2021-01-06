import QtQuick 2.1

import qb.components 1.0
import BasicUIControls 1.0
import DateTracker 1.0

BaseTodayTile {
	id: barTodayTile

	property alias lowerRectColor: usageIndicatorLowRect.color
	property alias upperRectColor: usageIndicatorUpperRect.color

	function updateTileGraphic() {
		var heightFullBar = backgroundRect.height - middleBarRect.height;	// full bar, subtract middle bar
		var heightHalfBar = heightFullBar / 2;

		if (dayDataOkay()) {
			var usage = dayUsage;
			var avg = avgDayValue;
			if (isPowerTile)
				usage += dayLowUsage;
			var total = usage + fixedDayCost;

			if (!avgDataOkay())
				avg = total;
			else
				avg += fixedDayCost;

			if (total === 0) {
				usageIndicatorLowRect.height = 0;
				usageIndicatorUpperRect.height = 0;
				return;
			}

			var beamHeight = total / avg * heightHalfBar;
			var fixedCostHeight = fixedDayCost / total * beamHeight;
			if (fixedCostHeight > heightHalfBar)
				fixedCostHeight = heightHalfBar;
			fixedCostIndicatorLowRect.height = fixedCostHeight;
			// lower part
			if (beamHeight <= heightHalfBar) {
				if (fixedDayCost > 0) {
					usageIndicatorLowRect.height = beamHeight - fixedCostIndicatorLowRect.height;
					usageIndicatorLowRect.bottomLeftRadiusRatio = 0;
					usageIndicatorLowRect.bottomRightRadiusRatio = 0;
				} else {
					usageIndicatorLowRect.height = beamHeight;
				}
				usageIndicatorUpperRect.height = 0;
			// upper part without rounding (subtract 3 for non-rounding)
			} else {
				if (fixedDayCost > 0) {
					usageIndicatorLowRect.height = heightHalfBar - fixedCostIndicatorLowRect.height;
					usageIndicatorLowRect.bottomLeftRadiusRatio = 0;
					usageIndicatorLowRect.bottomRightRadiusRatio = 0;
				} else {
					usageIndicatorLowRect.height = heightHalfBar;
				}
				if (beamHeight <= (heightFullBar - 3)) {
					usageIndicatorUpperRect.height = beamHeight - heightHalfBar;
					usageIndicatorUpperRect.topRightRadiusRatio = 0;
					usageIndicatorUpperRect.topLeftRadiusRatio = 0;
				// most upper part with rounding
				} else if (beamHeight < heightFullBar) {
					usageIndicatorUpperRect.height = beamHeight - heightHalfBar;
					usageIndicatorUpperRect.topRightRadiusRatio = 1;
					usageIndicatorUpperRect.topLeftRadiusRatio = 1;
				// >= 200 %
				} else {
					usageIndicatorUpperRect.height = heightHalfBar;
					usageIndicatorUpperRect.topRightRadiusRatio = 1;
					usageIndicatorUpperRect.topLeftRadiusRatio = 1;
				}
			}
		} else {
			usageIndicatorLowRect.height = 0;
			usageIndicatorUpperRect.height = 0;
		}
	}

	Rectangle {
		id: backgroundRect
		width: mask.width > 0 ? mask.width : Math.round(34 * horizontalScaling)
		height: Math.round(78 * verticalScaling)
		anchors.centerIn: parent
		radius: designElements.radius
		color: dimmableColors.dayTileBackgroundBar
	}

	Rectangle {
		id: middleBarRect
		width: backgroundRect.width
		height: Math.round(2 * verticalScaling)
		anchors.centerIn: parent
		color: dimmableColors.dayTileMiddleBar
	}

	StyledRectangle {
		id: fixedCostIndicatorLowRect
		radius: designElements.radius
		bottomRightRadiusRatio: 1
		bottomLeftRadiusRatio: 1
		topRightRadiusRatio: 0
		topLeftRadiusRatio: 0
		width: backgroundRect.width
		height: 0
		anchors {
			bottom: backgroundRect.bottom
			horizontalCenter: parent.horizontalCenter
		}
		color: dimmableColors.dayTileFixedCostBar
		mouseEnabled: false
	}

	StyledRectangle {
		id: usageIndicatorLowRect
		radius: designElements.radius
		bottomRightRadiusRatio: 1
		bottomLeftRadiusRatio: 1
		topRightRadiusRatio: 0
		topLeftRadiusRatio: 0
		width: backgroundRect.width
		height: 0
		anchors {
			bottom: fixedCostIndicatorLowRect.top
			horizontalCenter: parent.horizontalCenter
		}
		color: dimmableColors.dayTileAverageBar
		mouseEnabled: false
	}

	StyledRectangle {
		id: usageIndicatorUpperRect
		radius: designElements.radius
		topRightRadiusRatio: 0
		topLeftRadiusRatio: 0
		bottomRightRadiusRatio: 0
		bottomLeftRadiusRatio: 0
		width: backgroundRect.width
		height: 0
		anchors {
			bottom: middleBarRect.top
			horizontalCenter: parent.horizontalCenter
		}
		color: fixedDayCost ? dimmableColors.dayTileAverageBar : dimmableColors.dayTileUsageBar
		mouseEnabled: false
	}

	Image {
		id: mask
		source: maskFile ? "image://" + (dimState ? "scaled" : "colorized/" + bgColor.toString()) + "/apps/graph/drawables/" + maskFile : ""
		anchors.centerIn: parent
		visible: source ? true : false
		property string maskFile

		states: [
			State {
				name: "easter"
				when: DateTracker.isEaster
				PropertyChanges { target: mask; maskFile: "tile-mask-easter.svg" }
			}
		]
	}
}
