import QtQuick 2.1
import qb.components 1.0

StandardCheckBox {
	id: root

	width: root.implicitWidth + 2
	height: root.implicitHeight + 2
	backgroundColor: colors.graphCheckboxTextBackground
	squareBackgroundColor: colors.graphCheckboxFill
	squareSelectedColor: colors.graphCheckboxSquare
	squareUnselectedColor: squareSelectedColor
	squareRadius: 10
	smallSquareRadius: 9
	squareOffset: 0
	spacing: Math.round(3 * horizontalScaling)
	leftMargin: Math.round(1 * horizontalScaling)
	rightMargin: 0
	checkMarkStartXOffset: 3
	checkMarkStartYOffset: 6
	fontColorSelected: colors.cbText
	fontFamilySelected: qfont.regular.name
	fontPixelSize: qfont.metaText
	topClickMargin: 10
	bottomClickMargin: 10
}
