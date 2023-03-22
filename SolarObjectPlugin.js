/////////             <version>1.0.0</version>
/////////                     ZONNEPLAN-T1                        /////////////
/////////  Plugin to extract Zonneplan data for Toon  ///////////////
/////////                   By Oepi-Loepi                  ///////////////

	function getSolarData(passWord,userName,apiKey,siteid,urlString,totalValue){
		if (debugOutput) console.log("*********SolarPanel Start getSolarData")
		if (getDataCount == 0){getZonneplanStep1(1);}
		if (getDataCount == 1){getZonneplanStep1(2);}
    }



//Het token is verlopen, haal een nieuw token en een nieuw refreshtoken
	function getZonneplanRefreshToken(number){
		if (debugOutput) console.log("*********SolarPanel Start getZonneplanRefreshToken(" + number + ")" )
		var rfToken = ""
		try{
			if(number===1){
				rfToken = (solarPanel_refreshtoken.read()).trim()
			}else{
				rfToken = (solarPanel_refreshtoken2.read()).trim()
			}
		}catch(e) {
		}
		if (debugOutput) console.log("*********SolarPanel refreshtoken " + rfToken)
		if (rfToken.length <1){
			if (debugOutput) console.log("*********SolarPanel refreshtoken empty -> aborting")
		}else{
			if (debugOutput) console.log("*********SolarPanel haal de zonneplan info op via tsc command")
			var doc2 = new XMLHttpRequest()
			doc2.open("PUT", "file:///tmp/zonneplan_refresh.txt")
			doc2.send(rfToken)
			
			var doc4 = new XMLHttpRequest()
			doc4.open("PUT", "file:///tmp/tsc.command")
			doc4.send("external-solarPanel")
			
			//wacht op een response vanuit het TSC script
			var onetime = true
			zonneplanDelay(8000, function() {
				if (onetime){
					onetime = false
					parseRefreshToken(number)
				}
			})
		}
	}

//verwerk de gegevens uit het TSC scipt voor de nieuwe tokens
	function parseRefreshToken(number){
		if (debugOutput) console.log("*********SolarPanel Start Zonneplan parseRefreshToken()")
		var http = new XMLHttpRequest()
		var url = "file:///tmp/zonneplan_tokens.txt"
		if (debugOutput) console.log("*********SolarPanel url " + url)
		http.open("GET", url, true);
		http.onreadystatechange = function() { // Call a function when the state changes.
			 if (http.readyState === 4) {
					if (http.status === 200) {
						if (debugOutput) console.log("*********SolarPanel http.responseText " + http.responseText)
						if(http.responseText.toLowerCase().indexOf('token is invalid')>-1){
							if (debugOutput) console.log("*********SolarPanel token failed -> aborting")
							pluginWarning = "Foutieve inlog"
							if(number===1){
								zonneplanRefreshToken = ""
							}else{
								zonneplanRefreshToken2 = ""
							}
							parseReturnData(0,totalValue,0,0,0,0,0, http.status,"error")
						}else{
							var JsonString = http.responseText
							var JsonObject= JSON.parse(JsonString)
							if (JsonObject.access_token)
							if(number===1){
								zonneplanToken = JsonObject.access_token
								zonneplanRefreshToken = JsonObject.refresh_token
								if (debugOutput) console.log("*********SolarPanel token : " + zonneplanToken)
								if (debugOutput) console.log("*********SolarPanel RefreshToken : " + zonneplanRefreshToken)
								if (debugOutput) console.log("*********SolarPanel save refreshtoken" )
								solarPanel_refreshtoken.write(zonneplanRefreshToken)
							}else{
								zonneplanToken2 = JsonObject.access_token
								zonneplanRefreshToken2 = JsonObject.refresh_token
								if (debugOutput) console.log("*********SolarPanel token : " + zonneplanToken2)
								if (debugOutput) console.log("*********SolarPanel RefreshToken2 : " + zonneplanRefreshToken2)
								if (debugOutput) console.log("*********SolarPanel save refreshtoken2" )
								solarPanel_refreshtoken2.write(zonneplanRefreshToken2)
							}
						}
					} else {
						console.log("error: " + http.status)
					}
			}
		}
		http.send();
	}


