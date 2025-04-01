#!/bin/bash
# ea_uptime_days
# Purpose: Report system uptime in days
# Global Custom Field: Type: Text, Label: ea_uptime_days, Name: eauptimedays, Scope: Device
# Run "bash ea_uptime_days.sh -debug" to view results in a local terminal

DEBUG_MODE=false
if [[ "$1" == "-debug" ]]; then
    DEBUG_MODE=true
fi

uptimeOutput=$(uptime)

[ "${uptimeOutput/day/}" != "${uptimeOutput}" ] && uptimeDays=$(awk -F "up | day" '{print $2}' <<< "${uptimeOutput}")

result="${uptimeDays:-0}"

if $DEBUG_MODE; then
    echo "DEBUG OUTPUT: eauptimedays value:"
    echo "$result"
    exit 0
fi

/Applications/NinjaRMMAgent/programdata/ninjarmm-cli set eauptimedays "$result"