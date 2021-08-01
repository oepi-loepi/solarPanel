/////////             <version>1.0.0</version>
/////////                     ZONNEPLAN1                        /////////////
/////////  Plugin to extract Zonneplan data for Toon  ///////////////
/////////                   By Oepi-Loepi                  ///////////////

	function getSolarData(passWord,userName,apiKey,siteid,urlString,totalValue){
            if (debugOutput) console.log("*********SolarPanel Start getSolarData")
				var http = new XMLHttpRequest()
				var url = "https://app-api.zonneplan.nl/user-accounts/me"
				console.log("*********SolarPanel url " + url)
				console.log("*********SolarPanel token " + zonneplanToken)
				http.open("GET", url, true)
				http.setRequestHeader("content-type", "application/json;charset=utf-8");
				http.setRequestHeader("x-app-version","2.1.1");
				http.setRequestHeader("Authorization", "Bearer " + zonneplanToken);
				http.withCredentials = true; http.onreadystatechange = function() { // Call a function when the state changes.
				if (http.readyState === 4) {
					if (http.status === 200) {
						console.log("*********SolarPanel http.responseText " + http.responseText)
						var JsonString = http.responseText
						var JsonObject= JSON.parse(JsonString)
						var connect = JsonObject.data.address_groups[0].connections[0].uuid
						var totalPower = JsonObject.data.address_groups[0].connections[0].contracts[0].meta.total_power_measured
						var lastPower = JsonObject.data.address_groups[0].connections[0].contracts[0].meta.last_measured_power_value
						console.log("*********SolarPanel connect : " + connect)
						console.log("*********SolarPanel lastPower : " + lastPower)
						console.log("*********SolarPanel totalPower : " + totalPower)
						getStep2(connect,lastPower,totalPower)
					} else {
						parseReturnData(0,totalValue,0,0,0,0,0, http.status,"error")
						if (http.status === 401){
							console.log("*********SolarPanel token failesd -> getnewToken")
							SolarGeneral.getZonneplanRefreshToken()
						}
					}
				}
			}
            http.send();
    }

    function getStep2(connect,lastPower,totalPower){
			console.log("*********SolarPanel Start getStep2")
			var http = new XMLHttpRequest()
			var url = "https://app-api.zonneplan.nl/connections/" + connect + "/pv_installation/charts/live"
			console.log("*********SolarPanel url" + url)
			http.open("GET", url, true);
			http.setRequestHeader("content-type", "application/json;charset=utf-8");
			http.setRequestHeader("x-app-version","2.1.1");
			http.setRequestHeader("Authorization", "Bearer " + zonneplanToken);
			http.withCredentials = true;http.onreadystatechange = function() { // Call a function when the state changes.
			if (http.readyState === 4) {
				if (http.status === 200) {
					try {

						console.log("*********SolarPanel http.responseText " + http.responseText)

                        var JsonString = http.responseText
                        var JsonObject= JSON.parse(JsonString)
                        //var lastvalue = JsonObject.data[0].measurements[JsonObject.data[0].measurements.length-1].value
                        var today2 = parseInt(JsonObject.data[0].total)

                        console.log("*********SolarPanel lastPower : " + lastPower)
                        console.log("*********SolarPanel todayvalue : " + today2)
                        console.log("*********SolarPanel totalPower : " + totalPower)

						var JsonString = http.responseText
						var JsonObject= JSON.parse(JsonString)
						currentPower = parseInt(lastPower)
						todayValue= today2
						totalValue= parseInt(totalPower)
						console.log("*********SolarPanel parseInt(blblbtodayValue) : " + parseInt(todayValue))
						//parseReturnData(currentPower,totalValue, today2,0,0,0,0,http.status,"succes")
					}
					catch (e){
						currentPower = 0
						parseReturnData(0,totalValue,todayValue,0,0,0,0, http.status,"error")
					}
				} else {
					parseReturnData(0,totalValue,0,0,0,0,0, http.status,"error")
				}
			}
		}
		http.send();
    }
	
	