//haal periodiek data van de site
	function getZonneplanStep1(number){
		if (debugOutput) console.log("*********SolarPanel Start getZonneplanStep1()")
		if (debugOutput) console.log("*********SolarPanel haal de zonneplan info op via tsc command")
		if(number===1){
			if (debugOutput) console.log("*********SolarPanel token " + zonneplanToken)
		}else{
			if (debugOutput) console.log("*********SolarPanel token " + zonneplanToken2)
		}
		
		var doc2 = new XMLHttpRequest();
		doc2.open("PUT", "file:///tmp/zonneplan_step1.txt");
		if(number===1){
			doc2.send(zonneplanToken)
		}else{
			doc2.send(zonneplanToken2)
		}
		
		var doc4 = new XMLHttpRequest();
		doc4.open("PUT", "file:///tmp/tsc.command");
		doc4.send("external-solarPanel");
		
		//wacht op een response vanuit het TSC script
		var onetime = true
		zonneplanDelay(8000, function() {
			if (onetime){
				onetime = false
				if(number===1){
					parseZonneplanStep1(1)
				}else{
					parseZonneplanStep1(2)
				}
			}
		})
	}


	function parseZonneplanStep1(number){
		console.log("*********SolarPanel Start Zonneplan parseZonneplanStep1()")
		var http = new XMLHttpRequest()
		var url = "file:///tmp/zonneplan_response_step1.txt"
		if (debugOutput) console.log("*********SolarPanel url " + url)
		http.open("GET", url, true);
		http.onreadystatechange = function() { // Call a function when the state changes.
			 if (http.readyState === 4) {
					if (http.status === 200) {
						if (debugOutput) console.log("*********SolarPanel http.responseText " + http.responseText)
						var JsonString = http.responseText
						if(http.responseText.toLowerCase().indexOf('unauthenticated')>-1){
							if (debugOutput) console.log("*********SolarPanel token failed -> getnewToken")
							if (getZonneplanRefreshToken(number).length >1){
								getZonneplanRefreshToken(number)
							}
							if (debugOutput) console.log("*********SolarPanel http.status : " + http.status)
							parseReturnData(0,totalValue,0,0,0,0,0, http.status,"error")
						}else{
							var JsonObject= JSON.parse(JsonString)
							if(number===1){
								zonneplantotalPower = parseInt(JsonObject.data.address_groups[0].connections[0].contracts[0].meta.total_power_measured)
								zonneplanlastPower = parseInt(JsonObject.data.address_groups[0].connections[0].contracts[0].meta.last_measured_power_value)
								if (debugOutput) console.log("*********SolarPanel zonneplanlastPower : " + zonneplanlastPower)
								if (debugOutput) console.log("*********SolarPanel zonneplantotalPower : " + zonneplantotalPower)
							}else{
								zonneplantotalPower2 = parseInt(JsonObject.data.address_groups[0].connections[0].contracts[0].meta.total_power_measured)
								zonneplanlastPower2 = parseInt(JsonObject.data.address_groups[0].connections[0].contracts[0].meta.last_measured_power_value)
								if (debugOutput) console.log("*********SolarPanel zonneplanlastPower2 : " + zonneplanlastPower2)
								if (debugOutput) console.log("*********SolarPanel zonneplantotalPower2 : " + zonneplantotalPower2)
							}
							var connect = JsonObject.data.address_groups[0].connections[0].uuid
							if (debugOutput) console.log("*********SolarPanel connect : " + connect)
							getZonneplanStep2(connect,number)
						}
					} else {
						console.log("error: " + http.status)
					}
			}
		}
		http.send();
	}


	function getZonneplanStep2(connect,number){
		if (debugOutput) console.log("*********SolarPanel Start getZonneplanStep2()")
		if (debugOutput) console.log("*********SolarPanel haal de zonneplan info op via tsc command")
		if (debugOutput) console.log("*********SolarPanel connect " + connect)
		
		var doc2 = new XMLHttpRequest();
		doc2.open("PUT", "file:///tmp/zonneplan_step2.txt");
		if(number===1){
			doc2.send(connect + ";" + zonneplanToken);
		}else{
			doc2.send(connect + ";" + zonneplanToken2);
		}
		
		var doc4 = new XMLHttpRequest();
		doc4.open("PUT", "file:///tmp/tsc.command");
		doc4.send("external-solarPanel");
		
		var onetime = true
		zonneplanDelay(8000, function() {
			if (onetime){
				onetime = false
				parseZonneplanStep2(number)
			}
		})
	}

	function parseZonneplanStep2(number){
		if (debugOutput) console.log("*********SolarPanel Start Zonneplan parseZonneplanStep2()")
		var http = new XMLHttpRequest()
		var url = "file:///tmp/zonneplan_response_step2.txt"
		if (debugOutput) console.log("*********SolarPanel url " + url)
		http.open("GET", url, true);
		http.onreadystatechange = function() { // Call a function when the state changes.
			 if (http.readyState === 4) {
					if (http.status === 200) {
						console.log("*********SolarPanel http.responseText " + http.responseText)
						var JsonString = http.responseText
						if(JsonString.toLowerCase().indexOf('unauthenticated')>-1){
							if (debugOutput) console.log("*********SolarPanel token failed -> getnewToken")
							getZonneplanRefreshToken(number)
							if (debugOutput) console.log("*********SolarPanel http.status : " + http.status)
							parseReturnData(0,totalValue,0,0,0,0,0, http.status,"error")
						}else{
							var JsonString = http.responseText
							var JsonObject= JSON.parse(JsonString)
							var today2 = parseInt(JsonObject.data[0].total)
							if(number===1){
								if (debugOutput) console.log("*********SolarPanel zonneplanlastPower  : " + zonneplanlastPower)
								if (debugOutput) console.log("*********SolarPanel zonneplantotalPower : " + zonneplantotalPower)
								var currentPowerLoc = parseInt(zonneplanlastPower)
								var todayValueLoc= today2
								var totalValueLoc= parseInt(zonneplantotalPower)
							}else{
								if (debugOutput) console.log("*********SolarPanel zonneplanlastPower2  : " + zonneplanlastPower2)
								if (debugOutput) console.log("*********SolarPanel zonneplantotalPower2 : " + zonneplantotalPower2)
								var currentPowerLoc = parseInt(zonneplanlastPower2)
								var todayValueLoc= today2
								var totalValueLoc= parseInt(zonneplantotalPower2)
							}
							if (debugOutput) console.log("*********SolarPanel parseInt(todayValue) : " + parseInt(todayValue))
							parseReturnData(currentPowerLoc,totalValueLoc, todayValueLoc,0,0,0,0,http.status,"succes")
						}
					} else {
						if (debugOutput) console.log("error: " + http.status)
					}
			}
		}
		http.send();
	}
	
	
	

	
	
	
