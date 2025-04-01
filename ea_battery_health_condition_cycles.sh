#!/bin/bash
# ea_battery_health_condition_cycles
# Purpose: Check battery health, condition, and cycle count
# Global Custom Field: Type: Text, Label: ea_battery_health_condition_cycles, Name: eabatteryhealthconditioncycles, Scope: Device
# Run "bash ea_battery_health_condition_cycles.sh -debug" to view results in a local terminal

DEBUG_MODE=false
if [[ "$1" == "-debug" ]]; then
    DEBUG_MODE=true
fi

health=`ioreg -r -c "AppleSmartBattery" | grep "PermanentFailureStatus" | awk '{print $3}' | sed s/\"//g`
if [ "$health" == "1" ]; then
    health="Failure"
elif [ "$health" == "0" ]; then
    health="OK"
fi

condition=`system_profiler SPPowerDataType | grep "Condition" | awk '{print $2}'`
cycles=`system_profiler SPPowerDataType | grep "Cycle Count" | awk '{print $3}'`

result="$health, $condition, $cycles"

if $DEBUG_MODE; then
    echo "DEBUG OUTPUT: eabatteryhealthconditioncycles value:"
    echo "$result"
    exit 0
fi

/Applications/NinjaRMMAgent/programdata/ninjarmm-cli set eabatteryhealthconditioncycles "$result"