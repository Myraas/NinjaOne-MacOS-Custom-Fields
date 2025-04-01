#!/bin/bash
# ea_battery_cycles
# Purpose: Check battery cycle count
# Role Custom Field: Type: Text, Label: ea_battery_cycles, Name: eabatterycycles, Scope: Device
# Run "bash ea_battery_cycles.sh -debug" to view results in a local terminal

DEBUG_MODE=false
if [[ "$1" == "-debug" ]]; then
    DEBUG_MODE=true
fi

cycles=`system_profiler SPPowerDataType | grep "Cycle Count" | awk '{print $3}'`
result="$cycles"

if $DEBUG_MODE; then
    echo "DEBUG OUTPUT: eabatterycycles value:"
    echo "$result"
    exit 0
fi

/Applications/NinjaRMMAgent/programdata/ninjarmm-cli set eabatterycycles "$result"
