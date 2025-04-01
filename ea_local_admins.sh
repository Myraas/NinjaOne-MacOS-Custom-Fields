#!/bin/bash
# ea_local_admins
# Purpose: Detect local admin accounts with UID above 455
# Role Custom Field: Type: Text, Label: ea_local_admins, Name: ealocaladmins, Scope: Device
# Run "bash ea_local_admins.sh -debug" to view results in a local terminal

DEBUG_MODE=false
if [[ "$1" == "-debug" ]]; then
    DEBUG_MODE=true
fi

list=()

for username in $(dscl . list /Users UniqueID | awk '$2 > 455 { print $1 }'); do
    if [[ $(dsmemberutil checkmembership -U "${username}" -G admin) != *not* ]]; then
        list+=("${username}")
    fi
done

if [ ${#list[@]} -eq 0 ]; then
    result="No local admins found"
else
    result=$(printf "%s, " "${list[@]}" | sed 's/, $//')
fi

if $DEBUG_MODE; then
    echo "DEBUG OUTPUT: ealocaladmins value:"
    echo "$result"
    exit 0
fi

/Applications/NinjaRMMAgent/programdata/ninjarmm-cli set ealocaladmins "$result"
