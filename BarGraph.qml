import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0

import "BarGraphObjects.js" as BarGraph

/**
 * BarGraph component. Draws bar graph together with axes with given data.
 *
 * Input data:
 * To populate the graph, the fuction populate() with an filled instance of #BarGraph.GraphData is passed, along with the
 * scale type to be used and an array of bar categories to be preselected (@see BarGraph.BarInfo)
 *
 * Graph scale:
 * When data is populated, the maximum amount among values and applicable estimation is found. The closest value to the max
 * is searched on scale array and taken as y axis maximum. If data max is larger than the largest scale value, it will be
 * used as y axis maximum.
 *
 * Graph bars:
 * Bar width is determined by barWidth (default 24px). Each bar is clickable. Height of clickable area is same as maximum
 * graph bar height (240px default). Click area is extended by 10px on left and right side of the bar. Clicking the bar
 * will change bar color and show popup with detailed bar value information. Clicking the selected bar or popup shown
 * or graph area with no bar will unselect currently selected bar.
 *
 * Hatched index:
 * Current (unfinished) period should use hatched pattern for graph bar. If index is -1 (or does not match any bar index) all
 * bars are drawn in solid color.
 */

Item {
	id: root

	property alias title: title.text

	// scale id is sum of energy type and value type
	property int scaleTypeElectricity: 0
	property int scaleTypeGasWater: 1
	property int scaleTypeHeat: 2
	property int scaleTypeHeatingHour: 3
	property int scaleTypeConsumption: 0
	property int scaleTypeCost: 4

	property bool showTitle: false
	property bool showVAT: false
	property int hatchedBarIndex: -1

	property alias hourAxisVisible: xLegendRow.visible
	/// xLegend left margin - right side of the 0 hour (0 hour minutes "00" are anchored left here)
	property int xLegendLeftMargin: Math.round(24 * horizontalScaling)
	/// distance from xLegend hour text right till next hour text right
	property int xLegendItemWidth: Math.round(58 * horizontalScaling)
	property int xLegendItemWidthDstStart: Math.floor(xLegendItemWidth * 12 / 11.5)
	property int xLegendItemWidthDstEnd: Math.floor(xLegendItemWidth * 12 / 12.5)
	property color xLegendTextColor: colors.graphXLegendText
	property int xLegendTextSize: Math.round(12 * horizontalScaling)
	/// baseline offset from xLegend top
	property int xLegendTextBaselineOffset: Math.round(24 * verticalScaling)

	property bool dstStart: false
	property bool dstEnd: false
	property int dstHourChange: 0

	property int barWidth: Math.round(24 * horizontalScaling)
	property int graphHeight: Math.round(240 * verticalScaling)

	property variant selectedBoxes: []
	onSelectedBoxesChanged: {
		if (selectedBoxes.length) {
			p.chooseScale();
			p.updatePopoutPos();
		}
	}
	onVisibleChanged: {
		if (!visible)
			selectBar(-1);
	}

	QtObject {
		id: p
		property variant graphModel: new BarGraph.GraphData()
		property variant estimationsModel: []

		property variant scales: [
			// scales for electricity consumption
			[1, 2.5, 5, 10, 12.5, 15, 20, 25, 37.5, 50, 75, 100, 125, 150, 200, 250, 375, 500, 750, 1000, 1250, 1500, 2000, 2500, 3750,
			 5000, 7500, 10000, 12500, 15000, 20000, 25000, 30000],
			// scales for gas consumption
			[0.1, 0.25, 0.5, 1, 2.5, 5, 10, 12.5, 15, 20, 25, 37.5, 50, 75, 100, 125, 150, 200, 250, 375, 500, 750, 1000, 1250, 1500,
			 2000, 2500, 3750, 5000, 7500, 10000, 12500],
			// scales for district heat and heating by day or longer
			[0.1, 0.25, 0.5, 1, 2.5, 5, 10, 12.5, 15, 20, 25, 37.5, 50, 75, 100, 125, 150, 200, 250, 375, 500, 750, 1000, 1250, 1500,
			 2000, 2500, 3750, 5000, 7500, 10000, 12500],
			// scales for heating by hour
			[60],
			// scales for electricity costs
			[0.05, 0.10, 0.25, 0.50, 1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000, 200000],
			// scales for gas costs
			[0.05, 0.10, 0.25, 0.50, 1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000],
			// scales for district heat costs
			[0.05, 0.10, 0.25, 0.50, 1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000]
		]
		property variant scaleDivisions: [5, 5, 5, 6, 5, 5, 5]
		property int scaleTypeSelected: 0
		property double scaleMax

		property double valuePerPixel: 1
		property int barMaxHeightPx: Math.round(210 * verticalScaling)
		property int barArea: Math.round(700 * horizontalScaling)
		property int barTotalWidth
		property int selectedBar: -1

		function updatePopoutPos() {
			// Use hatchedBarIndex to determine when Popout for bars located on the right (future, without data)
			// of last bar with data (hatched) should not be shown
			if (p.selectedBar < 0 || ((hatchedBarIndex >= 0) && (p.selectedBar > hatchedBarIndex)) || !selectedBoxes.length)
				return;

			var popoutPosition = 0, idx;
			var firstHalf = (p.selectedBar < graphModel.data.length / 2);
			if (selectedBoxes.length === 1) {
				idx = selectedBoxes[0];
				popoutPosition = graphModel.data[p.selectedBar][idx].sum;
			} else if (selectedBoxes.length > 1) {
				if (firstHalf) {
					idx = selectedBoxes[selectedBoxes.length - 1];
					popoutPosition = graphModel.data[p.selectedBar][idx].sum;
				} else {
					popoutPosition = graphModel.data[p.selectedBar][0].sum;
				}
			}
			if (isNaN(popoutPosition))
				popoutPosition = 0;

			var margin = graphModel.barInfo.length > 1 || showTitle ? 35 : 5;
			popout.anchors.topMargin = Math.max(margin, graphLines.height - (Math.round(popoutPosition / p.valuePerPixel) + popout.height));
		}

		// Determine the maximum value of all passed arguments. Arguments must
		// be numeric. Any non-numeric (or NaN) arguments are ignored.
		function maxIgnoreNaN(/*arguments*/) {
			var curMax = Number.NEGATIVE_INFINITY;
			// Make use of the "arguments" list which contains the arguments passed to this function.
			for (var i = 0; i < arguments.length; i++) {
				if (arguments[i] > curMax && ! isNaN(arguments[i])) {
					curMax = arguments[i]
				}
			}
			return curMax;
		}

		function chooseScale() {
			var max = 0;
			for (var i = 0, len = graphModel.data.length; i < len; i++) {
				selectedBoxes.forEach(function (j) {
					if (graphModel.data[i][j]) {
						max = maxIgnoreNaN(max, graphModel.data[i][j].sum)
						if (selectedBoxes.length === 1)
							max = maxIgnoreNaN(max, graphModel.data[i][j].estimation);
					}
				});
			}
			horizontalLines.clear();
			if (isNaN(max)) {
				console.log("Warning in BarGraph.chooseScale() - Maximum value is reported as NaN.")
			}

			i = 0;
			var scaleToUse = p.scales[p.scaleTypeSelected];
			var divisionsToUse = p.scaleDivisions[p.scaleTypeSelected];
			while (scaleToUse[i] < max && i < scaleToUse.length) {
				i++;
			}
			p.scaleMax = (i === scaleToUse.length ? max : scaleToUse[i]);
			var valueStep = p.scaleMax / divisionsToUse;
			var divisionHeight = Math.round(p.barMaxHeightPx / divisionsToUse);
			var decimals = (p.scaleMax % 5) === 0 ? 0 : (p.scaleMax < 0.5 ? 2 : 1);
			for (i = 0; i <= divisionsToUse; i++) {
				var value = i * valueStep;
				horizontalLines.insert(0, { 'value': i18n.number(value, decimals), 'divisionHeight': divisionHeight});
			}
			p.valuePerPixel = p.scaleMax / p.barMaxHeightPx;
		}

		function updateSelectedBoxes(index) {
			var tmpSelectedBoxes = [];
			for (var i = 0; i < checkboxesRow.children.length; i++) {
				if (!BarGraph.isUndef(checkboxesRow.children[i].selected))
					if (checkboxesRow.children[i].selected)
						tmpSelectedBoxes.push(i);
			}
			if (tmpSelectedBoxes.length === 0) {
				var nextBox = checkboxesRow.children[index+1];
				var prevBox = checkboxesRow.children[index-1];
				if (!BarGraph.isUndef(nextBox) && !BarGraph.isUndef(nextBox.selected)) {
					nextBox.selected = true;
					tmpSelectedBoxes.push(index+1);
				} else if (!BarGraph.isUndef(prevBox) && !BarGraph.isUndef(prevBox.selected)) {
					prevBox.selected = true;
					tmpSelectedBoxes.push(index-1);
				}
			}
			selectedBoxes = tmpSelectedBoxes;
		}
	}

	function populate(graphData, scale, selectedTypes) {
		p.scaleTypeSelected = scale;

		var tmpEstimationModels = [];
		for (var i = 0, len = graphData.data.length - 1; i < len; i++) {
			for (var j = 0; j < graphData.data[i].length; j++) {
				if (!Array.isArray(tmpEstimationModels[j]))
					tmpEstimationModels[j] = [];
				if (graphData.data[i][j].estimation >= 0 && graphData.data[i+1][j].estimation >= 0)
					tmpEstimationModels[j][i] = {'yVal1': graphData.data[i][j].estimation, 'yVal2': graphData.data[i+1][j].estimation};
				else
					tmpEstimationModels[j][i] = {'yVal1' : 0, 'yVal2' : 0}
			}
		}
		p.estimationsModel = tmpEstimationModels;
		p.graphModel = graphData;

		p.barTotalWidth = Math.floor(p.barArea / p.graphModel.data.length);

		// select checkboxes
		for (i = 0; i < checkboxesRow.children.length; i++) {
			if (!BarGraph.isUndef(checkboxesRow.children[i].selected)) {
				checkboxesRow.children[i].selected = selectedTypes.indexOf(i) >= 0 ? true : false;
			}
		}
		p.updateSelectedBoxes();
		p.chooseScale();

		p.selectedBar = -1;
		var barToAutoselect = -1;
		if (hatchedBarIndex >= 0) {
			barToAutoselect = hatchedBarIndex - 1;
		} else {
			barToAutoselect = p.graphModel.data.length - 1;
		}
		if (barToAutoselect >= 0 && (p.graphModel.data[barToAutoselect][0].sum === 0 || isNaN(p.graphModel.data[barToAutoselect][0].sum)))
			barToAutoselect = -1;
		selectBar(barToAutoselect);
	}

	function selectBar(barToSelect) {
		if (p.selectedBar === barToSelect && barToSelect !== -1) {
			graphBars.itemAt(p.selectedBar).selected = false;
			p.selectedBar = -1;
			return;
		}
		// deselect previously selected bar
		if (p.selectedBar >= 0) {
			graphBars.itemAt(p.selectedBar).selected = false;
		}
		// select new bar
		if (barToSelect >= 0 && ((hatchedBarIndex >= 0 && barToSelect <= hatchedBarIndex) || hatchedBarIndex === -1)) {
			p.selectedBar = barToSelect;
			graphBars.itemAt(barToSelect).selected = true;
		} else {
			p.selectedBar = -1;
		}
		p.updatePopoutPos();
	}

	// Mouse area used everywhere but not for bars
	MouseArea {
		id: maGraph
		anchors.fill: parent
		property string kpiPostfix: "barGraph"
		onClicked: {
			parent.selectBar(-1);
		}
	}

	/**
	 * horizontal line related objects (model and delegate for repeater and column with repeater)
	 */
	ListModel {
		id: horizontalLines
	}

	Component {
		id: horizontalLine
		Item{
			width: Math.round(750 * horizontalScaling)
			height: divisionHeight
			Rectangle {
				id: line
				height: Math.round(1 * verticalScaling)
				width: parent.width
				color: colors.graphHorizontalLine;
				anchors {
					horizontalCenter: parent.horizontalCenter
					leftMargin: Math.round(12 * horizontalScaling)
					rightMargin: Math.round(12 * horizontalScaling)
					bottom: parent.bottom

				}
			}
			Text {
				text: value
				anchors {
					baseline: line.top
					baselineOffset: Math.round(-8 * verticalScaling)
					right: line.right
					rightMargin: Math.round(20 * horizontalScaling)
				}
				color: colors.barGraphValue
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
			}
		}
	}

	Column {
		id: graphLines
		width: parent.width
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(50 * verticalScaling)
			left: parent.left
			right: parent.right
			leftMargin: Math.round(16 * horizontalScaling)
			rightMargin: anchors.leftMargin
		}
		Repeater {
			id: graphLinesRepeater
			model: horizontalLines
			delegate: horizontalLine
		}
	}

	/// Horizontal Repeater representing xLegend containing texts for hours 0:00 till 24:00 with evry 2nd hour shown.
	/// Each Repeater item contains only minutes text "00" on the left and next hour text (e.g. "4") on the right. The zero hour
	/// text "0" and the 24 hour minutes "00" are added separately.
	Row {
		id: xLegendRow
		anchors.top: graphLines.bottom
		anchors.left: parent.left
		anchors.leftMargin: xLegendLeftMargin

		Repeater {
			id: xLegendRepeater
			model: 12
			Item {
				height: root.height - graphLines.height
				width: {
					if (dstStart) {
						index === Math.floor(dstHourChange / 2) ? xLegendItemWidthDstStart * 0.5 : xLegendItemWidthDstStart;
					} else if (dstEnd) {
						index === Math.floor(dstHourChange / 2) ? xLegendItemWidthDstEnd * 1.5 : xLegendItemWidthDstEnd;
					} else {
						xLegendItemWidth;
					}
				}

				Text {
					id: hourText
					anchors {
						baseline: parent.top
						baselineOffset: xLegendTextBaselineOffset
						right: parent.right
					}
					font {
						family: qfont.semiBold.name
						pixelSize: xLegendTextSize
					}
					color: xLegendTextColor
					// show only evry 2nd hour
					text: 2 * (index+1)
				}
				Text {
					anchors {
						bottom: hourText.verticalCenter
						left: parent.left
					}
					font {
						family: qfont.semiBold.name
						pixelSize: xLegendTextSize / 2
					}
					color: xLegendTextColor
					text: "00"
				}
			}
		}
	}

	/// separate zero hour text "0" on the left of xLegendRow
	Text {
		id: hour0
		anchors {
			baseline: xLegendRow.top
			baselineOffset: xLegendTextBaselineOffset
			right: xLegendRow.left
		}
		font {
			family: qfont.semiBold.name
			pixelSize: xLegendTextSize
		}
		visible: xLegendRow.visible
		color: xLegendTextColor
		text: "0"
	}

	/// separate 24 hour minutes text "00" on the right of xLegendRow
	Text {
		id: minute24_00
		anchors {
			bottom: hour0.verticalCenter
			left: xLegendRow.right
		}
		font {
			family: qfont.semiBold.name
			pixelSize: xLegendTextSize / 2
		}
		visible: xLegendRow.visible
		color: xLegendTextColor
		text: "00"
	}

	/**
	 * single bar related objects (model and delegate for repeater and row with repeater)
	 */

	Component {
		id: graphBar

		Rectangle {
			id: bar
			width: p.barTotalWidth
			height: graphHeight
			color: isNaN(modelData[0].sum) ? colors.graphNoDataOverlay : "transparent"
			property bool selected: false
			property string kpiPostfix: "bar" + index
			property bool hatched: hatchedBarIndex === index

			MouseArea {
				id: maBar
				height: parent.height
				width: barWidth + Math.min(Math.round(20 * horizontalScaling), p.barTotalWidth - barWidth)
				anchors.horizontalCenter: parent.horizontalCenter
				enabled: !isNaN(modelData[0].sum)
				z: 1

				onClicked: {
					selectBar(index);
				}
			}

			Row {
				id: barsRow
				anchors {
					bottom: parent.bottom
					horizontalCenter: parent.horizontalCenter
				}
				Repeater {
					id: barsRepeater
					model: modelData
					Column {
						id: barColumn
						anchors.bottom: parent.bottom
						visible: selectedBoxes.indexOf(index) >= 0
						property int idx: index
						Repeater {
							id: stackItemsRepeater
							model: modelData.values
							StyledRectangle {
								id: stackItem
								width: barWidth / selectedBoxes.length
								height: Math.round(modelData / p.valuePerPixel)
								color: bar.hatched ? colors.barGraphHatchBackground : hatchColor
								hatchLineWidth: bar.hatched ? 2 : 0
								hatchColor: {
									var barIdx = barColumn.idx;
									var stackIdx = selectedBoxes.length > 1 ? 0 : index;
									if (p.graphModel.barInfo[barIdx] && p.graphModel.barInfo[barIdx].stackItems[stackIdx])
										p.graphModel.barInfo[barIdx].stackItems[stackIdx]["color"]
									else
										"transparent"
								}
								opacity: (bar.selected || p.selectedBar === -1 ? 1 : colors.graphBarInactiveOpacity)
							}
						}
					}
				}
			}

			Text {
				id: xLegend
				text: p.graphModel.axisLabels[index] ? p.graphModel.axisLabels[index] : " "
				anchors {
					baseline: parent.bottom
					baselineOffset: Math.round(24 * verticalScaling)
					horizontalCenter: parent.horizontalCenter
				}
				font {
					family: qfont.semiBold.name
					pixelSize: qfont.xLegendText
				}
				color: colors.barGraphDate
			}
		}
	}

	Row {
		id: graph
		height: graphHeight
		width: parent.width
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(50 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(22 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}

		Repeater {
			id: graphBars
			model: p.graphModel.data
			delegate: graphBar
		}
	}

	// graph title
	Text {
		id: title
		text: ""
		color: colors.barGraphTitle
		visible: showTitle
		font {
			family: qfont.italic.name
			pixelSize: qfont.bodyText
		}
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(24 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
	}

	Row {
		id: estimation
		visible: selectedBoxes.length === 1
		height: graphHeight
		width: parent.width
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(50 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(22 * horizontalScaling) + (p.barTotalWidth / 2)
		}

		Repeater {
			id: estimationLines
			model: selectedBoxes.length === 1 ? p.estimationsModel[ selectedBoxes[0] ] : 0
			delegate: estimationLine
		}
	}

	Component {
		id: estimationLine
		Item {
			width: p.barTotalWidth
			height: parent ? parent.height : 0
			Line {
				id: line
				color: selectedBoxes.length && p.graphModel.barInfo[ selectedBoxes[0] ] ? p.graphModel.barInfo[ selectedBoxes[0] ].estimationColor : "transparent"
				visible: modelData.yVal1 && modelData.yVal2
				x1: 0
				x2: parent.width
				y1: parent.height - Math.round(modelData.yVal1 / p.valuePerPixel)
				y2: parent.height - Math.round(modelData.yVal2 / p.valuePerPixel)
			}
		}
	}

	Row {
		id: checkboxesRow
		anchors{
			left: parent.left
			leftMargin: Math.round(16 * horizontalScaling);
			top: parent.top
			topMargin: Math.round(10 * verticalScaling);
		}
		spacing: Math.round(20 * horizontalScaling)

		Repeater {
			id: checkboxesRepeater
			model: p.graphModel.barInfo

			SolarPowerCheckbox {
				checkMarkColor: modelData.color
				visible: checkboxesRepeater.count > 1
				text: modelData.name
				onSelectedChangedByUser: p.updateSelectedBoxes(index)
				Component.onDestruction: p.updateSelectedBoxes(index)
			}
		}
	}


	StyledRectangle {
		id: popout
		color: colors.white
		visible: p.selectedBar >= 0 && p.selectedBar < p.graphModel.data.length && (hatchedBarIndex >= 0 ? p.selectedBar <= hatchedBarIndex : true)
		anchors.top: graphLines.top
		anchors.left: root.left
		property int textLeftMargin: 0
		property int valueRightMargin: 0
		property int padding: Math.round(15 * verticalScaling)
		property int topExtraPadding: Math.round(8 * verticalScaling)
		property int labelSpacing: Math.round(14 * horizontalScaling)
		property int positionOffset: p.selectedBar >= 0 ? barWidth + (p.barTotalWidth * (p.selectedBar + 0.5)) : 0
		property variant currentBarData
		property variant currentBarInfo
		width: popoutColumn.width + horArrowSize + (padding * 2)
		height: popoutColumn.height + horArrowSize + (padding * 2) - topExtraPadding
		borderColor: colors._bg
		borderWidth: 2
		borderStyle: Qt.SolidLine
		radius: designElements.radius

		onHeightChanged: p.updatePopoutPos()
		Connections {
			target: root
			onSelectedBoxesChanged: popout.updateCurrent()
		}
		Connections {
			target: p
			onSelectedBarChanged: popout.updateCurrent()
		}

		function getColor() {
			if (selectedBoxes.length && p.graphModel.barInfo[ selectedBoxes[0] ])
				return p.graphModel.barInfo[ selectedBoxes[0] ].stackItems[0].colorSelected;
			else
				return colors.graphElecSingleOrLowTariffSelected;
		}

		function updateCurrent() {
			var barIdx;
			if (selectedBoxes.length === 1) {
				barIdx = selectedBoxes[0];
				currentBarData = p.graphModel.data[p.selectedBar] ? p.graphModel.data[p.selectedBar][barIdx] : undefined;
				currentBarInfo = p.graphModel.barInfo[barIdx];
			} else if (selectedBoxes.length > 1) {
				currentBarData = p.graphModel.combinedData[p.selectedBar] ? p.graphModel.combinedData[p.selectedBar][selectedBoxes.join("-")] : undefined;
				// convert combined bar level data to bar's stack item data format
				var barInfo = new BarGraph.BarInfo();
				for (var i = 0; i < selectedBoxes.length; i++) {
					barIdx = selectedBoxes[i];
					if (p.graphModel.barInfo[barIdx]) {
						barInfo.stackItems[i] = new BarGraph.StackItem(p.graphModel.barInfo[barIdx].name,
																	   p.graphModel.barInfo[barIdx].color,
																	   p.graphModel.barInfo[barIdx].colorSelected,
																	   p.graphModel.barInfo[barIdx].icon);
					}
				}
				barInfo.totalText = currentBarData ? currentBarData.totalText : " ";
				currentBarInfo = barInfo;
			} else {
				currentBarData = undefined;
				currentBarInfo = undefined;
			}
		}

		MouseArea {
			property string kpiPostfix: "barGraphPopout"
			id: maPopout
			anchors.fill: parent
			onClicked: {
				selectBar(-1);
			}
		}

		Column {
			id: popoutColumn
			anchors {
				top: parent.top
				topMargin: parent.padding - qfont.bodyText + parent.topExtraPadding
				left: parent.left
			}
			property int labelsWidth: 0
			property int valuesWidth: 0

			function adjustWidths() {
				var maxLabelW = 0;
				var maxValueW = 0;
				var iconWidth = 0;
				for (var i=0; i < children.length; i++) {
					if (children[i].iconWidth)
						iconWidth = children[i].iconWidth;
					if (children[i].labelPaintedWidth)
						maxLabelW = Math.max(maxLabelW, children[i].labelPaintedWidth + iconWidth);
					if (children[i].valuePaintedWidth)
						maxValueW = Math.max(maxValueW, children[i].valuePaintedWidth);
				}
				totalSpacer.width = iconWidth;
				labelsWidth = maxLabelW + popout.labelSpacing;
				valuesWidth = maxValueW;
			}

			Repeater {
				id: popoutRepeater
				model: popout.currentBarData ? popout.currentBarData.valuesFormatted : 0
				onItemAdded: popoutColumn.adjustWidths()

				Row {
					id: popoutRow
					height: Math.round(20 * verticalScaling)
					spacing: Math.round(7 * horizontalScaling)
					property alias iconWidth: popoutIcon.width
					property alias labelPaintedWidth: popoutLabel.paintedWidth
					property alias valuePaintedWidth: popoutValue.paintedWidth
					property variant currentStackItem: popout.currentBarInfo && popout.currentBarInfo.stackItems[index] ? popout.currentBarInfo.stackItems[index] : undefined
					onLabelPaintedWidthChanged: popoutColumn.adjustWidths()
					onValuePaintedWidthChanged: popoutColumn.adjustWidths()

					Image {
						id: popoutIcon
						anchors.bottom: parent.bottom
						source: parent.currentStackItem ? parent.currentStackItem.icon : ""
						visible: source ? true : false
						onWidthChanged: popoutColumn.adjustWidths()
					}
					Text {
						id: popoutLabel
						width: popoutColumn.labelsWidth
						anchors.baseline: parent.bottom
						visible: popoutRepeater.count > 1 || showVAT
						font {
							family: qfont.bold.name
							pixelSize: qfont.bodyText
						}
						color: colors.barGraphPopupTxt
						text: showVAT && popoutRepeater.count === 1 ? qsTr("excl. vat") : (parent.currentStackItem ? parent.currentStackItem.name : " ")
					}
					Text {
						id: popoutValue
						width: popoutColumn.valuesWidth
						anchors.baseline: parent.bottom
						font {
							family: qfont.semiBold.name
							pixelSize: qfont.bodyText
						}
						color: parent.currentStackItem ? parent.currentStackItem.color : "black"
						horizontalAlignment: Text.AlignRight
						text: modelData
					}
				}
			}

			Row {
				id: totalRow
				spacing: Math.round(7 * horizontalScaling)
				height: Math.round(32 * verticalScaling)
				visible: popoutRepeater.count > 1
				property alias labelPaintedWidth: totalLabel.paintedWidth
				property alias valuePaintedWidth: totalValue.paintedWidth
				onLabelPaintedWidthChanged: popoutColumn.adjustWidths()
				onValuePaintedWidthChanged: popoutColumn.adjustWidths()

				Text {
					id: totalLabel
					width: popoutColumn.labelsWidth
					anchors.baseline: parent.bottom
					font {
						family: qfont.bold.name
						pixelSize: qfont.titleText
					}
					color: colors.barGraphPopupTxt
					text: popout.currentBarInfo ? popout.currentBarInfo.totalText : " "
				}

				Item {
					id: totalSpacer
					visible: width ? true : false
					height: 1
				}

				Text {
					id: totalValue
					width: popoutColumn.valuesWidth
					anchors.baseline: parent.bottom
					font {
						family: qfont.semiBold.name
						pixelSize: qfont.bodyText
					}
					color: colors.barGraphPopupTxt
					text: popout.currentBarData ? popout.currentBarData.sumFormatted : " "
					horizontalAlignment: Text.AlignRight
				}
			}

			Row {
				id: vatRow
				visible: showVAT
				spacing: Math.round(7 * horizontalScaling)
				height: Math.round((popoutRepeater.count === 1 ? 20 : 35) * verticalScaling)
				property alias labelPaintedWidth: vatLabel.paintedWidth
				property alias valuePaintedWidth: vatValue.paintedWidth
				onLabelPaintedWidthChanged: popoutColumn.adjustWidths()
				onValuePaintedWidthChanged: popoutColumn.adjustWidths()

				Item {
					width: popoutColumn.labelsWidth
					height: parent.height
					Text {
						id: exclVatText
						visible: popoutRepeater.count > 1
						anchors {
							baseline: parent.top
							baselineOffset: font.pixelSize
						}
						font {
							family: qfont.regular.name
							pixelSize: qfont.metaText
						}
						color: colors.barGraphPopupTxt
						text: qsTr("excl. vat")
					}
					Text {
						id: vatLabel
						anchors.baseline: parent.bottom
						font {
							family: qfont.italic.name
							pixelSize: qfont.metaText
						}
						color: colors.barGraphPopupTxt
						text: qsTr("vat")
					}
				}
				Text {
					id: vatValue
					width: popoutColumn.valuesWidth
					anchors.baseline: parent.bottom
					font {
						family: qfont.italic.name
						pixelSize: qfont.metaText
					}
					color: colors.barGraphPopupTxt
					text: popout.currentBarData ? popout.currentBarData.vatFormatted : " "
					horizontalAlignment: Text.AlignRight
				}
			}
		}

		states: [
			State {
				name: "left"
				when: (p.selectedBar >= (p.graphModel.data.length / 2))
				PropertyChanges { target: popout; anchors.leftMargin: popout.positionOffset - Math.round(16 * horizontalScaling) - popout.width }
				PropertyChanges { target: popout; bottomLeftArrowVisible: false; bottomRightArrowVisible: true }
				PropertyChanges { target: popoutColumn; anchors.leftMargin: popout.padding }
			},
			State {
				name: "right"
				when: (p.selectedBar < (p.graphModel.data.length / 2))
				PropertyChanges { target: popout; anchors.leftMargin: popout.positionOffset + Math.round(12 * horizontalScaling) }
				PropertyChanges { target: popout; bottomLeftArrowVisible: true; bottomRightArrowVisible: false }
				PropertyChanges { target: popoutColumn; anchors.leftMargin: popout.padding + popout.horArrowSize }
			}
		]
	}
}
