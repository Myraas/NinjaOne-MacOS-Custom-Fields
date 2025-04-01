#!/bin/bash
# ea_chrome_version
# Purpose: Check installed Google Chrome version
# Role Custom Field: Type: Text, Label: ea_chrome_version, Name: eachromeversion, Scope: Device
# Run "bash ea_chrome_version.sh -debug" to view results in a local terminal

DEBUG_MODE=false
if [[ "$1" == "-debug" ]]; then
    DEBUG_MODE=true
fi

if [ -d "/Applications/Google Chrome.app" ] ; then
    RESULT=$( defaults read "/Applications/Google Chrome.app/Contents/Info" CFBundleShortVersionString )
else
    RESULT="Not Installed"
fi

if $DEBUG_MODE; then
    echo "DEBUG OUTPUT: eachromeversion value:"
    echo "$result"
    exit 0
fi

/Applications/NinjaRMMAgent/programdata/ninjarmm-cli set eachromeversion "$result"
