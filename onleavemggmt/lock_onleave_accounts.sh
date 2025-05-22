#!/bin/bash

GROUP_NAME="onleave"

echo "--- Locking accounts for users in group '$GROUP_NAME' ---"

# Get a list of users in the group
MEMBERS=$(getent group "$GROUP_NAME" | cut -d: -f4 | tr ',' '\n' | grep -v '^$')

# - getent group "$GROUP_NAME": fetches the group entry from /etc/group or other sources.
# - cut -d: -f4: extracts the 4th field (comma-separated list of users).
# - tr ',' '\n': converts the comma-separated list into one username per line.
# - grep -v '^$': removes any empty lines.

if [ -z "$MEMBERS" ]; then
    echo "No users found in group '$GROUP_NAME'. No accounts to lock."
else
    echo "Users in group '$GROUP_NAME':"
    echo "$MEMBERS"

    for USER in $MEMBERS; do
        echo "  Processing user: $USER"
        # 1. Lock the password (prevents password-based login)
        sudo passwd -l "$USER"
        if [ $? -ne 0 ]; then
            echo "    Warning: Failed to lock password for user $USER."
        fi

        # 2. Change the user's shell to /sbin/nologin (prevents interactive login via SSH, console)
        sudo usermod -s /sbin/nologin "$USER"
        if [ $? -ne 0 ]; then
            echo "    Warning: Failed to set /sbin/nologin shell for user $USER."
        fi

        # Optional but highly recommended for maximum security:
        # 3. Expire the account immediately (effective even with SSH keys, if enabled)
        sudo chage -E "$(date +%Y-%m-%d)" "$USER"
        if [ $? -ne 0 ]; then
            echo "    Warning: Failed to expire account for user $USER."
        fi

        echo "  Account for $USER locked."
    done
fi

echo "--- Account locking process complete ---"