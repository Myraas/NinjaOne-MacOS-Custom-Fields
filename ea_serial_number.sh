#!/bin/bash
# ea_serial_number
# Purpose: Report device serial number
# Role Custom Field: Type: Text, Label: ea_serial_number, Name: easerialnumber, Scope: Device
# Run "bash ea_serial_number.sh -debug" to view results in a local terminal

DEBUG_MODE=false
if [[ "$1" == "-debug" ]]; then
    DEBUG_MODE=true
fi

result=$(system_profiler SPHardwareDataType | grep "Serial Number" | awk '{print $4}')

if $DEBUG_MODE; then
    echo "DEBUG OUTPUT: easerialnumber value:"
    echo "$result"
    exit 0
fi

/Applications/NinjaRMMAgent/programdata/ninjarmm-cli set easerialnumber "$result"