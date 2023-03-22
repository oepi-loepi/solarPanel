
//DE VOLGENDE FUNCTIES WORDEN GESTUURD VANUIT CONFIGSCREEN... DAN IS app.nodig voor de globals
//send mail from the configscreen. The mail has to be confirmed in the mailbox
	function sendZonneplanMailRequest(mailadress,number){
		if (debugOutput) console.log("*********SolarPanel haal de zonneplan info op via tsc command")
		var doc2 = new XMLHttpRequest();
		doc2.open("PUT", "file:///tmp/zonneplan_mail.txt");
		doc2.send(mailadress);
		var doc4 = new XMLHttpRequest();
		doc4.open("PUT", "file:///tmp/tsc.command");
		doc4.send("external-solarPanel");
		if(number===1){
			solarPanelConfigScreen.sendMailText = "OK, Verstuurd. Keur svp de mail goed."
			solarPanelConfigScreen.getPasseText  = "wachten.."
		}else{
			solarPanelConfigScreen.sendMailText2 = "OK, Verstuurd. Keur svp de mail goed."
			solarPanelConfigScreen.getPasseText2  = "wachten.."
		}
		//wacht op een response vanuit het TSC script
		var onetime = true
		app.zonneplanRegisterDelay(8000, function() {
			if (onetime){
				onetime = false
				if (debugOutput) console.log("*********SolarPanel after delay requesting parseUUID(" + number + ")")
				parseUUID(number)
			}
		})
	}
	
//terug van TSC script na het versturen van een wachtwoordverzoek
	function parseUUID(number){
		console.log("*********SolarPanel Start parseUUID(" + number + ")")
		if(number===1){
			solarPanelConfigScreen.sendMailText = "Wachten.."
			solarPanelConfigScreen.getPasseText  = "Klik als de mail is goedgekeurd"
		}else{
			solarPanelConfigScreen.sendMailText2 = "Wachten.."
			solarPanelConfigScreen.getPasseText2  = "Klik als de mail is goedgekeurd"
		}
		var http = new XMLHttpRequest()
		var url = "file:///tmp/mail_uid.txt"
		if (debugOutput) console.log("*********SolarPanel url " + url)
		http.open("GET", url, true);
		http.onreadystatechange = function() { // Call a function when the state changes.
			if (http.readyState === 4) {
				if (http.status === 200) {
					if (debugOutput) console.log("*********SolarPanel http.responseText " + http.responseText)
					var returnText = JSON.parse(http.responseText);
					if(number===1){
						app.zonneplanUUID = returnText.data.uuid
						if (debugOutput) console.log("*********SolarPanel uuid : " + app.zonneplanUUID)
					}else{
						app.zonneplanUUID2 = returnText.data.uuid
						if (debugOutput) console.log("*********SolarPanel uuid : " + app.zonneplanUUID2)
					}
				} else {
					console.log("error: " + http.status)
					if(number===1){
						solarPanelConfigScreen.getPasseText = "Fout.."
					}else{
						solarPanelConfigScreen.getPasseText2 = "Fout.."
					}
				}
			}
		}
	    http.send();
	}		
	
	

//de knop is gedrukt dat de mail is goedgekeurd: haal een tijdelijk wachtwoord op
	function getPassword(mailadress,number){
		if (debugOutput) console.log("*********SolarPanel getPassword(" + mailadress + "," + number + ")")
		if(number===1){
			solarPanelConfigScreen.getPasseText  = "Wachtwoord halen, 8 sec wachten"
		}else{
			solarPanelConfigScreen.getPasseText2  = "Wachtwoord halen, 8 sec wachten"
		}
		if (debugOutput) console.log("*********SolarPanel haal de zonneplan info op via tsc command")
		var doc2 = new XMLHttpRequest();
		doc2.open("PUT", "file:///tmp/zonneplan_uid.txt");
		if(number===1){
			doc2.send(app.zonneplanUUID);
		}else{
			doc2.send(app.zonneplanUUID2);
		}

		var doc4 = new XMLHttpRequest();
		doc4.open("PUT", "file:///tmp/tsc.command");
		doc4.send("external-solarPanel");
		
		//wacht op een response vanuit het TSC script
		var onetime = true
		app.zonneplanRegisterDelay(8000, function() {
			if (onetime){
				onetime = false
				parseGetPassWord(number)
			}
		})
	}

