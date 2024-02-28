#!/bin/bash

# Check if /tmp is a separate partition
if mount | grep -q "on /tmp "; then
    echo "/tmp is a separate partition" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "/tmp is not a separate partition" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

#------------------------------------------------------------------------------------

# Check if nodev option is set on /tmp partition
if findmnt --kernel /tmp | grep nodev; then
    echo "nodev option is set on /tmp partition" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "nodev option is not set on /tmp partition" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

#------------------------------------------------------------------------------------

# Check if noexec option is set on /tmp partition
if findmnt --kernel /tmp | grep noexec; then
    echo "noexec option is set on /tmp partition" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "noexec option is not set on /tmp partition" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

#------------------------------------------------------------------------------------

# Check if nosuid option is set on /tmp partition
if findmnt --kernel /tmp | grep nosuid; then
    echo "nosuid option is set on /tmp partition" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "nosuid option is not set on /tmp partition" >> "/home/lab/kovennukset/security_check_fail.txt"
fi