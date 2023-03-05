import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0
import FileIO 1.0
import "SolarZonneplanProc.js" as SolarZonneplan

Screen {
	id: solarPanelConfigScreen
	screenTitle: "SolarPanel Configuratie"
	

	property variant invertersNameArray: []
	property variant filenameArray: []
	property variant dataStringArray: []
	property variant inputDataType: []
	property variant info: []
	
	property bool isDemoMode : false
	
	property url inverterUrl : "https://raw.githubusercontent.com/ToonSoftwareCollective/solarpanel-plugins/main/inverters.json"
	property url inverterTestUrl : "https://raw.githubusercontent.com/ToonSoftwareCollective/solarpanel-plugins/main/invertersTest.json"
	property url pluginUrl : "https://raw.githubusercontent.com/ToonSoftwareCollective/solarpanel-plugins/main/"
	
	property int numberofItems
	
	property string selectedInverter:app.selectedInverter
	property string selectedInverter2:app.selectedInverter2
	
	property string pluginFile : ""
	property string fieldText1 : "Wachtwoord :"
	property string fieldText2 : "Gebruikersnaam :"
	property string fieldText3 :  "SiteID:"
	property string fieldText4 : "API Key:"
	property string fieldText5 : "URL like \"192.168.10.5\":"
	property string fieldText6 : "IDX:"

	property string pluginFile2: ""
	property string fieldText21 : "Wachtwoord :"
	property string fieldText22 : "Gebruikersnaam :"
	property string fieldText23 :  "SiteID:"
	property string fieldText24 : "API Key:"
	property string fieldText25 : "URL like \"192.168.10.5\":"
	property string fieldText26 : "IDX:"
	
	property bool field1visible : false
	property bool field2visible : false
	property bool field3visible : false
	property bool field4visible : false
	property bool field5visible : false
	property bool field6visible : false
	
	
	property bool field1visible2 : false
	property bool field2visible2 : false
	property bool field3visible2 : false
	property bool field4visible2 : false
	property bool field5visible2 : false
	property bool field6visible2 : false
	
	
	property string tempPassWord : app.passWord
	property string tempUserName: app.userName
	property string tempSiteID: app.siteID
	property string tempApiKey: app.apiKey
	property string tempURL: app.urlString
	property string tempIDX: app.idx
	property string onlinePluginFileName : ""
	
	property string tempPassWord2 : app.passWord2
	property string tempUserName2: app.userName2
	property string tempSiteID2: app.siteID2
	property string tempApiKey2: app.apiKey2
	property string tempURL2: app.urlString2
	property string tempIDX2: app.idx2
	property string onlinePluginFileName2 : ""
	
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
	
	property bool updatepossible2 : false
	property string oldversionTotal2
	property string onlineversionTotal2
	property bool updatechecked2 : false
	property bool showUpdate2 : false
	property bool updated2 : false
	property bool updateSucces2 : false
	
	
	property bool inverterSel1Clicked : true
	property bool inverterSel2Clicked : false
	
	property bool wrongPlugin: false
	property bool wrongPlugin2: false
	
	property int tempInverterCount
	
	property bool debugOutput : app.debugOutput						// Show console messages. Turn on in settings file !
	
	property string sendMailText : "mail versturen"
	property string getPasseText : "Eerst mail versturen"
	

	FileIO {id: hcb_scsync_Configfile;	source: "file:///mnt/data/qmf/config/config_happ_scsync.xml"}
	FileIO {id: hcb_scsync_Configfile_bak;	source: "file:///mnt/data/qmf/config/config_happ_scsync.solarpanelbackup"}
	FileIO {id: hcb_rrd_Configfile;	source: "file:///qmf/config/config_hcb_rrd.xml"}
	FileIO {id: hcb_rrd_Configfile_bak;	source: "file:///qmf/config/config_hcb_rrd.solarpanelbackup"}
	FileIO {id: solarPanel_refreshtoken;	source: "file:///mnt/data/tsc/appData/solarPanel_refreshtoken.txt"}
	FileIO {id: mergeFile1;	source: "solarpanel_merge_prod.txt"}
	FileIO {id: mergeFile2;	source: "solarpanel_merge_solar.txt"}
	FileIO {id: pluginFile;	source: "SolarObjectPlugin.js"}
	FileIO {id: pluginFile2;source: "SolarObjectPlugin2.js"}

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
		inputField6.inputText = tempApiKey
		inputField21.inputText = tempPassWord2
		inputField22.inputText = tempUserName2
		inputField23.inputText = tempSiteID2
		inputField24.inputText = tempApiKey2
		inputField25.inputText = tempURL2
		inputField26.inputText = tempApiKey2
		if (app.inverterCount >1){tempInverterCount = 2 ;inverterCountToggle.isSwitchedOn = true}else{tempInverterCount = 1;inverterCountToggle.isSwitchedOn = false}
	}

	onCustomButtonClicked: {
		configChangeStep = 0
		stepRunning  = true
	}

/////////////////////////////////////////////////////// ADD ALL INVERTERS TO THE LIST ///////////////////////////////////////////////
	function fillInverters(){
		numberofItems =  invertersNameArray.length
		model.clear()
		for(var x1 = 0;x1 < invertersNameArray.length;x1++){
				listview1.model.append({name: invertersNameArray[x1]})
		}
		
	}
