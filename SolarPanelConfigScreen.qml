import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: solarPanelConfigScreen
	screenTitle: "SolarPanel Configuratie"

	property variant invertersArray: ["PVOutput","Fronius","Growatt","Kostal Piko","SMA","SolarEdge","ZeverSolar"]
	property int numberofItems
	property string selectedInverter:app.selectedInverter
	property string field1Text: ""
	property string field2Text: ""
	property string growattTempUser: app.growattUserName
	property string growattTempPass: app.growattPassWord
	property string solaredgeTempSite: app.solarEdgeSiteID
	property string solaredgeTempApi: app.solarEdgeApiKey
	property string froniusTempURL: app.froniusUrl
	property string smaTempUrl: app.smaUrl
	property string smaTempPass: app.smaPassWord
	property string kostalTempUrl: app.kostalUrl
	property string zeversolarTempUrl: app.zeversolarUrl
	property string pvOutputKeyTempApi: app.pvOutputApiKey
	property string pvOutputSidTempSid: app.pvOutputSid

	function setFieldText(text) {
			field1Text=""
			field2Text=""
		    if (text.toLowerCase()=="growatt") field1Text = "Gebruikersnaam (email):"
			if (text.toLowerCase()=="solaredge") field1Text = "SiteID:"
			if (text.toLowerCase()=="fronius") field1Text = "Fronius URL like \"192.168.10.5\":"
			if (text.toLowerCase()=="sma") field1Text = "SMA URL like \"192.168.10.5\":"
			if (text.toLowerCase()=="kostal piko") field1Text = "Kostal URL like \"192.168.10.5\":"
			if (text.toLowerCase()=="zeversolar") field1Text = "ZeverSolar URL like \"192.168.10.5\":"
			if (text.toLowerCase()=="pvoutput") field1Text = "SiteID:"
			
			if (text.toLowerCase()=="growatt") field2Text = "Wachtwoord:"
			if (text.toLowerCase()=="solaredge") field2Text = "Api Key:"
			if (text.toLowerCase()=="fronius") field2Text = ""
			if (text.toLowerCase()=="sma") field2Text = "Wachtwoord:"
			if (text.toLowerCase()=="kostal piko") field2Text = ""
			if (text.toLowerCase()=="pvoutput") field2Text = "Api Key:"
			
			for(var x2 = 0;x2 < invertersArray.length;x2++){
				if (invertersArray[x2].toLowerCase()==selectedInverter.toLowerCase()){ listview1.currentIndex = x2}
			}
	}
	
	function saveField1Data(text) {
			if (selectedInverter.toLowerCase()=="growatt") growattTempUser = text
			if (selectedInverter.toLowerCase()=="solaredge") solaredgeTempSite = text
			if (selectedInverter.toLowerCase()=="fronius") froniusTempUrl = text
			if (selectedInverter.toLowerCase()=="sma") smaTempUrl = text
			if (selectedInverter.toLowerCase()=="kostal piko") kostalTempUrl = text
			if (selectedInverter.toLowerCase()=="zeversolar") zeversolarTempUrl = text
			if (selectedInverter.toLowerCase()=="pvoutput") pvOutputSidTempSid = text
			setFieldText(selectedInverter)
	}
	
	function saveField2Data(text) {
			if (selectedInverter.toLowerCase()=="growatt") growattTempPass = text
			if (selectedInverter.toLowerCase()=="solaredge") solaredgeTempApi = text
			if (selectedInverter.toLowerCase()=="sma") smaTempPass = text
			if (selectedInverter.toLowerCase()=="pvoutput") pvOutputKeyTempApi = text
			setFieldText(selectedInverter)
	}

	
	onShown: {
		//selectedInverter = app.selectedInverter
		enableSleepToggle.isSwitchedOn = app.enableSleep
		
		growattUserName.inputText = growattTempUser
		growattPassWord.inputText = growattTempPass
		froniusUrl.inputText = froniusTempURL
		
		
		solaredgeSITE.inputText = solaredgeTempSite
		solaredgeAPI.inputText = solaredgeTempApi
		
		smaUrl.inputText = smaTempUrl
		smaPassWord.inputText = smaTempPass
		
		kostalUrl.inputText = kostalTempUrl	
		zeversolarUrl.inputText = zeversolarTempUrl
		
		pvOutputSITE.inputText = pvOutputSidTempSid
		pvOutputAPI.inputText = pvOutputKeyTempApi

		addCustomTopRightButton("Opslaan")
		fillInverters()
		listview1.currentIndex = app.tempConfigListIndex
		setFieldText(selectedInverter)
	}

	onCustomButtonClicked: {
		app.selectedInverter = selectedInverter
		app.growattUserName = growattUserName.inputText
		app.growattPassWord = growattPassWord.inputText
		app.solarEdgeSiteID = solaredgeSITE.inputText
		app.solarEdgeApiKey = solaredgeAPI.inputText
		app.froniusUrl = froniusUrl.inputText
		app.smaUrl = smaUrl.inputText
		app.smaPassWord = smaPassWord.inputText
		app.kostalUrl = kostalUrl.inputText
		app.zeversolarUrl = zeversolarUrl.inputText
		app.pvOutputSid = pvOutputSITE.inputText
		app.pvOutputApiKey = pvOutputAPI.inputText
		app.saveSettings()
		hide()
	}

	function fillInverters(){
		numberofItems =  invertersArray.length
		model.clear()
		for(var x1 = 0;x1 < invertersArray.length;x1++){
				listview1.model.append({name: invertersArray[x1]})
		}
		
	}
