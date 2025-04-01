#!/bin/bash
# ea_secure_token_holders
# Purpose: Report all user accounts who have a secure token
# Role Custom Field: Type: Text, Label: ea_secure_token_holders, Name: easecuretokenholders, Scope: Device
# Run "bash ea_secure_token_holders.sh -debug" to view results in a local terminal

DEBUG_MODE=false
if [[ "$1" == "-debug" ]]; then
    DEBUG_MODE=true
fi

# Check file system type
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

# Initialize arrays for secure token holders
declare -a secureTokenAdmins
declare -a secureTokenUsers

# Get list of secure token UUIDs - bash compatible version
uuids=$(/usr/sbin/diskutil apfs listUsers / | /usr/bin/awk '/\+\-\-/ {print $2}')

# Process each UUID
for uuid in $uuids; do
    username="$(/usr/bin/dscl . -search /Users GeneratedUID ${uuid} | /usr/bin/awk 'NR==1{print $1}')"
    
    # Skip empty usernames
    if [[ -z "$username" ]]; then
        continue
    fi
    
    # Check if user is admin
    if /usr/sbin/dseditgroup -o checkmember -m "$username" admin &>/dev/null; then
        secureTokenAdmins+=("$username")
    else
        secureTokenUsers+=("$username")
    fi
done

# Create temporary file for building output with proper newlines
tmpfile=$(mktemp)

# Handle case with no token holders
if [ ${#secureTokenAdmins[@]} -eq 0 ] && [ ${#secureTokenUsers[@]} -eq 0 ]; then
    echo "No Secure Token Users" > "$tmpfile"
else
    # Build admin section
    if [ ${#secureTokenAdmins[@]} -eq 0 ]; then
        echo "Admins: None" > "$tmpfile"
    else
        # Handle single admin case without comma
        if [ ${#secureTokenAdmins[@]} -eq 1 ]; then
            echo "Admins: ${secureTokenAdmins[0]}" > "$tmpfile"
        else
            # Multiple admins - join with commas
            admin_list="Admins: ${secureTokenAdmins[0]}"
            for ((i=1; i<${#secureTokenAdmins[@]}; i++)); do
                admin_list+=", ${secureTokenAdmins[$i]}"
            done
            echo "$admin_list" > "$tmpfile"
        fi
    fi

    # Build non-admin section
    if [ ${#secureTokenUsers[@]} -eq 0 ]; then
        echo "Non-Admins: None" >> "$tmpfile"
    else
        # Handle single non-admin case without comma
        if [ ${#secureTokenUsers[@]} -eq 1 ]; then
            echo "Non-Admins: ${secureTokenUsers[0]}" >> "$tmpfile"
        else
            # Multiple non-admins - join with commas
            non_admin_list="Non-Admins: ${secureTokenUsers[0]}"
            for ((i=1; i<${#secureTokenUsers[@]}; i++)); do
                non_admin_list+=", ${secureTokenUsers[$i]}"
            done
            echo "$non_admin_list" >> "$tmpfile"
        fi
    fi
fi

# Read the result with proper newlines
result=$(cat "$tmpfile")
rm "$tmpfile"

if $DEBUG_MODE; then
    echo "DEBUG OUTPUT: easecuretokenholders value:"
    echo "$result"
    exit 0
fi

/Applications/NinjaRMMAgent/programdata/ninjarmm-cli set easecuretokenholders "$result"
