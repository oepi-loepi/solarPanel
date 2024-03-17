/////////             <version>1.0.14</version>
/////////                     GROW1                        /////////////
/////////  Plugin to extract Growatt Solar data for Toon  ///////////////
/////////                   By Oepi-Loepi                  ///////////////

	function getSolarData(passWord,userName,apiKey,siteid,urlString,totalValue){
		if (debugOutput) console.log("*********SolarPanel Start getGrowattStep1")
		//modified hash : if first of pairs  is 0 then replace by c
		var newpass= Qt.md5(passWord)
		var newString =""
		for(var x = 0;x < newpass.length ;x++){
			if ((x%2 == 0) && newpass[x] == "0") {
				newString += "c"
			}
			else{
				newString += newpass[x]
			}
		}
		var params = "password=" + newString + "&userName=" + userName
		var http = new XMLHttpRequest()
		var url2 = "https://server-api.growatt.com/newTwoLoginAPI.do"
		console.log("*********SolarPanel  url2" +  url2)
		http.open("POST", url2, true)
		http.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
		http.setRequestHeader("Content-length", params.length)
		http.setRequestHeader("Connection", "keep-alive")
		http.setUserAgent = "ShinePhone/5.92 (iPad; iOS 14.6; Scale/2.00)"
        http.onreadystatechange = function() { // Call a function when the state changes.
			if (http.readyState === 4) {
				if (http.status === 200) {
					var JsonString = http.responseText
					if (debugOutput) console.log("*********SolarPanel JsonString " +  JsonString)
					var JsonObject= JSON.parse(JsonString)
					getGrowattStep2("https://server-api.growatt.com/newPlantAPI.do?action=getUserCenterEnertyDataTwo");
				} else {
					if (debugOutput) console.log("*********SolarPanel  getGrowattStep2 http.status " +  http.status)
					if (http.status === 405){getOtherServer(params)}
				}
			}
		}
		http.send(params);
    }
	
	function getOtherServer(params){
		if (debugOutput) console.log("*********SolarPanel Start getOtherServer")
		var http = new XMLHttpRequest()
		var url2 = "https://server.growatt.com/newTwoLoginAPI.do"
		console.log("*********SolarPanel  url2" +  url2)
		http.open("POST", url2, true)
		http.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
		http.setRequestHeader("Content-length", params.length)
		http.setRequestHeader("Connection", "keep-alive")
		http.setUserAgent = "ShinePhone/5.92 (iPad; iOS 14.6; Scale/2.00)"
        http.onreadystatechange = function() { // Call a function when the state changes.
			if (http.readyState === 4) {
				if (http.status === 200) {
					var JsonString = http.responseText
					if (debugOutput) console.log("*********SolarPanel JsonString " +  JsonString)
					var JsonObject= JSON.parse(JsonString)
					getGrowattStep2("https://server.growatt.com/newPlantAPI.do?action=getUserCenterEnertyDataTwo");
				} else {
					if (debugOutput) console.log("*********SolarPanel  getOtherServer http.status " +  http.status)
					currentPower = 0
					parseReturnData(0,totalValue,0,0,0,0,0, http.status,"error")
				}
			}
		}
		http.send(params);
    }


	function getGrowattStep2(url2){
		if (debugOutput) console.log("*********SolarPanel Start getGrowattStep2")
		var http = new XMLHttpRequest()
		var params = "language=5"
		console.log("*********SolarPanel  url2 " +  url2)
		http.open("GET", url2, true)
		http.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
		http.setRequestHeader("Content-length", params.length)
		http.setRequestHeader("Connection", "keep-alive")
		http.setUserAgent = "ShinePhone/5.92 (iPad; iOS 14.6; Scale/2.00)"
		http.onreadystatechange = function() { // Call a function when the state changes.
			if (http.readyState === 4) {
				if (http.status === 200) {
					try {
						var JsonString = http.responseText
						if (debugOutput) console.log("*********SolarPanel JsonString " +  JsonString)
						var JsonObject= JSON.parse(JsonString)
						currentPower = parseInt(JsonObject.powerValue)
						if (debugOutput) console.log("currentPower: " + currentPower)
						var today2 = Math.floor((JsonObject.todayValue)*1000)
						if (debugOutput) console.log("today2: " + today2)
						totalValue= Math.floor((JsonObject.totalValue)*1000)
						if (debugOutput) console.log("totalValue: " + totalValue)
						parseReturnData(currentPower,totalValue,today2,0,0,0,0,http.status,"succes")
					}
					catch (e){
						currentPower = 0
						parseReturnData(0,totalValue,0,0,0,0,0, http.status,"error")
					}
				} else {
					if (debugOutput) console.log("*********SolarPanel  getGrowattStep2 http.status " +  http.status)
					parseReturnData(0,totalValue,0,0,0,0,0, http.status,"error")
				}
			}
		}
		http.send(params);
	}
