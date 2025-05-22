This comprehensive set of steps and scripts should cover the entire workflow for managing users who go on and return from leave. 
Remember to always test these scripts in a non-production environment first!

### Step 1: Create the `onleave` Group (if it doesn't exist)

This group will identify users whose accounts should be locked.

**Command:**
```bash
sudo groupadd onleave
```
**Explanation:**
* `sudo`: Executes the command with superuser privileges.
* `groupadd`: Command to create a new group.
* `onleave`: The name of the group.

---

### Step 2: Add Users to the `onleave` Group

When a user goes on leave, add them to this group.

**Command:**
```bash
sudo usermod -aG onleave <username>
```
**Example:**
```bash
sudo usermod -aG onleave jsmith
sudo usermod -aG onleave mdoe
```
**Explanation:**
* `usermod`: Command to modify user account information.
* `-a`: Appends the user to the supplementary group(s) without removing them from other groups.
* `-G onleave`: Specifies the supplementary group `onleave`.
* `<username>`: The actual username of the person going on leave.

---

### Step 3: Lock Accounts for Users in the `onleave` Group

This is the crucial step to prevent access. You can use the provided script for automation.

/lock_onleave_accounts.sh

**How to use the script:**
1.  Save the code above to a file, e.g., `lock_onleave_accounts.sh`.
2.  Make it executable: `sudo chmod +x lock_onleave_accounts.sh`
3.  Run it: `sudo ./lock_onleave_accounts.sh`

---

### Step 4: When a User Returns - Unlock Account and Remove from `onleave` Group

This is the critical "reverse" process.

/unlock_and_remove_from_onleave.sh

**How to use the script:**
1.  Save the code above to a file, e.g., `unlock_and_remove_from_onleave.sh`.
2.  Make it executable: `chmod +x unlock_and_remove_from_onleave.sh`
3.  Run it, providing the username as an argument:
    ```bash
    sudo ./unlock_and_remove_from_onleave.sh jsmith
    ```

---

### Step 5: (Optional) Delete the `onleave` Group

Only do this if you no longer need the `onleave` group at all (i.e., it's a temporary concept for your organization). **Ensure no users are in the group before deleting it.**

**Command (after all users have been processed from Step 4):**
```bash
sudo groupdel onleave
```
**Explanation:**
* `groupdel`: Command to delete a group.

---