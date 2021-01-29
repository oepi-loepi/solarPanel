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
import "SolarObjectPlugin2.js" as Solar2

App {
	id: solarPanelApp
	
	property url 	tileUrl : "SolarPanelTile.qml"
	property url 	tileUrl2 : "SolarPanelTile2.qml"
	property url 	tileUrl3 : "SolarPanelTile3.qml"
	property url 	thumbnailIcon1: "qrc:/tsc/solarPanel_graph1.png"
	property url 	thumbnailIcon2: "qrc:/tsc/solarPanel_txt.png"
	property url 	thumbnailIcon3: "qrc:/tsc/solarPanel_rolling.png"
	property url 	thumbnailIcon4: "qrc:/tsc/solarPanel_now.png"
	property url 	thumbnailIcon5: "qrc:/tsc/solarPanel_graph2.png"
	property url 	thumbnailIcon6: "qrc:/tsc/solarPanel_kwh.png"

	
	//property url 	thumbnailIcon3: "qrc:/tsc/HomeSunny"
	//property url 	thumbnailIcon4: "qrc:/apps/graph/drawables/ChooseTileSolarNow.svg"
	//property url 	thumbnailIcon5: "qrc:/apps/graph/drawables/ChooseHourSolarTile.svg"
	//property url 	thumbnailIcon6: "qrc:/apps/graph/drawables/ChooseTileKWh"

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
	property int 	lastHourValue : 0
	
	property url 	weatherprovider : "https://data.buienradar.nl/2.0/feed/json"
	property int    sunrisePerc : 0
	property int	sunsetPerc : 0
	
	property string currentPowerProd : "0"
	property string currentUsage : "0"
    property string dtime : "0"
	
	property string succesTime: ""
    property string totalValue : "0"
	property string savedtotalValue : "0"

	property int 	maxWattage : 300
	
	property string rollingMinX :"05:00"
	property string rollingCenterX : "06:00"
    property string rollingMaxX :"07:00"
	property int 	minsfromfiveIndex
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
	property string pluginWarning : "Selecteer Inverter"
	property variant fiveminuteValues: []
	property variant rollingfiveminuteValues:[]
	property variant fiveminuteValuesProd: []
	property variant rollingfiveminuteValuesProd:[]
	property variant lastFiveDays: []
	property string selectedInverter: ""
	property string onlinePluginFileName:""
	property string selectedInverter2: ""
	property string onlinePluginFileName2:""
	property int inverterCount : 1
	property int getDataCount : 0
	property int getDataStepper : 1
	property bool stepRunning : false
	property int inverter1CurrentPower
	property int inverter1Day
	property int inverter1Total
	property string passWord : ""
	property string userName : ""
	property string siteID : ""
	property string apiKey : ""
    property string urlString : ""
	property string idx : ""
	property string passWord2 : ""
	property string userName2 : ""
	property string siteID2 : ""
	property string apiKey2 : ""
    property string urlString2 : ""
	property string idx2 : ""
	
	property variant solarpanelSettingsJson : {
			'inverterCount': "1",
			'selectedInverter': "",
			'passWord' : "",
			'userName' : "",
			'apiKey' : "",
			'siteID' : "",
			'urlString' : "",
			'idx' : "",
			'selectedInverter2': "",
			'passWord2' : "",
			'userName2' : "",
			'apiKey2' : "",
			'siteID2' : "",
			'urlString2' : "",
			'idx2' : "",
			'enableSleep' : "",
			'enablePolling' : "",
			'DebugOn': ""
	}

	function init() {
		registry.registerWidget("tile", tileUrl, this, null, {thumbLabel: qsTr("Solar Vandaag"), thumbIcon: thumbnailIcon1, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", tileUrl2, this, null, {thumbLabel: qsTr("Solar Panel"), thumbIcon: thumbnailIcon2, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", tileUrl3, this, null, {thumbLabel: qsTr("Solar 2 uur"), thumbIcon: thumbnailIcon3, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", solarThisMomentTileUrl, this, null,  {thumbLabel: qsTr("Solar Nu"), thumbIcon:  thumbnailIcon4, thumbCategory:  "general", thumbWeight: 30, baseTileSolarWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", graph2SolarHourTileUrl, this, null,  {thumbLabel: qsTr("Solar 2 uur"), thumbIcon:  thumbnailIcon5, thumbCategory:  "general", thumbWeight: 30, baseTileSolarWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", solarGenerationTodayTileUrl, this, null,  {thumbLabel: qsTr("Solar Vandaag"), thumbIcon:  thumbnailIcon6, thumbCategory:  "general", thumbWeight: 30, baseTileSolarWeight: 10, thumbIconVAlignment: "center"});
		
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
	FileIO {id: pluginFile;	source: "SolarObjectPlugin.js"}
	FileIO {id: pluginFile2;source: "SolarObjectPlugin2.js"}
		
	Component.onCompleted: { 
	
		//clear graph arrays
		for (var i = 0; i <= 216; i++){fiveminuteValues[i] = 0}  //moet 216 zijn (15 uur /dag 12 x per uur (elke 5 mins))
		for (var i = 0; i <= 216; i++){fiveminuteValuesProd[i] = 0}  //moet 216 zijn (15 uur /dag 12 x per uur (elke 5 mins))
		for (var i = 0; i <= 24; i++){rollingfiveminuteValues[i] = 0 }
		for (var i = 0; i <= 24; i++){rollingfiveminuteValuesProd[i] = 0 }
		for (var i = 0; i <= 5; i++){lastFiveDays[i] = 0 }
		
		currentPower = 0

		//get the user settings from the system file
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
		
		//must be a seperate try because this parameter was added later
		try {
			solarpanelSettingsJson = JSON.parse(solarpanelSettingsFile.read())
			onlinePluginFileName = solarpanelSettingsJson['onlinePluginFileName']
		} catch(e) {
		}
		
		//must be a seperate try because this parameter was added later
		try {
			solarpanelSettingsJson = JSON.parse(solarpanelSettingsFile.read())
			onlinePluginFileName2 = solarpanelSettingsJson['onlinePluginFileName2']
			idx = solarpanelSettingsJson['idx']
			selectedInverter2 = solarpanelSettingsJson['selectedInverter2-v2']
			passWord2 = solarpanelSettingsJson['passWord2']
			userName2 = solarpanelSettingsJson['userName2']
			apiKey2 = solarpanelSettingsJson['apiKey2']
			siteID2 = solarpanelSettingsJson['siteID2']
			urlString2 = solarpanelSettingsJson['urlString2']
			idx2 = solarpanelSettingsJson['idx2']
			onlinePluginFileName2 = solarpanelSettingsJson['onlinePluginFileName2']
			inverterCount = parseInt(solarpanelSettingsJson['inverterCount'])
		} catch(e) {
		}
		
		//check if plugin matches the selectedinverter
		var pluginFileString = pluginFile.read()
		if (debugOutput) console.log("*********SolarPanel pluginFile.read() : " + pluginFile.read())
		if (debugOutput) console.log("*********SolarPanel onlinePluginFileName : " + onlinePluginFileName)
		if (pluginFileString.indexOf(onlinePluginFileName)<0 || selectedInverter==""  || onlinePluginFileName =="" ){//wrong plugin
			if (debugOutput) console.log("*********SolarPanel wrong plugin : ")
			if (debugOutput) console.log("*********SolarPanel has wrong plugin when first started")
			pluginWarning = "Selecteer Inverter (1)"
		}else{
			pluginWarning = ""
		}

		if (inverterCount>1){
			var pluginFileString2 = pluginFile2.read()
			if (debugOutput) console.log("*********SolarPanel pluginFile2.read() : " + pluginFile2.read())
			if (debugOutput) console.log("*********SolarPanel onlinePluginFileName2 : " + onlinePluginFileName2)
			if (pluginFileString2.indexOf(onlinePluginFileName2)<0 || selectedInverter2==""  || onlinePluginFileName2 =="" ){//wrong plugin
				if (debugOutput) console.log("*********SolarPanel wrong plugin2 : ")
				if (debugOutput) console.log("*********SolarPanel has wrong plugin2 when first started")
				pluginWarning = "Selecteer Inverter (2)"
			}else{
				pluginWarning = ""
			}
		}
		

		//get the last values from the data file
		if (debugOutput) console.log("*********SolarPanel trying to resolve old values")
		
		//calculate the average 5 day value for the daytile
		try {var lastFiveDaysString = solarPanel_lastFiveDays.read() ; if (lastFiveDaysString.length >2 ){lastFiveDays = lastFiveDaysString.split(',') }} catch(e) { }
		var totalForAvg = 0
		var avgcounter = 0
		for (var i in lastFiveDays){
			if (debugOutput) cconsole.log("*********SolarPanel lastFiveDays[i]: " + lastFiveDays[i])
			if (!isNaN(lastFiveDays[i]) & (parseInt(lastFiveDays[i])>0)){
					totalForAvg = totalForAvg + parseInt(lastFiveDays[i])
					if (debugOutput) cconsole.log("*********SolarPanel parsed lastFiveDays[i]: " + lastFiveDays[i])
					avgcounter ++
				}
			}
		if((totalForAvg>0) && (avgcounter >3)) {dayAvgValue = parseInt(totalForAvg/avgcounter)} //calculate the avg for at least 3 days
		

		var todaydate = new Date()
		var todayFDate = (todaydate.getDate() + "-" + parseInt(Qt.formatDateTime(todaydate,"MM"))).toString().trim()
		var yesterdayDate =  Qt.formatDate(new Date(todaydate.getFullYear(), todaydate.getMonth(), todaydate.getDate()-1), "dd-MM-yyyy")

		//Try to resolve the yesterday total value from teh RRA  database
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
		
		var oldTotalValue = 0
		try {var totalValueString = solarPanel_totalValue.read(); if (totalValueString.length > 0 ){oldTotalValue = parseInt(totalValueString)}} catch(e) {}
		
	
		//if there was no yesterday total in th RRA  database, the yesterday will be the last value from the file
		if (typeof yesterdayTotal != 'undefined'  || typeof yesterdayTotal != 'null' || isNaN(yesterdayTotal)){
			if (yesterdayTotal == 0){
				totalValue = oldTotalValue
			}else{
				oldTotalValue = yesterdayTotal
				totalValue = oldTotalValue
			}
		}

		//check if there is totday data to be loaded into arrays
		
		try {var lastWriteDate = (solarPanel_lastWrite.read()).toString().trim() } catch(e) {}
		
		if (debugOutput) console.log("*********SolarPanel starting to load lastwrite timestamp file: "  + lastWriteDate)
		if (lastWriteDate.length > 2 ){			
			if (debugOutput) console.log("*********SolarPanel todayFDate:" + todayFDate)
			if (debugOutput) console.log("*********SolarPanel lastWriteDate:" + lastWriteDate)
			if  (lastWriteDate == todayFDate){
				if (debugOutput) console.log("*********SolarPanel last timestamp is from today so loading totdays arrays from file")
				try {var fiveminuteValuesString = solarPanel_fiveminuteValues.read() ; if (fiveminuteValuesString.length >2 ){ fiveminuteValues = fiveminuteValuesString.split(',') }} catch(e) { }
				try {var fiveminuteValuesStringProd = solarPanel_fiveminuteValuesProd.read() ; if (fiveminuteValuesStringProd.length >2 ){ fiveminuteValuesProd = fiveminuteValuesStringProd.split(',') }} catch(e) { }
			}
		}
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
		if (getDataCount == 0){
			inverter1CurrentPower = 0
			inverter1Day = 0
			inverter1Total = 0
			Solar.getSolarData(passWord,userName,apiKey,siteID,urlString, parseInt(totalValue))
		}
		if (getDataCount == 1){
			Solar2.getSolarData(passWord2,userName2,apiKey2,siteID2,urlString2, parseInt(totalValue))
		}
    }
	
	function parseReturnData(v0,v1,v2,v3,v4,v5,v6,v7,v8){
		getDataCount++
		//first inverter while there must be 2 inverters
		if (inverterCount == 2 & getDataCount == 1){
			if (v8 == "succes"){
				succesTime = Qt.formatDateTime(dateTimeNow,"ddd d-M  hh:mm")
				inverter1CurrentPower = v0
				if (typeof v1 == 'undefined' || typeof v1 == 'null' || v1 == null || v1 == 0 || isNaN(v2)){	
				}else{ // de api geeft een waarde uit voor het totaal
					inverter1Total = v1
				}
				if (typeof v2 == 'undefined' || typeof v2 == 'null' || v2 == null || isNaN(v2)){
					inverter1Total = parseFloat(totalValue - yesterdayTotal)
				}else{ // de api geeft een waarde uit voor het dagtotaal
					inverter1Day = v2
				}
			}
			getData()
		}
		//second inverter while there must be 2 inverters or first if there is only one inverter
		if ((inverterCount == 1 & getDataCount == 1) || (inverterCount == 2 & getDataCount == 2)){
			if (v8 == "succes"){
				succesTime = Qt.formatDateTime(dateTimeNow,"ddd d-M  hh:mm")
				currentPower = parseInt(v0) + inverter1CurrentPower

				if (typeof v1 == 'undefined' || typeof v1 == 'null' || v1 == null || v1 == 0 || isNaN(v2)){	
				}else{ // de api geeft een waarde uit voor het dagtotaal
					totalValue = parseInt(v1) + inverter1Total
				}
				
				if (typeof v2 == 'undefined' || typeof v2 == 'null' || v2 == null || isNaN(v2)){
					todayValue =  + inverter1Day + parseFloat(totalValue - yesterdayTotal)
				}else{ // de api geeft een waarde uit voor het dagtotaal
					todayValue = parseInt(v2) + inverter1Day
				}

				if (debugOutput) console.log("*********SolarPanel dtime: " + dtime)
				if (debugOutput) console.log("*********SolarPanel statuscode:" + v7)
				if (debugOutput) console.log("*********SolarPanel currentPower:" + currentPower)
				if (debugOutput) console.log("*********SolarPanel total:" + totalValue)
				if (debugOutput) console.log("*********SolarPanel yesterdayTotal: " + yesterdayTotal)
				if (debugOutput) console.log("*********SolarPanel totalValue: " + totalValue)
				doData()
			}
			if (v8 == "error"){
				currentPower = inverter1CurrentPower
				totalValue = inverter1Total
				todayValue = inverter1Day				
				doData()
			}
		}
	}

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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////DO DATA  //////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
    function doData(){
	
		doEachtimeStuff()
	
		if (dtime>=500 & dtime<2300){  //it is daytime
			doOnlyDuringDayTimeStuff()
		}
		
		if (mins>=0 & mins <=4){
			doHourlyStuff()
		}
		
		if (dtime>=0 & dtime<=4){ //it is a new day
			doDailyStuff()
		}
		
		if (dtime>=100 & dtime<=104){ //it is 1 hour after the beginning of a new day
			doDelayedDailyStuff()
		}
    }

/////////////////////////////////////////WRITE 5MIN   DATA/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////Each time data was received      /////////////////////////////////////////////////////////////////////////////////
	
	function doEachtimeStuff(){
				
		//load current 5 minutes into the array for the 5 minute graph
		var newArray = []
		newArray = fiveminuteValues
		newArray[minsfromfiveIndex] = parseInt(currentPower)
		fiveminuteValues = newArray
		
		//load current 5 minutes into the array for the 5 minute production graph
		var newArrayProd = []
		newArrayProd = fiveminuteValuesProd
		newArrayProd[minsfromfiveIndex] = parseInt(currentPowerProd)
		fiveminuteValuesProd = newArrayProd

		//push current 5 minutes into the array for the RRA  flow
		var http2 = new XMLHttpRequest()
		var url2 = "http://localhost/hcb_rrd?action=setRrdData&loggerName=elec_solar_flow&rra=5min&samples=%7B%22" + parseInt(dateTimeNow.getTime()/1000)+ "%22%3A" + parseInt(currentPower) + "%7D"
		http2.open("GET", url2, true)
		http2.send()
		
		//push quantity into the 5yrhours RRA data
		//produced this day so it must be in the RRA of next hour 00 mins
		var nexthour = new Date();
		nexthour.setMinutes (nexthour.getMinutes() + 60);  //60 minutes extra
		nexthour.setSeconds(0); //round to full hour
		nexthour.setMinutes(0); //round to full hour
		var http3 = new XMLHttpRequest()
		var url3 = "http://localhost/hcb_rrd?action=setRrdData&loggerName=elec_solar_quantity&rra=5yrhours&samples=%7B%22" + parseInt(nexthour.getTime()/1000)+ "%22%3A" + parseInt(totalValue) + "%7D"
		http3.open("GET", url3, true)
		http3.send()
		

		//push quantity into the 10yrdays RRA data
		//produced this day so it must be in the RRA of tomorrow 00:00
		var tomorrow = new Date()
		tomorrow.setDate(tomorrow.getDate() + 1)
		tomorrow.setHours(1,0,0,0)  //to make it UTC
		if (debugOutput) console.log("*********SolarPanel tomorrow : " +  tomorrow.toString())
		if (debugOutput) console.log("*********SolarPanel tomorrow unixTime : " + parseInt(tomorrow.getTime()/1000))
		var http4 = new XMLHttpRequest()	
		var url4 = "http://localhost/hcb_rrd?action=setRrdData&loggerName=elec_solar_quantity&rra=10yrdays&samples=%7B%22" + parseInt(tomorrow.getTime()/1000)+ "%22%3A" + parseInt(totalValue) + "%7D"
		if (debugOutput) console.log("*********SolarPanel url4 : " + url4)
		http4.open("GET", url4, true)
		http4.send()
	
	}

/////////////////////////////////////////WRITE 5MIN   DATA/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////Only during a time period      ///////////////////////////////////////////////////////////////////////////////////

	function doOnlyDuringDayTimeStuff(){
		//make new rolling array each 5 mins
		if (debugOutput) console.log("*********SolarPanel calculating rollingfiveminuteValues minsfromfiveIndex" + minsfromfiveIndex)
		var x2now  = minsfromfiveIndex
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
		if (debugOutput) console.log("*********SolarPanel calculating rollingfiveminuteValues minsfromfiveIndex" + minsfromfiveIndex)
		var x2now  = minsfromfiveIndex
		var x2twohoursAgo  = x2now - 24  //less 2 hours
		var newArray5Prod = []
		for (var y = x2twohoursAgo; y <= x2now; y++) { 
				if (debugOutput) console.log ("*********SolarPanel minsfromfiveIndex y:   " + y + "   value: " + (typeof fiveminuteValuesProd[y]))
				if (typeof fiveminuteValuesProd[y] != 'undefined' & typeof fiveminuteValuesProd[y] != 'null'){
					newArray5Prod.push(fiveminuteValuesProd[y])
				}else{
					newArray5Prod.push(0)
				}
		}
		rollingfiveminuteValuesProd = newArray5Prod
		
		//set the time on the x-axis of the rolling graph
		now = new Date(dateTimeNow.getFullYear(), dateTimeNow.getMonth(), dateTimeNow.getDate(), dateTimeNow.getHours(), dateTimeNow.getMinutes())
		oneHoursEarlier= new Date(dateTimeNow.getFullYear(), dateTimeNow.getMonth(), dateTimeNow.getDate(), dateTimeNow.getHours()-1, dateTimeNow.getMinutes())
		twoHoursEarlier= new Date(dateTimeNow.getFullYear(), dateTimeNow.getMonth(), dateTimeNow.getDate(), dateTimeNow.getHours()-2, dateTimeNow.getMinutes())
		rollingMinX = Qt.formatDateTime(twoHoursEarlier,"hh") + ":" + Qt.formatDateTime(twoHoursEarlier,"mm")
		rollingCenterX = Qt.formatDateTime(oneHoursEarlier,"hh") + ":" + Qt.formatDateTime(oneHoursEarlier,"mm")
		rollingMaxX = Qt.formatDateTime(now,"hh") + ":" + Qt.formatDateTime(now,"mm")
	}

/////////////////////////////////////////WRITE HOURLY DATA/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////At the beginning of a new hour ///////////////////////////////////////////////////////////////////////////////////

	function doHourlyStuff(){
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
		
	
		//it seems like the last hour is deleted when the new hour is set (dunno why) so we just set the previos hour again.
		//push quantity into the 5yrhours RRA data
		//produced this day so it must be in the RRA of next hour 00 mins
		var thishour = new Date();
		if (debugOutput) console.log("*********SolarPanel thishour: " + thishour.toString())
		thishour.setSeconds(0); //round to full hour
		thishour.setMinutes(0); //round to full hour
		if (debugOutput) console.log("*********SolarPanel thishour: " + thishour.toString())
		if (debugOutput) console.log("*********SolarPanel thishour unixTime : " + parseInt(thishour.getTime()/1000))
		var http3 = new XMLHttpRequest()
		var url3 = "http://localhost/hcb_rrd?action=setRrdData&loggerName=elec_solar_quantity&rra=5yrhours&samples=%7B%22" + parseInt(thishour.getTime()/1000)+ "%22%3A" + parseInt(totalValue) + "%7D"
		if (debugOutput) console.log("*********SolarPanel url3 : " + url3)
		http3.open("GET", url3, true)
		http3.send()
	}

/////////////////////////////////////////WRITE DAILY DATA/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////At the beginning of the day//////////////////////////////////////////////////////////////////////////////////////

	function doDailyStuff(){
	
		//clear the old fiveminute array
		var newArray2 = []
		for (var g = 0; g <= 216; g++) {
			newArray2.push(0)
		}
		fiveminuteValues = newArray2	
		
		//clear the old production fiveminute array
		var newArray2Prod = []
		for (var g = 0; g <= 216; g++) {
			newArray2Prod.push(0)
		}
		fiveminuteValuesProd = newArray2Prod
		
		//clear the 5 minutes file so we will start a new fresh day
		var zeroString = "0"
		var zeroStringProd = "0"
		for (var z = 1; z <= 216; z++) { 
			zeroString += "," + "0"
			zeroStringProd += "," + "0"

		}
		solarPanel_fiveminuteValues.write(zeroString)
		solarPanel_fiveminuteValuesProd.write(zeroStringProd)
		
	
		//shift the last5day array 1 day to the left, push today the the last pos and create a new string
		var lastFiveDaysString = parseInt(lastFiveDays[1])
		for (var g = 2; g <= 4; g++) {
			 lastFiveDaysString += "," + parseInt(lastFiveDays[g])
		}
		lastFiveDaysString += "," + parseInt(todayValue)
		solarPanel_lastFiveDays.write(lastFiveDaysString)
		
		
		//calculate the average 5 day value for the daytile
		lastFiveDays = lastFiveDaysString.split(',')
		var totalForAvg = 0
		var avgcounter = 0
		for (var i in lastFiveDays){
			if (!isNaN(lastFiveDays[i]) & (parseInt(lastFiveDays[i])>0)){
					totalForAvg = totalForAvg + parseInt(lastFiveDays[i])
					avgcounter ++
				}
			}
		if((totalForAvg>0) && (avgcounter >3)) {dayAvgValue = parseInt(totalForAvg/avgcounter)} //calculate the avg for at least 3 days
		if (debugOutput) console.log("*********SolarPanel dayAvgValue : " + dayAvgValue)
		

		savedtotalValue = totalValue
		doDelayedDailyStuff()
		todayValue = 0
		yesterdayTotal = totalValue
		solarPanel_totalValue.write(parseInt(totalValue))
		solarPanel_lastWrite.write(dday + "-" + month)	
	}
	
	function doDelayedDailyStuff(){

		//it seems like the day is deleted when the new day is set so we just set the previos day again.
		//push quantity into the 10yrdays RRA data
		//produced this day so it must be in the RRA of thisday 00:00
		if (parseInt(savedtotalValue) ==0){savedtotalValue = totalValue}
		var thisday = new Date()
		thisday.setDate(thisday.getDate())
		thisday.setHours(1,0,0,0)  //to make it UTC
		if (debugOutput) console.log("*********SolarPanel thisday : " +  thisday.toString())
		if (debugOutput) console.log("*********SolarPanel thisday unixTime : " + parseInt(thisday.getTime()/1000))
		if (debugOutput) console.log("*********SolarPanel thisday value : " + parseInt(savedtotalValue)    + " set at " + dtime )
		var http4 = new XMLHttpRequest()	
		var url4 = "http://localhost/hcb_rrd?action=setRrdData&loggerName=elec_solar_quantity&rra=10yrdays&samples=%7B%22" + parseInt(thisday.getTime()/1000)+ "%22%3A" + parseInt(savedtotalValue) + "%7D"
		if (debugOutput) console.log("*********SolarPanel url4 : " + url4)
		http4.open("GET", url4, true)
        http4.send()
		
		
		//get sunrise and sunset
		var http = new XMLHttpRequest()	
		http.open("GET", weatherprovider, true)
		http.onreadystatechange = function() {
			if (http.readyState == XMLHttpRequest.DONE) {
				if (http.status == 200) {
					var JsonString = http.responseText
					var JsonObject= JSON.parse(JsonString)
					var suntime = new Date(JsonObject.actual.sunrise)
					console.log("*********SolarPanel suntime : " + suntime)	
					var sunhrs = parseInt(Qt.formatDateTime(suntime,"hh"))
					var sunmins = parseInt(Qt.formatDateTime(suntime,"mm"))
					var sunminsfromfive = ((sunhrs-5)*60) + sunmins
					sunrisePerc  = parseInt(100*sunminsfromfive/(18*60))
					suntime = new Date(JsonObject.actual.sunset)
					console.log("*********SolarPanel suntime : " + suntime)	
					sunhrs = parseInt(Qt.formatDateTime(suntime,"hh"))
					sunmins = parseInt(Qt.formatDateTime(suntime,"mm"))
					sunminsfromfive = ((sunhrs-5)*60) + sunmins
					sunsetPerc  = parseInt(100*sunminsfromfive/(18*60))
				}
			}
		}
        http.send()

		
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
				dtime = parseInt(Qt.formatDateTime (dateTimeNow,"hh") + "" + Qt.formatDateTime (dateTimeNow,"mm"))

				dday = dateTimeNow.getDate()
				month = parseInt(Qt.formatDateTime(dateTimeNow,"MM"))
				hrs = parseInt(Qt.formatDateTime(dateTimeNow,"hh"))
				mins = parseInt(Qt.formatDateTime(dateTimeNow,"mm"))
				var minsfromfive = ((hrs-5)*60) + mins
				minsfromfiveIndex  = parseInt(minsfromfive/5)
				if (debugOutput) console.log("*********SolarPanel minsfromfive : " + minsfromfive)
				if (debugOutput) console.log("*********SolarPanel dtime : " + dtime)
				if (debugOutput) console.log("*********SolarPanel minsfromfiveIndex : " + minsfromfiveIndex)
				
				if(enablePolling){			
					requestRRDData()
					getDataCount = 0
					getData()
				}
			}
				
    }
 
///////////////////////////////////////// SAVE ALL TO SETTINGS ///////////////////////////////////////////////////////////////////////////////////////////////// 

   	function saveSettings() {
	
		console.log("*********SolarPanel inverterCount  " + inverterCount)
		console.log("*********SolarPanel passWord  " + passWord)
		console.log("*********SolarPanel userName  " + userName)
		console.log("*********SolarPanel apiKey  " + apiKey)
		console.log("*********SolarPanel siteID  " + siteID)
		console.log("*********SolarPanel urlString  " + urlString)
		console.log("*********SolarPanel idx  " + idx)
		
		console.log("*********SolarPanel passWord2  " + passWord2)
		console.log("*********SolarPanel userName2 " + userName2)
		console.log("*********SolarPanel apiKey2  " + apiKey2)
		console.log("*********SolarPanel siteID2  " + siteID2)
		console.log("*********SolarPanel urlString2  " + urlString2)
		console.log("*********SolarPanel idx2  " + idx2)


		if (debugOutput) console.log("*********SolarPanel Savedata Started" )
		var tmpDebugOn = ""
		if (debugOutput == true) {tmpDebugOn = "Yes";} else {tmpDebugOn = "No";	}
		var tmpenableSleep = ""
		if (enableSleep == true) {tmpenableSleep = "Yes";} else {tmpenableSleep = "No";	}
		var tmpenablePolling = ""
		if (enablePolling == true) {tmpenablePolling = "Yes";} else {tmpenablePolling = "No";	}
		var setJson = {
			"inverterCount" 	: inverterCount,
			"selectedInverter-v2" 	: selectedInverter,
			"passWord" : passWord,
			"userName" : userName,
			"apiKey" : apiKey,
			"siteID" : siteID,
			"urlString" : urlString,
			"idx" : idx,
			"onlinePluginFileName" : onlinePluginFileName,
			"selectedInverter2-v2" 	: selectedInverter2,
			"passWord2" : passWord2,
			"userName2" : userName2,
			"apiKey2" : apiKey2,
			"siteID2" : siteID2,
			"urlString2" : urlString2,
			"idx2" : idx2,
			"onlinePluginFileName2" : onlinePluginFileName2,
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
