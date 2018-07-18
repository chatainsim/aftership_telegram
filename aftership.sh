#!/bin/bash
ME=$(dirname $0)
source $ME/lib.sh

#checkdir

cat $CONF | grep -v "#" > $WORK

while read LINE; do
	COLIS=$(echo $LINE|awk -F";" '{print $2}')
	SLUG=$(echo $LINE|awk -F";" '{print $1}')
	COM=$(echo $LINE|awk -F";" '{print $3}')

	if [ "$1" == "display" ]; then
		echo "$SLUG: $COLIS"
	fi
	curl -s -H "Content-Type: application/json" -H "aftership-api-key: $API" \
	$URL/$SLUG/$COLIS > $PPATH/$COLIS.json
	COUNT=$(grep -o "\"message\"" $PPATH/$COLIS.json |wc -l)
	jq ".data.tracking.checkpoints[$COUNT-1].message" $PPATH/$COLIS.json > $PPATH/last.$COLIS

	if [ ! -f $PPATH/old.$COLIS ]; then
		cp $PPATH/last.$COLIS $PPATH/old.$COLIS
		#tracking_postal_code
		if [ "$SLUG" != "colis-prive" ]; then
			curl -s -H "Content-Type: application/json" -H "aftership-api-key: $API" \
			-d "{\"tracking\": {\"tracking_number\": \"$COLIS\", \"slug\": \"$SLUG\"}}" $URL > $PPATH/add.$COLIS
			exit 0
		else
			POSTAL=$(echo $COLIS| cut -c13-)
			if [ "$1" == "display" ]; then
                		echo "COLIS PRIVE $SLUG: $COLIS $POSTAL"
        		fi
			curl -s -H "Content-Type: application/json" -H "aftership-api-key: $API" \
                        -d "{\"tracking\": {\"tracking_number\": \"$COLIS\", \"tracking_postal_code\": \"$POSTAL\", \"slug\": \"$SLUG\"}}" $URL > $PPATH/add.$COLIS
			exit 0
		fi
	fi
	TAG=$(jq ".data.tracking.checkpoints[$COUNT-1].tag" $PPATH/$COLIS.json)

	diff $PPATH/last.$COLIS $PPATH/old.$COLIS
	if [ $? -eq 1 ]; then
		cp $PPATH/last.$COLIS $PPATH/old.$COLIS
		DATA=$(cat $PPATH/old.$COLIS)
		URLSUIVI=$(grep $SLUG $FOLLOW|awk -F";" '{print $2}'|sed "s/COLIS/$COLIS/g")
		telegram "Colis $COM $COLIS : $DATA - $URLSUIVI"
	fi
	if [ "$TAG" == "\"Delivered\"" ]; then
                sed -e "/$COLIS/ s/^#*/#/" -i $CONF
		curl -s -H "Content-Type: application/json" -H "aftership-api-key: $API" -X DELETE \
		$URL/$SLUG/$COLIS > $PPATH/del.$COLIS
        fi
done < $WORK
