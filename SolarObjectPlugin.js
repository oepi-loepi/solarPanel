/////////             <version>1.0.8</version>
/////////                     GROW1                        /////////////
/////////  Plugin to extract Growatt Solar data for Toon  ///////////////
/////////                   By Oepi-Loepi                  ///////////////

	function getSolarData(passWord,userName,apiKey,siteid,urlString,totalValue){
            if (debugOutput) console.log("*********SolarPanel Start getGrowattStep1")
			
			//modified hash : if first of pairs  is 0 then replace by c
			var newpass= Qt.md5(passWord)
            var newString =""
            for(var x = 0;x < newpass.length ;x++){
                console.log("char: " +newpass[x])
                if ((x%2 == 0) && newpass[x] == "0") {
                    newString += "c"
                    console.log("changed into: " + "c")
                }
                else{
                    newString += newpass[x]
                }
            }
			
            var http = new XMLHttpRequest()
            var url = "http://server-api.growatt.com/newLoginAPI.do";
            if (debugOutput) console.log("*********SolarPanel Hashed password: " + Qt.md5(passWord))
            var params = "password=" + newString + "&userName=" + userName
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
				parseReturnData(0,totalValue,0,0,0,0,0, http.status,"error")
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
			    var today2 = Math.floor((JsonObject.todayValue)*1000)
                            totalValue= Math.floor((JsonObject.totalValue)*1000)
			    parseReturnData(currentPower,totalValue,today2,0,0,0,0,http.status,"succes")
				} else {
					if (debugOutput) console.log("*********SolarPanel error: " + http.status)
					parseReturnData(0,totalValue,0,0,0,0,0, http.status,"error")
				}
			}
		}
		http.send();
    }
	