//terug van TSC script na het versturen van een wachtwoordverzoek
	function parseGetPassWord(number){
		console.log("*********SolarPanel Start parseGetPassWord(" + number + ")")
		var http = new XMLHttpRequest()
		var url = "file:///tmp/zonneplan_pass.txt"
		if (debugOutput) console.log("*********SolarPanel url " + url)
		http.open("GET", url, true);
		http.onreadystatechange = function() { // Call a function when the state changes.
			if (http.readyState === 4) {
				if (http.status === 200) {
					if (debugOutput) console.log("*********SolarPanel http.responseText " + http.responseText)
					var passReturn = JSON.parse(http.responseText);
					var zonnePass = passReturn.data.password
					var mailadress = passReturn.data.email
					if(number===1){
						solarPanelConfigScreen.getPasseText = "Ontvangen, 8 sec wachten"
					}else{
						solarPanelConfigScreen.getPasseText2 = "Ontvangen, 8 sec wachten"
					}
					if (debugOutput) console.log("*********SolarPanel zonnePass : " + zonnePass)
					if (debugOutput) console.log("*********SolarPanel mailadress : " + mailadress)
					if (debugOutput) console.log("*********SolarPanel Start getToken")
					if (debugOutput) console.log("*********SolarPanel haal de zonneplan info op via tsc command")

					//stuur het tijdelijke wachtwoord en mailadres weer terug naar het TSC script
					var doc2 = new XMLHttpRequest();
					doc2.open("PUT", "file:///tmp/zonneplan_passw.txt");
					doc2.send(mailadress + ";" + zonnePass);

					var doc4 = new XMLHttpRequest();
					doc4.open("PUT", "file:///tmp/tsc.command");
					doc4.send("external-solarPanel");
					
					//wacht op een response vanuit het TSC script
					var onetime = true
					app.zonneplanRegisterDelay(8000, function() {
						if (onetime){
							onetime = false
							parseToken(number)
						}
					})
					
				} else {
					console.log("error: " + http.status)
					if(number===1){
						solarPanelConfigScreen.getPasseText = "Fout.."
					}else{
						solarPanelConfigScreen.getPasseText2 = "Fout.."
					}
					
				}
			}
		}
	    http.send();
	}	


//haal het token uit de respons van het TSC script
	function parseToken(number){
		console.log("*********SolarPanel Start getToken")
		var http = new XMLHttpRequest()
		var url = "file:///tmp/zonneplan_tokens.txt"
		if (debugOutput) console.log("*********SolarPanel url " + url)
		http.open("GET", url, true);
		http.onreadystatechange = function() { // Call a function when the state changes.
			 if (http.readyState === 4) {
					if (http.status === 200) {
						console.log("*********SolarPanel http.responseText " + http.responseText)
						if (http.responseText.indexOf("were incorrect")> 0){
							if(number===1){
								solarPanelConfigScreen.getPasseText = "Fout.."
							}else{
								solarPanelConfigScreen.getPasseText2 = "Fout.."
							}
						}else{
							var JsonString = http.responseText
							var JsonObject= JSON.parse(JsonString)
							if(number===1){
								app.zonneplanToken = JsonObject.access_token
								app.zonneplanRefreshToken = JsonObject.refresh_token
								if (debugOutput) console.log("*********SolarPanel token : " + app.zonneplanToken)
								if (debugOutput) console.log("*********SolarPanel RefreshToken : " + app.zonneplanRefreshToken)
								if (debugOutput) console.log("*********SolarPanel save refreshtoken" )
								solarPanelConfigScreen.getPasseText = "Token OK, sla op"
								solarPanelConfigScreen.sendMailText = "Token OK, sla op"
								var doc4 = new XMLHttpRequest()
								doc4.open("PUT", "file:///mnt/data/tsc/appData/solarPanel_refreshtoken.txt")
								doc4.send(app.zonneplanRefreshToken)
								needRestart = true
							}else{
								app.zonneplanToken2 = JsonObject.access_token
								app.zonneplanRefreshToken2 = JsonObject.refresh_token
								if (debugOutput) console.log("*********SolarPanel token2 : " + app.zonneplanToken2)
								if (debugOutput) console.log("*********SolarPanel RefreshToken2 : " + app.zonneplanRefreshToken2)
								if (debugOutput) console.log("*********SolarPanel save refreshtoken2" )
								solarPanelConfigScreen.getPasseText2 = "Token OK, sla op"
							    solarPanelConfigScreen.sendMailText2 = "Token OK, sla op"
								var doc4 = new XMLHttpRequest()
								doc4.open("PUT", "file:///mnt/data/tsc/appData/solarPanel_refreshtoken2.txt")
								doc4.send(app.zonneplanRefreshToken2)
								needRestart = true
							}
						}
					} else {
						if (debugOutput) console.log("error: " + http.status)
						if(number===1){
							solarPanelConfigScreen.getPasseText = "Fout.."
						}else{
							solarPanelConfigScreen.getPasseText2 = "Fout.."
						}
					}
			}
		}
		http.send();
	}
