#!/bin/sh

#===================================================================================================================================================================
# This script is used to get some data for the solarPanel app where xmlHttpRequest is not possible
# The app is started from the TSC script
#
# Version: 1.0  - oepi-loepi - 18-3-2023
#
#===================================================================================================================================================================


# Start


	echo "$(date '+%d/%m/%Y %H:%M:%S') TSC script instructed me to do some solar"
	if [ -s /var/tmp/zonneplan_mail.txt ]
	then
		MAIL=`cat /var/tmp/zonneplan_mail.txt`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting approval for: $MAIL"
		curl -H "Content-type: application/x-www-form-urlencoded" -d "email=$MAIL" -X POST https://app-api.zonneplan.nl/auth/request -o /tmp/mail_uid.txt
		rm /var/tmp/zonneplan_mail.txt
	fi
	if [ -s /var/tmp/zonneplan_uid.txt ]
	then
		UID=`cat /var/tmp/zonneplan_uid.txt`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting approval for: $UID"
		curl https://app-api.zonneplan.nl/auth/request/$UID -o /tmp/zonneplan_pass.txt
		rm /var/tmp/zonneplan_uid.txt
	fi
	if [ -s /var/tmp/zonneplan_passw.txt ]
	then
		EMAIL=`cat /var/tmp/zonneplan_passw.txt | cut -d ";" -f 1`
		PASSW=`cat /var/tmp/zonneplan_passw.txt | cut -d ";" -f 2`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting approval for: $EMAIL"
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting approval for: $PASSW"
		curl -H "Content-type: application/x-www-form-urlencoded" -d "password=$PASSW" -d "grant_type=one_time_password" -d "email=$EMAIL"  -X POST https://app-api.zonneplan.nl/oauth/token -o /tmp/zonneplan_tokens.txt
		rm /var/tmp/zonneplan_passw.txt
	fi
	if [ -s /var/tmp/zonneplan_refresh.txt ]
	then
		RFTOKEN=`cat /var/tmp/zonneplan_refresh.txt`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting approval for: $RFTOKEN"
		curl -H "Content-type: application/x-www-form-urlencoded" -d "grant_type=refresh_token" -d "refresh_token=$RFTOKEN"  -X POST https://app-api.zonneplan.nl/oauth/token -o /tmp/zonneplan_tokens.txt
		cp /var/tmp/zonneplan_refresh.txt /tmp/zonneplan_old.txt 
		rm /var/tmp/zonneplan_refresh.txt
	fi
	if [ -s /var/tmp/zonneplan_step1.txt ]
	then
		TOKEN=`cat /var/tmp/zonneplan_step1.txt`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting step 1 for: $TOKEN"
		curl -w 'RESP_CODE:%{response_code}' -s -H "Content-type: application/json;charset=utf-8" -H "Authorization: Bearer $TOKEN"   https://app-api.zonneplan.nl/user-accounts/me -o /tmp/zonneplan_response_step1.txt | grep -o  '[1-4][0-9][0-9]'
		rm /var/tmp/zonneplan_step1.txt
	fi
	if [ -s /var/tmp/zonneplan_step2.txt ]
	then
		CONNECT=`cat /var/tmp/zonneplan_step2.txt | cut -d ";" -f 1`
		TOKEN=`cat /var/tmp/zonneplan_step2.txt | cut -d ";" -f 2`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting step 2 for: $CONNECT"
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting step 2 for: $TOKEN"
		echo "https://app-api.zonneplan.nl/connections/$CONNECT/pv_installation/charts/live"
		curl -w 'RESP_CODE:%{response_code}' -s -H "Content-type: application/json;charset=utf-8" -H "Authorization: Bearer $TOKEN"   https://app-api.zonneplan.nl/connections/$CONNECT/pv_installation/charts/live -o /tmp/zonneplan_response_step2.txt | grep -o  '[1-4][0-9][0-9]'
		rm /var/tmp/zonneplan_step2.txt
	fi

	if [ -s /var/tmp/enphase_info.txt ]
	then
		URL=`cat /tmp/enphase_info.txt`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting enphase info for: $URL"
		curl -k https://$URL/info.xml -o /tmp/enphase_info_return.txt
		rm /var/tmp/enphase_info.txt
	fi
	
	if [ -s /var/tmp/enphase_token.txt ]
	then
		URL=`cat /var/tmp/enphase_token.txt | cut -d ";" -f 1`
		TOKEN=`cat /var/tmp/enphase_token.txt | cut -d ";" -f 2`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting approval for: $URL"
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting approval for: $TOKEN"
		curl -vs -k -H "Authorization: Bearer $TOKEN" https://$URL/auth/check_jwt 2>&1| tee  /tmp/enphase_token_return.txt
		rm /var/tmp/enphase_token.txt
	fi
	
	if [ -s /var/tmp/enphase_D7.txt ]
	then
		URL=`cat /var/tmp/enphase_D7.txt | cut -d ";" -f 1`
		TOKEN=`cat /var/tmp/enphase_D7.txt | cut -d ";" -f 2`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting data for: $URL"
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting data for: $TOKEN"
		curl -k --cookie "sessionid=$TOKEN"  https://$URL/production.json -o /tmp/enphase_D7_return.txt
		rm /var/tmp/enphase_D7.txt
	fi

	if [ -s /var/tmp/huawei_passw.txt ]
	then
		EMAIL=`cat /tmp/huawei_passw.txt | cut -d ";" -f 1`
		PASSW=`cat /tmp/huawei_passw.txt | cut -d ";" -f 2`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting approval for: $EMAIL"
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting approval for: $PASSW"		

		curl --location -k 'https://region01eu5.fusionsolar.huawei.com:32800/rest/neteco/appauthen/v1/smapp/app/token' \
		-c /var/tmp/cookie.txt \
		-b /var/tmp/cookie.txt \
		--header 'Host: region01eu5.fusionsolar.huawei.com:32800' \
		--header 'x-timezone-offset: 120' \
		--header 'client-info: _manufacturer=iPad;_model=iPad;_os_ver=16.1.1;_os=iOS;_app_ver=6.23.205;_package_name=com.huawei.smartpvms;appClientId=92693FFB-6F2F-4717-96BF-BA033C7D72BC' \
		--header 'Accept: */*' \
		--header 'Accept-Encoding: gzip, deflate, br' \
		--header 'Cache-Control: no-cache' \
		--header 'Accept-Language: nl-NL;q=1' \
		--header 'Content-Type: application/json' \
		--header 'User-Agent: iCleanPower/6.23.205 (iPad; iOS 16.1.1; Scale/2.00)' \
		--header 'Connection: keep-alive' \
		--header 'roaRand;' \
		--data '{"userName":"'"$EMAIL"'","value":"'"$PASSW"'","grantType":"password","verifyCode":"","appClientId":"92693FFB-6F2F-4717-96BF-BA033C7D72BC"}' \
		>/var/tmp/huaweistep1.txt

		RESPONSE=`cat /var/tmp/huaweistep1.txt`
		echo "$(date '+%d/%m/%Y %H:%M:%S') RESPONSE found : $RESPONSE"
				
		#PARSE ROARAND 1ST REQUEST
		ROARAND=`grep -o 'roaRand":"[^"]*' /var/tmp/huaweistep1.txt | grep -o '[^"]*$'`
		echo "$(date '+%d/%m/%Y %H:%M:%S') ROARAND found in 1st request: $ROARAND"

		if [ !  "$ROARAND" == "" ]
		then
				#PARSE accessToken 1ST REQUEST
				TOKEN=`grep -o 'accessToken":"[^"]*' /var/tmp/huaweistep1.txt | grep -o '[^"]*$'`
				echo "$(date '+%d/%m/%Y %H:%M:%S') TOKEN found in 1st request: $TOKEN"
				
				HOST="region01eu5.fusionsolar.huawei.com:32800"
		else
				curl --location -k 'https://intl.fusionsolar.huawei.com:32800/rest/neteco/appauthen/v1/smapp/app/token' \
				--header 'Host: intl.fusionsolar.huawei.com:32800' \
				--header 'x-timezone-offset: 120' \
				--header 'client-info: _manufacturer=iPad;_model=iPad;_os_ver=16.1.1;_os=iOS;_app_ver=6.23.205;_package_name=com.huawei.smartpvms;appClientId=92693FFB-6F2F-4717-96BF-BA033C7D72BC' \
				--header 'Accept: */*' \
				--header 'Accept-Encoding: gzip, deflate, br' \
				--header 'Cache-Control: no-cache' \
				--header 'Accept-Language: nl-NL;q=1' \
				--header 'Content-Type: application/json' \
				--header 'User-Agent: iCleanPower/6.23.205 (iPad; iOS 16.1.1; Scale/2.00)' \
				--header 'Connection: keep-alive' \
				--header 'roaRand;' \
				--header 'Cookie: locale=nl-nl;Path=/; Secure; HttpOnly' \
				--data '{"userName":"'"$EMAIL"'","value":"'"$PASSW"'","grantType":"password","verifyCode":"","appClientId":"92693FFB-6F2F-4717-96BF-BA033C7D72BC"}' \
				>/var/tmp/huaweistep1.txt

				#PARSE ROARAND 1ST REQUEST
				ROARAND=`grep -o 'roaRand":"[^"]*' /var/tmp/huaweistep1.txt | grep -o '[^"]*$'`
				echo "$(date '+%d/%m/%Y %H:%M:%S') ROARAND found in 1st request: $ROARAND"

				#PARSE accessToken 1ST REQUEST
				TOKEN=`grep -o 'accessToken":"[^"]*' /var/tmp/huaweistep1.txt | grep -o '[^"]*$'`
				echo "$(date '+%d/%m/%Y %H:%M:%S') TOKEN found in 1st request: $TOKEN"
				
		fi
			echo "$(date '+%d/%m/%Y %H:%M:%S') try first server"
			# 2ND REQUEST
			curl --location -k --compressed --request POST 'https://region01eu5.fusionsolar.huawei.com:32800/rest/pvms/web/station/v1/station/station-list' \
			--header 'Host: region01eu5.fusionsolar.huawei.com:32800' \
			--header 'Content-Type: application/json' \
			--header 'x-timezone-offset: 120' \
			--header 'Accept: */*' \
			--header 'Accept-Encoding: gzip, deflate, br' \
			--header 'Accept-Language: nl-NL;q=1' \
			--header 'Cache-Control: no-cache' \
			--header 'client-info: _manufacturer=iPad;_model=iPad7,5;_os_ver=16.1.1;_os=iOS;_app_ver=6.23.205;_package_name=com.huawei.smartpvms;appClientId=92693FFB-6F2F-4717-96BF-BA033C7D72BC' \
			--header 'User-Agent: iCleanPower/6.23.205 (iPad; iOS 16.1.1; Scale/2.00)' \
			--header 'Referer: https://region01eu5.fusionsolar.huawei.com' \
			--header 'Connection: keep-alive' \
			--header "roaRand: $ROARAND" \
			--header "Cookie: locale=nl-nl;bspsession=$TOKEN;Path=/; Secure; HttpOnly" \
			--data '{"locale":"nl_NL","sortId":"createTime","sortDir":"DESC","curPage":1,"pageSize":100}' \
			>/var/tmp/huaweistep2.txt
				
			#PARSE DATA REQUEST
			DATATXT=`grep -o '"data"[^"]*' /var/tmp/huaweistep2.txt | grep -o '[^"]*$'`
			echo "$(date '+%d/%m/%Y %H:%M:%S') DATATXT found in 1st request: $DATATXT"

		if [ "$DATATXT" == "" ]
		then
			echo "$(date '+%d/%m/%Y %H:%M:%S') try different server"
			# 2ND REQUEST
			curl --location -k --compressed --request POST 'https://region04eu5.fusionsolar.huawei.com:32800/rest/pvms/web/station/v1/station/station-list' \
			--header 'Host: region04eu5.fusionsolar.huawei.com:32800' \
			--header 'Content-Type: application/json' \
			--header 'x-timezone-offset: 120' \
			--header 'Accept: */*' \
			--header 'Accept-Encoding: gzip, deflate, br' \
			--header 'Accept-Language: nl-NL;q=1' \
			--header 'Cache-Control: no-cache' \
			--header 'client-info: _manufacturer=iPad;_model=iPad7,5;_os_ver=16.1.1;_os=iOS;_app_ver=6.23.205;_package_name=com.huawei.smartpvms;appClientId=92693FFB-6F2F-4717-96BF-BA033C7D72BC' \
			--header 'User-Agent: iCleanPower/6.23.205 (iPad; iOS 16.1.1; Scale/2.00)' \
			--header 'Referer: https://region04eu5.fusionsolar.huawei.com' \
			--header 'Connection: keep-alive' \
			--header "roaRand: $ROARAND" \
			--header "Cookie: locale=nl-nl;bspsession=$TOKEN;Path=/; Secure; HttpOnly" \
			--data '{"locale":"nl_NL","sortId":"createTime","sortDir":"DESC","curPage":1,"pageSize":100}' \
			>/var/tmp/huaweistep2.txt

		fi

		RESPONSE2=`cat /var/tmp/huaweistep2.txt`
		echo "$(date '+%d/%m/%Y %H:%M:%S') RESPONSE2 found : $RESPONSE2"

		rm /var/tmp/huawei_passw.txt
		rm /var/tmp/huaweistep1.txt
	fi

# Done