/////////////////////////////////////////////////////////////////////////

	Text {
		id: mytexttop1
		text: "Selecteer je inverter en vul je gegevens in."
		font {
			family: qfont.semiBold.name
			pixelSize: isNxt ? 18:14
		}
		anchors {
			top:parent.top
			left:parent.left
			leftMargin: isNxt ? 10 :8
			topMargin: isNxt ? 5 :4
		}
	}
	
	Text {
		id: mytexttop2
		text: "Selecteer:"
		font {
			family: qfont.semiBold.name
			pixelSize: isNxt ? 18:14
		}
		anchors {
			top:mytexttop1.bottom
			left:mytexttop1.left
			topMargin: isNxt ? 10 :8
		}
	}
	
	Rectangle{
		id: listviewContainer1
		width: isNxt ? 250 : 200
		height: isNxt ? 180 : 120
		color: "white"
		radius: isNxt ? 5 : 4
		border.color: "black"
			border.width: isNxt ? 3 : 2
		anchors {
			top:		mytexttop2.bottom
			topMargin: 	isNxt? 8:6
			left:   	mytexttop1.left
		}

		Component {
			id: aniDelegate
			Item {
				width: isNxt ? (parent.width-20) : (parent.width-16)
				height: isNxt ? 22 : 18
				Text {
					id: tst
					text: name
					font.pixelSize: isNxt ? 18:14
				}
			}
		}

		ListModel {
				id: model
		}


		ListView {
			id: listview1
			anchors {
				top: parent.top
				topMargin:isNxt ? 20 : 16
				leftMargin: isNxt ? 12 : 9
				left: parent.left
			}
			width: parent.width
			height: isNxt ? (parent.height-50) : (parent.height-40)
			model:model
			delegate: aniDelegate
			highlight: Rectangle { 
				color: "lightsteelblue"; 
				radius: isNxt ? 5 : 4
			}
			focus: true
		}
	}

/////////////////////////////////////////////////////////////////////////

	IconButton {
		id: upButton
		anchors {
			top: listviewContainer1.top
			left:  listviewContainer1.right
			leftMargin : isNxt? 3 : 2
		}

		iconSource: "qrc:/tsc/up.png"
		onClicked: {
		    if (listview1.currentIndex>0){
                        listview1.currentIndex  = listview1.currentIndex -1
            }
		}	
	}

	IconButton {
		id: downButton
		anchors {
			bottom: listviewContainer1.bottom
			left:  listviewContainer1.right
			leftMargin : isNxt? 3 : 2

		}
		iconSource: "qrc:/tsc/down.png"
		onClicked: {
		    if (listview1.currentIndex+1< numberofItems){
                        listview1.currentIndex  = listview1.currentIndex +1
            }
		}	
	}

	NewTextLabel {
		id: selText
		width: isNxt ? 120 : 96;  
		height: isNxt ? 40:32
		buttonActiveColor: "lightgreen"
		buttonHoverColor: "blue"
		enabled : true
		textColor : "black"
		buttonText:  "Selecteer"
		anchors {
			top: listviewContainer1.bottom
			left: listviewContainer1.left
			topMargin: isNxt? 5: 4
			}
		onClicked: {
			selectedInverter = invertersArray[listview1.currentIndex]
			setFieldText(selectedInverter)
		}
	}

