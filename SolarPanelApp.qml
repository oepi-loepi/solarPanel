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
import "SolarGeneralProc.js" as SolarGeneral

App {
	id: solarPanelApp
	
	property url 	tileUrl : "SolarPanelTile.qml"
	property url 	tileUrl2 : "SolarPanelTile2.qml"
	property url 	tileUrl3 : "SolarPanelTile3.qml"
	property url 	tileUrl5 : "SolarPanelTile5.qml"
	property url 	thumbnailIcon1: "qrc:/tsc/solarPanel_graph1.png"
	property url 	thumbnailIcon2: "qrc:/tsc/solarPanel_txt.png"
	property url 	thumbnailIcon3: "qrc:/tsc/solarPanel_rolling.png"
	property url 	thumbnailIcon4: "qrc:/tsc/solarPanel_now.png"
	property url 	thumbnailIcon5: "qrc:/tsc/solarPanel_graph2.png"
	property url 	thumbnailIcon6: "qrc:/tsc/solarPanel_kwh.png"

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
	property int 	powerAvgValue : 1000

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

	property bool 	zonneplan : false
	property string zonneplanUUID: ""
	property string zonneplanToken: ""
	property string zonneplanRefreshToken: ""
	
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
		registry.registerWidget("tile", tileUrl5, this, null, {thumbLabel: qsTr("Eigen verbruik"), thumbIcon: thumbnailIcon2, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});			
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
	FileIO {id: solarPanel_refreshtoken;	source: "file:///mnt/data/tsc/appData/solarPanel_refreshtoken.txt"}
	FileIO {id: pluginFile;	source: "SolarObjectPlugin.js"}
	FileIO {id: pluginFile2;source: "SolarObjectPlugin2.js"}
	FileIO {id: solar_mobile;	source: "file:///qmf/www/solar.html"}
		
	Component.onCompleted: { 
		currentPower = 0
		SolarGeneral.clearAllArrays() 			//clear graph arrays
		SolarGeneral.getSettings()   			//get the user settings from the system file
		SolarGeneral.checkInvertersOnStart()   	//check if plugin matches the selectedinverter
		SolarGeneral.getAllSavedData() 			//get data from data/tsc/data  and rrs
		SolarGeneral.getSunTimes() 				//get sunrise and sunset
		
		scrapeTimer.running = true
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
		
		if (dtime>=200 & dtime<=204){ //it is 2 hour after the beginning of a new day
			doDelayedDailyStuff()
		}
    }

/////////////////////////////////////////WRITE 5MIN   DATA/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////Each time data was received      /////////////////////////////////////////////////////////////////////////////////
	
	function doEachtimeStuff(){
		var ownusage = (parseInt(parseInt(currentPower) + parseInt(currentUsage) - parseInt(currentPowerProd)))
		solar_mobile.write("{\"result\":\"ok\",\"solar\": {\"current\":" + currentPower + ", \"total\":" + totalValue + ", \"today\":" + todayValue + ", \"production\":" + currentPowerProd + ", \"usage_net\":" + currentUsage + ", \"usage_own\":" + ownusage + "}}")
				
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

		SolarGeneral.push5minData()		//push current 5 minutes into the array for the RRA  flow
		SolarGeneral.push5yrhoursData()	//push quantity into the 5yrhours RRA data
		SolarGeneral.push10yrdaysData() //push quantity into the 10yrdays RRA data
	}

/////////////////////////////////////////WRITE 5MIN   DATA/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////Only during a time period      ///////////////////////////////////////////////////////////////////////////////////

	function doOnlyDuringDayTimeStuff(){
		
		var x2now  = minsfromfiveIndex
		var x2twohoursAgo  = x2now - 24  //less 2 hours
		
		//make new rolling array each 5 mins
		if (debugOutput) console.log("*********SolarPanel calculating rollingfiveminuteValues minsfromfiveIndex" + minsfromfiveIndex)
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
		//produced this day so it must be in the RRA of thisday 02:00
		if (parseInt(savedtotalValue) ==0){savedtotalValue = totalValue}
		var thisday = new Date()

		var offset = (-1*thisday.getTimezoneOffset())/60
		if (debugOutput) console.log("*********SolarPanel thisday offset: " +  offset)
		thisday.setDate(thisday.getDate())
		thisday.setHours(offset,0,0,0)  //to make it UTC

		thisday.setHours(offset,0,0,0)  //to make it UTC
		if (debugOutput) console.log("*********SolarPanel thisday : " +  thisday.toString())
		if (debugOutput) console.log("*********SolarPanel thisday unixTime : " + parseInt(thisday.getTime()/1000))
		if (debugOutput) console.log("*********SolarPanel thisday value : " + parseInt(savedtotalValue)    + " set at " + dtime )
		var http4 = new XMLHttpRequest()	
		var url4 = "http://localhost/hcb_rrd?action=setRrdData&loggerName=elec_solar_quantity&rra=10yrdays&samples=%7B%22" + parseInt(thisday.getTime()/1000)+ "%22%3A" + parseInt(savedtotalValue) + "%7D"
		if (debugOutput) console.log("*********SolarPanel url4 : " + url4)
		http4.open("GET", url4, true)
        	http4.send()

		SolarGeneral.getSunTimes() // get sunrise and sunset
	}

///////////////////////////////////////// TIMERS /////////////////////////////////////////////////////////////////////////////////////////////////
	
	Timer {
		id: getUsageTimer   //interval to get ussage power data
		interval: 20000
		repeat: true
		running: true
		triggeredOnStart: true
		onTriggered: {
			SolarGeneral.getCurrentUsage("localhost")
		}
    }

    Timer {//
		id: scrapeTimer   //interval to get the solar data
		interval: 30000
		repeat: true
		running: false
		triggeredOnStart: false
		onTriggered: {
			scrapeTimer.interval = 300000
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
				getDataCount = 0
				getData()
			}
		}	
    }
 
///////////////////////////////////////// SAVE ALL TO SETTINGS ///////////////////////////////////////////////////////////////////////////////////////////////// 
	
	function saveSettings() {
		SolarGeneral.saveSettings() //savesettings to file
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
