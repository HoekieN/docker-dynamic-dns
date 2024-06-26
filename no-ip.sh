#!/bin/bash

while :
do

if [ -z "$USER" ]
then
	echo "No user was set. Use -u=username"
	exit 10
fi

if [ -z "$PASSWORD" ]
then
	echo "No password was set. Use -p=password"
	exit 20
fi


if [ -z "$HOSTNAME" ]
then
	echo "No host name. Use -h=host.example.com"
	exit 30
fi


if [ -n "$DETECTIP" ]
then
	IP=$(wget -qO- "http://myexternalip.com/raw")

	if [ -n "$UPDATEIPV6" ]
	then
		IPV6=$(wget -q --output-document - http://checkipv6.dyndns.com/ | grep -o "[0-9a-f\:]\{8,\}")
	fi
fi


if [ -n "$DETECTIP" ] && [ -z $IP ]
then
	RESULT="Could not detect external IP."
fi


if [[ $INTERVAL != [0-9]* ]]
then
	echo "Interval is not an integer."
	exit 35
fi


SERVICEURL="dynupdate.no-ip.com/nic/update"

case "$SERVICE" in
        noip)
            SERVICEURL="dynupdate.no-ip.com/nic/update"
            ;;

        dyndns)
            SERVICEURL="members.dyndns.org/v3/update"
            ;;

        duckdns)
            SERVICEURL="www.duckdns.org/v3/update"
            ;;

		google)
            SERVICEURL="domains.google.com/nic/update"
            ;;

    	freedns)
            SERVICEURL="freedns.afraid.org/nic/update"
            ;;

        stratodns)
            SERVICEURL="dyndns.strato.com/nic/update"
            ;;

        *)
			SERVICEURL="dynupdate.no-ip.com/nic/update"

esac

USERAGENT="--user-agent=\"no-ip shell script/1.0 mail@mail.com\""
BASE64AUTH=$(echo '"$USER:$PASSWORD"' | base64)
AUTHHEADER="--header=\"Authorization: $BASE64AUTH\""

NOIPURL="https://$USER:$PASSWORD@$SERVICEURL"


if [ -n "$IP" ] || [ -n "$HOSTNAME" ]
then
	NOIPURL="$NOIPURL?"
fi

if [ -n "$HOSTNAME" ]
then
	NOIPURL="${NOIPURL}hostname=${HOSTNAME}"
fi

if [ -n "$IP" ]
then
	if [ -n "$HOSTNAME" ]
	then
		NOIPURL="$NOIPURL&"
	fi
	NOIPURL="${NOIPURL}myip=$IP"
	if [ -n "$UPDATEIPV6" ]
	then
		NOIPURL="${NOIPURL},$IPV6&myipv6=$IPV6"
	fi
fi


#echo "$AUTHHEADER $USERAGENT $NOIPURL"

	RESULT=$(wget --no-check-certificate -qO- $NOIPURL)


	echo $RESULT


	if [ $INTERVAL -eq 0 ]
	then
		break
	else
		sleep "${INTERVAL}m"
	fi

done

exit 0