/////////////////////////////////////////////////////// GET INVERTERS FROM THE INTERNET  ///////////////////////////////////////////////	
	function getInverters(){
		if (invertersNameArray.length < 1 || manual){
			manual = false 
			var http = new XMLHttpRequest()
			http.onreadystatechange=function() {
				if (http.readyState === 4){
					if (http.status === 200 || http.status === 300  || http.status === 302) {
						model.clear()
						invertersNameArray= []
						inputDataType =[]
						filenameArray = []						
						var JsonString = http.responseText
						if (debugOutput) console.log("responsetext: " +  http.responseText)
						var JsonObject= JSON.parse(JsonString)
						var invertersArray = JsonObject.plugins
						numberofItems =  invertersArray.length
						for (var i in invertersArray){
							info[i] = invertersArray[i].info
							invertersNameArray[i] = invertersArray[i].friendlyName
							filenameArray[i] = invertersArray[i].filename
							inputDataType[i] = invertersArray[i].data
						}
						resumefromHttpRequest()
					}
					else {
						if (debugOutput) console.log("*********SolarPanel error: " + http.status)
					}
				}
			}
			if (isDemoMode){
				selectedInverter=""
				selectedInverter2=""
				http.open("GET",inverterTestUrl, true)
			}else{
				http.open("GET",inverterUrl, true)
			}
			http.send()
		}	
	}

/////////////////////////////////////////////////////// AFTER INVERTERS ARE FETCHED FROM THE INTERNET ///////////////////////////////////////////////

	function resumefromHttpRequest(){
		console.log("*********SolarPanel gselectedInverter : " + selectedInverter)
		enableSleepToggle.isSwitchedOn = app.enableSleep
		addCustomTopRightButton("Opslaan")
		fillInverters()
		if (app.inverterCount == 2){
			tempPassWord2 = app.passWord2
			tempUserName2 = app.userName2
			tempApiKey2 = app.apiKey2 
			tempSiteID2= app.siteID2
			tempURL2 = app.urlString2
			tempIDX2 = app.apiKey2
			setFieldText2()
		}
		tempPassWord = app.passWord
		tempUserName = app.userName
		tempApiKey = app.apiKey 
		tempSiteID= app.siteID
		tempURL = app.urlString
		tempIDX = app.apiKey
		setFieldText()
	}

/////////////////////////////////////////////////////// CREATE INPUTFIELDS DEPENDANT ON THER "DATA" FIELD ///////////////////////////////////////////////
	function setFieldText() {
		console.log("*********SolarPanel gselectedInverter : " + selectedInverter)
		for(var x2 = 0;x2 < invertersNameArray.length;x2++){
			if (invertersNameArray[x2].toLowerCase()==selectedInverter.toLowerCase()){listview1.currentIndex = x2 }
		}
		field1visible = ((inputDataType[listview1.currentIndex]).toString().toLowerCase().indexOf('ass')>-1)
		field2visible = ((inputDataType[listview1.currentIndex]).toString().toLowerCase().indexOf('use')>-1)
		field3visible = ((inputDataType[listview1.currentIndex]).toString().toLowerCase().indexOf('iteid')>-1)
		field4visible = ((inputDataType[listview1.currentIndex]).toString().toLowerCase().indexOf('api')>-1)
		field5visible = ((inputDataType[listview1.currentIndex]).toString().toLowerCase().indexOf('url')>-1)
		field6visible = ((inputDataType[listview1.currentIndex]).toString().toLowerCase().indexOf('idx')>-1)
	}
	
	function setFieldText2() {
		for(var x2 = 0;x2 < invertersNameArray.length;x2++){
			if (invertersNameArray[x2].toLowerCase()==selectedInverter2.toLowerCase()){ listview1.currentIndex = x2}
		}
		field1visible2 = ((inputDataType[listview1.currentIndex]).toString().toLowerCase().indexOf('ass')>-1)
		field2visible2 = ((inputDataType[listview1.currentIndex]).toString().toLowerCase().indexOf('use')>-1)
		field3visible2 = ((inputDataType[listview1.currentIndex]).toString().toLowerCase().indexOf('iteid')>-1)
		field4visible2 = ((inputDataType[listview1.currentIndex]).toString().toLowerCase().indexOf('api')>-1)
		field5visible2 = ((inputDataType[listview1.currentIndex]).toString().toLowerCase().indexOf('url')>-1)
		field6visible2 = ((inputDataType[listview1.currentIndex]).toString().toLowerCase().indexOf('idx')>-1)
		field7visible2 = ((inputDataType[listview1.currentIndex]).toString().toLowerCase().indexOf('info')>-1)
	}

/////////////////////////////////////////////////////// SAVE DATA TO TEMPS WHEN SAVE IS CLICKED ON AN INPUTFIELD ///////////////////////////////////////////////

	function saveFieldData1(text) {	tempPassWord = text	}
	function saveFieldData2(text) {	tempUserName= text	}
	function saveFieldData3(text) {	tempSiteID= text	}
	function saveFieldData4(text) {	tempApiKey= text	}
	function saveFieldData5(text) {	tempURL= text		}	
	function saveFieldData6(text) {	tempApiKey= text		}	
	function saveFieldData21(text) {tempPassWord2 = text}	
	function saveFieldData22(text) {tempUserName2= text	}
	function saveFieldData23(text) {tempSiteID2= text	}
	function saveFieldData24(text) {tempApiKey2= text	}
	function saveFieldData25(text) {tempURL2= text}
	function saveFieldData26(text) {tempApiKey2= text}	
	

