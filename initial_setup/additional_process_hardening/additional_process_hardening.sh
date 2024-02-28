#!/bin/bash

# Check if address space layout randomization (ASLR) is enabled
echo "Ensuring 'ASLR' is enabled"
if sysctl kernel.randomize_va_space | grep -q "^kernel.randomize_va_space = 2$"; then
    echo "Address Space Layout Randomization (ASLR) is enabled" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    printf "kernel.randomize_va_space = 2" >> /etc/sysctl.d/60-kernel_sysctl.conf
    sysctl -w kernel.randomize_va_space = 2
    if sysctl kernel.randomize_va_space | grep -q "^kernel.randomize_va_space = 2$"; then
        echo "Address Space Layout Randomization (ASLR) is enabled" >> "/home/lab/kovennukset/security_check_fix.txt"
    else
        echo "Address Space Layout Randomization (ASLR) is not enabled" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi

#------------------------------------------------------------------------------------

# Check if prelink is not installed
echo "Ensuring 'prelink' is not installed"
if dpkg-query -W -f='${Status}' prelink 2>/dev/null | grep -q "install ok installed"; then
    prelink -ua
    apt purge -y prelink > /dev/null 2>&1
    if dpkg-query -W -f='${Status}' prelink 2>/dev/null | grep -q "install ok installed"; then
        echo "Prelink is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "Prelink is not installed" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "Prelink is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

#------------------------------------------------------------------------------------

# Check if Automatic Error Reporting is not enabled
echo "Ensuring Automatic Error Reporting is not enabled"
if [ ! -f /etc/default/apport ]; then
    echo "Automatic Error Reporting is not enabled" >> "/home/lab/kovennukset/security_check_pass.txt"
elif grep -q "^enabled=0" /etc/default/apport; then
    echo "Automatic Error Reporting is not enabled" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    apt purge -y apport > /dev/null 2>&1
    if [ ! -f /etc/default/apport ]; then
        echo "Automatic Error Reporting is not enabled" >> "/home/lab/kovennukset/security_check_fix.txt"
    elif grep -q "^enabled=0" /etc/default/apport; then
        echo "Automatic Error Reporting is not enabled" >> "/home/lab/kovennukset/security_check_fix.txt"
    else
        echo "Automatic Error Reporting is enabled" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi

#------------------------------------------------------------------------------------

# Check if core dumps are restricted
echo "Ensuring core dumps are restricted"
if grep -q "#*               hard    core            0" /etc/security/limits.conf; then
    echo "Core dumps are restricted 1/2" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    sed -i 's/#\*               soft    core            0/#*               hard    core            0/g' /etc/security/limits.conf
    if grep -q "#*               hard    core            0" /etc/security/limits.conf; then
        echo "Core dumps are restricted 1/2" >> "/home/lab/kovennukset/security_check_fix.txt"
    else
        echo "Core dumps are not restricted 1/2" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi

if sysctl fs.suid_dumpable | grep -q "fs.suid_dumpable = 0"; then
    echo "Core dumps are restricted 2/2" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf
    sysctl -w fs.suid_dumpable=0
    if sysctl fs.suid_dumpable | grep -q "fs.suid_dumpable = 0"; then
        echo "Core dumps are restricted 2/2" >> "/home/lab/kovennukset/security_check_fix.txt"
        systemctl daemon-reload
    else
        echo "Core dumps are not restricted 2/2" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi