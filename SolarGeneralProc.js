/////////////////////////////////////////////////////////////////  GET SETTINGS /////////////////////////////////////////////
function getSettings(){
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
	
	if (selectedInverter == "Zonneplan"){
		zonneplan=true
		getZonneplanRefreshToken()
	}else{
		zonneplan=false
	}
}
///////////////////////////////////////// SAVE ALL TO SETTINGS ///////////////////////////////////////////////////////////////////////////////////////////////// 

   function saveSettings() {

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
//////////////////////////////////////////////////////////////// CLEAR ALL ARRAYS //////////////////////////////////////////

function clearAllArrays(){
	//clear graph arrays
	for (var i = 0; i <= 216; i++){fiveminuteValues[i] = 0}  //moet 216 zijn (15 uur /dag 12 x per uur (elke 5 mins))
	for (var i = 0; i <= 216; i++){fiveminuteValuesProd[i] = 0}  //moet 216 zijn (15 uur /dag 12 x per uur (elke 5 mins))
	for (var i = 0; i <= 24; i++){rollingfiveminuteValues[i] = 0 }
	for (var i = 0; i <= 24; i++){rollingfiveminuteValuesProd[i] = 0 }
	for (var i = 0; i <= 5; i++){lastFiveDays[i] = 0 }
}

//////////////////////////////////////////////////////////////// CHECK INVERTERS  //////////////////////////////////////////

function checkInvertersOnStart(){
	
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
}
/////////////////////////////////////////////////////////////// GET ALL SAVED DATA //////////////////////////////////////////

function getAllSavedData(){
	//get data from data/tsc/data  and rrs
	
	//get the last values from the data file
	if (debugOutput) console.log("*********SolarPanel trying to resolve old values")
	//calculate the average 5 day value for the daytile
	try {var lastFiveDaysString = solarPanel_lastFiveDays.read() ; if (lastFiveDaysString.length >2 ){lastFiveDays = lastFiveDaysString.split(',') }} catch(e) { }
	var totalForAvg = 0
	var avgcounter = 0
	for (var i in lastFiveDays){
		if (debugOutput) console.log("*********SolarPanel lastFiveDays[i]: " + lastFiveDays[i])
		if (!isNaN(lastFiveDays[i]) & (parseInt(lastFiveDays[i])>0)){
				totalForAvg = totalForAvg + parseInt(lastFiveDays[i])
				if (debugOutput) cconsole.log("*********SolarPanel parsed lastFiveDays[i]: " + lastFiveDays[i])
				avgcounter ++
			}
		}
	if((totalForAvg>0) && (avgcounter >3)) {dayAvgValue = parseInt(totalForAvg/avgcounter)} //calculate the avg for at least 3 days
	
	var todaydate = new Date()
	var todayFDate = (todaydate.getDate() + "-" + parseInt(Qt.formatDateTime(todaydate,"MM"))).toString().trim()
	var yesterdayDate = yesterday()

	//Try to resolve the yesterday total value from the RRA database
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
	
//////////////////////////////////////////////////////////////// SUNRISE AND SUNSET  //////////////////////////////////////////////////////////////////////////

function getSunTimes(){
	//get sunrise and sunset
	var http = new XMLHttpRequest()	
	http.open("GET", weatherprovider, true)
	http.onreadystatechange = function() {
		if (http.readyState == XMLHttpRequest.DONE) {
			if (http.status == 200) {
				var JsonString = http.responseText
				var JsonObject= JSON.parse(JsonString)
				var suntime = new Date(JsonObject.actual.sunrise)
				var sunhrs = parseInt(Qt.formatDateTime(suntime,"hh"))
				var sunmins = parseInt(Qt.formatDateTime(suntime,"mm"))
				var sunminsfromfive = ((sunhrs-5)*60) + sunmins
				sunrisePerc  = parseInt(100*sunminsfromfive/(18*60))
				suntime = new Date(JsonObject.actual.sunset)
				sunhrs = parseInt(Qt.formatDateTime(suntime,"hh"))
				sunmins = parseInt(Qt.formatDateTime(suntime,"mm"))
				sunminsfromfive = ((sunhrs-5)*60) + sunmins
				sunsetPerc  = parseInt(100*sunminsfromfive/(18*60))
			}
		}
	}
	http.send()	
}

//////////////////////////////////////////////////////////////// CURRENT DATA  //////////////////////////////////////////////////////////////////////////

function getCurrentUsage(host){
	if (debugOutput) console.log("*********SolarPanel getCurrentUsage")
	var url = "http://" + host + "/happ_pwrusage?action=GetCurrentUsage"
	var http = new XMLHttpRequest()
	http.open("GET", url, true);
	http.onreadystatechange = function() { // Call a function when the state changes.
				if (http.readyState === 4) {
					if (http.status === 200) {
						var JsonString = http.responseText
						var JsonObject= JSON.parse(JsonString)
						currentPowerProd = parseInt(JsonObject.powerProduction.value)
						currentUsage = parseInt(JsonObject.powerUsage.value)
						powerAvgValue = parseInt(JsonObject.powerUsage.avgValue)
						if (powerAvgValue ==0 ){powerAvgValue =1000}
						if (debugOutput) console.log("*********SolarPanel currentUsage" + currentUsage)
						if (debugOutput) console.log("*********SolarPanel currentPowerProd" + currentPowerProd)
					} else {
						if (debugOutput) console.log("*********SolarPanel error currentUsage ")
						currentPowerProd = 0
						currentUsage = 0
					}
				}
			}
	http.send();
}

//////////////////////////////////////////////////////////////// PRODU DATA  //////////////////////////////////////////////////////////////////////////
function yesterday(){
	var $date = new Date();
	$date.setDate($date.getDate()-1);
	return $date.getDate() + '-' + ($date.getMonth()+1) + '-' + $date.getFullYear()
}

function getProductionNt(host){

if (debugOutput) console.log("*********SolarPanel getProductionNt")
var yesterdayDate = yesterday()

//Try to resolve the production total based on the running total minus yesterday total from the RRA database
var http = new XMLHttpRequest()
var url = "http://" + host + "/hcb_rrd?action=getRrdData.csv&loggerName=elec_quantity_nt_produ&rra=10yrdays&from=" + yesterdayDate
http.open("GET", url, true)
http.onreadystatechange = function() { // Call a function when the state changes.
	if (http.readyState === 4) {
		if (http.status === 200) {
			var firstline = http.responseText.split("\n")[0]
			var yesterdayProduNt = parseInt(firstline.split(",")[1])
			if (debugOutput) console.log("*********SolarPanel yesterdayProduNt: " + yesterdayProduNt)
			var secondline = http.responseText.split("\n")[1]
			var todayProduNt = parseInt(secondline.split(",")[1])
			if (debugOutput) console.log("*********SolarPanel todayProduNt: " + todayProduNt)
			totalPowerProductionNt = todayProduNt - yesterdayProduNt
		} else {
			console.log("*********SolarPanel error: " + http.status)
			totalPowerProductionNt = 0
		}
	}
}
http.send()

}

function getProductionLt(host){

if (debugOutput) console.log("*********SolarPanel getProductionLt")
var yesterdayDate = yesterday()

//Try to resolve the production total based on the running total minus yesterday total from the RRA database
var http = new XMLHttpRequest()
var url = "http://" + host + "/hcb_rrd?action=getRrdData.csv&loggerName=elec_quantity_lt_produ&rra=10yrdays&from=" + yesterdayDate
http.open("GET", url, true)
http.onreadystatechange = function() { // Call a function when the state changes.
	if (http.readyState === 4) {
		if (http.status === 200) {
			var firstline = http.responseText.split("\n")[0]
			var yesterdayProduLt = parseInt(firstline.split(",")[1])
			if (debugOutput) console.log("*********SolarPanel yesterdayProduLt: " + yesterdayProduLt)
			var secondline = http.responseText.split("\n")[1]
			var todayProduLt = parseInt(secondline.split(",")[1])
			if (debugOutput) console.log("*********SolarPanel todayProduLt: " + todayProduLt)
			totalPowerProductionLt = todayProduLt - yesterdayProduLt
		} else {
			console.log("*********SolarPanel error: " + http.status)
			totalPowerProductionLt = 0
		}
	}
}
http.send()

}

//////////////////////////////////////////////////////////////// RRD  DATA  //////////////////////////////////////////////////////////////////////////
function push5minData(){
	//push current 5 minutes into the array for the RRA  flow
	var http2 = new XMLHttpRequest()
	var url2 = "http://localhost/hcb_rrd?action=setRrdData&loggerName=elec_solar_flow&rra=5min&samples=%7B%22" + parseInt(dateTimeNow.getTime()/1000)+ "%22%3A" + parseInt(currentPower) + "%7D"
	http2.open("GET", url2, true)
	http2.send()
}

function push5yrhoursData(){
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
}

	
function push10yrdaysData(){
	//push quantity into the 10yrdays RRA data
	//produced this day so it must be in the RRA of tomorrow 00:00 + offset
	var tomorrow = new Date()
	var offset = (-1*tomorrow.getTimezoneOffset())/60
	tomorrow.setDate(tomorrow.getDate() + 1)

	if (debugOutput) console.log("*********SolarPanel tomorrow offset: " +  offset)
	tomorrow.setHours(offset,0,0,0)  //to make it UTC
	if (debugOutput) console.log("*********SolarPanel tomorrow : " +  tomorrow.toString())
	if (debugOutput) console.log("*********SolarPanel tomorrow unixTime : " + parseInt(tomorrow.getTime()/1000))
	var http4 = new XMLHttpRequest()	
	var url4 = "http://localhost/hcb_rrd?action=setRrdData&loggerName=elec_solar_quantity&rra=10yrdays&samples=%7B%22" + parseInt(tomorrow.getTime()/1000)+ "%22%3A" + parseInt(totalValue) + "%7D"
	if (debugOutput) console.log("*********SolarPanel url4 : " + url4)
	http4.open("GET", url4, true)
	http4.send()
}


function getZonneplanRefreshToken(){

	if (debugOutput) console.log("*********SolarPanel Start getZonneplanRefreshToken()")
	
	var http = new XMLHttpRequest()
	var url = "https://app-api.zonneplan.nl/oauth/token"
	var rfToken = ""
	try{
		rfToken = (solarPanel_refreshtoken.read()).trim()
	}catch(e) {
	}
	if (debugOutput) console.log("*********SolarPanel refreshtoken " + rfToken)
	var params = "{\"grant_type\": \"refresh_token\",\"refresh_token\": \"" + rfToken + "\"}"
	if (debugOutput) console.log("*********SolarPanel url " + url)
	if (debugOutput) console.log("*********SolarPanel params : " + params)
	http.open("POST", url, true);
	http.setRequestHeader("content-type", "application/json;charset=utf-8");
	http.setRequestHeader("x-app-version","2.1.1");
	http.withCredentials = true;
	http.onreadystatechange = function() { // Call a function when the state changes.
		if (debugOutput) console.log("*********SolarPanel refreshtoken readyState" + http.readyState)
		if (http.readyState === 4) {
			if (http.status === 200) {
				if (debugOutput) console.log("*********SolarPanel http.responseText " + http.responseText)
				var JsonString = http.responseText
				var JsonObject= JSON.parse(JsonString)
				zonneplanToken = JsonObject.access_token
				zonneplanRefreshToken = JsonObject.refresh_token
				if (debugOutput) console.log("*********SolarPanel token : " + zonneplanToken)
				if (debugOutput) console.log("*********SolarPanel RefreshToken : " + zonneplanRefreshToken)
				if (debugOutput) console.log("*********SolarPanel save refreshtoken" )
				solarPanel_refreshtoken.write(zonneplanRefreshToken)
				scrapeTimer.interval = 20000
			} else {
				if (debugOutput) console.log("*********SolarPanel refreshtoken http.status error " + http.status)
			}
		}
	}
	http.send(params);
}
