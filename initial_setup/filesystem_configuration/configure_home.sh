#!/bin/bash

# Check if /home is a separate partition
if mount | grep -q "on /home "; then
    echo "/home is a separate partition" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "/home is not a separate partition" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

#------------------------------------------------------------------------------------

# Check if nodev option is set on /home partition
if findmnt -k | grep /home; then
    if findmnt --kernel /home | grep nodev; then
        echo "nodev option is set on /home partition" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "nodev option is not set on /home partition" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
else
    echo "/home is not a partition" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

#------------------------------------------------------------------------------------

# Check if nosuid option is set on /home partition
if findmnt -k | grep /home; then
    if findmnt --kernel /home | grep nosuid; then
        echo "nosuid option is set on /home partition" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "nosuid option is not set on /home partition" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
else
    echo "/home is not a partition" >> "/home/lab/kovennukset/security_check_fail.txt"
fi