#!/bin/bash

# Check if sudo is installed
echo "Ensuring 'sudo' is installed"
if dpkg -s sudo &> /dev/null; then
    echo "sudo is installed" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "sudo is not installed" >> "/home/lab/kovennukset/security_check_fail.txt"
fi
#------------------------------------------------------------------------------------

# Check if sudo commands use pty
echo "Ensuring if sudo commands use pty"
if grep -qrPi '^\h*Defaults\h+([^#\n\r]+,)?use_pty(,\h*\h+\h*)*\h*(#.*)?$' /etc/sudoers*; then
    echo "sudo commands use pty" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    # Backup the original file
    cp -f /etc/sudoers /etc/sudoers.bak
    echo "Defaults use_pty" >> /etc/sudoers
    # Check if the modification was successful
    if grep -qrPi '^\h*Defaults\h+([^#\n\r]+,)?use_pty(,\h*\h+\h*)*\h*(#.*)?$' /etc/sudoers*; then
        echo "sudo commands use pty" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "sudo commands do not use pty" >> "/home/lab/kovennukset/security_check_fail.txt"
        # restore the original file
        cp /etc/sudoers.bak /etc/sudoers
    fi
fi

#------------------------------------------------------------------------------------

# Check if sudo log file exists
echo "Ensuring if sudo log file exists"
if grep -qrPsi "^\h*Defaults\h+([^#]+,\h*)?logfile\h*=\h*(\"|\')?\H+(\"|\')?(,\h*\H+\h*)*\h*(#.*)?$" /etc/sudoers*; then
    echo "sudo log file exists" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    # Backup the original file
    cp -f /etc/sudoers /etc/sudoers.bak
    echo "Defaults logfile="/var/log/sudo.log"" >> /etc/sudoers
    # Check if the modification was successful
    if grep -qrPsi "^\h*Defaults\h+([^#]+,\h*)?logfile\h*=\h*(\"|\')?\H+(\"|\')?(,\h*\H+\h*)*\h*(#.*)?$" /etc/sudoers*; then
        echo "sudo log file exists" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "sudo log file does not exist" >> "/home/lab/kovennukset/security_check_fail.txt"
        # restore the original file
        cp /etc/sudoers.bak /etc/sudoers
    fi
fi

#------------------------------------------------------------------------------------

# Ensure users must provide password for privilege escalation
echo "Ensuring users must provide password for privilege escalation"
# Check if any line contains NOPASSWD in sudoers files
result=$(grep -r "^[^#].*NOPASSWD" /etc/sudoers* | grep -v "/etc/sudoers.d/" | grep -v ":#includedir /etc/sudoers.d")
if [ -z "$result" ]; then
    echo "Users must provide password for privilege escalation" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    # Remove any line with NOPASSWD tag in sudoers files
    sudo sed -i 's/\s*NOPASSWD//g' /etc/sudoers /etc/sudoers.d/*
    result1=$(grep -r "^[^#].*NOPASSWD" /etc/sudoers* | grep -v "/etc/sudoers.d/" | grep -v ":#includedir /etc/sudoers.d")
    if [ -z "$result1" ]; then
        echo "Users must provide password for privilege escalation" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "Users doesn't need to provide password for privilege escalation" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi

#------------------------------------------------------------------------------------

# Check if re-authentication for privilege escalation is not disabled globally
echo "Ensuring re-authentication for privilege escalation is not disabled globally"
if ! grep -q "^Defaults.*!authenticate.*$" /etc/sudoers; then
    echo "re-authentication for privilege escalation is not disabled globally" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    # Backup the original file
    cp -f /etc/sudoers /etc/sudoers.bak
    sed -i '/^Defaults.*!authenticate.*$/d' /etc/sudoers
    # Check if the modification was successful
    if ! grep -q "^Defaults.*!authenticate.*$" /etc/sudoers; then
        echo "re-authentication for privilege escalation is not disabled globally" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "re-authentication for privilege escalation is disabled globally" >> "/home/lab/kovennukset/security_check_fail.txt"
        # restore the original file
        cp /etc/sudoers.bak /etc/sudoers
    fi
fi

#------------------------------------------------------------------------------------

# Check if sudo authentication timeout is configured correctly
echo "Ensuring sudo authentication timeout is configured correctly"
if grep -q "^Defaults.*timestamp_timeout=15.*$" /etc/sudoers; then
    echo "sudo authentication timeout is configured correctly" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    # Backup the original file
    cp -f /etc/sudoers /etc/sudoers.bak
    echo "Defaults timestamp_timeout=15" >> /etc/sudoers;
    # Check if the modification was successful
    if grep -q "^Defaults.*timestamp_timeout=15.*$" /etc/sudoers; then
        echo "sudo authentication timeout is configured correctly" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "sudo authentication timeout is not configured correctly" >> "/home/lab/kovennukset/security_check_fail.txt"
        # restore the original file
        cp /etc/sudoers.bak /etc/sudoers
    fi
fi

#------------------------------------------------------------------------------------

# Check if the su command is restricted in /etc/pam.d/su
echo "Ensuring su command is restricted in /etc/pam.d/su"
# If the line exists in the file
if grep -q "auth required pam_wheel.so use_uid group=sugroup" /etc/pam.d/su; then
    echo "Access to the su command is restricted" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    # Uncomment the line
    sed -i 's/#\s*auth.*pam_wheel.so$/auth       required   pam_wheel.so/g' /etc/pam.d/su
    # Add group=sugroup to the line
    sed -i 's/^auth.*pam_wheel.so$/auth required pam_wheel.so use_uid group=sugroup/g' /etc/pam.d/su
    # Create new group "sugroup"
    groupadd sugroup
    if grep -q "auth\s*required\s*pam_wheel.so\s*use_uid\s*group=sugroup" /etc/pam.d/su; then
        echo "Access to the su command is restricted." >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "Access to the su command is not restricted." >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi