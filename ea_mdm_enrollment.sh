#!/bin/bash
# ea_mdm_enrollment
# Purpose: Check MDM enrollment status
# Role Custom Field: Type: Text, Label: ea_mdm_enrollment, Name: eamdmenrollment, Scope: Device
# Run "bash ea_mdm_enrollment.sh -debug" to view results in a local terminal

DEBUG_MODE=false
if [[ "$1" == "-debug" ]]; then
    DEBUG_MODE=true
fi

# Get MDM enrollment information directly from profiles command
result=$(profiles status -type enrollment)

if $DEBUG_MODE; then
    echo "DEBUG OUTPUT: eamdmenrollment value:"
    echo "$result"
    exit 0
fi

/Applications/NinjaRMMAgent/programdata/ninjarmm-cli set eamdmenrollment "$result"
