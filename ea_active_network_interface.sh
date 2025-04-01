#!/bin/bash
# ea_active_network_interface
# Purpose: Display active network services and IP Addresses
# Role Custom Field: Type: Text, Label: ea_active_network_interface, Name: eaactivenetworkinterface, Scope: Device
# Run "bash ea_active_network_interface.sh -debug" to view results in a local terminal"

DEBUG_MODE=false
if [[ "$1" == "-debug" ]]; then
    DEBUG_MODE=true
fi

networkServices=$( /usr/sbin/networksetup -listallnetworkservices | /usr/bin/grep -v asterisk )
result=""

while IFS= read aService
do
    activePort=$( /usr/sbin/networksetup -getinfo "$aService" | /usr/bin/grep "IP address" | /usr/bin/grep -v "IPv6" )
    if [ "$activePort" != "" ] && [ "$result" != "" ]; then
        result="$result\n$aService $activePort"
    elif [ "$activePort" != "" ] && [ "$result" = "" ]; then
        result="$aService $activePort"
    fi
done <<< "$networkServices"

result=$( echo "$result" | /usr/bin/sed '/^$/d')

if $DEBUG_MODE; then
    echo "DEBUG OUTPUT: eaactivenetworkinterface value:"
    echo "$result"
    exit 0
fi

/Applications/NinjaRMMAgent/programdata/ninjarmm-cli set eaactivenetworkinterface "$result"
