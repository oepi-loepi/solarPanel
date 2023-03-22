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
	if [ -s /tmp/zonneplan_mail.txt ]
	then
		MAIL=`cat /tmp/zonneplan_mail.txt`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting approval for: $MAIL"
		curl -H "Content-type: application/x-www-form-urlencoded" -d "email=$MAIL" -X POST https://app-api.zonneplan.nl/auth/request -o /tmp/mail_uid.txt
		rm /tmp/zonneplan_mail.txt
	fi
	if [ -s /tmp/zonneplan_uid.txt ]
	then
		UID=`cat /tmp/zonneplan_uid.txt`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting approval for: $UID"
		curl https://app-api.zonneplan.nl/auth/request/$UID -o /tmp/zonneplan_pass.txt
		rm /tmp/zonneplan_uid.txt
	fi
	if [ -s /tmp/zonneplan_passw.txt ]
	then
		EMAIL=`cat /tmp/zonneplan_passw.txt | cut -d ";" -f 1`
		PASSW=`cat /tmp/zonneplan_passw.txt | cut -d ";" -f 2`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting approval for: $EMAIL"
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting approval for: $PASSW"
		curl -H "Content-type: application/x-www-form-urlencoded" -d "password=$PASSW" -d "grant_type=one_time_password" -d "email=$EMAIL"  -X POST https://app-api.zonneplan.nl/oauth/token -o /tmp/zonneplan_tokens.txt
		rm /tmp/zonneplan_passw.txt
	fi
	if [ -s /tmp/zonneplan_refresh.txt ]
	then
		RFTOKEN=`cat /tmp/zonneplan_refresh.txt`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting approval for: $RFTOKEN"
		curl -H "Content-type: application/x-www-form-urlencoded" -d "grant_type=refresh_token" -d "refresh_token=$RFTOKEN"  -X POST https://app-api.zonneplan.nl/oauth/token -o /tmp/zonneplan_tokens.txt
		cp /tmp/zonneplan_refresh.txt /tmp/zonneplan_old.txt 
		rm /tmp/zonneplan_refresh.txt
	fi
	if [ -s /tmp/zonneplan_step1.txt ]
	then
		TOKEN=`cat /tmp/zonneplan_step1.txt`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting step 1 for: $TOKEN"
		curl -w 'RESP_CODE:%{response_code}' -s -H "Content-type: application/json;charset=utf-8" -H "Authorization: Bearer $TOKEN"   https://app-api.zonneplan.nl/user-accounts/me -o /tmp/zonneplan_response_step1.txt | grep -o  '[1-4][0-9][0-9]'
		rm /tmp/zonneplan_step1.txt
	fi
	if [ -s /tmp/zonneplan_step2.txt ]
	then
		CONNECT=`cat /tmp/zonneplan_step2.txt | cut -d ";" -f 1`
		TOKEN=`cat /tmp/zonneplan_step2.txt | cut -d ";" -f 2`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting step 2 for: $CONNECT"
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting step 2 for: $TOKEN"
		echo "https://app-api.zonneplan.nl/connections/$CONNECT/pv_installation/charts/live"
		curl -w 'RESP_CODE:%{response_code}' -s -H "Content-type: application/json;charset=utf-8" -H "Authorization: Bearer $TOKEN"   https://app-api.zonneplan.nl/connections/$CONNECT/pv_installation/charts/live -o /tmp/zonneplan_response_step2.txt | grep -o  '[1-4][0-9][0-9]'
		rm /tmp/zonneplan_step2.txt
	fi

	if [ -s /tmp/enphase_info.txt ]
	then
		URL=`cat /tmp/enphase_info.txt`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting enphase info for: $URL"
		curl -k https://$URL/info.xml -o /tmp/enphase_info_return.txt
		rm /tmp/enphase_info.txt
	fi
	
	if [ -s /tmp/enphase_token.txt ]
	then
		URL=`cat /tmp/enphase_token.txt | cut -d ";" -f 1`
		TOKEN=`cat /tmp/enphase_token.txt | cut -d ";" -f 2`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting approval for: $URL"
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting approval for: $TOKEN"
		curl -vs -k -H "Authorization: Bearer $TOKEN" https://$URL/auth/check_jwt 2>&1| tee  /tmp/enphase_token_return.txt
		rm /tmp/enphase_token.txt
	fi
	
	if [ -s /tmp/enphase_D7.txt ]
	then
		URL=`cat /tmp/enphase_D7.txt | cut -d ";" -f 1`
		TOKEN=`cat /tmp/enphase_D7.txt | cut -d ";" -f 2`
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting data for: $URL"
		echo "$(date '+%d/%m/%Y %H:%M:%S') Getting data for: $TOKEN"
		curl -k --cookie "sessionid=$TOKEN"  https://$URL/production.json -o /tmp/enphase_D7_return.txt
		rm /tmp/enphase_D7.txt
	fi


# Done
