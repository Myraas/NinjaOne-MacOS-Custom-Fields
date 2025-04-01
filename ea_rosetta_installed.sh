#!/bin/bash
# ea_rosetta_installed
# Purpose: Check if Rosetta translation layer is installed on Apple Silicon Macs
# Role Custom Field: Type: Text, Label: ea_rosetta_installed, Name: earosettainstalled, Scope: Device
# Run "bash ea_rosetta_installed.sh -debug" to view results in a local terminal

DEBUG_MODE=false
if [[ "$1" == "-debug" ]]; then
    DEBUG_MODE=true
fi

if [[ "`pkgutil --files com.apple.pkg.RosettaUpdateAuto`" == "" ]]; then
    result="Not Installed"
else
    result="Installed"
fi

if $DEBUG_MODE; then
    echo "DEBUG OUTPUT: earosettainstalled value:"
    echo "$result"
    exit 0
fi

/Applications/NinjaRMMAgent/programdata/ninjarmm-cli set earosettainstalled "$result"