/////////////////////////////////////////////////////// CHECK FOR UPDATES ///////////////////////////////////////////////
	function checkforUpdates(){
		//check current version
		updatechecked = true
		var oldPluginFileString = pluginFile.read()
		var n1 = oldPluginFileString.indexOf('<version>')
		var n2 = oldPluginFileString.indexOf('</version>',n1)
		oldversionTotal =  (oldPluginFileString.substring(n1 + 9, n2)).trim()	
		
		//get filename of installed inverter
		for(var x2 = 0;x2 < invertersNameArray.length;x2++){
			if (invertersNameArray[x2].toLowerCase()==app.selectedInverter.toLowerCase()){onlinePluginFileName = filenameArray[x2]}
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

	function checkforUpdates2(){
		//check current version
		updatechecked2 = true
		var oldPluginFileString = pluginFile2.read()
		var n1 = oldPluginFileString.indexOf('<version>')
		var n2 = oldPluginFileString.indexOf('</version>',n1)
		oldversionTotal2 =  (oldPluginFileString.substring(n1 + 9, n2)).trim()	
		
		//get filename of installed inverter
		for(var x2 = 0;x2 < invertersNameArray.length;x2++){
			if (invertersNameArray[x2].toLowerCase()==app.selectedInverter2.toLowerCase()){onlinePluginFileName2 = filenameArray[x2]}
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
					onlineversionTotal2 =  (onlinePluginFileString.substring(n1 + 9, n2)).trim()			
					compareVersions2(oldversionTotal2,onlineversionTotal2)
				}
				else {
					if (debugOutput) console.log("*********SolarPanel error retrieving new Plugin2: " + http.status)
				}
			}
		}
		console.log(pluginUrl + onlinePluginFileName2 + ".plugin.txt")
		http.open("GET",pluginUrl + onlinePluginFileName2 + ".plugin.txt"  , true)
		http.send()
	}	
