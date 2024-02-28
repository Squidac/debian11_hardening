#!/bin/bash

# Check if chrony is installed and enabled
echo "Ensuring chrony is not installed"
chrony_status=$(systemctl is-active chrony)

# Mask chrony if it is installed and enabled
if [[ $chrony_status == "active" ]]; then
    apt purge chrony
    echo "Chrony removed" >> "/home/lab/kovennukset/security_check_fix.txt"
else
    echo "Chrony is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check if systemd-timesyncd is installed and enabled
echo "Ensuring systemd-timesyncd is not installed"
systemd_status=$(systemctl is-active systemd-timesyncd)

# Mask systemd-timesyncd if it is installed and enabled
if [[ $systemd_status == "active" ]]; then
    echo "systemd-timesync is now masked" >> "/home/lab/kovennukset/security_check_fix.txt"
    sudo systemctl --now mask systemd-timesyncd
else
    echo "systemd-timesyncd is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi