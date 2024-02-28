#!/bin/bash

#--------------------------------------------------------------------------------------------

# Check if the accounts in /etc/passwd use shadowed passwords
echo "Ensuring accounts in /etc/passwd use shadowed passwords"
non_shadowed=$(awk -F: '($2 != "x" ) { print $1 " is not set to shadowed passwords "}' /etc/passwd)

if [ -z "$non_shadowed" ]; then
  echo "All accounts in /etc/passwd are using shadowed passwords." >> "/home/lab/kovennukset/security_check_pass.txt"
else
  echo "Fixing non-shadowed passwords in /etc/passwd..."
  sed -e 's/^\([a-zA-Z0-9_]*\):[^:]*:/\1:x:/' -i /etc/passwd
  echo "Done fixing non-shadowed passwords in /etc/passwd." >> "/home/lab/kovennukset/security_check_fix.txt"
fi

#--------------------------------------------------------------------------------------------

# Check if the password fields in /etc/shadow are not empty
echo "Ensuring password fields in /etc/shadow are not empty"
empty_fields=$(awk -F: '($2 == "" ) { print $1 " does not have a password "}' /etc/shadow)

if [ -z "$empty_fields" ]; then
  echo "All password fields in /etc/shadow are not empty." >> "/home/lab/kovennukset/security_check_pass.txt"
else
  echo "Fixing empty password fields in /etc/shadow..."
  while read -r username; do
    passwd -l "$username"
  done <<< "$empty_fields"
  echo "Done fixing empty password fields in /etc/shadow." >> "/home/lab/kovennukset/security_check_fix.txt"
fi

#--------------------------------------------------------------------------------------------

# Check if all groups in /etc/passwd exist in /etc/group
echo "Ensuring all groups in /etc/passwd exist in /etc/group"
for i in $(cut -s -d: -f4 /etc/passwd | sort -u ); do
    grep -q -P "^.*?:[^:]*:$i:" /etc/group
    if [ $? -ne 0 ]; then
        echo "Group $i is referenced by /etc/passwd but does not exist in /etc/group." >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "All groups referenced by /etc/passwd also exists in /etc/group" >> "/home/lab/kovennukset/security_check_pass.txt"
    fi
done

#--------------------------------------------------------------------------------------------

# Check if the shadow group is empty
echo "Ensuring shadow group is empty"
group_members=$(awk -F: -v GID="$(awk -F: '($1=="shadow") {print $3}' /etc/group)" '($4==GID) {print $1}' /etc/passwd)

if [ -n "$group_members" ]; then
  echo "The shadow group is not empty. Removing all users from the shadow group."
  sed -ri 's/(^shadow:[^:]*:[^:]*:)([^:]+$)/\1/' /etc/group
  for user in $group_members; do
    primary_group=$(id -g $user)
    usermod -g $primary_group $user
  done
  echo "The shadow group is now empty." >> "/home/lab/kovennukset/security_check_fix.txt"
else
  echo "The shadow group is empty." >> "/home/lab/kovennukset/security_check_pass.txt"
fi

#--------------------------------------------------------------------------------------------

# Check for duplicate UIDs in /etc/passwd
echo "Ensuring duplicate UIDs doesn't exist in /etc/passwd"
cut -f3 -d":" /etc/passwd | sort -n | uniq -c | while read x ; do
    [ -z "$x" ] && break
    set - $x
    if [ $1 -gt 1 ]; then
        users=$(awk -F: '($3 == n) { print $1 }' n=$2 /etc/passwd | xargs)
        echo "Duplicate UID ($2): $users" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "No duplicate UIDs found in /etc/passwd" >> "/home/lab/kovennukset/security_check_pass.txt"
    fi
done

#--------------------------------------------------------------------------------------------

# Check for duplicate GIDs in /etc/group
echo "Ensuring duplicate GIDs doesn't exist in /etc/group"

duplicate_found=0
cut -d: -f3 /etc/group | sort | uniq -d | while read x ; do
  echo "Duplicate GID ($x) in /etc/group" >> "/home/lab/kovennukset/security_check_fail.txt"
  duplicate_found=1
done

if [ $duplicate_found -eq 0 ]; then
  echo "No duplicate GIDs in /etc/group" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

#--------------------------------------------------------------------------------------------

# Ensure no duplicate user names exist
echo "Ensuring duplicate user names doesn't exist in /etc/passwd"

duplicate_user_found=0
cut -d: -f1 /etc/passwd | sort | uniq -d | while read -r x; do
  echo "Duplicate login name $x in /etc/passwd" >> "/home/lab/kovennukset/security_check_fail.txt"
  duplicate_user_found=1
done

if [ $duplicate_user_found -eq 0 ]; then
  echo "No duplicate user names in /etc/passwd" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

#--------------------------------------------------------------------------------------------

# Ensure no duplicate group names exist
echo "Ensuring duplicate group names doesn't exist in /etc/group"