/////////////////////////////////////////////////////// CHECK DIFFERENCE BETWEEN VERSIONS ///////////////////////////////////////////////

	function compareVersions(oldversionTotal,onlineversionTotal){
		updatepossible = false
		var oldversionArray = oldversionTotal.split(".")
		if(typeof(oldversionArray[2]) == "undefined"){oldversionTotal = "0.0.0" ; oldversionArray[0] = 0 ;  oldversionArray[1] = 0  ;  oldversionArray[2] = 0 }
		oldversionText.text =  "Oude versie: " + oldversionTotal
		var onlineversionArray = onlineversionTotal.split(".")
		if(typeof(onlineversionArray[2]) == "undefined"){onlineversionTotal = "0.0.0" ; onlineversionArray[0] = 0 ;  onlineversionArray[1] = 0  ;  onlineversionArray[2] = 0 }

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

	function compareVersions2(oldversionTotal2,onlineversionTotal2){
		updatepossible2 = false
		if (debugOutput) console.log("*********SolarPanel oldvalue of Plugin2 : " + oldversionTotal2)
		var oldversionArray2 = oldversionTotal2.split(".")
		if(typeof(oldversionArray2[2]) == "undefined"){oldversionTotal2 = "0.0.0" ; oldversionArray2[0] = 0 ;  oldversionArray2[1] = 0  ;  oldversionArray2[2] = 0 }
		oldversionText2.text =  "Oude versie: " + oldversionTotal2
		var onlineversionArray2 = onlineversionTotal2.split(".")
		if(typeof(onlineversionArray2[2]) == "undefined"){onlineversionTotal2 = "0.0.0" ; onlineversionArray2[0] = 0 ;  onlineversionArray2[1] = 0  ;  onlineversionArray2[2] = 0 }
		//compare versions
		if (parseInt(onlineversionArray2[0]) > parseInt(oldversionArray2[0])) {
			updatepossible2 = true
		}
		if (!updatepossible2 && (parseInt(onlineversionArray2[1]) > parseInt(oldversionArray2[1]))) {
			updatepossible2 = true
		}
		if (!updatepossible2 && (parseInt(onlineversionArray2[2]) > parseInt(oldversionArray2[2]))) {
			updatepossible2 = true
		}
	}
	
/////////////////////////////////////////////////////// UPDATE PLUGIN ///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	function updatePlugin(){
		app.popupString = "Plugin ophalen voor " + selectedInverter + "..."
		app.solarRebootPopup.show()
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
					updated = true
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


	function updatePlugin2(){
		app.popupString = "Plugin ophalen voor " + selectedInverter2 + "..."
		app.solarRebootPopup.show()
		//get filename of installed inverter
		for(var x2 = 0;x2 < invertersNameArray.length;x2++){
			if (invertersNameArray[x2].toLowerCase()==selectedInverter2.toLowerCase()){onlinePluginFileName2 = filenameArray[x2]}
		}
		needRestart = true
		if (debugOutput) console.log("*********SolarPanel downloading new inverter plugin")
		var http = new XMLHttpRequest()
		http.onreadystatechange=function() {
			if (http.readyState === 4){
				if (http.status === 200) {
					if (debugOutput) console.log("*********SolarPanel new Plugin: " + http.responseText)
					pluginFile2.write(http.responseText)
					app.popupString = "Plugin opgehaald voor " + selectedInverter2 + "..." 
					oldversionTotal2 = onlineversionTotal2
					oldversionText2.text = "Oude versie: " + oldversionTotal2 +  " (geupdate, restart nodig)"
					app.solarRebootPopup.hide()
					updated2 = true
					updateSucces2 = true
					needRestart = true
					updateSuccesText2.text = "Update geslaagd"
				}
				else {
					if (debugOutput) console.log("*********SolarPanel error retrieving new Plugin: " + http.status)
					app.popupString = "Fout in ophalen van plugin" + "..." 
					updateSucces2 = false
					updateSuccesText2.text = "Update mislukt"
					app.solarRebootPopup.hide()
				}
			}
		}
		if (debugOutput) console.log(pluginUrl + onlinePluginFileName2+ ".plugin.txt")
		http.open("GET",pluginUrl + onlinePluginFileName2+ ".plugin.txt"  , true)
		http.send()
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////// START GUI ///////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	Text {
		id: mytexttop1
		text: "Selecteer je inverter(s) en vul je gegevens in."
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
		id: inverterCountText
		width:  isNxt? 160:128
		text: "Aantal inverters :   1"
		font.pixelSize:  isNxt ? 18 : 14
		font.family: qfont.semiBold.name
		anchors {
			left: mytexttop1.left
			top: mytexttop1.bottom
			topMargin: isNxt? 8 : 6
		}
	}

	OnOffToggle {
		id: inverterCountToggle
		height:  30
		anchors {
			left: inverterCountText.right
			top: inverterCountText.top
			leftMargin: isNxt ? 20:16
		}
		leftIsSwitchedOn: false
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				tempInverterCount = 2
			} else {
				tempInverterCount = 1
			}
		}
	}
	
	Text {
		id: inverterCountText2
		width:  isNxt? 20:16
		text: " 2"
		font.pixelSize:  isNxt ? 18 : 14
		font.family: qfont.semiBold.name
		anchors {
			left: inverterCountToggle.right
			leftMargin: isNxt ? 10 : 8
			top: inverterCountText.top
		}
	}
	
	Text {
		id: mytexttop2
		text: "Selecteer jouw inverter:"
		font {
			family: qfont.semiBold.name
			pixelSize: isNxt ? 18:14
		}
		anchors {
			top:inverterCountText.bottom
			left:mytexttop1.left
			topMargin: isNxt? 8 : 6
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
				height: isNxt ? 20 : 16
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
				topMargin:isNxt ? 16 : 12
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

/////////////////////////////////////////////////////////////////////////////////////////////////////////

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

	Text {
		id: helpText1
		text: "Druk een van de groene knopjes hieronder na selecteren van de juiste omvormer"
		wrapMode: Text.WordWrap
		width : isNxt ? parent.width/2 - 100 : parent.width/2 - 80
		font {
			family: qfont.semiBold.name
			pixelSize: isNxt ? 18:14
		}
		anchors {
			top:listviewContainer1.bottom
			left:mytexttop1.left
			topMargin: isNxt? 5: 4
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
		buttonText:  "Selecteer 1"
		anchors {
			top: helpText1.bottom
			left: listviewContainer1.left
			topMargin: isNxt? 5: 4
			}
		onClicked: {
			inverterSel1Clicked = true
			inverterSel2Clicked = false
			selectedInverter = invertersNameArray[listview1.currentIndex]
			
			if (app.selectedInverter == selectedInverter){
				showUpdate = true
			}else{
				showUpdate = false
			}
			
			if (selectedInverter == "Zonneplan"){
				app.zonneplan=true
			}else{
			    app.zonneplan=false
			}
			
			if (selectedInverter != listview1.name){
				setFieldText()
			}
			
		}
	}
	
	NewTextLabel {
		id: selText2
		width: isNxt ? 120 : 96;  
		height: isNxt ? 40:32
		buttonActiveColor: "lightgreen"
		buttonHoverColor: "blue"
		enabled : true
		textColor : "black"
		buttonText:  "Selecteer 2"
		anchors {
			top: selText.top
			right: listviewContainer1.right
			}
		onClicked: {
			inverterSel1Clicked = false
			inverterSel2Clicked = true
			selectedInverter2 = invertersNameArray[listview1.currentIndex]
			if (app.selectedInverter2 == selectedInverter2){
				showUpdate2 = true
			}else{
				showUpdate2 = false 
			}
			
			if (selectedInverter2 != listview1.name){
				setFieldText2()
			}
		}
		visible : (tempInverterCount == 2 & !app.zonneplan)
	}
///////////////////////////////////////////// SELECTED ///////////////////////////////////////////////////////////////////////////////
	Text {
		id: showInSleep
		width:  isNxt? 160:128
		text: "Zichtbaar in gedimde mode: "
		font.pixelSize:  isNxt ? 18 : 14
		font.family: qfont.semiBold.name
		anchors {
			left: listviewContainer1.left
			top: selText.bottom
			topMargin: isNxt? 8 : 6
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
			topMargin: isNxt? 8 : 6
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
	
	Text {
		id: select1
		text:  (selectedInverter.length >2 ) ? "Gelecteerde omvormer 1: " + selectedInverter : "Gelecteerd omvormer 1: " +"n/a"
		font {
			family: qfont.semiBold.name
			pixelSize: isNxt ? 24:18
		}
		anchors {
			bottom:parent.bottom
			left: enablePolling.left
			bottomMargin: isNxt? 8 : 6
		}
	}
	
	Text {
		id: select2
		text:  (selectedInverter2.length >2 ) ? "Gelecteerde omvormer 2: " + selectedInverter2 : "Gelecteerd omvormer 2: " +"n/a"
		font {
			family: qfont.semiBold.name
			pixelSize: isNxt ? 24:18
		}
		anchors {
			top: select1.bottom
			left: select1.left
		}
		visible : (tempInverterCount == 2)
	}
	
	
	
////////////////////////////////////////////// SELECTED 1 ///////////////////////////////////////////////////////////////////////////////

	Text {
		id: mytext1
		text: "Geselecteerd 1: "
		font {
			family: qfont.semiBold.name
			pixelSize: isNxt ? 18:14
		}
		anchors {
			top: mytexttop1.top
			left:upButton.right
			leftMargin:isNxt ? 140:112
		}
		visible: (selectedInverter.length>2) & !inverterSel2Clicked & inverterSel1Clicked
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
			leftMargin: isNxt ? 20:16
		}
		visible: (selectedInverter.length>2) & !inverterSel2Clicked & inverterSel1Clicked
	}
	
	Text {
		id: infoText1
		text: "info"
		font {
			family: qfont.semiBold.name
			pixelSize: isNxt ? 18:14
		}
		anchors {
			top: mytext1.bottom
			topMargin: isNxt ? 10:8
			left: mytext1.left
		}
		visible: selectedInverter.length>2 && info[listview1.currentIndex].length>2
	}
	
	Text {
		id: infoText2
		width: parent.width/2
		wrapMode: Text.WordWrap
		text:info[listview1.currentIndex]
		font {
			family: qfont.semiBold.name
			pixelSize: isNxt ? 18:14
		}
		anchors {
			top: infoText1.bottom
			left: mytext1.left
		}
		visible:  selectedInverter.length>2
	}	
	
	
	Grid {
		id: gridContainer1
		columns: 1
		spacing: 2
		visible: (selectedInverter.length>2) & !inverterSel2Clicked & inverterSel1Clicked
		anchors {
			top: infoText2.bottom
			topMargin: isNxt ? 10:8
			left : mytext1.left
		}

		//username
		Text {id: inputField2Text;font.pixelSize: isNxt ? 18:14; font.family: qfont.semiBold.name ;text:fieldText2;visible: field2visible}
		EditTextLabel4421 {  
			id: inputField2 ; width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32; height: isNxt? 35:28;	leftTextAvailableWidth: isNxt? 100:80; 
			leftText: "";	visible: (inputField2Text.visible);	onClicked: {qkeyboard.open(fieldText2, inputField2.inputText, saveFieldData2)}
		}
		//password
		Text {id: inputField1Text;font.pixelSize: isNxt ? 18:14; font.family: qfont.semiBold.name ;text:fieldText1;visible: field1visible }
		EditTextLabel4421 { 
			id: inputField1 ; width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32; height: isNxt? 35:28;	leftTextAvailableWidth: isNxt? 100:80; 
			leftText: "";visible: (inputField1Text.visible); onClicked:{qkeyboard.open(fieldText1, inputField1.inputText, saveFieldData1)}
		}
		//siteid
		Text {id: inputField3Text;font.pixelSize: isNxt ? 18:14; font.family: qfont.semiBold.name ;text:fieldText3;visible: field3visible }
		EditTextLabel4421 { 
			id: inputField3 ; width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32; height: isNxt? 35:28;	leftTextAvailableWidth: isNxt? 100:80; 
			leftText: "";visible: (inputField3Text.visible);	onClicked: {qkeyboard.open(fieldText3, inputField3.inputText, saveFieldData3)}
		}
		//apikey
		Text {id: inputField4Text;font.pixelSize: isNxt ? 18:14; font.family: qfont.semiBold.name ;text:fieldText4;visible: field4visible}
		EditTextLabel4421 { 
			id: inputField4 ; width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32; height: isNxt? 35:28;	leftTextAvailableWidth: isNxt? 100:80; 
			leftText: ""; visible: (inputField4Text.visible); onClicked: {qkeyboard.open(fieldText4, inputField4.inputText, saveFieldData4)}
		}
		//url
		Text {id: inputField5Text;font.pixelSize: isNxt ? 18:14; font.family: qfont.semiBold.name ;text:fieldText5;visible: field5visible}
		EditTextLabel4421 { 
			id: inputField5 ; width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32; height: isNxt? 35:28;	leftTextAvailableWidth: isNxt? 100:80; 
			leftText: "";visible: (inputField5Text.visible);onClicked: {qkeyboard.open(fieldText5, inputField5.inputText, saveFieldData5)}
		}
		//idx
		Text {id: inputField6Text;font.pixelSize: isNxt ? 18:14; font.family: qfont.semiBold.name ;text:fieldText6;visible: field6visible}
		EditTextLabel4421 { 
			id: inputField6 ; width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32; height: isNxt? 35:28;	leftTextAvailableWidth: isNxt? 100:80; 
			leftText: "";visible: (inputField6Text.visible);onClicked: {qkeyboard.open(fieldText6, inputField6.inputText, saveFieldData6)}
		}

	}

	Grid {
		id: gridContainer2
		columns: 1
		spacing: 2
		visible: (selectedInverter.length>2) & !inverterSel2Clicked & inverterSel1Clicked
		anchors {
			top: gridContainer1.bottom
			topMargin: isNxt ? 10:8	
			left : mytext1.left
		}
		
		NewTextLabel {
			id: sendMail
			width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32
			height: isNxt ? 40:32
			buttonActiveColor: "lightgreen" ; buttonHoverColor: "blue";	enabled : true;	textColor : "black"
			buttonText:  sendMailText
			onClicked: SolarZonneplan.sendZonneplanMailRequest(inputField2.inputText)
			visible:   app.zonneplan
		}
		
		
		NewTextLabel {
			id: getPassw
			width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32
			height: isNxt ? 40:32
			buttonActiveColor: "lightgreen" ; buttonHoverColor: "blue";	enabled : true;	textColor : "black"
			buttonText:  getPasseText
			onClicked: SolarZonneplan.getPassword(inputField2.inputText)
			visible:   app.zonneplan
		}

		
		NewTextLabel {
			id: updateText
			width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32
			height: isNxt ? 40:32
			buttonActiveColor: "lightgreen" ; buttonHoverColor: "blue";	enabled : true;	textColor : "black"
			buttonText:  "Controleer op updates voor " + app.selectedInverter
			onClicked: {checkforUpdates()}
			visible: showUpdate
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
			visible :  showUpdate && updatepossible
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

/////////////////////////////////////////////////////////////// INVERTER 2 //////////////////////////////////////////////////////////////////

	Text {
		id: mytext12
		text: "Geselecteerd 2: "
		font {
			family: qfont.semiBold.name
			pixelSize: isNxt ? 18:14
		}
		anchors {
			top: mytext1.top
			left:mytext1.left
		}
		visible: (selectedInverter2.length>2) & inverterSel2Clicked & !inverterSel1Clicked
	}
	
	
	Text {
		id: selectedText2
		text: selectedInverter2
		font {
			family: qfont.semiBold.name
			pixelSize: isNxt ? 24:18
		}
		anchors {
			bottom: mytext12.bottom
			left: mytext12.right
			leftMargin: 20
		}
		visible: (selectedInverter2.length>2) & inverterSel2Clicked & !inverterSel1Clicked
	}


	Grid {
		id: gridContainer12
		columns: 1
		spacing: 2
		visible: (selectedInverter2.length>2) & inverterSel2Clicked & !inverterSel1Clicked
		
		anchors {
			top: gridContainer1.top
			left : gridContainer1.left

		}		
		//username
		Text {id: inputField2Text2;font.pixelSize: isNxt ? 18:14; font.family: qfont.semiBold.name ;text:fieldText22;visible: field2visible2}
		EditTextLabel4421 { 
			id: inputField22 ; width: isNxt?  parent.width - mytext12.left - 40 : parent.width - mytext12.left - 32; height: isNxt? 35:28;	leftTextAvailableWidth: isNxt? 100:80; 
			leftText: "";	visible: (inputField2Text2.visible);	onClicked: {qkeyboard.open(fieldText22, inputField22.inputText, saveFieldData22)}
		}
		//password
		Text {id: inputField1Text2;font.pixelSize: isNxt ? 18:14; font.family: qfont.semiBold.name ;text:fieldText21;visible: field1visible2 }
		EditTextLabel4421 { 
			id: inputField21 ; width: isNxt?  parent.width - mytext12.left - 40 : parent.width - mytext12.left - 32; height: isNxt? 35:28;	leftTextAvailableWidth: isNxt? 100:80; 
			leftText: "";visible: (inputField1Text2.visible); onClicked:{qkeyboard.open(fieldText21, inputField21.inputText, saveFieldData21)}
		}
		//siteid
		Text {id: inputField3Text2;font.pixelSize: isNxt ? 18:14; font.family: qfont.semiBold.name ;text:fieldText23;visible: field3visible2 }
		EditTextLabel4421 { 
			id: inputField23 ; width: isNxt?  parent.width - mytext12.left - 40 : parent.width - mytext12.left - 32; height: isNxt? 35:28;	leftTextAvailableWidth: isNxt? 100:80; 
			leftText: "";visible: (inputField3Text2.visible);	onClicked: {qkeyboard.open(fieldText23, inputField23.inputText, saveFieldData23)}
		}
		//apikey
		Text {id: inputField4Text2;font.pixelSize: isNxt ? 18:14; font.family: qfont.semiBold.name ;text:fieldText24;visible: field4visible2}
		EditTextLabel4421 { 
			id: inputField24 ; width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext12.left - 32; height: isNxt? 35:28;	leftTextAvailableWidth: isNxt? 100:80; 
			leftText: ""; visible: (inputField4Text2.visible); onClicked: {qkeyboard.open(fieldText24, inputField24.inputText, saveFieldData24)}
		}
		//url
		Text {id: inputField5Text2;font.pixelSize: isNxt ? 18:14; font.family: qfont.semiBold.name ;text:fieldText25;visible: field5visible2}
		EditTextLabel4421 { 
			id: inputField25 ; width: isNxt?  parent.width - mytext12.left - 40 : parent.width - mytext12.left - 32; height: isNxt? 35:28;	leftTextAvailableWidth: isNxt? 100:80; 
			leftText: "";visible: (inputField5Text2.visible);onClicked: {qkeyboard.open(fieldText25, inputField25.inputText, saveFieldData25)}
		}
		//idx
		Text {id: inputField6Text2;font.pixelSize: isNxt ? 18:14; font.family: qfont.semiBold.name ;text:fieldText26;visible: field6visible2}
		EditTextLabel4421 { 
			id: inputField26 ; width: isNxt?  parent.width - mytext12.left - 40 : parent.width - mytext12.left - 32; height: isNxt? 35:28;	leftTextAvailableWidth: isNxt? 100:80; 
			leftText: "";visible: (inputField6Text2.visible);onClicked: {qkeyboard.open(fieldText26, inputField26.inputText, saveFieldData26)}
		}
		
	}

	Grid {
		id: gridContainer22
		columns: 1
		spacing: 2
		visible: (selectedInverter2.length>2) & inverterSel2Clicked & !inverterSel1Clicked
		
		anchors {
			top: gridContainer12.bottom
			topMargin : 20			
			left : mytext12.left
		}
		
		NewTextLabel {
			id: updateText2
			width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext12.left - 32
			height: isNxt ? 40:32
			buttonActiveColor: "lightgreen" ; buttonHoverColor: "blue";	enabled : true;	textColor : "black"
			buttonText:  "Controleer op updates voor " + app.selectedInverter2
			onClicked: {checkforUpdates2()}
			visible:   showUpdate2
		}
		
		Text {
			id:oldversionText2
			text: "Oude versie: " + oldversionTotal2
			font.family: qfont.semiBold.name; font.pixelSize: isNxt ? 18:14	
			visible : showUpdate2 && updatechecked2
		}
	
		Text {
			id: onlineversionText2
			text: "Online versie: " + onlineversionTotal2
			font.family: qfont.semiBold.name;font.pixelSize: isNxt ? 18:14
			visible : showUpdate2 && updatechecked2
		}
	
		NewTextLabel {
			id: updatePluginText2
			width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext12.left - 32
			height: isNxt ? 40:32
			buttonActiveColor: "lightgreen";buttonHoverColor: "blue";enabled : true;textColor : "black"
			buttonText:   "Update plugin " + app.selectedInverter2
			onClicked: {updatePlugin2()}
			visible :  showUpdate2 && updatepossible2
		}
		
		NewTextLabel {
			id: forceupdatePluginText2
			width: isNxt?  parent.width - mytext1.left - 40 : parent.width - mytext1.left - 32
			height: isNxt ? 40:32
			buttonActiveColor: "lightgreen";buttonHoverColor: "blue";enabled : true;textColor : "black"
			buttonText:  "Forceer reload van "  + selectedInverter2
			onClicked: {updatePlugin2()}
			visible : showUpdate2 && !updatepossible2 
		}
		
		Text {
			id: updateSuccesText2
			text: ""
			font.family: qfont.semiBold.name;font.pixelSize: isNxt ? 18:14
		}
		
	}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////// CHECK AND SAVE ALL WHEN OPSLAN IS CLICKED ///////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	function modRRDConfig(configChangeStep){
		var configfileString
		
		if (debugOutput) console.log("*********SolarPanel configChangeStep = " + configChangeStep)
		updateSucces = true
		switch (configChangeStep) {
		
			case 0: {
				console.log("*********SolarPanel show popup")
				app.popupString = "SolarPanel instellen en herstarten als nodig" + "..."
				app.solarRebootPopup.show()
				
				//prepare steps
				for(var x2 = 0;x2 < invertersNameArray.length;x2++){
					if (invertersNameArray[x2].toLowerCase()==selectedInverter.toLowerCase()){
						onlinePluginFileName = filenameArray[x2]
					}
				}
				
				//get the name off the currently installed inverter
				var pluginFileString  = ""
				try {pluginFileString = pluginFile.read() } catch(e) {}
				if (pluginFileString.indexOf(onlinePluginFileName)<0 || selectedInverter==""  || onlinePluginFileName =="" ){//wrong plugin
					wrongPlugin = true
				}else{
					wrongPlugin = false
				}

				for(var x2 = 0;x2 < invertersNameArray.length;x2++){
					if (invertersNameArray[x2].toLowerCase()==selectedInverter2.toLowerCase()){
						onlinePluginFileName2 = filenameArray[x2]
					}
				}
				
				//get the name off the currently installed inverter
				var pluginFileString2  = ""
				try {pluginFileString2 = pluginFile2.read() } catch(e) {}
				if (pluginFileString2.indexOf(onlinePluginFileName2)<0 || selectedInverter2==""  || onlinePluginFileName2 =="" ){//wrong plugin
					wrongPlugin2 = true
				}else{
					wrongPlugin2 = false
				}
				
				
				if (app.pluginWarning.length > 2){needRestart = true}
				
				break;
			}
		
			case 1: {
				break;
			}
			
			case 2: {
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
						var newconfigfileString = configfileString.substring(0, n201) + "<SolarDisplay>1" + configfileString.substring(n202, configfileString.length)
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
						var newconfigfileString = configfileString.substring(0, n203) + "<SolarActivated>1" + configfileString.substring(n204, configfileString.length)
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
			
			
			case 3: {
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
			
			case 4: {
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
			
			
			case 5: {
				var rewrite_hcb_rrd = false
				try {
					configfileString =  hcb_rrd_Configfile.read()
					oldConfigScsyncFileString = configfileString
					//console.log("*********SolarPanel configfileString : " + configfileString)
					var fl = configfileString.length
					var n100 = configfileString.indexOf('<name>elec_solar_quantity</name>')
					var n101 = configfileString.indexOf('</rrdLogger>',n100)	
					var n150 = (configfileString.substring(n100, n101)).indexOf('<futureBins>')
					
					if (n150<0){ // futurebins is not in the rrd solar
					    console.log("*********SolarPanel writing setting futureBins to 1 ")
						rewrite_hcb_rrd = true
						var n151 = configfileString.indexOf('<name>5yrhours</name>',n100)
						var n152  = n151 + ('<name>5yrhours</name>').length
						var newconfigfileString = configfileString.substring(0, n151) + "<futureBins>1</futureBins><name>5yrhours</name>" + configfileString.substring(n152, configfileString.length)
					
						
						var n161 = newconfigfileString.indexOf('<name>10yrdays</name>',n100)
						var n162  = n161 + ('<name>10yrdays</name>').length
						var newconfigfileString2 = newconfigfileString.substring(0, n161) + "<futureBins>1</futureBins><name>10yrdays</name>" + newconfigfileString.substring(n162, newconfigfileString.length)
						configfileString = newconfigfileString2
					}

					else {
						var n200 = configfileString.indexOf('<futureBins>',n100)
						var n201 = configfileString.indexOf('</futureBins>',n200)
						console.log("*********SolarPanel <futureBins> : " + configfileString.substring(n200, n201))
						
						if (configfileString.substring(n200, n201) == "<futureBins>0"){
							rewrite_hcb_rrd = true
							console.log("*********SolarPanel setting futureBins to 1 ")
							var newconfigfileString = configfileString.substring(0, n200) + "<futureBins>1" + configfileString.substring(n201, configfileString.length)
							configfileString = newconfigfileString
						}
						var n203 = configfileString.indexOf('<futureBins>',n201)
						var n204 = configfileString.indexOf('</futureBins>',n203)
						console.log("*********SolarPanel <futureBins>: " + configfileString.substring(n203, n204))
						
						if (configfileString.substring(n203, n204) == "<futureBins>0"){
							rewrite_hcb_rrd = true
							console.log("*********SolarPanel setting futureBins to 1 ")
							var newconfigfileString = configfileString.substring(0, n203) + "<futureBins>1" + configfileString.substring(n204, configfileString.length)
							configfileString = newconfigfileString
						}
					}
					
					if (rewrite_hcb_rrd){
						needReboot = true
						//console.log("*********SolarPanel configfileString : " + configfileString)
						hcb_rrd_Configfile.write(configfileString)
						app.popupString = "Solar databases aangepast voor FutureBins" + "..."
					}
					else{
						console.log("*********SolarPanel no need to rewrite hcb_rrd")
						app.popupString = "FutureBins stonden reeds op 1" + "..." 
					}
				} catch(e) { }
				break;
			}

			
			case 6: {
				if (app.selectedInverter != selectedInverter  || wrongPlugin){
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
								app.popupString = "Plugin 1 opgehaald voor : " + selectedInverter + "..." 
								updateSucces = true
								updated = true
							}
							else {
								console.log("*********SolarPanel error retrieving new Plugin: " + http.status)
								app.popupString = "Fout in ophalen van plugin 1 " + "..."  + http.status
								updateSucces = false
							}
						}
					}
					http.open("GET",pluginUrl + onlinePluginFileName+ ".plugin.txt"  , true)
					http.send()
					break;
				}
				else{
					console.log("*********SolarPanel inverter (1) plugin does not have to change")
					app.popupString = "Omvormer 1 niet gewijzigd" + "..." 
				}
				break;
			}
			
						
			case 7: {
				if (updated || wrongPlugin){
					needRestart = true
					app.popupString = "Plugin 1 was geupdate voor " + selectedInverter + "..." 
				}
				else{
					app.popupString = "Plugin 1 was niet geupdate voor " + selectedInverter + "..." 
				}
				break;
			}
			
			
			case 8: {
				if ((app.selectedInverter2 != selectedInverter2  || wrongPlugin2) & tempInverterCount>1){
					needRestart = true
					console.log("*********SolarPanel downloading new inverter plugin")
					console.log("*********SolarPanel downloading new inverter plugin : " + pluginUrl + onlinePluginFileName2+ ".plugin.txt")
					var http = new XMLHttpRequest()
					http.onreadystatechange=function() {
						if (http.readyState === 4){
							if (http.status === 200) {
								console.log("*********SolarPanel new Plugin2: " + http.responseText)
								pluginFile2.write(http.responseText)
								needRestart = true
								app.popupString = "Plugin 2 opgehaald voor : " + selectedInverter2 + "..." 
								updateSucces2 = true
								updated2 = true
							}
							else {
								console.log("*********SolarPanel error retrieving new Plugin2: " + http.status)
								app.popupString = "Fout in ophalen van plugin 2 " + "..."  + http.status
								updateSucces2 = false
							}
						}
					}
					http.open("GET",pluginUrl + onlinePluginFileName2+ ".plugin.txt"  , true)
					http.send()
					break;
				}
				else{
					console.log("*********SolarPanel inverter plugin 2 does not have to change")
					if (tempInverterCount>1){
						app.popupString = "Omvormer 2 niet gewijzigd" + "..." 
					}else{
						app.popupString = "Omvormer 2 niet geselecteerd" + "..." 
					}
				}
				break;
			}
			
			
			case 9: {
				if ((updated2 || wrongPlugin2) & tempInverterCount>1){
					needRestart = true
					app.popupString = "Plugin 2 was geupdate voor " + selectedInverter2 + "..." 
				}
				else{
					if (tempInverterCount>1){
						app.popupString = "Plugin 2 was niet geupdate voor " + selectedInverter2 + "..." 
					}else{
						app.popupString = "Omvormer 2 niet geselecteerd" + "..." 
					}
				}
				break;
			}
			
			
			case 10: {
				console.log("*********SolarPanel save app setting")
				app.inverterCount = tempInverterCount
				app.selectedInverter = selectedInverter
				app.passWord = tempPassWord
				app.userName = tempUserName
				app.siteID = tempSiteID
				if(selectedInverter.toLowerCase() == "foxcloud"){tempApiKey = ""}
				if(selectedInverter.toLowerCase() == "Enphase V4-2"){tempApiKey = ""}
				app.apiKey = tempApiKey
				app.urlString = tempURL
				app.idx = tempApiKey
				app.onlinePluginFileName = onlinePluginFileName
				app.selectedInverter2 = selectedInverter2
				app.passWord2 = tempPassWord2
				app.userName2 = tempUserName2
				app.siteID2 = tempSiteID2
				if(selectedInverter2.toLowerCase() == "foxcloud"){tempApiKey2 = ""}
				if(selectedInverter2.toLowerCase() == "Enphase V4-2"){tempApiKey2 = ""}
				app.apiKey2 = tempApiKey2
				app.urlString2 = tempURL2
				app.idx2 = tempApiKey2
				app.onlinePluginFileName2 = onlinePluginFileName2
				app.saveSettings()
				app.popupString = "Instellingen opgeslagen" + "..." 
				break;
			}
				
			case 11: {
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
			case 12: {
				if ((needRestart || needReboot) && (updateSucces||updateSucces2)) {
					console.log("*********SolarPanel creating backup of config_rdd ")
					hcb_rrd_Configfile_bak.write(oldconfigfileString)
					app.popupString = "Backup van config_rdd maken" + "..." 
				}
				break;
			}
			case 13: {
				if  ((needRestart || needReboot) && (updateSucces||updateSucces2)) {
					console.log("*********SolarPanel creating backup of config scsync ")
					hcb_scsync_Configfile_bak.write(oldConfigScsyncFileString)
					app.popupString = "Backup van config_scsync maken" + "..." 
				}
				break;
			}
			
			case 14: {
				if (needRestart && !needReboot && (updateSucces||updateSucces2) ) {
					console.log("*********SolarPanel restart")
					console.log("*********SolarPanel restartingToon")
					app.popupString = "Herstarten van Toon" + "..." 
					app.solarRebootPopup.hide()
					Qt.quit();
				}
				break;
			}
			
			case 15: {
				if (needReboot) {
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
		interval: 2000
		repeat:true
		running: stepRunning 
		triggeredOnStart: true
		onTriggered: {
			modRRDConfig(configChangeStep)
			configChangeStep++
		}
    }
	
/////////////////////////////////////////////////////// TEST MODUS GUI ///////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	MouseArea {
		height : 80
		width : 80
		anchors {
			bottom: parent.bottom
			right: parent.right
			rightMargin: 0
			bottomMargin:0
		}
		onClicked: {
			isDemoMode = !isDemoMode
			console.log("clicked demo mode")
		}
	}

	Text{
		id:demoMode
		font.pixelSize:  isNxt ? 20 : 16
		font.family: qfont.regular.name
		color:  "red" 
		text: isDemoMode? "Test" : ""
		anchors {
			bottom: parent.bottom
			right: parent.right
			rightMargin: 10
			bottomMargin:10
		}    		
	}
	
}

