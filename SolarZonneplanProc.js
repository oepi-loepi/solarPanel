
function sendZonneplanMailRequest(mailadress){
	console.log("*********SolarPanel  Start sendMailRequest()")
	var url = "https://app-api.zonneplan.nl/auth/request?email=" + mailadress
	if (debugOutput) console.log("*********SolarPanel url" + url)
	var http = new XMLHttpRequest()
	http.open("POST", url, true);
	http.setRequestHeader("content-type", "application/json;charset=utf-8");
	http.setRequestHeader("x-app-version","2.1.1");
	http.onreadystatechange = function() { // Call a function when the state changes.
				if (http.readyState === 4) {
					if (http.status === 200||http.status === 201){
						if (debugOutput) console.log("*********SolarPanel Accept in your mail, click mail link")
						if (debugOutput) console.log("*********SolarPanel http.responseText " + http.responseText)
						var JsonString = http.responseText
						var JsonObject= JSON.parse(JsonString)
						app.zonneplanUUID = JsonObject.data.uuid
						if (debugOutput) console.log("*********SolarPanel uuid : " + app.zonneplanUUID)
						solarPanelConfigScreen.sendMailText = "OK, Verstuurd"
						solarPanelConfigScreen.getPasseText  = "Ik heb de mail bevestigd"
				} else {
					if (http.status === 422){
						if (debugOutput) console.log("error: " + http.status)
						solarPanelConfigScreen.sendMailText = "Geen geldige mail"
					}else{
						if (debugOutput) console.log("error: " + http.status)
						solarPanelConfigScreen.sendMailText = "Fout met versturen"
					}
				}
		}
	}
	http.send();
}

function getPassword(mailadress){
	if (debugOutput) console.log("*********SolarPanel Start getPassword")
	var http = new XMLHttpRequest()
	var url = "https://app-api.zonneplan.nl/auth/request/" + app.zonneplanUUID
	if (debugOutput) console.log("*********SolarPanel url" + url)
	http.open("GET", url, true);
	http.setRequestHeader("content-type", "application/json;charset=utf-8");
	http.setRequestHeader("x-app-version","2.1.1");
	http.withCredentials = true;
	http.onreadystatechange = function() { // Call a function when the state changes.
		 if (http.readyState === 4) {
				if (http.status === 200) {
					if (debugOutput) console.log("*********SolarPanel http.responseText " + http.responseText)
					var JsonString = http.responseText
					var JsonObject= JSON.parse(JsonString)
					var zonnePass = JsonObject.data.password
					if (debugOutput) console.log("*********SolarPanel " + zonnePass)
					getToken(zonnePass,mailadress)
					solarPanelConfigScreen.getPasseText = "OK, passw received"
				} else {
					if (debugOutput) console.log("error: " + http.status)
					solarPanelConfigScreen.getPasseText = "Fout met ophalen"
				}
		}
	}
	http.send();
}


function getToken(zonnePass,mailadress){
	if (debugOutput) console.log("*********SolarPanel Start getToken")
	var http = new XMLHttpRequest()
	var url = "https://app-api.zonneplan.nl/oauth/token"
	if (debugOutput) console.log("*********SolarPanel url " + url)
	var params = "{\"grant_type\": \"one_time_password\",\"email\":\"" + mailadress + "\",\"password\": \"" + zonnePass + "\"}"
	if (debugOutput) console.log("*********SolarPanel params" + params)
	http.open("POST", url, true);
	http.setRequestHeader("content-type", "application/json;charset=utf-8");
	http.setRequestHeader("x-app-version","2.1.1");
	http.withCredentials = true;
	http.onreadystatechange = function() { // Call a function when the state changes.
		 if (http.readyState === 4) {
				if (http.status === 200) {
					if (debugOutput) console.log("*********SolarPanel http.responseText " + http.responseText)
					var JsonString = http.responseText
					var JsonObject= JSON.parse(JsonString)
					app.zonneplanToken = JsonObject.access_token
					app.zonneplanRefreshToken = JsonObject.refresh_token
					if (debugOutput) console.log("*********SolarPanel token : " + app.zonneplanToken)
					if (debugOutput) console.log("*********SolarPanel RefreshToken : " + app.zonneplanRefreshToken)
					if (debugOutput) console.log("*********SolarPanel save refreshtoken" )
					solarPanelConfigScreen.getPasseText = "OK, token ontvangen"
					solarPanel_refreshtoken.write(app.zonneplanRefreshToken)
				} else {
					if (debugOutput) console.log("error: " + http.status)
					solarPanelConfigScreen.getPasseText = "Fout met ophalen"
				}
		}
	}
	http.send(params);
}

