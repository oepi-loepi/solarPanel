/////////             <version>1.0.13</version>
/////////                     GROW1                        /////////////
/////////  Plugin to extract Growatt Solar data for Toon  ///////////////
/////////                   By Oepi-Loepi                  ///////////////


	function base64 (input) {
        var result = '', binData, i;
        var base64Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='.split(''); // Base is 65 in fact :-)
        if (typeof input === 'string') for (i = 0, input = input.split(''); i < input.length; i++) input[i] = input[i].charCodeAt(0);
        for (i = 0; i < input.length; i += 3) {
            binData = (input[i] & 0xFF) << 16 |     // FF.00.00
                      (input[i + 1] & 0xFF) << 8 |  // 00.FF.00
                      (input[i + 2] & 0xFF);        // 00.00.FF
            result += base64Alphabet[(binData & 0xFC0000) >>> 18] +                   //11111100.00000000.00000000 = 0xFC0000 = 16515072
                      base64Alphabet[(binData & 0x03F000) >>> 12] +                   //00000011.11110000.00000000 = 0x03F000 = 258048
                      base64Alphabet[( i + 3 >= input.length && (input.length << 1) % 3 === 2 ? 64 :
                                         (binData & 0x000FC0) >>> 6 )] +              //00000000.00001111.11000000 = 0x000FC0 = 4032
                      base64Alphabet[( i + 3 >= input.length && (input.length << 1) % 3 ? 64 :
                                      binData & 0x00003F )];                          //00000000.00000000.00111111 = 0x00003F = 63
        }
        return result;
    }


     function hexStr2bin(str) {
        str = str.replace(/[^0-9^a-f]/ig, ''); // Cutting off the garbage.
        if (str.length & 1) return false; // Oh, this is not hex string (len % 2 !== 0).
        var result = [], i;
        for (i = 0; i < str.length; i += 2) {
            result[result.length] = parseInt(str.substr(i, 2), 16);
        }
        return result;
    }


	function getSolarData(passWord,userName,apiKey,siteid,urlString,totalValue){
		if (debugOutput) console.log("*********SolarPanel Start getSolisStep1")
		var body = "{\"pageNo\":1,\"pageSize\":10}"
		var keyId= "1300386381676583396"
		var keySecret = "f7f6497ca48c471493fd5b5a3ef56b85"
		var port = "13333"

        var result = ''
        var reqDate = new Date()
        var options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
        var dayArray=['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        var strArray=['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        var wd = dayArray[reqDate.getDay()]
        var d = reqDate.getDate()
        var m = strArray[reqDate.getMonth()]
        var y = reqDate.getFullYear()

        var h = reqDate.getUTCHours()
        var min = reqDate.getMinutes()
        var s = reqDate.getSeconds()

        if (h.toString().length == 1) {
          h = "0" + h;
        }

        if (min.toString().length == 1) {
          min = "0" + min;
        }
        if (s.toString().length == 1) {
         s = "0" + s;
        }

        var newDate =  wd + ", " + d + " " + m + " " + y + " " + h + ":" + min + ":" + s + " GMT"
        var newDateEncoded =encodeURI(newDate)

        var encryptedBody= Qt.md5(body)
        encryptedBody = base64( hexStr2bin(encryptedBody) )
        //console.log(encryptedBody)
        var encryptedBodyEncoded = encodeURI(encryptedBody)
        //console.log(encryptedBodyEncoded)

        var xhr = new XMLHttpRequest()
        var url = "https://codedev.tools/CryptoSecurity/GetHmacGenerator?text=POST%0A" + encryptedBodyEncoded + "%0Aapplication%2Fjson%0A" + newDate + "%0A%2Fv1%2Fapi%2FuserStationList&algorithm=SHA1&secretKey=" + keySecret
        
		var onetime = true
		xhr.open("GET", url, true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
						if (debugOutput) console.log("xhr.status: " + xhr.status)
						if (debugOutput) console.log("xhr.responseText: " + xhr.responseText)
						var JsonObject= JSON.parse(xhr.responseText)
						var encryptedHex = JsonObject.encryptedText
						//console.log("encryptedHex : " + encryptedHex)
						var encrypterdBase64 = base64( hexStr2bin(encryptedHex))
						//console.log("encrypterdBase64 : " + encrypterdBase64)
						var auth =  "API " + keyId + ":" + encrypterdBase64
						var body = "{\"pageNo\":1,\"pageSize\":10}"

						console.log("---------------------------------------------------------------")
						console.log("Content-MD5: " + encryptedBody)
						console.log("Content-Type: application/json")
						console.log("Date: " + newDate)
						console.log("Authorization: " + auth)
						console.log("Port： " + port)
						
						var doc2 = new XMLHttpRequest();
						doc2.open("PUT", "file:///tmp/solis.txt");
						doc2.send(newDate + ";" + auth + ";" + port);

						var doc4 = new XMLHttpRequest();
						doc4.open("PUT", "file:///tmp/tsc.command");
						doc4.send("external-solarPanel");

						//wacht op een response vanuit het TSC script
						solarEnphaseDelay(8000, function() {
							if (onetime){
								onetime = false
								parseSolisJson(totalValue)
							}
						})
					}
                }
            }
        xhr.send();
    }
	
	function parseSolisJson(totalValue){
         if (debugOutput) console.log("*********SolarPanel Start parseSolisJson")
        var http = new XMLHttpRequest()
        var url = "file:///tmp/solis_output.txt"
        if (debugOutput) console.log("*********SolarPanel url: " + url)
        http.open("GET", url, true);
        http.onreadystatechange = function() { // Call a function when the state changes.
            if (debugOutput) console.log("http.readyState: " + http.readyState)
            if (http.readyState === XMLHttpRequest.DONE) {
                if (debugOutput) console.log("http.status: " + http.status)
                if (http.status === 200 || http.status === 300  || http.status === 302) {
                    try {
                        if (debugOutput) console.log("http.status: " + http.status)
                        if (debugOutput) console.log(http.responseText)
                        var JsonObject= JSON.parse(http.responseText)	
						var today2=parseInt((JsonObject.data.page.records[0].dayEnergy) * 1000)
						totalValue= parseInt((JsonObject.data.page.records[0].allEnergy) * 1000000)
						currentPower = parseInt((JsonObject.data.page.records[0].power) * 1000)
						if (debugOutput) console.log("*********SolarPanel currentPower: " + currentPower)
						if (debugOutput) console.log("*********SolarPanel today2: " + today2)
						if (debugOutput) console.log("*********SolarPanel totalValue: " + totalValue)
						parseReturnData(currentPower,totalValue,today2,0,0,0,0,http.status,"succes")
                    }
                    catch (e){
                        currentPower = 0
                        parseReturnData(currentPower,totalValue,todayValue,0,0,0,0, http.status,"error")
                    }
                } else {
					if (http.status === 401){
						if (getDataCount == 0){apiKey = ""}
                        if (getDataCount == 1){apiKey2 = ""}
					}
                     parseReturnData(currentPower,totalValue,todayValue,0,0,0,0, http.status,"error")
                }
            }
        }
       http.send();
    }
