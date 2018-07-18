#!/bin/bash
#Aftership API
API=""
#Telegram API
APITELEGRAM=""
#Telegram Chat id
CHATID=""

#Do not edit below

ME=$(dirname $0)
PPATH="$ME/data"
WORK="$ME/colis.conf.work"
CONF="$ME/colis.conf"
FOLLOW="$ME/url.conf"
ARCH="$ME/archive"
URL="https://api.aftership.com/v4/trackings"


checkdir() {
	for DIRECTORY in $PPATH $ARCH; do
		if [ ! -d $DIRECTORY ]; then
			mkdir $DIRECTORY
		fi
	done
}


telegram() {
	URLTELE="https://api.telegram.org"

	if [ x"$1" == "x" ]; then
        	echo "Error, no message"
        	exit 0
	else
        	curl -s "$URLTELE/bot$APITELEGRAM/sendMessage?chat_id=$CHATID&text=$1" > /dev/null 2>&1
	fi
}
