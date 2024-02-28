#!/bin/bash

# Check if permissions on /etc/passwd are configured
echo "Ensuring permissions on /etc/passwd are configured"
if [ $(stat -c %a /etc/passwd) -le 644 ]; then
    echo "permissions on /etc/passwd are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    chmod 644 /etc/passwd
    chown root:root /etc/passwd
    echo "permissions on /etc/passwd are now configured" >> "/home/lab/kovennukset/security_check_fix.txt"
fi

#------------------------------------------------------------------------------------

# Check if permissions on /etc/passwd- are configured
echo "Ensuring permissions on /etc/passwd- are configured"
if [ $(stat -c %a /etc/passwd-) -le 644 ]; then
    echo "permissions on /etc/passwd- are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    chmod 644 /etc/passwd-
    chown root:root /etc/passwd-
    echo "permissions on /etc/passwd- are now configured" >> "/home/lab/kovennukset/security_check_fix.txt"
fi

#------------------------------------------------------------------------------------

# Check if permissions on /etc/group are configured
echo "Ensuring permissions on /etc/group are configured"
if [ $(stat -c %a /etc/group) -le 644 -a $(stat -c %u /etc/group) -eq 0 -a $(stat -c %g /etc/group) -eq 0 ]; then
    echo "permissions on /etc/group are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    chmod 644 /etc/group
    chown root:root /etc/group
    echo "permissions on /etc/group are now configured" >> "/home/lab/kovennukset/security_check_fix.txt"
fi

#------------------------------------------------------------------------------------

# Check if permissions on /etc/group- are configured
echo "Ensuring permissions on /etc/group- are configured"
if [ $(stat -c %a /etc/group-) -le 644 ]; then
    echo "permissions on /etc/group- are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    chmod 644 /etc/group-
    chown root:root /etc/group-
    echo "permissions on /etc/group- are now configured" >> "/home/lab/kovennukset/security_check_fix.txt"
fi

#------------------------------------------------------------------------------------

# Check if permissions on /etc/shadow are configured
echo "Ensuring permissions on /etc/shadow are configured"
if [ $(stat -c %a /etc/shadow) -le 640 ]; then
    echo "permissions on /etc/shadow are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    chmod 640 /etc/shadow
    chown root:root /etc/shadow
    echo "permissions on /etc/shadow are now configured" >> "/home/lab/kovennukset/security_check_fix.txt"
fi

#------------------------------------------------------------------------------------

# Check if permissions on /etc/shadow- are configured
echo "Ensuring permissions on /etc/shadow are configured"
if [ $(stat -c %a /etc/shadow-) -le 640 ]; then
    echo "permissions on /etc/shadow- are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    chmod 640 /etc/shadow-
    chown root:root /etc/shadow-
    echo "permissions on /etc/shadow- are now configured" >> "/home/lab/kovennukset/security_check_fix.txt"
fi

#------------------------------------------------------------------------------------

# Check if permissions on /etc/gshadow are configured
echo "Ensuring permissions on /etc/gshadow are configured"
if [ $(stat -c %a /etc/gshadow) -le 640 ]; then
    echo "permissions on /etc/gshadow are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    chmod 640 /etc/gshadow
    chown root:root /etc/gshadow
    echo "permissions on /etc/gshadow are now configured" >> "/home/lab/kovennukset/security_check_fix.txt"
fi

#------------------------------------------------------------------------------------

# Check if permissions on /etc/gshadow- are configured
echo "Ensuring permissions on /etc/gshadow- are configured"
if [ $(stat -c %a /etc/gshadow-) -le 640 ]; then
    echo "permissions on /etc/gshadow- are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    chmod 640 /etc/gshadow-
    chown root:root /etc/gshadow-
    echo "permissions on /etc/gshadow- are now configured" >> "/home/lab/kovennukset/security_check_fix.txt"
fi

#------------------------------------------------------------------------------------

# Ensure no world writable files exist
echo "Ensuring no world writable files exist"
world_writable_files=$(df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type f -perm -0002)

# If there are world writable files, fix the permissions and record the failure
if [ -n "$world_writable_files" ]; then
    chmod -R o-w $world_writable_files
    echo "The following files were world writable but are now fixed: $world_writable_files" >> "/home/lab/kovennukset/security_check_fix.txt"
else
    echo "No world writable files found." >> "/home/lab/kovennukset/security_check_pass.txt"
fi

#------------------------------------------------------------------------------------

# Ensure no unowned files or directories exist
echo "Ensuring no unowned files or directories exist"
unowned_files=$(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nouser)

# If there are unowned files, fix ownership and record the failure
if [ -n "$unowned_files" ]; then
    chown -R root:root $unowned_files
    echo "The following files or directories were unowned but are now fixed: $unowned_files" >> "/home/lab/kovennukset/security_check_fix.txt"
else
    echo "No unowned files or directories found." >> "/home/lab/kovennukset/security_check_pass.txt"
fi

#------------------------------------------------------------------------------------

# Ensure no ungrouped files or directories exist
echo "Ensuring no ungrouped files or directories exist"
ungrouped_files=$(df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -nogroup)

# If there are ungrouped files, fix the group and record the failure
if [ -n "$ungrouped_files" ]; then
    chgrp -R root $ungrouped_files
    echo "The following files or directories were ungrouped but are now fixed: $ungrouped_files" >> "/home/lab/kovennukset/security_check_fix.txt"
else
    echo "No ungrouped files or directories found." >> "/home/lab/kovennukset/security_check_pass.txt"
fi