//
// SolarPanel by Oepi-Loepi
//

import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
import FileIO 1.0

App {
	id: solarPanelApp

	property url 	tileUrl : "SolarPanelTile.qml"
	property url 	tileUrl2 : "SolarPanelTile2.qml"
	property url 	tileUrl3 : "SolarPanelTile3.qml"
	//property url 	thumbnailIcon: "qrc:/tsc/BalloonIcon.png"
	//property url 	thumbnailIcon2: "qrc:/tsc/BalloonIcon.png"
	
	property url 	thumbnailIcon: "qrc:/tsc/HomeSunny"
	property url 	thumbnailIcon2: "qrc:/tsc/HomeSunny"
	property url 	thumbnailIcon3: "qrc:/tsc/HomeSunny"
	
	property		SolarPanelScreen solarPanelScreen
	property url 	solarPanelScreenUrl : "SolarPanelScreen.qml"
	property		SolarPanelDayScreen solarPanelDayScreen
	property url 	solarPanelDayScreenUrl : "SolarPanelDayScreen.qml"
	property		SolarPanelMonthScreen solarPanelMonthScreen
	property url 	solarPanelMonthScreenUrl : "SolarPanelMonthScreen.qml"
	property		SolarPanelTodayScreen solarPanelTodayScreen
	property url 	solarPanelTodayScreenUrl : "SolarPanelTodayScreen.qml"
	property		SolarPanelConfigScreen solarPanelConfigScreen
	property url 	solarPanelConfigScreenUrl : "SolarPanelConfigScreen.qml"
	
	property string currentPower : "0"
    property string dtime : "0001"
    property string todayValue : "0"
    property string monthValue : "0"
	property string yearValue : "0"
    property string totalValue : "0"
	property int 	maxWattage : 300
	property int 	tempConfigListIndex
	property string rollingMinX :"07:00"
	property string rollingCenterX : "08:00"
    property string rollingMaxX :"09:00"
	property int 	x2
	property int 	nextday
	
	property bool enableSleep : false
	property bool debugOutput : true						// Show console messages. Turn on in settings file !
	
	
	property variant dayValues: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	//property variant dayValues: [0,121,10,2,10,194,6,34,67,42,24,65,13,86,89,54,12,12,65,21,76,56,78,78,56,65,0,0,0,100,100,45]
	property variant prevMonthDayValues: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	
    property variant monthValues: [0,0,0,0,0,0,0,0,0,0,0,0,0]
	//property variant monthValues: [0,130,140,123,123,130,130,0,313,130,131,130,111]
	property variant prevYearMonthValues: [0,0,0,0,0,0,0,0,0,0,0,0,0]
	
	property variant yearValues:  [0,0,0,0,0,0,0,0,0,0,0]
	property int 	 oldYearValue : 0
	
	property variant fiveminuteValues: []
	property variant yesterday: []
	property variant rollingfiveminuteValues:[]
	
	property string selectedInverter: ""
	property string growattUserName: "GrowattUser"
	property string growattPassWord: "GrowattPass"
	
	property string solarEdgeSiteID: "SolarEdgeSite"
	property string solarEdgeApiKey: "SolarEdgeApi"
	
	property string froniusUrl: "Fronius URL"
	
	property string smaUrl: "SMA URL"
	property string smaPassWord : "SMA Password"
	
	property string kostalUrl : ""
	
	property string zeversolarUrl : ""
	
	property variant solarpanelSettingsJson : {
			'selectedInverter': "",
			'growattUserName': "",
			'growattPassWord' : "",
			'solarEdgeSiteID' : "",
			'solarEdgeApiKey': "",
			'froniusUrl': "",
			'smaUrl': "",
			'smaPassWord': "",
			'kostalUrl': "",
			'seversolarUrl': "",
			'enableSleep' : "",
			'DebugOn': ""
	}

	function getData(){
		if (selectedInverter.toLowerCase()=="growatt") getGrowattStep1()
		if (selectedInverter.toLowerCase()=="solaredge") getSolarEdgeData()
		if (selectedInverter.toLowerCase()=="fronius") getFroniusData()
		if (selectedInverter.toLowerCase()=="sma") getSmaStep1()
		if (selectedInverter.toLowerCase()=="kostal piko") getKostalData()
		if (selectedInverter.toLowerCase()=="zeversolar") getZeversolarData()
    }
	

	function init() {
		registry.registerWidget("tile", tileUrl, this, null, {thumbLabel: qsTr("Solar Grafiek"), thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", tileUrl2, this, null, {thumbLabel: qsTr("SolarPanel 2"), thumbIcon: thumbnailIcon2, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", tileUrl3, this, null, {thumbLabel: qsTr("Solar Rolling"), thumbIcon: thumbnailIcon3, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		
		registry.registerWidget("screen", solarPanelScreenUrl, this, "solarPanelScreen")
		registry.registerWidget("screen", solarPanelDayScreenUrl, this, "solarPanelDayScreen")
		registry.registerWidget("screen", solarPanelMonthScreenUrl, this, "solarPanelMonthScreen")
		registry.registerWidget("screen", solarPanelTodayScreenUrl, this, "solarPanelTodayScreen")
		registry.registerWidget("screen", solarPanelConfigScreenUrl, this, "solarPanelConfigScreen")
	}

	FileIO {id: solarpanelSettingsFile;	source: "file:///mnt/data/tsc/solarpanel_userSettings.json"}
	FileIO {id: solarPanel_fiveminuteValues;	source: "file:///mnt/data/tsc/appData/solarPanel_fiveminuteValues.txt"}
	FileIO {id: solarPanel_yesterday;	source: "file:///mnt/data/tsc/appData/solarPanel_yesterday.txt"}
	FileIO {id: solarPanel_dailyTotals;	source: "file:///mnt/data/tsc/appData/solarPanel_dailyTotals.txt"}
	FileIO {id: solarPanel_dailyTotals_prevMonth;	source: "file:///mnt/data/tsc/appData/solarPanel_dailyTotals_prevMonth.txt"}
	FileIO {id: solarPanel_monthTotals;	source: "file:///mnt/data/tsc/appData/solarPanel_monthTotals.txt"}
	FileIO {id: solarPanel_yearValues;	source: "file:///mnt/data/tsc/appData/solarPanel_yearValues.txt"}
	FileIO {id: solarPanel_monthTotals_prevYear;	source: "file:///mnt/data/tsc/appData/solarPanel_monthTotals_prevYear.txt"}
	FileIO {id: solarPanel_totalValue;	source: "file:///mnt/data/tsc/appData/solarPanel_totalValue.txt"}
	FileIO {id: solarPanel_oldYearValue;	source: "file:///mnt/data/tsc/appData/solarPanel_oldYearValue.txt"}
	FileIO {id: solarPanel_lastWrite;	source: "file:///mnt/data/tsc/appData/solarPanel_lastWrite.txt"}

		
	Component.onCompleted: { //clear array
		for (var i = 0; i <= 180; i++){fiveminuteValues[i] = 0}  //moet 180 zijn (15 uur /dag 12 x per uur (elke 5 mins))
		for (var c = 0; c <= 180; c++){yesterday[i]= 0	}
		for (var k = 0; k <= 31; k++){dayValues[k] = 0 }
		for (var m = 0; m <= 31; m++){prevMonthDayValues[m] = 0 }
		for (var a = 0; a <= 12; a++){monthValues[a] = 0 }
		for (var b = 0; b <= 12; b++){prevYearMonthValues[b] = 0 }
		for (var d = 0; d <= 24; d++){rollingfiveminuteValues[d] = 0 }
		for (var e = 0; e <= 10; e++){yearValues[e] = 0 }

		
		try {
			solarpanelSettingsJson = JSON.parse(solarpanelSettingsFile.read())
			selectedInverter = solarpanelSettingsJson['selectedInverter']
			growattUserName = solarpanelSettingsJson['growattUserName']
			growattPassWord = solarpanelSettingsJson['growattPassWord']
			solarEdgeSiteID = solarpanelSettingsJson['solarEdgeSiteID']
			solarEdgeApiKey = solarpanelSettingsJson['solarEdgeApiKey']
			froniusUrl = solarpanelSettingsJson['froniusUrl']
			smaUrl = solarpanelSettingsJson['smaUrl']
			smaPassWord = solarpanelSettingsJson['smaPassWord']
			kostalUrl = solarpanelSettingsJson['kostalUrl']
			zeversolarUrl = solarpanelSettingsJson['zeversolarUrl']
			if (solarpanelSettingsJson['enableSleep'] == "Yes") {enableSleep = true} else {enableSleep = false}
			//if (solarpanelSettingsJson['DebugOn'] == "Yes") {debugOutput = true} else {debugOutput = false}
		} catch(e) {
		}

		try {var fiveminuteValuesString = solarPanel_fiveminuteValues.read() ; if (fiveminuteValuesString.length >2 ){ fiveminuteValues = fiveminuteValuesString.split(',') }} catch(e) { }
		try {var yesterdayString = solarPanel_yesterday.read() ; if (yesterdayString.length >2 ){yesterday = yesterdayString.split(',')}} catch(e) { }
		try {var dayValuesString = solarPanel_dailyTotals.read() ; if (dayValuesString.length >2 ){dayValues = dayValuesString.split(',')}} catch(e) {}
		try {var prevMonthDayValuesString = solarPanel_dailyTotals_prevMonth.read() ; if (fprevMonthDayValuesString.length >2 ){prevMonthDayValues = prevMonthDayValuesString.split(',')}} catch(e) {}
		try {var monthValuesString = solarPanel_monthTotals.read() ; if (monthValuesString.length >2 ){monthValues = monthValuesString.split(',')}} catch(e) {}
		try {var prevYearMonthValuesString = solarPanel_monthTotals_prevYear.read() ; if (prevYearMonthValuesString.length >2 ){prevYearMonthValues = prevYearMonthValuesString.split(',')}} catch(e) {}		
		try {var yearValuesString = solarPanel_yearValues.read; if (yearValuesString.length >2 ){yearValues = yearValuesString.split(',')}} catch(e) {}
		try {var totalValueString = solarPanel_totalValue.read; if (totalValueString.length > 0 ){totalValue = parseInt(totalValueString)}} catch(e) {}
		try {oldYearValue = solarPanel_oldYearValue.read} catch(e) {}
		try {var solarPanel_lastWriteString = solarPanel_lastWrite.read} catch(e) {}
		
		if (debugOutput) console.log("*********SolarPanel trying to resolve old values")
		var todaydate = new Date()
		currentPower = 0
		todayValue = dayValues[todaydate.getDate()]
		monthValue = monthValues[todaydate.getMonth()+1]
		yearValue = yearValues[todaydate.getFullYear()-2020]
		
		try {
			if (debugOutput) console.log("*********SolarPanel starting to load lastwrite timestamp file")
			var oldDateStr = solarPanel_lastWrite.read()
			if (debugOutput) console.log("*********SolarPanel oldDateStr:" + oldDateStr)
			if (oldDateStr.length > 2 ){	
			//old timestamp found
				var todayFDate = Qt.formatDate(todaydate, "yyMMdd")
				var yesterdayDate =  Qt.formatDate(new Date(todaydate.getFullYear(), todaydate.getMonth(), todaydate.getDate()-1), "yyMMdd")
				var lastWriteDate =  Qt.formatDate(new Date (oldDateStr), "yyMMdd")

				if (debugOutput) console.log("*********SolarPanel todayFDate:" + todayFDate)
				if (debugOutput) console.log("*********SolarPanel yesterdayDate:" + yesterdayDate)
				if (debugOutput) console.log("*********SolarPanel lastWriteDate:" + lastWriteDate)

				if  (lastWriteDate != todayFDate){							//timestamp is not from today so do something
					if (debugOutput) console.log("*********SolarPanel last timestamp is older than today")
					if (lastWriteDate == yesterdayDate){
							yesterday = fiveminuteValues; 
							if (debugOutput) console.log("*********SolarPanel last timestamp is from yesterday so copy today to yesterday")
					}
					if (lastWriteDate != todayFDate){
							for (var i = 0; i <= 180; i++){fiveminuteValues[i] = 0}; 
							if (debugOutput) console.log("*********SolarPanel last timestamp is not from today so clear 5 min array")
					}
					if (lastWriteDate != yesterdayDate & lastWriteDate != todayFDate ){
							for (var c = 0; c <= 180; c++){yesterday[i]= 0} ; 
							if (debugOutput) console.log("*********SolarPanel last timestamp is not from today or yesterday so also clear yesterday array")
					} 
					if (lastWriteDate.getMonth() == (todayFDate.getMonth()-1)) {
							prevMonthDayValues = dayValues  ; 
							if (debugOutput) console.log("*********SolarPanel last timestamp is from prev month so copy day array to prev day array")
					} 
					if (lastWriteDate.getMonth() != todayFDate.getMonth()) {
							for (var k = 0; k <= 31; k++){dayValues[k] = 0 }; 
							if (debugOutput) console.log("*********SolarPanel last timestamp is not from this month so clear day array")
					} 
					if (lastWriteDate.getMonth() != todayFDate.getMonth() & lastWriteDate.getMonth() != (todayFDate.getMonth()-1) ) {
							for (var m = 0; m <= 31; m++){prevMonthDayValues[m] = 0 } ; 
							if (debugOutput) console.log("*********SolarPanel last timestamp is not from this month or prev month so also clear prev day array")
					}
					if (lastWriteDate.getFullYear() != (todayFDate.getFullYear()-1)) {
							prevYearMonthValues = monthValues
							if (debugOutput) console.log("*********SolarPanel last timestamp is from prev year so copy month array to prev month array")
					} 
					if (lastWriteDate.getFullYear() != todayFDate.getFullYear()) {
							for (var a = 0; a <= 12; a++){monthValues[a] = 0 }
							if (debugOutput) console.log("*********SolarPanel last timestamp is not from this year so clear month array")
					} 
					if (lastWriteDate.getFullYear() != todayFDate.getFullYear() & lastWriteDate.getFullYear() != (todayFDate.getFullYear()-1)) {
							for (var b = 0; b <= 12; b++){prevYearMonthValues[b] = 0 }
							if (debugOutput) console.log("*********SolarPanel last timestamp is not from this year or prev year so also clear prev month array")
					}
				}
			}
		} 
		catch(e) {
		}

		if (debugOutput) console.log("*********SolarPanel currentPower:" + currentPower)
		if (debugOutput) console.log("*********SolarPanel day:" + todayValue)
		if (debugOutput) console.log("*********SolarPanel month:" + monthValue)
		if (debugOutput) console.log("*********SolarPanel year:" + yearValue)
		if (debugOutput) console.log("*********SolarPanel total:" + totalValue)
		if (debugOutput) console.log("*********SolarPanel oldYearValue:" + oldYearValue)

	}
	
/////////////////////////////////////////////////////////////////GROWATT//////////////////////////////////////////////////////////////////////////////	

    function getGrowattStep1(){
            if (debugOutput) console.log("*********SolarPanel Start getGrowattStep1")
            var http = new XMLHttpRequest()
            var url = "http://server-api.growatt.com/newLoginAPI.do";
            var username = growattUserName
            var password = growattPassWord
            if (debugOutput) console.log("*********SolarPanel Hashed password: " + Qt.md5(password))
            var params = "password=" + Qt.md5(password) + "&userName=" + username
            http.open("POST", url, true)
            http.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
            http.setRequestHeader("Content-length", params.length)
            http.setRequestHeader("Connection", "close")
            http.setUserAgent = "Dalvik/2.1.0 (Linux; U; Android 9; ONEPLUS A6003 Build/PKQ1.180716.001"
            http.onreadystatechange = function() { // Call a function when the state changes.
                        if (http.readyState === 4) {
                            if (http.status === 200) {
                                 getGrowattStep2();
                            } else {
                                if (debugOutput) console.log("*********SolarPanel error: " + http.status)
                            }
                        }
                    }
            http.send(params);
    }

    function getGrowattStep2(){
        if (debugOutput) console.log("*********SolarPanel Start getGrowattStep2")
        var http = new XMLHttpRequest()
        var url2 = "http://server-api.growatt.com/newPlantAPI.do?action=getUserCenterEnertyData"
        http.open("POST", url2, true)
        http.setRequestHeader("Referer", "http://server.growatt.com/LoginAPI.do")
        http.setUserAgent = "Dalvik/2.1.0 (Linux; U; Android 9; ONEPLUS A6003 Build/PKQ1.180716.001"
        http.onreadystatechange = function() { // Call a function when the state changes.
                    if (http.readyState === 4) {
                        if (http.status === 200) {
                            if (debugOutput) console.log("*********SolarPanel Growatt: " + http.responseText)
                            var JsonString = http.responseText
                            var JsonObject= JSON.parse(JsonString)
                            currentPower = parseInt(JsonObject.powerValue)
                            todayValue = parseFloat(JsonObject.todayValue).toFixed(2)
							monthValue = parseFloat(JsonObject.monthValue).toFixed(1)
							yearValue = parseInt(JsonObject.yearValue)
                            totalValue= Math.floor(JsonObject.totalValue)
                            doData()
                        } else {
                            if (debugOutput) console.log("*********SolarPanel error: " + http.status)
                        }
                    }
                }
        http.send();
    }
/////////////////////////////////////////////////////////////////SOLAREDGE//////////////////////////////////////////////////////////////////////////////	
   function getSolarEdgeData(){
		if (debugOutput) console.log("*********SolarPanel Start getSolarEdgeData")
		var fingerprint = "69 01 51 C2 49 16 4A 38 93 FA 7C A8 E4 BC 61 9A 25 4B 98 BF"
		var http = new XMLHttpRequest();
		http.open("GET", "https://monitoringapi.solaredge.com/site/" + solarEdgeSiteID + "/overview.json?api_key=" + solarEdgeApiKey, true)
		if (debugOutput) console.log("*********SolarPanel solaredgeUrl: " + "https://monitoringapi.solaredge.com/site/" + solarEdgeSiteID + "/overview.json?api_key=" + solarEdgeApiKey)
		http.onreadystatechange = function() {
			if (http.readyState == XMLHttpRequest.DONE) {
					if (http.status === 200 || http.status === 300  || http.status === 302) {
						if (debugOutput) console.log("*********SolarPanel SolarEdge  ResponseText:" + http.responseText)
						var JsonString = http.responseText
						var JsonObject= JSON.parse(JsonString)
						currentPower = parseInt(JsonObject.overview.currentPower.power)					
						todayValue = (JsonObject.overview.lastDayData.energy /1000).toFixed(2)
						monthValue = (JsonObject.overview.lastMonthData.energy /1000).toFixed(1)
						yearValue = parseInt(JsonObject.overview.lastYearData.energy /1000)
						totalValue= Math.floor(JsonObject.overview.lifeTimeData.energy /1000)
						
						if (debugOutput) console.log("*********SolarPanel currentPower:" + currentPower)
						if (debugOutput) console.log("*********SolarPanel day:" + todayValue)
						if (debugOutput) console.log("*********SolarPanel month:" + monthValue)
						if (debugOutput) console.log("*********SolarPanel year:" + yearValue)
						if (debugOutput) console.log("*********SolarPanel total:" + totalValue)

						doData()
					} else {
						if (debugOutput) console.log("*********SolarPanel error: " + http.status)
					}
			}
		}
		http.send(fingerprint);
    }
	
/////////////////////////////////////////////////////////////////FRONIUS//////////////////////////////////////////////////////////////////////////////	

	function getFroniusData(){
		if (debugOutput) console.log("*********SolarPanel Start getFroniusData")
		var http = new XMLHttpRequest();
		http.open("GET", "http://" + froniusUrl + "/solar_api/v1/GetInverterRealtimeData.cgi?Scope=Device&DeviceID=1&DataCollection=CommonInverterData", true)
		http.onreadystatechange = function() {
			if (http.readyState == XMLHttpRequest.DONE) {
					if (http.status === 200 || http.status === 300  || http.status === 302) {
						var JsonString = http.responseText
						var JsonObject= JSON.parse(JsonString)
						var froniusCode = parseInt(JsonObject.Head.Status.Code)
						if (froniusCode == 0) {    //All Ok
							var froniusStatus = parseInt(JsonObject.Body.Data.DeviceStatus.StatusCode)
							if (froniusStatus == 7) {
								currentPower = parseInt(JsonObject.Body.Data.PAC.Value)					
								todayValue = (JsonObject.Body.Data.DAY_ENERGY.Value /1000).toFixed(2)
								monthValue = (getArraySum(dayValues) + todayValue).toFixed(1)
								yearValue = parseInt(JsonObject.Body.Data.YEAR_ENERGY.Value /1000)
								totalValue= Math.floor(JsonObject.Body.Data.TOTAL_ENERGY.Value /1000)
								doData()
							}
						}						
					} else {
						if (debugOutput) console.log("*********SolarPanel error: " + http.status)
					}
			}
		}
		http.send()
    }

//////////////////////////////////////////////////////////// SMA ////////////////////////////////////////////////////////////////////////////////////


    function getSmaStep1(){
		if (debugOutput) console.log("*********SolarPanel Start getSmaStep1")
		var http = new XMLHttpRequest()
		var url = "https://" + smaUrl + "dyn/login.json"
		var params = "{\"right\":\"istl\",\"pass\":\"" + smaPassWord + "\"}"
		if (debugOutput) console.log("*********SolarPanel params " + params)
		http.open("POST", url, true);
		http.setRequestHeader("Accept", "application/json, text/plain, */*")
		http.setRequestHeader("Content-type", "application/json;charset=UTF-8")
		http.setRequestHeader("Origin", "https://" + smaUrl)
		http.setRequestHeader("Connection", "Keep-alive");
		http.setRequestHeader("Content-length", params.length)

		http.onreadystatechange = function() { // Call a function when the state changes.
			if (http.readyState === 4) {
				if (http.status === 200) {
					var JsonString = http.responseText
					var JsonObject= JSON.parse(JsonString)
					var smaSID = parseInt(JsonObject.result.sid)
					if (debugOutput) console.log("*********SolarPanel Session ID " + smaSID)
					getSmaStep2(smaSID)
				} else {
					if (debugOutput) console.log("*********SolarPanel error: " + http.status)
				}
			}
		}
		http.send(params);
    }

    function getSmaStep2(smaSID){
		if (debugOutput) console.log("*********SolarPanel Start getSmaStep2")
		var http = new XMLHttpRequest()
		var url2 = "https://" + smaUrl +  "getValues.json?sid=" + smaSID
		var params = "{\"destDev\":[],\"keys\":[\"6400_00260100\",\"6400_00262200\",\"6100_40263F00\"]}"
		if (debugOutput) console.log("*********SolarPanel params " + params)
		http.open("POST", url2, true);
		http.setRequestHeader("Accept", "application/json, text/plain, */*")
		http.setRequestHeader("Content-type", "application/json;charset=UTF-8")
		http.setRequestHeader("Connection", "Keep-alive");
		http.setRequestHeader("Content-length", params.length)

		http.onreadystatechange = function() { // Call a function when the state changes.
			if (http.readyState === 4) {
				if (http.status === 200) {
					if (debugOutput) console.log("*********SolarPanel SMA: " + http.responseText)
					var JsonString = http.responseText
					var JsonObject= JSON.parse(JsonString)
					var ident1 = "012F-730B00E6"
					var currentident = "6100_40263F00"
					var dayident = "6400_00262200"
					var totalident = "6400_00260100"
					var zeroident = "0"
					var oneident = "1"

					if ( typeof(JsonObject.result.ident1.currentident.oneident.zeroident.val) != "undefined") currentPower = parseInt(JsonObject.result.ident1.currentident.oneident.zeroident.val)
					if ( typeof(JsonObject.result.ident1.dayident.oneident.zeroident.val) != "undefined") todayValue = parseFloat(JsonObject.result.ident1.dayident.oneident.zeroident.val).toFixed(2)
					monthValue = (getArraySum(dayValues) + todayValue).toFixed(1)
					if ( typeof(JsonObject.result.ident1.totalident.oneident.zeroident.val) != "undefined") totalValue = Math.floor(JsonObject.result.ident1.totalident.oneident.zeroident.val)
					yearValue = 0

					doData()
				} else {
					if (debugOutput) console.log("*********SolarPanel error: " + http.status)
				}
			}
		}
        http.send();
    }


/////////////////////////////////////////////////////////////////KOSTAL PIKO //////////////////////////////////////////////////////////////////////////////	

	function getKostalData(){
		if (debugOutput) console.log("*********SolarPanel Start getKostalData")
		var http = new XMLHttpRequest();
		http.open("GET", "http://pvserver:pvwr@" + kostalUrl, true)
		//http.open("GET", "http://localhost/tsc/kostal.html", true)
		http.onreadystatechange = function() {
			if (http.readyState == XMLHttpRequest.DONE) {
				if (http.status === 200 || http.status === 300  || http.status === 302) {
					if (debugOutput) console.log("*********SolarPanel http.responseText: " +http.responseText)
					var responseText = http.responseText

					var kostalarray = responseText.split('bgcolor="#FFFFFF">')
					for(var x in kostalarray){
						//if (debugOutput) console.log("*********SolarPanel kostalarray[" + x + "]: " + kostalarray[x])
						//if (debugOutput) console.log("*********SolarPanel kostalarray[" + x + "] Parsed: " + parseFloat(kostalarray[x]))
						if (isNaN(parseFloat(kostalarray[x]))){kostalarray[x]=0}
					}
					currentPower = parseInt(parseFloat(kostalarray[1]))					
					todayValue = (parseFloat(kostalarray[3])).toFixed(2)
					monthValue = (parseFloat(getArraySum(dayValues)) + parseFloat(todayValue)).toFixed(1)
					yearValue = parseInt(parseFloat(kostalarray[2]) /1000)
					totalValue= Math.floor(parseFloat(kostalarray[2]))
					doData()
				} else {
					if (debugOutput) console.log("*********SolarPanel error: " + http.status)
				}
			}
		}
		http.send()
    }

///////////////////////////////////////////////////////////////// ZEVERSOLAR //////////////////////////////////////////////////////////////////////////////	

	function getZeversolarData(){
		if (debugOutput) console.log("*********SolarPanel Start getZeversolarData")
		var http = new XMLHttpRequest();
		http.open("GET", "http://" + zeversolarUrl +  "/home.cgi", true)
		//http.open("GET", "http://localhost/tsc/zeversolar.html", true)
		http.onreadystatechange = function() {
			if (http.readyState == XMLHttpRequest.DONE) {
				if (http.status === 200 || http.status === 300  || http.status === 302) {
						if (debugOutput) console.log("*********SolarPanel http.responseText: " +http.responseText)
						var responseText = http.responseText
						var zeversolararray = responseText.split("\n")
						if (zeversolararray[12]=="OK"){
							currentPower = parseInt(parseFloat(zeversolararray[10]))
							var zevensolarString = zeversolararray[11].split(".")
							if (zevensolarString[1].length==1){todayValue = (parseFloat(zevensolarString[0] + ".0" + zevensolarString[1])).toFixed(2)}
							if (zevensolarString[1].length==0 || zevensolarString[1].length==2){todayValue = parseFloat(zeversolararray[11]).toFixed(2)}
							if (debugOutput) console.log("*********SolarPanel parseFloat(getArraySum(dayValues)): " +parseFloat(getArraySum(dayValues)))
							if (debugOutput) console.log("*********SolarPanel parseFloat(todayValue): " +parseFloat(todayValue))
							monthValue = (parseFloat(getArraySum(dayValues)) + parseFloat(todayValue)).toFixed(1)
							if (debugOutput) console.log("*********SolarPanel monthValue: " +monthValue)
							yearValue = parseInt(parseFloat(getArraySum(monthValues)))
							totalValue= 0
							doData()
						}
				} else {
						if (debugOutput) console.log("*********SolarPanel error: " + http.status)
				}
			}
		}
		http.send()
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
		if (debugOutput) console.log("*********SolarPanel day:" + todayValue)
		if (debugOutput) console.log("*********SolarPanel month:" + monthValue)
		if (debugOutput) console.log("*********SolarPanel year:" + yearValue)
		if (debugOutput) console.log("*********SolarPanel total:" + totalValue)
		
		var newArray = []
		newArray = fiveminuteValues
		newArray[x2] = parseInt(currentPower)
		fiveminuteValues = newArray
		
		if (mins >= 10 & mins < 16){  //every hour
			//Write 5minute values to file
			var fiveminuteValuesString = fiveminuteValues[0]
			for (var j = 1; j <= 180; j++) { 
				fiveminuteValuesString += "," + fiveminuteValues[j]
			}
			solarPanel_fiveminuteValues.write(fiveminuteValuesString)
		
			//Write new daytotal to daily file  each hour
			dayValues[dday] = parseFloat(todayValue).toFixed(2)
			var dayTotal2 = dayValues[0]
			for (var t = 1; t <= 31; t++) { 
				dayTotal2 += "," + dayValues[t]
			}
			solarPanel_dailyTotals.write(dayTotal2)
			
			//write last month totals to file each hour
			monthValues[d.getMonth()+1] = parseFloat(monthValue).toFixed(1)
			var monthTotal2 = monthValues[0]
			for (var s2 = 1; s2 <= 12; s2++) { 
				monthTotal2 += "," + monthValues[s2]
			}
			solarPanel_monthTotals.write(monthTotal2)
			
			//write last year totals to file
			yearValues[d.getFullYear()-2020] = Math.floor(yearValue)
			var yearTotal = yearValues[0]
			for (var p = 0; p <= 10; p++) { 
				yearTotal += "," + yearValues[p]
			}
			solarPanel_yearValues.write(yearTotal)
			
			solarPanel_lastWrite.write(d)
		}

		//make new rolling array each 5 mins
		if (debugOutput) console.log("*********SolarPanel calculating rollingfiveminuteValues minsfromseven" + minsfromseven)
		var x2now  = parseInt(minsfromseven/5)
		var x2twohoursAgo  = x2now - 24  //less 2 hours
		var newArray5 = []
		for (var y = x2twohoursAgo; y <= x2now; y++) { 
							newArray5.push(fiveminuteValues[y])
						}
		rollingfiveminuteValues = newArray5

		var now = new Date(d.getFullYear(), d.getMonth(), d.getDate(), d.getHours(), d.getMinutes())
		var oneHoursEarlier= new Date(d.getFullYear(), d.getMonth(), d.getDate(), d.getHours()-1, d.getMinutes())
		var twoHoursEarlier= new Date(d.getFullYear(), d.getMonth(), d.getDate(), d.getHours()-2, d.getMinutes())
		rollingMinX = Qt.formatDateTime(twoHoursEarlier,"hh") + ":" + Qt.formatDateTime(twoHoursEarlier,"mm")
		rollingCenterX = Qt.formatDateTime(oneHoursEarlier,"hh") + ":" + Qt.formatDateTime(oneHoursEarlier,"mm")
		rollingMaxX = Qt.formatDateTime(now,"hh") + ":" + Qt.formatDateTime(now,"mm")
		if (debugOutput) console.log("*********SolarPanel rollingMinX " + rollingMinX)
		if (debugOutput) console.log("*********SolarPanel rollingCenterX " + rollingCenterX)
		if (debugOutput) console.log("*********SolarPanel rollingMaxX " + rollingMaxX)
		
    }


	function witeDailyData(){
		if (debugOutput) console.log("*********SolarPanel dtime: " + dtime )
	
	//Write 5minute values to file
		yesterday = fiveminuteValues
		var yesterdayString = yesterday[0]
		for (var j = 1; j <= 180; j++) { 
			yesterdayString += "," + yesterday[j]
		}
		solarPanel_yesterday.write(yesterdayString)

	//clear the old fiveminute array
		var newArray2 = []
		for (var g = 0; g <= 180; g++) {
			newArray2.push(0)
		}
		fiveminuteValues = newArray2
	
	//clear the 5 minutes file so we will start a new fresh day
		var zeroString = "0"
		for (var z = 1; z <= 180; z++) { 
			yesterdayString += "," + "0"
		}
		solarPanel_fiveminuteValues.write(zeroString)
	
	//Write new daytotal to daily file
		dayValues[dday] = parseFloat(todayValue).toFixed(2)
		var dayTotal = dayValues[0]
		for (var h = 1; h <= 31; h++) { 
			dayTotal += "," + dayValues[h]
		}
		solarPanel_dailyTotals.write(dayTotal)
	
	//write total to file
		solarPanel_totalValue.write(parseInt(totalValue))
	
		solarPanel_lastWrite.write(d)

	
	
	function writeMonthlyData(){
	
		//write last daily totals to file
			prevMonthDayValues = dayValues
			var prevMonthDayValuesString = prevMonthDayValues[0]
			for (var m = 1; m <= 31; m++) { 
				prevMonthDayValuesString += "," + prevMonthDayValues[m]
			}
			solarPanel_dailyTotals_prevMonth.write(prevMonthDayValuesString)

		//clear the old daily totals array
			var newArray3 = []
			for (var n = 0; n <= 31; n++) {
				newArray3.push(0)
			}
			dayValues = newArray3
			

			//write last year totals to file
			yearValues[d.getFullYear()-2020] = Math.floor(yearValue)
			var yearTotal = yearValues[0]
			for (var p = 0; p <= 10; p++) { 
				yearTotal += "," + yearValues[p]
			}
			solarPanel_yearValues.write(yearTotal)
	
		//calculate last day month totals from total
			if ((
					selectedInverter.toLowerCase()=="fronius" || 
					selectedInverter.toLowerCase()=="sma" || 
					selectedInverter.toLowerCase()=="kostal piko" || 
					selectedInverter.toLowerCase()=="zeversolar") 
					&& 
					(oldYearValue != 0)){
				
				var calculatedMonthValue = ParseInt(totalValue - oldYearValue)
				monthValue = calculatedMonthValue
			}	
			
		//write this months total to file
			solarPanel_oldYearValue.write(parseInt(totalValue))	
		
		//write last month totals to file
			monthValues[d.getMonth()+1] = parseFloat(monthValue).toFixed(1)
			var monthTotal = monthValues[0]
			for (var s = 1; s <= 12; s++) { 
				monthTotal += "," + monthValues[s]
			}
			solarPanel_monthTotals.write(monthTotal)
			
			if ((d.getMonth()+1)==12){	//end of year
				//write last year totals to file
				yearValues[d.getFullYear()-2020] = Math.floor(yearValue)
				var yearTotal = yearValues[0]
				for (var p = 0; p <= 10; p++) { 
					yearTotal += "," + yearValues[p]
				}
				solarPanel_yearValues.write(yearTotal)

				
			//write last year monthtotals to file
				prevYearMonthValues = monthValues
				var prevYearMonthValuesString = prevYearMonthValues[0]
				for (var y = 1; y <= 12; y++) { 
					prevYearMonthValuesString += "," + prevYearMonthValues[y]
				}
				solarPanel_monthTotals_prevYear.write(prevYearMonthValuesString)
				
				//clear the old month totals array
				var newArray4 = []
				for (var z = 0; z <= 12; z++) {
					newArray4.push(0)
				}
				monthValues = newArray4
			}
		}
	}
	
	
    Timer {
            id: scrapeTimer   //interval to get the solar data
            interval: 300000
            repeat: true
            running: true
            triggeredOnStart: true
            onTriggered: {
			
				var d = new Date()
					dtime = parseInt(Qt.formatDateTime (d,"hh") + Qt.formatDateTime (d,"mm"))
				if (debugOutput) console.log("*********SolarPanel dtime: " + dtime)
					var dday = d.getDate()
					var hrs = parseInt(Qt.formatDateTime(d,"hh"))
					var mins = parseInt(Qt.formatDateTime(d,"mm"))
					var minsfromseven = ((hrs-7)*60) + mins
					x2  = parseInt(minsfromseven/5)
				if (debugOutput) console.log("*********SolarPanel minsfromseven : " + minsfromseven)
				if (debugOutput) console.log("*********SolarPanel dtime : " + dtime)
				if (debugOutput) console.log("*********SolarPanel x2 : " + x2)
				
				var nextdayDate = new Date(d.getFullYear(), d.getMonth(), d.getDate()+1)
				nextday = nextdayDate.getDate()
				if (debugOutput) console.log("*********SolarPanel nextdayDate : " + nextdayDate)
				if (debugOutput) console.log("*********SolarPanel nextday : " + nextday)
					
				if (dtime>=700 & dtime<2300){  //it is daytime
					getData()
				}
			
				if (dtime>=2351 & dtime<2356){ //just before midnight
					witeDailyData()
						if (nextday==1){ //today is the last day of the month
							writeMonthlyData()
						}
				}
            }
    }
   
   	function saveSettings() {
		if (debugOutput) console.log("*********SolarPanel Savedata Started" )
		var tmpDebugOn = ""
		if (debugOutput == true) {tmpDebugOn = "Yes";} else {tmpDebugOn = "No";	}
		var tmpenableSleep = ""
		if (enableSleep == true) {tmpenableSleep = "Yes";} else {tmpenableSleep = "No";	}
		var setJson = {
			"selectedInverter" 	: selectedInverter,
			"growattUserName" 	: growattUserName,
			"growattPassWord" 	: growattPassWord,
			"solarEdgeSiteID" 	: solarEdgeSiteID,
			"solarEdgeApiKey" 	: solarEdgeApiKey,
			"froniusUrl" 		: froniusUrl,
			"smaUrl" 			: smaUrl,
			"kostalUrl" 		: kostalUrl,
			"zeversolarUrl" 	: zeversolarUrl,
			"enableSleep" 		: tmpenableSleep,
			"DebugOn"			: tmpDebugOn
		}
		solarpanelSettingsFile.write(JSON.stringify(setJson))
		getData()
	}
}