duplicate_group_name_found=0
cut -d: -f1 /etc/group | sort | uniq -d | while read -r x; do
  echo "Duplicate group name $x in /etc/group" >> "/home/lab/kovennukset/security_check_fail.txt"
  duplicate_group_name_found=1
done

if [ $duplicate_group_name_found -eq 0 ]; then
  echo "No duplicate group names in /etc/group" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

#--------------------------------------------------------------------------------------------

# Ensure local interactive user home directories exist
echo "Ensuring local interactive user home directories exist"
{
    valid_shells_exist="^($( sed -rn '/^\//{s,/,\\\\/,g;p}' /etc/shells | paste -s -d '|' - ))$"

    output=""
    while read -r user home; do
        if [ ! -d "$home" ]; then
            echo -e "\n- User \"$user\" home directory \"$home\" doesn't exist\n- creating home directory \"$home\"\n"
            mkdir "$home"
            chmod g-w,o-wrx "$home"
            chown "$user" "$home"
            echo "User \"$user\" home directory has been created." >> "/home/lab/kovennukset/security_check_fix.txt"
        fi
    done < <(awk -v pat="$valid_shells_exist" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd)

    # Check if there are any users without a home directory
    output=$(awk -F: 'NF < 6 { print "User " $1 " does not have a home directory assigned" }' /etc/passwd)

    if [ -z "$output" ]; then
        echo -e "All local interactive users have a home directory" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo -e "FAILED: $output"
        while read -r user; do
            # Remove the user without a home directory
            userdel "$user"
            if [ $? -ne 0 ]; then
                echo "ERROR: Failed to remove user $user" >> "/home/lab/kovennukset/security_check_fail.txt"
                exit 1
            else
                echo "$user has been removed successfully" >> "/home/lab/kovennukset/security_check_fix.txt"
            fi
        done < <(awk -F: 'NF < 6 { print $1 }' /etc/passwd)
    fi
}

#--------------------------------------------------------------------------------------------

# Ensure local interactive users own their home directories
echo "Ensuring local interactive users own their home directories"
{
    # Define a variable for the valid shell patterns
    valid_shells_own="^($( sed -rn '/^\//{s,/,\\\\/,g;p}' /etc/shells | paste -s -d '|' - ))$"

    # Use awk to extract the username and home directory of all local interactive users
    awk -v pat="$valid_shells_own" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd | while read -r user home; do
    # Get the owner of the home directory
    owner="$(stat -L -c "%U" "$home")"

    # If the owner of the home directory is not the user, update the ownership
    if [ "$owner" != "$user" ]; then
        echo -e "\n- User \"$user\" home directory \"$home\" is owned by user \"$owner\"\n - changing ownership to \"$user\"\n"
        chown "$user" "$home"
        echo -e "\n- User \"$user\" home directory \"$home\" was owned by user \"$owner\"\n - Ownership changed to: \"$user\"\n" >> "/home/lab/kovennukset/security_check_fix.txt"
    else
        echo "All users owns their home directory" >> "/home/lab/kovennukset/security_check_pass.txt"
    fi

    # If the home directory doesn't exist, create it and assign the correct ownership
    if [ ! -d "$home" ]; then
        echo -e "\n- User \"$user\" home directory \"$home\" doesn't exist\n- creating home directory \"$home\"\n"
        mkdir "$home"
        chmod g-w,o-wrx "$home"
        chown "$user" "$home"
        echo -e "\n- User \"$user\" home directory \"$home\" didn't exist\n- Created home directory: \"$home\"\n" >> "/home/lab/kovennukset/security_check_fix.txt"
    else
        echo "All users has home directory" >> "/home/lab/kovennukset/security_check_pass.txt"
    fi
    done
}

#--------------------------------------------------------------------------------------------

