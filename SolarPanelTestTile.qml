import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0;

Tile {
    id: test    	


 MouseArea {
		height : parent.height/2
		width : parent.width/2
		anchors {
			top: parent.top
			left: parent.left
			leftMargin: parent.width/4
			topMargin:parent.height/4
		}
		onClicked: {
			app.doScrapeNow()
		}
	}
	
 NewTextLabel {
		id: justaButton
		width: isNxt ? 200 : 160 
		height: isNxt ? 80 : 54
		buttonActiveColor: "lightgrey"
		buttonHoverColor: "blue"
		enabled : true
		textColor : "black"
		textDisabledColor : "grey"
		buttonText:  "Test Now"
        anchors.centerIn: parent
		onClicked: {
			app.doScrapeNow()
		}
	}

}





