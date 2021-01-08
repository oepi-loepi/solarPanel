//
// SolarPanel by Oepi-Loepi
//

import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
import FileIO 1.0

import BxtClient 1.0
import qb.energyinsights 1.0 as EnergyInsights
import "SolarObjectPlugin.js" as Solar


App {
	id: solarPanelApp
	
	property url 	tileUrl : "SolarPanelTile.qml"
	property url 	tileUrl2 : "SolarPanelTile2.qml"
	property url 	tileUrl3 : "SolarPanelTile3.qml"
	property url 	thumbnailIcon1: "qrc:/tsc/HomeSunny"
	property url 	thumbnailIcon2: "qrc:/tsc/HomeSunny"
	property url 	thumbnailIcon3: "qrc:/tsc/HomeSunny"
	property url 	thumbnailIcon4: "qrc:/apps/graph/drawables/ChooseTileSolarNow.svg"
	property url 	thumbnailIcon5: "qrc:/apps/graph/drawables/ChooseHourSolarTile.svg"
	property url 	thumbnailIcon6: "qrc:/apps/graph/drawables/ChooseTileKWh"

	property		SolarPanelScreen solarPanelScreen
	property url 	solarPanelScreenUrl : "SolarPanelScreen.qml"

	property		SolarPanelConfigScreen  solarPanelConfigScreen
	property url 	solarPanelConfigScreenUrl : "SolarPanelConfigScreen.qml"
	property url 	solarThisMomentTileUrl : "SolarThisMomentTile.qml"
	property url	graph2SolarHourTileUrl : "Graph2SolarHourTile.qml"
	property url	solarGenerationTodayTileUrl : "SolarGenerationTodayTile.qml"
	
	property url 	solarRebootPopupUrl: "SolarRebootPopup.qml"
	property 		Popup solarRebootPopup


	property string currentPower : "0"
	property int 	todayValue : 0
	property int 	dayAvgValue : 1000
	property int 	yesterdayTotal : 0

	property string currentPowerProd : "0"
	property string currentUsage : "0"
    property string dtime : "0001"
	
	property string succesTime: ""

    property string totalValue : "0"
	property string oldTotalValue : "0"

	property int 	maxWattage : 300
	property int 	tempConfigListIndex
	property string rollingMinX :"05:00"
	property string rollingCenterX : "06:00"
    property string rollingMaxX :"07:00"
	property int 	minsfromsevenIndex
	property int 	nextday
	property date 	dateTimeNow
	property int 	dday
	property int	month
	property int 	hrs
	property int 	mins
	property int	maxRollingY
	
	property date 	now
	property date 	oneHoursEarlier
	property date 	twoHoursEarlier
	
	property bool 	enableSleep : false
	property bool 	debugOutput : false	// Show console messages. Turn on in settings file !
	property bool 	enablePolling : true
	
	property string configMsgUuid : ""
	property string popupString : "SolarPanel instellen en herstarten als nodig" + "..."

	
	property variant fiveminuteValues: []
	property variant rollingfiveminuteValues:[]
	
	property variant fiveminuteValuesProd: []
	property variant rollingfiveminuteValuesProd:[]
	
	property variant lastFiveDays: []
	
	property string selectedInverter: ""
	
	property string passWord : ""
	property string userName : ""
	property string siteID : ""
	property string apiKey : ""
    property string urlString : ""
	
	property variant solarpanelSettingsJson : {
			'selectedInverter': "",
			'passWord' : "",
			'userName' : "",
			'apiKey' : "",
			'siteID' : "",
			'urlString' : "",
			'enableSleep' : "",
			'enablePolling' : "",
			'DebugOn': ""
	}

	function init() {
		registry.registerWidget("tile", tileUrl, this, null, {thumbLabel: qsTr("Solar Grafiek"), thumbIcon: thumbnailIcon1, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", tileUrl2, this, null, {thumbLabel: qsTr("SolarPanel 2"), thumbIcon: thumbnailIcon2, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", tileUrl3, this, null, {thumbLabel: qsTr("Solar Rolling"), thumbIcon: thumbnailIcon3, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", solarThisMomentTileUrl, this, null,  {thumbLabel: qsTr("Solar Nu"), thumbIcon:  thumbnailIcon4, thumbCategory:  "general", thumbWeight: 30, baseTileSolarWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", graph2SolarHourTileUrl, this, null,  {thumbLabel: qsTr("Solar Uren"), thumbIcon:  thumbnailIcon5, thumbCategory:  "general", thumbWeight: 30, baseTileSolarWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", solarGenerationTodayTileUrl, this, null,  {thumbLabel: qsTr("Solar Dag"), thumbIcon:  thumbnailIcon6, thumbCategory:  "general", thumbWeight: 30, baseTileSolarWeight: 10, thumbIconVAlignment: "center"});
		
		registry.registerWidget("screen", solarPanelConfigScreenUrl, this, "solarPanelConfigScreen")
		registry.registerWidget("popup", solarRebootPopupUrl, solarPanelApp, "solarRebootPopup");
		registry.registerWidget("screen", solarPanelScreenUrl, this, "solarPanelScreen")
	}

	FileIO {id: solarpanelSettingsFile;	source: "file:///mnt/data/tsc/solarpanel_userSettings.json"}
	FileIO {id: solarPanel_fiveminuteValues;	source: "file:///mnt/data/tsc/appData/solarPanel_fiveminuteValues.txt"}
	FileIO {id: solarPanel_fiveminuteValuesProd;	source: "file:///mnt/data/tsc/appData/solarPanel_fiveminuteValuesProd.txt"}
	FileIO {id: solarPanel_totalValue;	source: "file:///mnt/data/tsc/appData/solarPanel_totalValue.txt"}
	FileIO {id: solarPanel_lastWrite;	source: "file:///mnt/data/tsc/appData/solarPanel_lastWrite.txt"}
	FileIO {id: solarPanel_lastFiveDays;	source: "file:///mnt/data/tsc/appData/solarPanel_lastFiveDays.txt"}


		
	Component.onCompleted: { //clear array
		for (var i = 0; i <= 216; i++){fiveminuteValues[i] = 0}  //moet 216 zijn (15 uur /dag 12 x per uur (elke 5 mins))
		for (var i = 0; i <= 216; i++){fiveminuteValuesProd[i] = 0}  //moet 216 zijn (15 uur /dag 12 x per uur (elke 5 mins))
		for (var i = 0; i <= 24; i++){rollingfiveminuteValues[i] = 0 }
		for (var i = 0; i <= 24; i++){rollingfiveminuteValuesProd[i] = 0 }
	
		try {
			solarpanelSettingsJson = JSON.parse(solarpanelSettingsFile.read())
			selectedInverter = solarpanelSettingsJson['selectedInverter-v2']
			passWord = solarpanelSettingsJson['passWord']
			userName = solarpanelSettingsJson['userName']
			apiKey = solarpanelSettingsJson['apiKey']
			siteID = solarpanelSettingsJson['siteID']
			urlString = solarpanelSettingsJson['urlString']
			if (solarpanelSettingsJson['enableSleep'] == "Yes") {enableSleep = true} else {enableSleep = false}
			if (solarpanelSettingsJson['enablePolling'] == "No") {enablePolling = false} else {enablePolling = true}
			//if (solarpanelSettingsJson['DebugOn'] == "Yes") {debugOutput = true} else {debugOutput = false}
		} catch(e) {
		}

		var lastWriteDate = ""
		
		try {var fiveminuteValuesString = solarPanel_fiveminuteValues.read() ; if (fiveminuteValuesString.length >2 ){ fiveminuteValues = fiveminuteValuesString.split(',') }} catch(e) { }
		try {var fiveminuteValuesStringProd = solarPanel_fiveminuteValuesProd.read() ; if (fiveminuteValuesStringProd.length >2 ){ fiveminuteValuesProd = fiveminuteValuesStringProd.split(',') }} catch(e) { }
		try {var totalValueString = solarPanel_totalValue.read(); if (totalValueString.length > 0 ){oldTotalValue = parseInt(totalValueString)}} catch(e) {}
		try {lastWriteDate = (solarPanel_lastWrite.read()).toString().trim() } catch(e) {}
		try {var lastFiveDaysString = solarPanel_lastFiveDays.read() ; if (lastFiveDaysString.length >2 ){lastFiveDays = lastFiveDaysString.split(',') }} catch(e) { }
		
		var totalForAvg = 0
		for (var i in lastFiveDays){totalForAvg += lastFiveDays[i]}
		if((totalForAvg>0) && (lastFiveDays.length >0)) {dayAvgValue = parseInt(totalForAvg/lastFiveDays.length)}
		
		if (debugOutput) console.log("*********SolarPanel trying to resolve old values")
		if (debugOutput) console.log("*********SolarPanel starting to load lastwrite timestamp file: "  + lastWriteDate)
		currentPower = 0

		var todaydate = new Date()
		var todayFDate = (todaydate.getDate() + "-" + parseInt(Qt.formatDateTime(todaydate,"MM"))).toString().trim()
		var yesterdayDate =  Qt.formatDate(new Date(todaydate.getFullYear(), todaydate.getMonth(), todaydate.getDate()-1), "dd-MM-yyyy")

		//get last totalValue4
		var http= new XMLHttpRequest()
		var url = "http://localhost/hcb_rrd?action=getRrdData.csv&loggerName=elec_solar_quantity&rra=10yrdays&from=" + yesterdayDate
		http.onreadystatechange = function() { // Call a function when the state changes.
			if (http.readyState === 4) {
				if (http.status === 200) {
					var firstline = http.responseText.split("\n")[0]
					yesterdayTotal = parseInt(firstline.split(",")[1])
					if (debugOutput) console.log("*********SolarPanel yesterdayTotal: " + yesterdayTotal)
				} else {
					console.log("*********SolarPanel error: " + http.status)
				}
			}
		}
		http.open("GET", url, true)
        http.send()
	
		if (typeof yesterdayTotal == 'undefined' || typeof yesterdayTotal == 'null' || yesterdayTotal == null || yesterdayTotal == 0 ){	
			oldTotalValue = oldTotalValue
		}else{
			oldTotalValue = yesterdayTotal
		}

		if (lastWriteDate.length > 2 ){			
			if (debugOutput) console.log("*********SolarPanel todayFDate:" + todayFDate)
			if (debugOutput) console.log("*********SolarPanel lastWriteDate:" + lastWriteDate)

			if  (lastWriteDate !== todayFDate){
				for (var i = 0; i <= 216; i++){fiveminuteValues[i] = 0};
				for (var i = 0; i <= 24; i++){rollingfiveminuteValues[i] = 0 }
				for (var i = 0; i <= 216; i++){fiveminuteValuesProd[i] = 0};
				for (var i = 0; i <= 24; i++){rollingfiveminuteValuesProd[i] = 0 }
				if (debugOutput) console.log("*********SolarPanel last timestamp is not from today so clear 5 min array")
			}
		}

		if (debugOutput) console.log("*********SolarPanel currentPower:" + currentPower)
	}
	
	
//////////////////////////////////////////////////////////////// RRD  DATA  //////////////////////////////////////////////////////////////////////////

	function dataRequestForProdCallback(initVar, varPrefix, findMax, success, response, batchDone) {
		var rddValue = 0
		if (debugOutput) console.log("*********SolarPanel Start parsing RRD data")

		if (typeof JSON.stringify(response) == 'undefined' || typeof JSON.stringify(response) == 'null' || JSON.stringify(response) == null ){	
			currentPowerProd = rddValue
		}
		else{
			if (debugOutput) console.log("*********SolarPanel JSON.stringify(response): " + JSON.stringify(response))
			var JsonString = JSON.stringify(response)
			var JsonObject= JSON.parse(JsonString)
			var dataArray = JsonObject.data

			for (var i in dataArray){
				rddValue = JsonObject.data[i].value
				if (debugOutput) console.log("*********SolarPanel Start parsing rddValue: "  + rddValue)
				if (debugOutput) console.log("*********SolarPanel rddValue (" + JsonObject.data[i].timestamp + ") : " + rddValue)
				if (typeof rddValue === 'undefined' || typeof rddValue === 'null' || rddValue === null ) rddValue = 0
				currentPowerProd = rddValue
			}
		}
	}

	function dataRequestForUsageCallback(initVar, varPrefix, findMax, success, response, batchDone) {
		var rddValue = 0
		if (debugOutput) console.log("*********SolarPanel Start parsing RRD data")

		if (typeof JSON.stringify(response) == 'undefined' || typeof JSON.stringify(response) == 'null' || JSON.stringify(response) == null ){	
			currentPowerProd = rddValue
		}
		else{
			if (debugOutput) console.log("*********SolarPanel JSON.stringify(response): " + JSON.stringify(response))
			var JsonString = JSON.stringify(response)
			var JsonObject= JSON.parse(JsonString)
			var dataArray = JsonObject.data

			for (var i in dataArray){
				rddValue = JsonObject.data[i].value
				if (debugOutput) console.log("*********SolarPanel Start parsing rddValue: "  + rddValue)
				if (debugOutput) console.log("*********SolarPanel rddValue (" + JsonObject.data[i].timestamp + ") : " + rddValue)
				if (typeof rddValue === 'undefined' || typeof rddValue === 'null' || rddValue === null ) rddValue = 0
				currentUsage = parseInt(rddValue)
			}
		}
	}

	function requestRRDData() {
		//what = "Now", "Hour", "Day","prodNow", "prodHour" or "prodDay"
		var args = [];
		if (debugOutput) console.log("*********SolarPanel Start requesting RRD data")
			var d = new Date();
			var hourTileEndTime5min = d;
			d.setMinutes((hourTileEndTime5min.getMinutes() - 5), 0, 0);
			var hourTileStartTime5min = d;
			var from5min = graphUtils.dateToISOString(new Date(hourTileStartTime5min));
			var to5min = graphUtils.dateToISOString(new Date());

			//flow 5 mins
			var argsElec = new EnergyInsights.Definitions.RequestArgs("electricity", "consumption", "flow", false, undefined, from5min, to5min ,["hourTilePower", true]);
			args.push(argsElec)
			
			if (debugOutput) console.log("*********SolarPanel Start requesting data Now")
			EnergyInsights.Functions.requestBatchData(args, util.partialFn(dataRequestForUsageCallback, 1));

			//flow 5 mins
			argsElec = new EnergyInsights.Definitions.RequestArgs("electricity", "production", "flow", false, undefined, from5min, to5min ,["hourTilePower", true]);
			args.push(argsElec)
			EnergyInsights.Functions.requestBatchData(args, util.partialFn(dataRequestForProdCallback, 1));	
	}

///////////////////////////////////////////////////////////////// GET DATA //////////////////////////////////////////////////////////////////////////////	

	function getData(){
		Solar.getSolarData(passWord,userName,apiKey,siteID,urlString, parseInt(oldTotalValue))
		if (debugOutput) console.log("*********SolarPanel send request to Plugin")
    }

	function parseReturnData(v0,v1,v2,v3,v4,v5,v6,v7,v8){
		if (debugOutput) console.log("*********SolarPanel got data from Plugin returnString: " + v8)
		if (v8 == "succes"){
			succesTime = Qt.formatDateTime(dateTimeNow,"ddd d-M  hh:mm")
			currentPower = v0					
			totalValue= v1
			if (debugOutput) console.log("*********SolarPanel currentPower:" + currentPower)
			if (debugOutput) console.log("*********SolarPanel total:" + totalValue)
			if (debugOutput) console.log("*********SolarPanel statuscode:" + v7)
			if (debugOutput) console.log("*********SolarPanel yesterdayTotal: " + yesterdayTotal)
			if (debugOutput) console.log("*********SolarPanel totalValue: " + totalValue)
			todayValue = parseInt(totalValue - yesterdayTotal)
			if (debugOutput) console.log("*********SolarPaneltodayValue: " + todayValue)
			doData()
		}
		if (v8 == "error"){
			currentPower = 0					
			totalValue= totalValue
			doData()
		}
	}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////DO DATA  //////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function randomNumber(from, to) {
		return Math.floor(Math.random() * (to - from + 1) + from);
    }
	
	function getArraySum(a){
		var total=0;
		for(var i in a) { 
			total += a[i];
		}
		return total;
	}

	
	
    function doData(){
		if (debugOutput) console.log("*********SolarPanel currentPower:" + currentPower)
		if (debugOutput) console.log("*********SolarPanel total:" + totalValue)
		
		var newArray = []
		newArray = fiveminuteValues
		newArray[minsfromsevenIndex] = parseInt(currentPower)
		fiveminuteValues = newArray
		
		var newArrayProd = []
		newArrayProd = fiveminuteValuesProd
		newArrayProd[minsfromsevenIndex] = parseInt(currentPowerProd)
		fiveminuteValuesProd = newArrayProd

		var http2 = new XMLHttpRequest()
        if (debugOutput) console.log("*********SolarPanel unixTime : " + parseInt(dateTimeNow.getTime()/1000))
		var url2 = "http://localhost/hcb_rrd?action=setRrdData&loggerName=elec_solar_flow&rra=5min&samples=%7B%22" + parseInt(dateTimeNow.getTime()/1000)+ "%22%3A" + parseInt(currentPower) + "%7D"
		if (debugOutput) console.log("*********SolarPanel url2 : " + url2)
		http2.open("GET", url2, true)
        http2.send()
		
		var http3 = new XMLHttpRequest()
		if (debugOutput) console.log("*********SolarPanel unixTime : " + parseInt(dateTimeNow.getTime()/1000))
		var url3 = "http://localhost/hcb_rrd?action=setRrdData&loggerName=elec_solar_quantity&rra=5yrhours&samples=%7B%22" + parseInt(dateTimeNow.getTime()/1000)+ "%22%3A" + parseInt(totalValue) + "%7D"
		if (debugOutput) console.log("*********SolarPanel url3 : " + url3)
		http3.open("GET", url3, true)
		http3.send()
			
		var http4 = new XMLHttpRequest()
        if (debugOutput) console.log("*********SolarPanel unixTime : " + parseInt(dateTimeNow.getTime()/1000))
		var url4 = "http://localhost/hcb_rrd?action=setRrdData&loggerName=elec_solar_quantity&rra=10yrdays&samples=%7B%22" + parseInt(dateTimeNow.getTime()/1000)+ "%22%3A" + parseInt(totalValue) + "%7D"
		if (debugOutput) console.log("*********SolarPanel url4 : " + url3)
		http4.open("GET", url4, true)
        http4.send()
		

		if (mins >= 10 & mins < 16){  //every hour
			//Write 5minute values to file
			var fiveminuteValuesString = fiveminuteValues[0]
			for (var j = 1; j <= 216; j++) { 
				fiveminuteValuesString += "," + fiveminuteValues[j]
			}
			solarPanel_fiveminuteValues.write(fiveminuteValuesString)
			
			//Write 5minute production values to file
			var fiveminuteValuesStringProd = fiveminuteValuesProd[0]
			for (var j = 1; j <= 216; j++) { 
				fiveminuteValuesStringProd += "," + fiveminuteValuesProd[j]
			}
			solarPanel_fiveminuteValuesProd.write(fiveminuteValuesStringProd)
			solarPanel_lastWrite.write(dday + "-" + month)

		}

		//make new rolling array each 5 mins
		if (debugOutput) console.log("*********SolarPanel calculating rollingfiveminuteValues minsfromsevenIndex" + minsfromsevenIndex)
		var x2now  = minsfromsevenIndex
		var x2twohoursAgo  = x2now - 24  //less 2 hours
		var newArray5 = []
		maxRollingY = 0
		for (var y = x2twohoursAgo; y <= x2now; y++) { 
			newArray5.push(fiveminuteValues[y])
			if (parseInt(maxRollingY) < parseInt(fiveminuteValues[y])){
					maxRollingY = fiveminuteValues[y]
			}
		}
		rollingfiveminuteValues = newArray5
		
		//make new rolling array for production each 5 mins
		if (debugOutput) console.log("*********SolarPanel calculating rollingfiveminuteValues minsfromsevenIndex" + minsfromsevenIndex)
		var x2now  = minsfromsevenIndex
		var x2twohoursAgo  = x2now - 24  //less 2 hours
		var newArray5Prod = []
		for (var y = x2twohoursAgo; y <= x2now; y++) { 
				newArray5Prod.push(fiveminuteValuesProd[y])
		}
		rollingfiveminuteValuesProd = newArray5Prod
		

		now = new Date(dateTimeNow.getFullYear(), dateTimeNow.getMonth(), dateTimeNow.getDate(), dateTimeNow.getHours(), dateTimeNow.getMinutes())
		oneHoursEarlier= new Date(dateTimeNow.getFullYear(), dateTimeNow.getMonth(), dateTimeNow.getDate(), dateTimeNow.getHours()-1, dateTimeNow.getMinutes())
		twoHoursEarlier= new Date(dateTimeNow.getFullYear(), dateTimeNow.getMonth(), dateTimeNow.getDate(), dateTimeNow.getHours()-2, dateTimeNow.getMinutes())
		rollingMinX = Qt.formatDateTime(twoHoursEarlier,"hh") + ":" + Qt.formatDateTime(twoHoursEarlier,"mm")
		rollingCenterX = Qt.formatDateTime(oneHoursEarlier,"hh") + ":" + Qt.formatDateTime(oneHoursEarlier,"mm")
		rollingMaxX = Qt.formatDateTime(now,"hh") + ":" + Qt.formatDateTime(now,"mm")
		if (debugOutput) console.log("*********SolarPanel rollingMinX " + rollingMinX)
		if (debugOutput) console.log("*********SolarPanel rollingCenterX " + rollingCenterX)
		if (debugOutput) console.log("*********SolarPanel rollingMaxX " + rollingMaxX)
    }



/////////////////////////////////////////WRITE DAILY DATA/////////////////////////////////////////////////////////////////////////////////////////////////

	function writeDailyData(){
		if (debugOutput) console.log("*********SolarPanel dtime: " + dtime )

		
	//clear the old fiveminute array
		var newArray2 = []
		for (var g = 0; g <= 216; g++) {
			newArray2.push(0)
		}
		fiveminuteValues = newArray2	
	
	//clear the 5 minutes file so we will start a new fresh day
		var zeroString = "0"
		for (var z = 1; z <= 216; z++) { 
			zeroStringString += "," + "0"
		}
		solarPanel_fiveminuteValues.write(zeroString)
	

	//clear the old production fiveminute array
		var newArray2Prod = []
		for (var g = 0; g <= 216; g++) {
			newArray2Prod.push(0)
		}
		fiveminuteValuesProd = newArray2Prod
		
		
		var lastFiveDaysString = lastFiveDays[1]
		for (var g = 1; g < 4; g++) {
			 lastFiveDaysString += "," + lastFiveDays[g+1]
		}
		solarPanel_lastFiveDays.write(lastFiveDaysString)
		
		var newArray3 = []
		for (var g  in lastFiveDays) {
			if (g<5){newArray3.push(lastFiveDays[g+1])}
		}
		newArray3.push(todayValue)
		lastFiveDays = newArray3
		
		var totalForAvg = 0
		for (var i in lastFiveDays){totalForAvg += lastFiveDays[i]}
		if((totalForAvg>0) && (lastFiveDays.length >0)) {dayAvgValue = parseInt(totalForAvg/lastFiveDays.length)}

		yesterdayTotal = totalValue
		oldTotalValue=totalValue
		solarPanel_fiveminuteValuesProd.write(zeroStringProd)
		solarPanel_totalValue.write(parseInt(totalValue))
		solarPanel_lastWrite.write(dday + "-" + month)
	}
	
///////////////////////////////////////// TIMERS /////////////////////////////////////////////////////////////////////////////////////////////////
	
	Timer {
            id: getUsageTimer   //interval to get ussage power data
            interval: 20000
            repeat: true
            running: true
            triggeredOnStart: true
            onTriggered: {
				requestRRDData("Now")
            }
    }
	
    Timer {
            id: scrapeTimer   //interval to get the solar data
            interval: 300000
            repeat: true
            running: true
            triggeredOnStart: true
            onTriggered: {
			
				dateTimeNow= new Date()
				dtime = parseInt(Qt.formatDateTime (dateTimeNow,"hh") + Qt.formatDateTime (dateTimeNow,"mm"))
				if (debugOutput) console.log("*********SolarPanel dtime: " + dtime)
				dday = dateTimeNow.getDate()
				month = parseInt(Qt.formatDateTime(dateTimeNow,"MM"))
				hrs = parseInt(Qt.formatDateTime(dateTimeNow,"hh"))
				mins = parseInt(Qt.formatDateTime(dateTimeNow,"mm"))
				var minsfromseven = ((hrs-5)*60) + mins
				minsfromsevenIndex  = parseInt(minsfromseven/5)
				if (debugOutput) console.log("*********SolarPanel minsfromseven : " + minsfromseven)
				if (debugOutput) console.log("*********SolarPanel dtime : " + dtime)
				if (debugOutput) console.log("*********SolarPanel minsfromsevenIndex : " + minsfromsevenIndex)
					
				if ((dtime>=500 & dtime<2300) & enablePolling){  //it is daytime
					requestRRDData()
					getData()
				}
				
				if (dtime>=2351 & dtime<2356){ //just before midnight
					writeDailyData()
				}
            }
    }
 
///////////////////////////////////////// SAVE ALL TO SETTINGS ///////////////////////////////////////////////////////////////////////////////////////////////// 

   	function saveSettings() {
	
		console.log("*********SolarPanel passWord  " + passWord)
		console.log("*********SolarPanel userName  " + userName)
		console.log("*********SolarPanel apiKey  " + apiKey)
		console.log("*********SolarPanel siteID  " + siteID)
		console.log("*********SolarPanel urlString  " + urlString)

		if (debugOutput) console.log("*********SolarPanel Savedata Started" )
		var tmpDebugOn = ""
		if (debugOutput == true) {tmpDebugOn = "Yes";} else {tmpDebugOn = "No";	}
		var tmpenableSleep = ""
		if (enableSleep == true) {tmpenableSleep = "Yes";} else {tmpenableSleep = "No";	}
		var tmpenablePolling = ""
		if (enablePolling == true) {tmpenablePolling = "Yes";} else {tmpenablePolling = "No";	}
		var setJson = {
			"selectedInverter-v2" 	: selectedInverter,
			"passWord" : passWord,
			"userName" : userName,
			"apiKey" : apiKey,
			"siteID" : siteID,
			"urlString" : urlString,
			"enableSleep" : tmpenableSleep,
			"enablePolling" : tmpenablePolling,
			"DebugOn": tmpDebugOn
		}
		solarpanelSettingsFile.write(JSON.stringify(setJson))
		solarpanelSettingsJson = JSON.parse(solarpanelSettingsFile.read())
		getData()
	}

	function restartToon() {
		var restartToonMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, configMsgUuid, "specific1", "RequestReboot");
		bxtClient.sendMsg(restartToonMessage);
	}
	
	BxtDiscoveryHandler {
		id: configDiscoHandler
		deviceType: "hcb_config"
		onDiscoReceived: {
			configMsgUuid = deviceUuid
		}
	}
}
