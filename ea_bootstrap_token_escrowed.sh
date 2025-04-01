#!/bin/bash
# ea_bootstrap_token_escrowed
# Purpose: Check if the boostrap token has been escrowed to the MDM
# Global Custom Field: Type: Text, Label: ea_bootstrap_token_escrowed, Name: eabootstraptokenescrowed, Scope: Device
# Run "bash ea_bootstrap_token_escrowed.sh -debug" to view results in a local terminal

DEBUG_MODE=false
if [[ "$1" == "-debug" ]]; then
    DEBUG_MODE=true
fi

bootstrap=$(profiles status -type bootstraptoken)
if [[ $bootstrap == *"escrowed to server: YES"* ]]; then
    result="YES"
else
    result="NO"
fi

if $DEBUG_MODE; then
    echo "DEBUG OUTPUT: eabootstraptokenescrowed value:"
    echo "$result"
    exit 0
fi

/Applications/NinjaRMMAgent/programdata/ninjarmm-cli set eabootstraptokenescrowed "$result"