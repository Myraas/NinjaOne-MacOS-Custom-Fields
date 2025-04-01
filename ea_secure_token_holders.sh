#!/bin/bash
# ea_secure_token_holders
# Purpose: Report all user accounts who have a secure token
# Global Custom Field: Type: Text, Label: ea_secure_token_holders, Name: easecuretokenholders, Scope: Device
# Run "bash ea_secure_token_holders.sh -debug" to view results in a local terminal

DEBUG_MODE=false
if [[ "$1" == "-debug" ]]; then
    DEBUG_MODE=true
fi

fsType="$(/usr/sbin/diskutil info / | /usr/bin/awk 'sub(/File System Personality: /,""){print $0}')"
if [[ "$fsType" != *APFS* ]]; then
    result="Unsupported File System: $fsType"
    
    if $DEBUG_MODE; then
        echo "DEBUG OUTPUT: easecuretokenholders value:"
        echo "$result"
        exit 0
    fi
    
    /Applications/NinjaRMMAgent/programdata/ninjarmm-cli set easecuretokenholders "$result"
    exit 0
fi

declare -a secureTokenAdmins
declare -a secureTokenUsers

uuids=$(/usr/sbin/diskutil apfs listUsers / | /usr/bin/awk '/\+\-\-/ {print $2}')

for uuid in $uuids; do
    username="$(/usr/bin/dscl . -search /Users GeneratedUID ${uuid} | /usr/bin/awk 'NR==1{print $1}')"
    
    if /usr/sbin/dseditgroup -o checkmember -m "$username" admin &>/dev/null; then
        secureTokenAdmins+=("$username")
    else
        secureTokenUsers+=("$username")
    fi
done

tmpfile=$(mktemp)

if [ ${#secureTokenAdmins[@]} -eq 0 ] && [ ${#secureTokenUsers[@]} -eq 0 ]; then
    echo "No Secure Token Users" > "$tmpfile"
else
    if [ ${#secureTokenAdmins[@]} -eq 0 ]; then
        echo "Admins: None" > "$tmpfile"
    else
        admin_list="Admins: ${secureTokenAdmins[0]}"
        for ((i=1; i<${#secureTokenAdmins[@]}; i++)); do
            admin_list+=", ${secureTokenAdmins[$i]}"
        done
        echo "$admin_list" > "$tmpfile"
    fi

    if [ ${#secureTokenUsers[@]} -eq 0 ]; then
        echo "Non-Admins: None" >> "$tmpfile"
    else
        non_admin_list="Non-Admins: ${secureTokenUsers[0]}"
        for ((i=1; i<${#secureTokenUsers[@]}; i++)); do
            non_admin_list+=", ${secureTokenUsers[$i]}"
        done
        echo "$non_admin_list" >> "$tmpfile"
    fi
fi

result=$(cat "$tmpfile")
rm "$tmpfile"

if $DEBUG_MODE; then
    echo "DEBUG OUTPUT: easecuretokenholders value:"
    echo "$result"
    exit 0
fi

/Applications/NinjaRMMAgent/programdata/ninjarmm-cli set easecuretokenholders "$result"
