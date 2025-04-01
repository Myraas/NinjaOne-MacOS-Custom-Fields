#!/bin/zsh
# ea_secure_token_holders
# Purpose: Report all user accounts who have a secure token
# Global Custom Field: Type: Text, Label: ea_secure_token_holders, Name: easecuretokenholders, Scope: Device
# Run "zsh ea_secure_token_holders.sh -debug" to view results in a local terminal

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

secureTokenAdmins=()
secureTokenUsers=()

for uuid in ${$(/usr/sbin/diskutil apfs listUsers / | /usr/bin/awk '/\+\-\-/ {print $2}')}; do
    username="$(/usr/bin/dscl . -search /Users GeneratedUID ${uuid} | /usr/bin/awk 'NR==1{print $1}')"
    
    if /usr/sbin/dseditgroup -o checkmember -m "$username" admin &>/dev/null; then
        secureTokenAdmins+=($username)
    else
        secureTokenUsers+=($username)
    fi
done

if [[ -z ${secureTokenAdmins[@]} ]]; then
    stList="$(echo "Admins: None")"
else
    stList="$(echo "Admins: ${secureTokenAdmins[1]}")"
    
    for user in ${secureTokenAdmins[@]:1}; do
        stList+=", $user"
    done
fi

if [[ -z ${secureTokenAdmins[@]} ]] && [[ -z ${secureTokenUsers[@]} ]]; then
    stList="$(echo "No Secure Token Users")"
elif [[ -z ${secureTokenUsers[@]} ]]; then
    stList+="\n$(echo "Non-Admins: None")"
else
    stList+="\n$(echo "Non-Admins: ${secureTokenUsers[1]}")"
    
    for user in ${secureTokenUsers[@]:1}; do
        stList+=", $user"
    done
fi

result="$stList"

if $DEBUG_MODE; then
    echo "DEBUG OUTPUT: easecuretokenholders value:"
    echo "$result"
    exit 0
fi

/Applications/NinjaRMMAgent/programdata/ninjarmm-cli set easecuretokenholders "$result"