#!/bin/bash

# Check if /var is a separate partition
if mount | grep -q "on /var "; then
    echo "/var is a separate partition" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "/var is not a separate partition" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

#------------------------------------------------------------------------------------

# Check if nodev option is set on /var partition
if findmnt --kernel /var | grep nodev; then
    echo "nodev option is set on /var partition" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "nodev option is not set on /var partition" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

#------------------------------------------------------------------------------------

# Check if nosuid option is set on /var partition
if findmnt --kernel /var | grep nosuid; then
    echo "nosuid option is set on /var partition" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "nosuid option is not set on /var partition" >> "/home/lab/kovennukset/security_check_fail.txt"
fi