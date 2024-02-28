#!/bin/bash

# Check if nodev option is set on /dev/shm partition
if findmnt --kernel /dev/shm | grep nodev; then
    echo "nodev option is set on /dev/shm partition" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "nodev option is not set on /dev/shm partition" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

#------------------------------------------------------------------------------------

# Check if noexec option is set on /dev/shm partition
if findmnt --kernel /dev/shm | grep noexec; then
    echo "noexec option is set on /dev/shm partition" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "noexec option is not set on /dev/shm partition" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

#------------------------------------------------------------------------------------

# Check if nosuid option is set on /dev/shm partition
if findmnt --kernel /dev/shm | grep nosuid; then
    echo "nosuid option is set on /dev/shm partition" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "nosuid option is not set on /dev/shm partition" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

#------------------------------------------------------------------------------------

# Disable Automounting
echo "Disabling Automounting"
if dpkg -s autofs &> /dev/null; then
    # autofs is installed, so uninstall it
    apt purge autofs -y
    echo "autofs was installed and has been uninstalled" >> "/home/lab/kovennukset/security_check_fix.txt"
else
    echo "autofs is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi