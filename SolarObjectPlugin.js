/////////             <version>1.0.2</version>
/////////                     FOX1                        /////////////
/////////  Plugin to extract FoxCloud Solar data for Toon  ///////////////
/////////                   By Oepi-Loepi                  ///////////////

    function getSolarData(passWord,userName,apiKeyPlugin,siteid,urlString,totalValue){
		
		if (debugOutput) console.log("*********SolarPanel Start getSolarData")
		if (debugOutput) console.log("*********SolarPanel Start getSolarData apiKey: " + apiKeyPlugin)
		if (apiKeyPlugin !=""){
			getStep2(apiKeyPlugin)
		}else{
			var newpass= Qt.md5(passWord)
			var http = new XMLHttpRequest()
			var url = "https://www.foxesscloud.com/c/v0/user/login"
			http.open("POST", url, true);
			http.withCredentials = true;
			http.setRequestHeader("Content-Type", "application/json");
			http.onreadystatechange = function() { // Call a function when the state changes.
				if (http.readyState === XMLHttpRequest.DONE) {
					if (http.status === 200 || http.status === 300  || http.status === 302) {
						try {
							if (debugOutput) console.log("http.status: " + http.status)
							if (debugOutput) console.log(http.responseText)
							var JsonString = http.responseText
							var JsonObject= JSON.parse(JsonString)
							var token = JsonObject.result.token
							if (debugOutput) console.log(token)
							if (getDataCount == 0){apiKey = token}
							if (getDataCount == 1){apiKey2 = token}
							getStep2(token)
						}
						catch (e){
							currentPower = 0
							if (debugOutput) console.log("http.status (error1): " + http.status)
							parseReturnData(0,totalValue,todayValue,0,0,0,0, http.status,"error")
						}
					} else {
						if (debugOutput) console.log("http.status (error2): " + http.status)
						parseReturnData(currentPower,totalValue,0,0,0,0,0, http.status,"error")
					}
				}
			}
			http.send(JSON.stringify({"user": userName,"password": Qt.md5(passWord)}));
		}
    }

    function getStep2(token){
        if (debugOutput) console.log("*********SolarPanel Start getStep2")
        var data = "{\"pageSize\":10,\"currentPage\":1,\"total\":0,\"condition\":{\"queryDate\":{\"begin\":0,\"end\":0}}}";
        var http = new XMLHttpRequest()
        var url = "https://www.foxesscloud.com/c/v0/device/list";
        http.open("POST", url, true);
        http.withCredentials = true;
        http.setRequestHeader("Content-Type", "application/json");
        http.setRequestHeader("token", token);
        http.onreadystatechange = function() {
            if (http.readyState === XMLHttpRequest.DONE) {
                if (http.status === 200 || http.status === 300  || http.status === 302) {
                    try {
						if (debugOutput) console.log(http.responseText)
						if (http.responseText.indexOf("null")>0 & http.responseText.indexOf("41809")>0){
							if (debugOutput) console.log("No token or wrong token submitted so try to get new token next time")
							if (getDataCount == 0){apiKey = ""}
							if (getDataCount == 1){apiKey2 = ""}
							parseReturnData(currentPower,totalValue,todayValue,0,0,0,0, http.status,"error")
						}else{
							var JsonString = http.responseText
							var JsonObject= JSON.parse(JsonString)
							var today2 = Math.floor(JsonObject.result.devices[0].generationToday  * 1000)
							currentPower = Math.floor(JsonObject.result.devices[0].power * 1000)
							totalValue = Math.floor(JsonObject.result.devices[0].generationTotal * 1000)
							parseReturnData(currentPower, totalValue, today2 ,0,0,0,0,http.status,"succes")
						}
                    }
                    catch (e){
                        currentPower = 0
						if (debugOutput) console.log("http.status (error3): " + http.status)
                        parseReturnData(0,totalValue,todayValue,0,0,0,0, http.status,"error")
                    }
                } else {
					if (debugOutput) console.log("http.status (error4): " + http.status)
                    parseReturnData(currentPower,totalValue,0,0,0,0,0, http.status,"error")
                }
            }
        }
        http.send(data);
    }
