#!/bin/bash

# Define the group and the user to process
GROUP_NAME="onleave"
USER_TO_PROCESS="$1" # Takes the username as the first argument

if [ -z "$USER_TO_PROCESS" ]; then
    echo "Usage: $0 <username>"
    echo "Example: $0 jsmith"
    exit 1
fi

echo "--- Processing user: $USER_TO_PROCESS ---"

# 1. Unlock the user's password
echo "  Unlocking password for $USER_TO_PROCESS..."
sudo passwd -u "$USER_TO_PROCESS"
if [ $? -ne 0 ]; then
    echo "    Error: Failed to unlock password for $USER_TO_PROCESS. Please check manually."
    exit 1
fi

# 2. Restore the user's original shell
# Get original shell from /etc/passwd
ORIGINAL_SHELL=$(grep "^$USER_TO_PROCESS:" /etc/passwd | cut -d: -f7)
if [ -z "$ORIGINAL_SHELL" ] || [ "$ORIGINAL_SHELL" == "/sbin/nologin" ]; then
    echo "    Could not determine original shell for $USER_TO_PROCESS. Defaulting to /bin/bash."
    ORIGINAL_SHELL="/bin/bash"
fi
echo "  Restoring shell for $USER_TO_PROCESS to: $ORIGINAL_SHELL..."
sudo usermod -s "$ORIGINAL_SHELL" "$USER_TO_PROCESS"
if [ $? -ne 0 ]; then
    echo "    Error: Failed to restore shell for $USER_TO_PROCESS. Please check manually."
fi

# 3. Remove any account expiration (if applied in Step 3)
echo "  Removing account expiration for $USER_TO_PROCESS..."
sudo chage -E -1 "$USER_TO_PROCESS" # -1 means no expiration date
if [ $? -ne 0 ]; then
    echo "    Warning: Failed to remove account expiration for $USER_TO_PROCESS."
fi

# 4. Remove the user from the 'onleave' group
echo "  Removing $USER_TO_PROCESS from group '$GROUP_NAME'..."
# Check if the user is actually a member of the group before attempting to remove
if id -nG "$USER_TO_PROCESS" | grep -qw "$GROUP_NAME"; then
    sudo gpasswd -d "$USER_TO_PROCESS" "$GROUP_NAME"
    if [ $? -ne 0 ]; then
        echo "    Error: Failed to remove user $USER_TO_PROCESS from group $GROUP_NAME. Please check manually."
    else
        echo "  $USER_TO_PROCESS successfully removed from group '$GROUP_NAME'."
    fi
else
    echo "  $USER_TO_PROCESS is not a member of group '$GROUP_NAME'."
fi

echo "--- Processing for $USER_TO_PROCESS complete. Account unlocked and group removed. ---"