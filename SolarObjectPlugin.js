/////////                     PVOUTPUT1                     /////////////
/////////  Plugin to extract PVoutput data for Toon         ///////////////
/////////                   By Oepi-Loepi                  ///////////////

function getSolarData(passWord,userName,apiKey,siteid,urlString,totalValue){
		if (debugOutput) console.log("*********SolarPanel Start  getPVOutputData")
            var http = new XMLHttpRequest()
            var url = "https://pvoutput.org/service/r2/getstatus.jsp?stats=1"
            http.open("POST", url, true)
            http.setRequestHeader("X-Pvoutput-Apikey", apiKey)
            http.setRequestHeader("X-Pvoutput-SystemId", siteid)
            http.onreadystatechange = function() { // Call a function when the state changes.
                        if (http.readyState === 4) {
                            if (http.status === 200) {
                                if (debugOutput) console.log("*********SolarPanel PVOutput: " + http.responseText)
                               var pvoutputararray = http.responseText.split(",")
                                currentPower = parseInt(pvoutputararray[1])
                                getPVOutputData2(apiKey,siteid,currentPower)
                            } else {
                                parseReturnData(currentPower,totalValue,0,0,0,0,0, http.status,"error")
                            }
                        }
                    }
            http.send();
        }

    function getPVOutputData2(apiKey,siteid,currentPower){
		if (debugOutput) console.log("*********SolarPanel Start  getPVOutputData2")
		var http = new XMLHttpRequest()
		var url = "https://pvoutput.org/service/r2/getstatistic.jsp"
		http.open("POST", url, true)
		http.setRequestHeader("X-Pvoutput-Apikey", apiKey)
		http.setRequestHeader("X-Pvoutput-SystemId", siteid)
		http.onreadystatechange = function() { // Call a function when the state changes.
			if (http.readyState === 4) {
				 if (http.status === 200) {
					if (debugOutput) console.log("*********SolarPanel PVOutput4: " + http.responseText)
					var pvoutputararray = http.responseText.split(",")
					totalValue = parseInt(pvoutputararray[0])
					parseReturnData(currentPower,totalValue,0,0,0,0,0,http.status,"succes")
				} else {
					if (debugOutput) console.log("*********SolarPanel error: " + http.status)
					parseReturnData(currentPower,totalValue,0,0,0,0,0, http.status,"error")
				}
			}
		}
		http.send();
    }
	