////////////////////////////////////////////// SELECTED ///////////////////////////////////////////////////////////////////////////////

	Text {
		id: showInSleep
		width:  isNxt? 160:128
		text: "Zichtbaar in gedimde mode: "
		font.pixelSize:  isNxt ? 18 : 14
		font.family: qfont.semiBold.name
		anchors {
			left: listviewContainer1.left
			top: selText.bottom
			topMargin: isNxt? 30 : 25
		}
	}

	OnOffToggle {
		id: enableSleepToggle
		height:  30
		anchors.left: showInSleep.right
		anchors.leftMargin: isNxt ? 100 : 80
		anchors.top: showInSleep.top
		leftIsSwitchedOn: false
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				app.enableSleep = true;
			} else {
				app.enableSleep = false;
			}
		}
	}
////////////////////////////////////////////// SELECTED ///////////////////////////////////////////////////////////////////////////////

	Text {
		id: mytext1
		text: "Geselecteerd: "
		font {
			family: qfont.semiBold.name
			pixelSize: isNxt ? 18:14
		}
		anchors {
			top: mytexttop2.top
			left:upButton.right
			leftMargin:100
		}
		visible: (selectedInverter.length>2)
	}
	
	
	Text {
		id: selectedText
		text: selectedInverter
		font {
			family: qfont.semiBold.name
			pixelSize: isNxt ? 24:18
		}
		anchors {
			bottom: mytext1.bottom
			left: mytext1.right
			leftMargin: 20
		}
	}
	
	Text {
		id: inputField1Text
		text: field1Text
		font {
			family: qfont.semiBold.name
			pixelSize: isNxt ? 18:14
		}
		anchors {
			left: mytext1.left
			top: mytext1.bottom			
			topMargin: isNxt? 30:25
		}
	}

	
	Text {
		id: inputField2Text
		text: field2Text
		font {
			family: qfont.semiBold.name
			pixelSize: isNxt ? 18:14
		}
		anchors {
			left: mytext1.left
			top: growattUserName.bottom
			topMargin: isNxt? 10:8
		}
	}

//////////////////////////////////////////////GROWATT INVERTER//////////////////////////////////////////
	EditTextLabel4421 {
		id: growattUserName
		width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32
		height: isNxt? 35:28
		leftTextAvailableWidth: isNxt? 100:80
		leftText: ""
		anchors {
			left: mytext1.left
			top: inputField1Text.bottom
			topMargin: isNxt? 10:8
		}
		onClicked: {
			qkeyboard.open(field1Text, growattUserName.inputText, saveField1Data)
		}
		visible: (selectedInverter.toLowerCase()=="growatt")
	}
	
	EditTextLabel4421 {
		id: growattPassWord
		width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32
		height: isNxt? 35:28
		leftTextAvailableWidth: isNxt? 100:80
		leftText: ""
		anchors {
			left: mytext1.left
			top: inputField2Text.bottom
			topMargin: isNxt? 10:8
		}
		onClicked: {
			qkeyboard.open(field2Text, growattPassWord.inputText, saveField2Data)
		}
		visible: (selectedInverter.toLowerCase()=="growatt")
	}
	
	
//////////////////////////////////////////////SOLAREDGE INVERTER//////////////////////////////////////////
	EditTextLabel4421 {
		id: solaredgeSITE
		width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32
		height: isNxt? 35:28
		leftTextAvailableWidth: isNxt? 100:80
		leftText: ""
		anchors {
			left: mytext1.left
			top: inputField1Text.bottom
			topMargin: isNxt? 10:8
		}
		onClicked: {
			qkeyboard.open(field1Text, solaredgeSITE.inputText, saveField1Data)
		}
		visible: (selectedInverter.toLowerCase()=="solaredge")
	}
	
	EditTextLabel4421 {
		id: solaredgeAPI
		width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32
		height: isNxt? 35:28
		leftTextAvailableWidth: isNxt? 100:80
		leftText: ""
		anchors {
			left: mytext1.left
			top: inputField2Text.bottom
			topMargin: isNxt? 10:8
		}
		onClicked: {
			qkeyboard.open(field2Text, solaredgeAPI.inputText, saveField2Data)
		}
		visible: (selectedInverter.toLowerCase()=="solaredge")
	}
	
