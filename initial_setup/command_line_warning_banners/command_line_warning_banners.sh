#!/bin/bash

# Check if message of the day is configured properly
if [ -f /etc/motd ]; then
    echo "message of the day is configured properly" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "message of the day is not configured properly" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

------------------------------------------------------------------------------------

# Check if local login warning banner is configured properly
if [ -f /etc/issue ]; then
    echo "local login warning banner is configured properly" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "local login warning banner is not configured properly" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

------------------------------------------------------------------------------------

# Check if remote login warning banner is configured properly
if [ -f /etc/issue.net ]; then
    echo "remote login warning banner is configured properly" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "remote login warning banner is not configured properly" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

------------------------------------------------------------------------------------

# Check if permissions on /etc/motd are configured
if stat -c "%a" /etc/motd | grep -q "^644$"; then
    echo "permissions on /etc/motd are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "permissions on /etc/motd are not configured" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

------------------------------------------------------------------------------------

# Check if permissions on /etc/issue are configured
if stat -c "%a" /etc/issue | grep -q "^644$"; then
    echo "permissions on /etc/issue are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "permissions on /etc/issue are not configured" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

------------------------------------------------------------------------------------

# Check if permissions on /etc/issue.net are configured
if stat -c "%a" /etc/issue.net | grep -q "^644$"; then
    echo "permissions on /etc/issue.net are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "permissions on /etc/issue.net are not configured" >> "/home/lab/kovennukset/security_check_fail.txt"
fi