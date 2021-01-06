import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0
import FileIO 1.0

Screen {
	id: solarPanelConfigScreen
	screenTitle: "SolarPanel Configuratie"
	

	property variant invertersNameArray: []
	property variant filenameArray: []
	property variant dataStringArray: []
	property variant inputDataType: []
	
	property url inverterUrl : "https://raw.githubusercontent.com/ToonSoftwareCollective/solarpanel-plugins/main/inverters.json"
	property url pluginUrl : "https://raw.githubusercontent.com/ToonSoftwareCollective/solarpanel-plugins/main/"

	
	property int numberofItems
	property string selectedInverter:app.selectedInverter
	property string pluginFile: ""
	property string fieldText1 : "Wachtwoord :"
	property string fieldText2 : "Gebruikersnaam :"
	property string fieldText3 :  "SiteID:"
	property string fieldText4 : "API Key:"
	property string fieldText5 : "URL like \"192.168.10.5\":"
	
	property bool field1visible : false
	property bool field2visible : false
	property bool field3visible : false
	property bool field4visible : false
	property bool field5visible : false
	
	
	
	property string tempPassWord : app.passWord
	property string tempUserName: app.userName
	property string tempSiteID: app.siteID
	property string tempApiKey: app.apiKey
	property string tempURL: app.urlString
	
	property bool manual: false
	
	property int configChangeStep : 0
	property bool stepRunning : false
	property bool needReboot : false
	property bool needRestart : false
	property string oldconfigfileString
	property string oldConfigScsyncFileString
	
	property bool updatepossible : false
	property string oldversionTotal
	property string onlineversionTotal
	property bool updatechecked : false
	property bool showUpdate : false
	property bool updated : false
	property bool updateSucces : false
	
	property bool debugOutput : app.debugOutput						// Show console messages. Turn on in settings file !
	

	FileIO {id: hcb_scsync_Configfile;	source: "file:///mnt/data/qmf/config/config_happ_scsync.xml"}
	FileIO {id: hcb_scsync_Configfile_bak;	source: "file:///mnt/data/qmf/config/config_happ_scsync.solarpanelbackup"}
	FileIO {id: hcb_rrd_Configfile;	source: "file:///qmf/config/config_hcb_rrd.xml"}
	FileIO {id: hcb_rrd_Configfile_bak;	source: "file:///qmf/config/config_hcb_rrd.solarpanelbackup"}
	FileIO {id: mergeFile1;	source: "solarpanel_merge_prod.txt"}
	FileIO {id: mergeFile2;	source: "solarpanel_merge_solar.txt"}
	FileIO {id: pluginFile;	source: "SolarObjectPlugin.js"}

/*
	{"plugins":[
			{"friendlyName":"Growatt", "filename":"GROW1", "data": ["Password", "Username"]},
			{"friendlyName":"Solaredge", "filename":"SOLEDGE1", "data": ["SiteID", "APIKey"]},
			{"friendlyName":"Fronius", "filename":"FRONIUS1", "data": ["URL"]},
			{"friendlyName":"PVOutput", "filename":"PVOUTPUT1", "data": ["SiteID", "APIKey"]},
			{"friendlyName":"Kostal Piko", "filename":"KOSTAL1", "data": ["URL"]},
			{"friendlyName":"SMA", "filename":"SMA1", "data": ["Password","URL"]},
			{"friendlyName":"ZeverSolar", "filename":"ZEVER1", "data": ["URL"]}
		]
	}
*/

	onShown: {
		addCustomTopRightButton("Opslaan")
		getInverters()
		enableSleepToggle.isSwitchedOn = app.enableSleep
		enablePollingToggle.isSwitchedOn = app.enablePolling
		inputField1.inputText = tempPassWord
		inputField2.inputText = tempUserName
		inputField3.inputText = tempSiteID
		inputField4.inputText = tempApiKey
		inputField5.inputText = tempURL
	}

	onCustomButtonClicked: {
		configChangeStep = 0
		stepRunning  = true
	}

	function fillInverters(){
		numberofItems =  invertersNameArray.length
		model.clear()
		for(var x1 = 0;x1 < invertersNameArray.length;x1++){
				listview1.model.append({name: invertersNameArray[x1]})
		}
		
	}
	
	function getInverters(){
		if (invertersNameArray.length < 1 || manual){
			manual = false 
			var http = new XMLHttpRequest()
			http.onreadystatechange=function() {
				if (http.readyState === 4){
					if (http.status === 200 || http.status === 300  || http.status === 302) {
						model.clear()
						var JsonString = http.responseText
						if (debugOutput) console.log("responsetext: " +  http.responseText)
						var JsonObject= JSON.parse(JsonString)
						var invertersArray = JsonObject.plugins
						numberofItems =  invertersArray.length
						for (var i in invertersArray){
							invertersNameArray[i] = invertersArray[i].friendlyName
							filenameArray[i] = invertersArray[i].filename
							inputDataType[i] = invertersArray[i].data
							console.log(invertersNameArray[i])
							console.log(inputDataType[i])
							console.log(filenameArray[i])
						}
						resumefromHttpRequest()
					}
					else {
						if (debugOutput) console.log("*********SolarPanel error: " + http.status)
					}
				}
			}
			http.open("GET",inverterUrl, true)
			http.send()
		}	
	}
	
	function resumefromHttpRequest(){
		enableSleepToggle.isSwitchedOn = app.enableSleep
		addCustomTopRightButton("Opslaan")
		fillInverters()
		listview1.currentIndex = app.tempConfigListIndex
		tempPassWord = app.passWord
		tempUserName = app.userName
		tempApiKey = app.apiKey 
		tempSiteID= app.siteID
		tempURL = app.urlString
		setFieldText()
	}

	function setFieldText() {
		for(var x2 = 0;x2 < invertersNameArray.length;x2++){
			if (invertersNameArray[x2].toLowerCase()==selectedInverter.toLowerCase()){ listview1.currentIndex = x2 ; showUpdate = true}
		}
		field1visible = ((inputDataType[listview1.currentIndex]).toString().toLowerCase().indexOf('ass')>-1)
		field2visible = ((inputDataType[listview1.currentIndex]).toString().toLowerCase().indexOf('use')>-1)
		field3visible = ((inputDataType[listview1.currentIndex]).toString().toLowerCase().indexOf('iteid')>-1)
		field4visible = ((inputDataType[listview1.currentIndex]).toString().toLowerCase().indexOf('api')>-1)
		field5visible = ((inputDataType[listview1.currentIndex]).toString().toLowerCase().indexOf('url')>-1)
	}
	
	function saveFieldData1(text) {
		tempPassWord = text
	}
	
	function saveFieldData2(text) {
		tempUserName= text
	}

	function saveFieldData3(text) {
		tempSiteID= text
	}

	function saveFieldData4(text) {
		tempApiKey= text
	}

	function saveFieldData5(text) {
		tempURL= text
	}

	function checkforUpdates(){
		//check current version
		updatechecked = true
		var oldPluginFileString = pluginFile.read()
		var n1 = oldPluginFileString.indexOf('<version>')
		var n2 = oldPluginFileString.indexOf('</version>',n1)
		oldversionTotal =  (oldPluginFileString.substring(n1 + 9, n2)).trim()	
		
		//get filename of installed inverter
		for(var x2 = 0;x2 < invertersNameArray.length;x2++){
			if (invertersNameArray[x2].toLowerCase()==app.selectedInverter.toLowerCase()){var onlinePluginFileName = filenameArray[x2]}
		}
		
		var onlineversionArray = ["0","0","0"]
		//check online version
		var http = new XMLHttpRequest()
		http.onreadystatechange=function() {
			if (http.readyState === 4){
				if (http.status === 200) {
					console.log("*********SolarPanel new Plugin: " + http.responseText)
					var onlinePluginFileString = http.responseText
					var n1 = onlinePluginFileString.indexOf('<version>')
					var n2 = onlinePluginFileString.indexOf('</version>',n1)
					onlineversionTotal =  (onlinePluginFileString.substring(n1 + 9, n2)).trim()			
					compareVersions(oldversionTotal,onlineversionTotal)
				}
				else {
					if (debugOutput) console.log("*********SolarPanel error retrieving new Plugin: " + http.status)
				}
			}
		}
		console.log(pluginUrl + onlinePluginFileName + ".plugin.txt")
		http.open("GET",pluginUrl + onlinePluginFileName + ".plugin.txt"  , true)
		http.send()
		
		
		
	}

	
/////////////////////////////////////////////////////////////////////////

	function compareVersions(oldversionTotal,onlineversionTotal){
	
		updatepossible = false
		
		if (debugOutput) console.log("*********SolarPanel oldvalue of Plugin : " + oldversionTotal)
		
		var oldversionArray = oldversionTotal.split(".")
		if (debugOutput) console.log("*********SolarPanel oldvalue of Plugin major : " + oldversionArray[0])
		if (debugOutput) console.log("*********SolarPanel oldvalue of Plugin minor : " + oldversionArray[1])
		if (debugOutput) console.log("*********SolarPanel oldvalue of Plugin patch : " + oldversionArray[2])
		if(typeof(oldversionArray[2]) == "undefined"){oldversionTotal = "0.0.0" ; oldversionArray[0] = 0 ;  oldversionArray[1] = 0  ;  oldversionArray[2] = 0 }
		if (debugOutput) console.log("*********SolarPanel oldvalue of Plugin : " + oldversionTotal)
		oldversionText.text =  "Oude versie: " + oldversionTotal
		
		if (debugOutput) console.log("*********SolarPanel oldvalue of Plugin major : " + oldversionArray[0])
		if (debugOutput) console.log("*********SolarPanel oldvalue of Plugin minor : " + oldversionArray[1])
		if (debugOutput) console.log("*********SolarPanel oldvalue of Plugin patch : " + oldversionArray[2])
	
		if (debugOutput) console.log("*********SolarPanel online of Plugin : " + onlineversionTotal)
		var onlineversionArray = onlineversionTotal.split(".")
		if (debugOutput) console.log("*********SolarPanel online of Plugin major : " + onlineversionArray[0])
		if (debugOutput) console.log("*********SolarPanel online of Plugin minor : " + onlineversionArray[1])
		if (debugOutput) console.log("*********SolarPanel online of Plugin patch : " + onlineversionArray[2])
		
		if(typeof(onlineversionArray[2]) == "undefined"){onlineversionTotal = "0.0.0" ; onlineversionArray[0] = 0 ;  onlineversionArray[1] = 0  ;  onlineversionArray[2] = 0 }
		if (debugOutput) console.log("*********SolarPanel online of Plugin major : " + onlineversionArray[0])
		if (debugOutput) console.log("*********SolarPanel online of Plugin minor : " + onlineversionArray[1])
		if (debugOutput) console.log("*********SolarPanel online of Plugin patch : " + onlineversionArray[2])
	
		//compare versions

		if (parseInt(onlineversionArray[0]) > parseInt(oldversionArray[0])) {
			updatepossible = true
		}
		if (!updatepossible && (parseInt(onlineversionArray[1]) > parseInt(oldversionArray[1]))) {
			updatepossible = true
		}
		if (!updatepossible && (parseInt(onlineversionArray[2]) > parseInt(oldversionArray[2]))) {
			updatepossible = true
		}

		if (debugOutput) console.log("*********SolarPanel updatepossible : " + updatepossible)
	
	}

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
		id: refreshButton
		anchors {
			verticalCenter: listviewContainer1.verticalCenter
			left:  listviewContainer1.right
			leftMargin : isNxt? 3 : 2
		}
		iconSource: "qrc:/tsc/refresh.png"
		onClicked: {
			manual =true
			getInverters()
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
			selectedInverter = invertersNameArray[listview1.currentIndex]
			if (selectedInverter != listview1.name){
				setFieldText()
			}
			if (app.selectedInverter == selectedInverter){
				showUpdate = true
			}else{
				showUpdate = false
			}

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
		anchors.leftMargin: isNxt ? 140 : 112
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
	
	
	Text {
		id: enablePolling
		width:  isNxt? 160:128
		text: "Ophalen van data ingeschakeld: "
		font.pixelSize:  isNxt ? 18 : 14
		font.family: qfont.semiBold.name
		anchors {
			left: listviewContainer1.left
			top: showInSleep.bottom
			topMargin: isNxt? 20 : 16
		}
	}

	
	OnOffToggle {
		id: enablePollingToggle
		height:  30
		anchors.left: enableSleepToggle.left
		anchors.top: enablePolling.top
		leftIsSwitchedOn: false
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				app.enablePolling = true;
			} else {
				app.enablePolling = false;
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


	Grid {
		id: gridContainer1
		columns: 1
		spacing: 2
		
		anchors {
			top: listviewContainer1.top	
			left : mytext1.left
		}
		Text {id: inputField1Text;font.pixelSize: isNxt ? 18:14; font.family: qfont.semiBold.name ;text:fieldText1;visible: field1visible }
		EditTextLabel4421 { 
			id: inputField1 ; width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32; height: isNxt? 35:28;	leftTextAvailableWidth: isNxt? 100:80; 
			leftText: "";visible: (inputField1Text.visible); onClicked:{qkeyboard.open(fieldText1, inputField1.inputText, saveFieldData1)}
		}
		Text {id: inputField2Text;font.pixelSize: isNxt ? 18:14; font.family: qfont.semiBold.name ;text:fieldText2;visible: field2visible}
		EditTextLabel4421 { 
			id: inputField2 ; width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32; height: isNxt? 35:28;	leftTextAvailableWidth: isNxt? 100:80; 
			leftText: "";	visible: (inputField2Text.visible);	onClicked: {qkeyboard.open(fieldText2, inputField2.inputText, saveFieldData2)}
		}
		Text {id: inputField3Text;font.pixelSize: isNxt ? 18:14; font.family: qfont.semiBold.name ;text:fieldText3;visible: field3visible }
		EditTextLabel4421 { 
			id: inputField3 ; width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32; height: isNxt? 35:28;	leftTextAvailableWidth: isNxt? 100:80; 
			leftText: "";visible: (inputField3Text.visible);	onClicked: {qkeyboard.open(fieldText3, inputField3.inputText, saveFieldData3)}
		}
		Text {id: inputField4Text;font.pixelSize: isNxt ? 18:14; font.family: qfont.semiBold.name ;text:fieldText4;visible: field4visible}
		EditTextLabel4421 { 
			id: inputField4 ; width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32; height: isNxt? 35:28;	leftTextAvailableWidth: isNxt? 100:80; 
			leftText: ""; visible: (inputField4Text.visible); onClicked: {qkeyboard.open(fieldText4, inputField4.inputText, saveFieldData4)}
		}
		Text {id: inputField5Text;font.pixelSize: isNxt ? 18:14; font.family: qfont.semiBold.name ;text:fieldText5;visible: field5visible}
		EditTextLabel4421 { 
			id: inputField5 ; width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32; height: isNxt? 35:28;	leftTextAvailableWidth: isNxt? 100:80; 
			leftText: "";visible: (inputField5Text.visible);onClicked: {qkeyboard.open(fieldText5, inputField5.inputText, saveFieldData5)}
		}

	}


	Grid {
		id: gridContainer2
		columns: 1
		spacing: 2
		
		anchors {
			top: gridContainer1.bottom
			topMargin : 20			
			left : mytext1.left
		}
		
		NewTextLabel {
			id: updateText
			width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32
			height: isNxt ? 40:32
			buttonActiveColor: "lightgreen" ; buttonHoverColor: "blue";	enabled : true;	textColor : "black"
			buttonText:  "Controleer op updates voor " + app.selectedInverter
			onClicked: {checkforUpdates()}
			visible:   showUpdate
		}
		
		Text {
			id:oldversionText
			text: "Oude versie: " + oldversionTotal
			font.family: qfont.semiBold.name; font.pixelSize: isNxt ? 18:14	
			visible : showUpdate && updatechecked
		}
	
		Text {
			id: onlineversionText
			text: "Online versie: " + onlineversionTotal
			font.family: qfont.semiBold.name;font.pixelSize: isNxt ? 18:14
			visible : showUpdate && updatechecked
		}
	
		NewTextLabel {
			id: updatePluginText
			width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32
			height: isNxt ? 40:32
			buttonActiveColor: "lightgreen";buttonHoverColor: "blue";enabled : true;textColor : "black"
			buttonText:   "Update plugin " + app.selectedInverter 
			onClicked: {updatePlugin()}
			visible : !updated && showUpdate && updatepossible
		}
		
		NewTextLabel {
			id: forceupdatePluginText
			width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32
			height: isNxt ? 40:32
			buttonActiveColor: "lightgreen";buttonHoverColor: "blue";enabled : true;textColor : "black"
			buttonText:  "Forceer reload van "  + selectedInverter
			onClicked: {updatePlugin()}
			visible : showUpdate && !updatepossible
		}
		
		Text {
			id: updateSuccesText
			text: ""
			font.family: qfont.semiBold.name;font.pixelSize: isNxt ? 18:14
		}
	}


	function updatePlugin(){
		app.popupString = "Plugin ophalen voor " + selectedInverter + "..."
		app.solarRebootPopup.show()
		var onlinePluginFileName
		//get filename of installed inverter
		for(var x2 = 0;x2 < invertersNameArray.length;x2++){
			if (invertersNameArray[x2].toLowerCase()==selectedInverter.toLowerCase()){onlinePluginFileName = filenameArray[x2]}
		}
		needRestart = true
		if (debugOutput) console.log("*********SolarPanel downloading new inverter plugin")
		var http = new XMLHttpRequest()
		http.onreadystatechange=function() {
			if (http.readyState === 4){
				if (http.status === 200) {
					if (debugOutput) console.log("*********SolarPanel new Plugin: " + http.responseText)
					pluginFile.write(http.responseText)
					needRestart = true
					app.popupString = "Plugin opgehaald voor " + selectedInverter + "..." 
					oldversionTotal = onlineversionTotal
					oldversionText.text = "Oude versie: " + oldversionTotal +  " (geupdate, restart nodig)"
					app.solarRebootPopup.hide()
					//updated = true
					updateSucces = true
					needRestart = true
					updateSuccesText.text = "Update geslaagd"
				}
				else {
					if (debugOutput) console.log("*********SolarPanel error retrieving new Plugin: " + http.status)
					app.popupString = "Fout in ophalen van plugin" + "..." 
					updateSucces = false
					updateSuccesText.text = "Update mislukt"
					app.solarRebootPopup.hide()
				}
			}
		}
		if (debugOutput) console.log(pluginUrl + onlinePluginFileName+ ".plugin.txt")
		http.open("GET",pluginUrl + onlinePluginFileName+ ".plugin.txt"  , true)
		http.send()
	}

	
	function modRRDConfig(configChangeStep){
		var configfileString
		if (debugOutput) console.log("*********SolarPanel configChangeStep = " + configChangeStep)
		updateSucces = true
		switch (configChangeStep) {
		
			case 0: {
				console.log("*********SolarPanel show popup")
				app.popupString = "SolarPanel instellen en herstarten als nodig" + "..."
				app.solarRebootPopup.show()
				break;
			}
			
			case 1: {
				console.log("*********SolarPanel check Solar features in hcb_scsync ")
				try {
					var rewrite_hcb_scsync = false
					configfileString =  hcb_scsync_Configfile.read()
					oldConfigScsyncFileString = configfileString
					//console.log("*********SolarPanel configfileString : " + configfileString)
					var fl = configfileString.length
					var n201 = configfileString.indexOf('<SolarDisplay>')
					var n202 = configfileString.indexOf('</SolarDisplay>',n201)
					console.log("*********SolarPanel oldvalue of SolarDisplay: " + configfileString.substring(n201, n202))
					if (configfileString.substring(n201, n202) != "<SolarDisplay>1"){
						needReboot = true
						rewrite_hcb_scsync = true
						console.log("*********SolarPanel setting SolarDisplay to 1 ")
						var newconfigfileString = configfileString.substring(1, n201) + "<SolarDisplay>1" + configfileString.substring(n202, configfileString.length)
						configfileString = newconfigfileString
					}
					else{
						console.log("*********SolarPanel no need to update SolarDisplay")
					}

					var n203 = configfileString.indexOf('<SolarActivated>')
					var n204 = configfileString.indexOf('</SolarActivated>',n203)
					console.log("*********SolarPanel oldvalue of SolarDisplay: " + configfileString.substring(n203, n204))
					if (configfileString.substring(n203, n204) != "<SolarActivated>1"){
						needReboot = true
						rewrite_hcb_scsync = true
						console.log("*********SolarPanel setting SolarActivated to 1 ")
						var newconfigfileString = configfileString.substring(1, n203) + "<SolarActivated>1" + configfileString.substring(n204, configfileString.length)
						configfileString = newconfigfileString
					}
					else{
						console.log("*********SolarPanel no need to update SolarActivated")
					}
					if (rewrite_hcb_scsync){
						needReboot = true
						hcb_scsync_Configfile.write(newconfigfileString)
						console.log("*********SolarPanel new hcb_scsync saved")
						app.popupString = "Zon op Toon geactiveerd" + "..." 
					}
					else{
						console.log("*********SolarPanel no need to rewrite_hcb_scsync")
						app.popupString = "Zon op Toon was reeds geactiveerd" + "..." 
					}
				} catch(e) { }
				break;
			}
			
			
			case 2: {
				try {
					configfileString =  hcb_rrd_Configfile.read()
					if (configfileString.indexOf("<name>elec_produ_flow</name>") >-1) {
						console.log("*********SolarPanel not mergin production because database is available ")
						app.popupString = "Production databases reeds aanwezig" + "..." 
					}
					else{ //no production so lets create them
						console.log("*********SolarPanel needtochange part 1")
						needReboot = true
						var hcb_rrd_ConfigfileArray = configfileString.split("</Config>")
						var mergeFileString = mergeFile1.read()
						var newFileString = hcb_rrd_ConfigfileArray[0] + "" + mergeFileString
						hcb_rrd_Configfile.write(newFileString)
						app.popupString = "Production databases aangemaakt" + "..."
					}
				} catch(e) { }
				break;
			}
			
			case 3: {
				try {
					configfileString =  hcb_rrd_Configfile.read()
					if ((configfileString.indexOf("<name>elec_solar_quantity</name>") > -1 )  ||  (configfileString.indexOf("<name>elec_solar_quantity</name>") >-1)) {
						console.log("*********SolarPanel not mergin solar because database is available ")
						app.popupString = "Solar databases reeds aanwezig" + "..." 
					}
					else{//no solar so lets create them
						console.log("*********SolarPanel needtochange part 2")
						needReboot = true
						var hcb_rrd_ConfigfileArray = configfileString.split("</Config>")
						var mergeFileString = mergeFile2.read()
						var newFileString = hcb_rrd_ConfigfileArray[0] + "" + mergeFileString
						hcb_rrd_Configfile.write(newFileString)
						app.popupString = "Solar databases aangemaakt" + "..."
					}
				} catch(e) { }
			
				break;
			}
			
			case 4: {
				if (app.selectedInverter != selectedInverter){
					var onlinePluginFileName
					//get filename of installed inverter
					for(var x2 = 0;x2 < invertersNameArray.length;x2++){
						if (invertersNameArray[x2].toLowerCase()==selectedInverter.toLowerCase()){onlinePluginFileName = filenameArray[x2]}
						break;
					}
		
					needRestart = true
					console.log("*********SolarPanel downloading new inverter plugin")
					console.log("*********SolarPanel downloading new inverter plugin : " + pluginUrl + onlinePluginFileName+ ".plugin.txt")
					var http = new XMLHttpRequest()
					http.onreadystatechange=function() {
						if (http.readyState === 4){
							if (http.status === 200) {
								console.log("*********SolarPanel new Plugin: " + http.responseText)
								pluginFile.write(http.responseText)
								needRestart = true
								app.popupString = "Plugin opgehaald voor " + selectedInverter + "..." 
								updateSucces = true
								updateSuccesText.text = "Update geslaagd"
							}
							else {
								console.log("*********SolarPanel error retrieving new Plugin: " + http.status)
								app.popupString = "Fout in ophalen van plugin" + "..."  + http.status
								updateSucces = false
								updateSuccesText.text = "Update mislukt"
							}
						}
					}
					http.open("GET",pluginUrl + onlinePluginFileName+ ".plugin.txt"  , true)
					http.send()
					break;
				}
				else{
					console.log("*********SolarPanel inverter plugin does not have to change")
					app.popupString = "Omvormer niet gewijzigd" + "..." 
				}
				break;
			}
			
			case 5: {
				if (updated){
					needRestart = true
					app.popupString = "Plugin was geupdate voor " + selectedInverter + "..." 
				}
				else{
					app.popupString = "Plugin was niet geupdate voor " + selectedInverter + "..." 
				}
				break;
			}
			
			case 6: {
				console.log("*********SolarPanel save app setting")
				app.selectedInverter = selectedInverter
				app.passWord = tempPassWord
				app.userName = tempUserName
				app.siteID = tempSiteID
				app.apiKey = tempApiKey
				app.urlString = tempURL
				app.saveSettings()
				app.popupString = "Instellingen opgeslagen" + "..." 
				break;
			}
				
			case 7: {
				if (!needRestart && !needReboot) {
					console.log("*********SolarPanel no changes so no need to restart")
					app.popupString = "Restart niet nodig" + "..." 
					app.solarRebootPopup.hide()
					configChangeStep = 20
					stepRunning = false
					hide()
					break
				}
				break;
			}
			case 8: {
				if ((needRestart || needReboot) && updateSucces) {
					console.log("*********SolarPanel creating backup of config_rdd ")
					hcb_rrd_Configfile_bak.write(oldconfigfileString)
					app.popupString = "Backup van config_rdd maken" + "..." 
				}
				break;
			}
			case 9: {
				if  ((needRestart || needReboot) && updateSucces) {
					console.log("*********SolarPanel creating backup of config scsync ")
					hcb_scsync_Configfile_bak.write(oldConfigScsyncFileString)
					app.popupString = "Backup van config_scsync maken" + "..." 
				}
				break;
			}
			
			case 10: {
				if (needRestart && !needReboot && updateSucces ) {
					console.log("*********SolarPanel restart")
					console.log("*********SolarPanel restartingToon")
					app.popupString = "Herstarten van Toon" + "..." 
					app.solarRebootPopup.hide()
					Qt.quit();
				}
				break;
			}
			
			case 11: {
				if (needReboot && updateSucces) {
					console.log("*********SolarPanel reboot")
					console.log("*********SolarPanel restartingToon")
					app.popupString = "Rebooten van Toon" + "..." 
					app.solarRebootPopup.hide()
					app.restartToon()
				}
				break;
			}
			default: {
				console.log("*********SolarPanel to default case ")
				app.solarRebootPopup.hide()
				configChangeStep = 20
				stepRunning = false
				needReboot = false
				needRestart = false
				updateSuccesText.text = ""
				hide()
				break;
			}
		}
	}

	Timer {
		id: stepTimer   //interval to nicely save all and reboot
		interval: 2500
		repeat:true
		running: stepRunning 
		triggeredOnStart: true
		onTriggered: {
			modRRDConfig(configChangeStep)
			configChangeStep++
		}
    }
	
}

