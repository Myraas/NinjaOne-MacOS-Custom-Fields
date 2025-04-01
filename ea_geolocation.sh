#!/bin/bash
# ea_geolocation
# Purpose: Report device geolocation based on public IP address
# Role Custom Field: Type: Text, Label: ea_geolocation, Name: eageolocation, Scope: Device
# Run "bash ea_geolocation.sh -debug" to view results in a local terminal

DEBUG_MODE=false
if [[ "$1" == "-debug" ]]; then
    DEBUG_MODE=true
fi

myIP=`curl -L -s --max-time 10 http://checkip.dyndns.org | egrep -o -m 1 '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}'`
myLocationInfo=`curl -L -s --max-time 10 http://ip-api.com/csv/?fields=country,city,lat,lon,/$myIP`

result="$myLocationInfo"

if $DEBUG_MODE; then
    echo "DEBUG OUTPUT: eageolocation value:"
    echo "$result"
    exit 0
fi

/Applications/NinjaRMMAgent/programdata/ninjarmm-cli set eageolocation "$result"