# Ensure local interactive user home directories are mode 750 or more restrictive
echo "Ensuring local interactive user home directories are mode 750 or more restrictive"
{
    # Define the permission mask and maximum allowed permission
    perm_mask='0027'
    maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"

    # Define a regular expression for valid shells
    valid_shells="^($( sed -rn '/^\//{s,/,\\\\/,g;p}' /etc/shells | paste -s -d '|' - ))$"

    # Get a list of local interactive users and their home directories
    awk -v pat="$valid_shells" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd | (
    output=""
    # Loop through the list of users and check their home directory permissions
    while read -r user home; do
        if [ -d "$home" ]; then
        mode=$( stat -L -c '%#a' "$home" )
        # If the permissions are too permissive, add to the output
        if [ $(( $mode & $perm_mask )) -gt 0 ]; then
            output="$output User $user home directory: \"$home\" is too permissive: \"$mode\" (should be: \"$maxperm\" or more restrictive)"
            # Modify the permissions to be more restrictive
            chmod g-w,o-rwx "$home"
        fi
        fi
    done
    # Output the results
    if [ -n "$output" ]; then
        echo -e "Fixed:$output" >> "/home/lab/kovennukset/security_check_fix.txt"
    else
        echo -e "All user home directories are mode: \"$maxperm\" or more restrictive" >> "/home/lab/kovennukset/security_check_pass.txt"
    fi
    )
}
#--------------------------------------------------------------------------------------------
{
    # Ensure no local interactive user has .netrc files
    # Ensure no local interactive user has .forward files
    # Ensure no local interactive user has .rhosts files

    echo "Ensuring no local interactive user has .netrc, .forward or .rhosts files"

    # Define output variable and filenames
    netrc_output=""
    forward_output=""
    rhosts_output=""
    netrc_fname=".netrc"
    forward_fname=".forward"
    rhosts_fname=".rhosts"

    # Define the valid shells using a regular expression pattern
    valid_shells="^($( sed -rn '/^\//{s,/,\\\\/,g;p}' /etc/shells | paste -s -d '|' - ))$"

    # Use awk to filter users from /etc/passwd whose shell matches the pattern
    awk -v pat="$valid_shells" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd | (
    # For each filtered user
    while read -r user home; do
        # Check if the user has a .netrc file in their home directory
        if [ -f "$home/$netrc_fname" ]; then
            # If the file exists, add a message to the output
            netrc_output="$netrc_output User \"$user\" file: \"$home/$netrc_fname\" exists\n- removing file: \"$home/$netrc_fname\""
            # Remove the file
            rm -f "$home/$netrc_fname"
        fi

        # Check if the user has a .forward file in their home directory
        if [ -f "$home/$forward_fname" ]; then
            # If the file exists, add a message to the output
            forward_output="$forward_output User \"$user\" file: \"$home/$forward_fname\" exists\n- removing file: \"$home/$forward_fname\""
            # Remove the file
            rm -f "$home/$forward_fname"
        fi

        # Check if the user has a .rhosts file in their home directory
        if [ -f "$home/$rhosts_fname" ]; then
            # If the file exists, add a message to the output
            rhosts_output="$rhosts_output User \"$user\" file: \"$home/$rhosts_fname\" exists\n- removing file: \"$home/$rhosts_fname\""
            # Remove the file
            rm -f "$home/$rhosts_fname"
        fi
    done
    
    # Check if the output variables are empty
    if [ -z "$netrc_output" ] && [ -z "$forward_output" ] && [ -z "$rhosts_output" ]; then
        # If the output variables are empty, print a PASSED message
        echo -e "No local interactive users have \"$netrc_fname\", \"$forward_fname\" or \"$rhosts_fname\" files in their home directory" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        # If the output variables are not empty, print a FAILED message and the output
        if [ -n "$netrc_output" ]; then
            echo -e "Fixed: $netrc_output" >> "/home/lab/kovennukset/security_check_fix.txt"
        fi
        if [ -n "$forward_output" ]; then
            echo -e "Fixed: $forward_output" >> "/home/lab/kovennukset/security_check_fix.txt"
        fi
        if [ -n "$rhosts_output" ]; then
            echo -e "Fixed: $rhosts_output" >> "/home/lab/kovennukset/security_check_fix.txt"
        fi
    fi
    )
}
#--------------------------------------------------------------------------------------------

# Ensure local interactive user dot files are not group or world writable
echo "Ensuring local interactive user dot files are not group or world writable"
{
    # Variables for the permission mask and valid shells.
    perm_mask='0022'
    valid_shells="^($( sed -rn '/^\//{s,/,\\\\/,g;p}' /etc/shells | paste -s -d '|' - ))$"

    # Variable to store the maximum permissions for dot files.
    maxperm="$( printf '%o' $(( 0777 & ~$perm_mask)) )"

    # Store the output of the check in a variable.
    output=""

    # Loop through all the users in /etc/passwd, find the dot files in their home directories, and check the permissions of each file.
    awk -v pat="$valid_shells" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd | while read -r user home; do
        for dfile in $(find "$home" -type f -name '.*'); do
            mode=$( stat -L -c '%#a' "$dfile" )
            if [ $(( $mode & $perm_mask )) -gt 0 ]; then
            output="$output User $user file: \"$dfile\" is too permissive: \"$mode\" (should be: \"$maxperm\" or more restrictive)"
            fi
        done
    done

    # Check if the output variable is empty. If it is not, print the output with a "Failed" message.
    if [ -n "$output" ]; then
        echo -e "Failed:$output"
    else
        echo -e "Passed: All user home dot files are mode: \"$maxperm\" or more restrictive" >> "/home/lab/kovennukset/security_check_pass.txt"
    fi

    # If the check fails, remove the excessive permissions on dot files within interactive users' home directories.
    if [ -n "$output" ]; then
        awk -v pat="$valid_shells" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd | while read -r user home; do
            find "$home" -type f -name '.*' | while read -r dfile; do
                mode=$( stat -L -c '%#a' "$dfile" )
                if [ $(( $mode & $perm_mask )) -gt 0 ]; then
                    echo -e "Modifying User \"$user\" file: \"$dfile\"\n- removing group and other write permissions" >> "/home/lab/kovennukset/security_check_fix.txt"
                    chmod go-w "$dfile"
                fi
            done
        done
    fi
}

#--------------------------------------------------------------------------------------------