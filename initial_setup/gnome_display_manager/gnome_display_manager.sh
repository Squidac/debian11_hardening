#!/bin/bash

# Check if GDM is installed
if dpkg-query -W -f='${Status}' gdm3 2>/dev/null | grep -q "ok installed"; then
    # Uninstalling GDM
    apt purge gdm3 -y
    if dpkg-query -W -f='${Status}' gdm3 2>/dev/null | grep -q "ok installed"; then
        echo "Uninstalling GDM failed." >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "GDM has been uninstalled successfully." >> "/home/lab/kovennukset/security_check_pass.txt"
    fi
else
    echo "GDM is not installed." >> "/home/lab/kovennukset/security_check_pass.txt"
fi

#------------------------------------------------------------------------------

# Check if XDCMP is not enabled
if ! grep -Eis '^\s*Enable\s*=\s*true' /etc/gdm3/custom.conf; then
    echo "XDCMP is not enabled" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    sed -i '/^\s*Enable\s*=\s*true/d' /etc/gdm3/custom.conf
    if ! grep -Eis '^\s*Enable\s*=\s*true' /etc/gdm3/custom.conf; then
        echo "XDCMP is not enabled" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "XDCMP is enabled" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi