.pragma library

var AGGREGATOR_SUM = 1;
var AGGREGATOR_DIFF = 2;

function BarData() {
	this.values = [];
	this.valuesFormatted = [];
	this.sum= 0;
	this.sumFormatted = "";
	this.vat = 0;
	this.vatFormatted = "";
	this.estimation = -1;
	this.totalText = "";
}

function BarInfo() {
	this.name = ""
	this.stackItems = [new StackItem()];
	this.icon = "";
	this.color = "transparent";
	this.estimationColor = "transparent";
	this.totalText = "";
}

function StackItem(name, color, colorSelected, icon) {
	this.name = !isUndef(name) ? name : "";
	this.color = !isUndef(color) ? color : "transparent";
	this.colorSelected = !isUndef(colorSelected) ? colorSelected  : "transparent";
	this.icon = !isUndef(icon) ? icon : "";
}

function GraphData() {
	this.data = []; ///< This is a 2 dimensional array where the first are the groups of data in the X axis and the second dimension represents the different categories per group in the X axis
	this.barInfo = [new BarInfo()];
	this.axisLabels = [];
	this.combinedData = [];
	this.combinedBarsInfo = [];
}

function isUndef(value) {
	return typeof value === "undefined";
}