//////////////////////////////////////////////FRONIUS INVERTER//////////////////////////////////////////

	EditTextLabel4421 {
		id: froniusUrl
		width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32
		height: isNxt? 35:28
		leftTextAvailableWidth: isNxt? 100:80
		leftText: ""
		anchors {
			left: mytext1.left
			top: inputField1Text.bottom
			topMargin: isNxt? 10:8
		}
		onClicked: {
			qkeyboard.open(field1Text, froniusUrl.inputText, saveField1Data)
		}
		visible: (selectedInverter.toLowerCase()=="fronius")
	}
//////////////////////////////////////////////SMA INVERTER//////////////////////////////////////////

	EditTextLabel4421 {
		id: smaUrl
		width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32
		height: isNxt? 35:28
		leftTextAvailableWidth: isNxt? 100:80
		leftText: ""
		anchors {
			left: mytext1.left
			top: inputField1Text.bottom
			topMargin: isNxt? 10:8
		}
		onClicked: {
			qkeyboard.open(field1Text, smaUrl.inputText, saveField1Data)
		}
		visible: (selectedInverter.toLowerCase()=="sma")
	}
	
	EditTextLabel4421 {
		id: smaPassWord
		width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32
		height: isNxt? 35:28
		leftTextAvailableWidth: isNxt? 100:80
		leftText: ""
		anchors {
			left: mytext1.left
			top: inputField2Text.bottom
			topMargin: isNxt? 10:8
		}
		onClicked: {
			qkeyboard.open(field2Text, smaPassWord.inputText, saveField2Data)
		}
		visible: (selectedInverter.toLowerCase()=="sma")
	}

//////////////////////////////////////////////KOSTAL INVERTER//////////////////////////////////////////

	EditTextLabel4421 {
		id: kostalUrl
		width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32
		height: isNxt? 35:28
		leftTextAvailableWidth: isNxt? 100:80
		leftText: ""
		anchors {
			left: mytext1.left
			top: inputField1Text.bottom
			topMargin: isNxt? 10:8
		}
		onClicked: {
			qkeyboard.open(field1Text, kostalUrl.inputText, saveField1Data)
		}
		visible: (selectedInverter.toLowerCase()=="kostal piko")
	}

////////////////////////////////////////////// ZEVERSOLAR //////////////////////////////////////////

	EditTextLabel4421 {
		id: zeversolarUrl
		width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32
		height: isNxt? 35:28
		leftTextAvailableWidth: isNxt? 100:80
		leftText: ""
		anchors {
			left: mytext1.left
			top: inputField1Text.bottom
			topMargin: isNxt? 10:8
		}
		onClicked: {
			qkeyboard.open(field1Text, zeversolarUrl.inputText, saveField1Data)
		}
		visible: (selectedInverter.toLowerCase()=="zeversolar")
	}
	
//////////////////////////////////////////////PV OUTPUT  //////////////////////////////////////////
	EditTextLabel4421 {
		id: pvOutputSITE
		width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32
		height: isNxt? 35:28
		leftTextAvailableWidth: isNxt? 100:80
		leftText: ""
		anchors {
			left: mytext1.left
			top: inputField1Text.bottom
			topMargin: isNxt? 10:8
		}
		onClicked: {
			qkeyboard.open(field1Text, pvOutputSITE.inputText, saveField1Data)
		}
		visible: (selectedInverter.toLowerCase()=="pvoutput")
	}
	
	EditTextLabel4421 {
		id: pvOutputAPI
		width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32
		height: isNxt? 35:28
		leftTextAvailableWidth: isNxt? 100:80
		leftText: ""
		anchors {
			left: mytext1.left
			top: inputField2Text.bottom
			topMargin: isNxt? 10:8
		}
		onClicked: {
			qkeyboard.open(field2Text, pvOutputAPI.inputText, saveField2Data)
		}
		visible: (selectedInverter.toLowerCase()=="pvoutput")
	}
	
}

