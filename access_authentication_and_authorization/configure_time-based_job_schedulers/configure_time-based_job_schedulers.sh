#!/bin/bash

# Check if cron daemon is enabled and running
echo "Ensuring cron daemon is enabled and running"
if systemctl is-enabled cron > /dev/null 2>&1 && systemctl is-active cron > /dev/null 2>&1; then
    echo "cron daemon is enabled and running" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    systemctl --now enable cron
    if systemctl is-enabled cron > /dev/null 2>&1 && systemctl is-active cron > /dev/null 2>&1; then
        echo "cron daemon is enabled and running" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "cron daemon is not enabled or running" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi

#------------------------------------------------------------------------------------

# Check if permissions on /etc/crontab are configured
echo "Ensuring permissions on /etc/crontab are configured"
if [ $(stat -c "%u" /etc/crontab) == "0" ] && [ $(stat -c "%g" /etc/crontab) == "0" ] && [ $(stat -c "%a" /etc/crontab) == "600" ]; then
    echo "permissions on /etc/crontab are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    chown root:root /etc/crontab
    chmod og-rwx /etc/crontab
    if [ $(stat -c "%u" /etc/crontab) == "0" ] && [ $(stat -c "%g" /etc/crontab) == "0" ] && [ $(stat -c "%a" /etc/crontab) == "600" ]; then
        echo "permissions on /etc/crontab are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "permissions on /etc/crontab are not configured" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi

#------------------------------------------------------------------------------------

# Check if permissions on /etc/cron.hourly are configured
echo "Ensuring permissions on /etc/cron.hourly are configured"
if [ $(stat -c "%u" /etc/cron.hourly) == "0" ] && [ $(stat -c "%g" /etc/cron.hourly) == "0" ] && [ $(stat -c "%a" /etc/cron.hourly) == "700" ]; then
    echo "permissions on /etc/cron.hourly are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    chown root:root /etc/cron.hourly
    chmod og-rwx /etc/cron.hourly
    if [ $(stat -c "%u" /etc/cron.hourly) == "0" ] && [ $(stat -c "%g" /etc/cron.hourly) == "0" ] && [ $(stat -c "%a" /etc/cron.hourly) == "700" ]; then
        echo "permissions on /etc/cron.hourly are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "permissions on /etc/cron.hourly are not configured" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi

#------------------------------------------------------------------------------------

# Check if permissions on /etc/cron.daily are configured
echo "Ensuring permissions on /etc/cron.daily are configured"
if [ $(stat -c "%u" /etc/cron.daily) == "0" ] && [ $(stat -c "%g" /etc/cron.daily) == "0" ] && [ $(stat -c "%a" /etc/cron.daily) == "700" ]; then
    echo "permissions on /etc/cron.daily are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    chown root:root /etc/cron.daily
    chmod og-rwx /etc/cron.daily
    if [ $(stat -c "%u" /etc/cron.daily) == "0" ] && [ $(stat -c "%g" /etc/cron.daily) == "0" ] && [ $(stat -c "%a" /etc/cron.daily) == "700" ]; then
        echo "permissions on /etc/cron.daily are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "permissions on /etc/cron.daily are not configured" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi

#------------------------------------------------------------------------------------

# Check if permissions on /etc/cron.weekly are configured
echo "Ensuring permissions on /etc/cron.weekly are configured"
if [ $(stat -c "%u" /etc/cron.weekly) == "0" ] && [ $(stat -c "%g" /etc/cron.weekly) == "0" ] && [ $(stat -c "%a" /etc/cron.weekly) == "700" ];then
    echo "permissions on /etc/cron.weekly are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    chown root:root /etc/cron.weekly
    chmod og-rwx /etc/cron.weekly
    if [ $(stat -c "%u" /etc/cron.weekly) == "0" ] && [ $(stat -c "%g" /etc/cron.weekly) == "0" ] && [ $(stat -c "%a" /etc/cron.weekly) == "700" ];then
        echo "permissions on /etc/cron.weekly are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "permissions on /etc/cron.weekly are not configured" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi

#------------------------------------------------------------------------------------

# Check if permissions on /etc/cron.monthly are configured
echo "Ensuring permissions on /etc/cron.monthly are configured"
if [ $(stat -c "%u" /etc/cron.monthly) == "0" ] && [ $(stat -c "%g" /etc/cron.monthly) == "0" ] && [ $(stat -c "%a" /etc/cron.monthly) == "700" ];then
    echo "permissions on /etc/cron.monthly are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    chown root:root /etc/cron.monthly
    chmod og-rwx /etc/cron.monthly
    if [ $(stat -c "%u" /etc/cron.monthly) == "0" ] && [ $(stat -c "%g" /etc/cron.monthly) == "0" ] && [ $(stat -c "%a" /etc/cron.monthly) == "700" ];then
        echo "permissions on /etc/cron.monthly are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "permissions on /etc/cron.monthly are not configured" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi

#------------------------------------------------------------------------------------

# Check if permissions on /etc/cron.d are configured
echo "Ensuring permissions on /etc/cron.d are configured"
if [ $(stat -c "%u" /etc/cron.d) == "0" ] && [ $(stat -c "%g" /etc/cron.d) == "0" ] && [ $(stat -c "%a" /etc/cron.d) == "700" ];then
    echo "permissions on /etc/cron.d are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    chown root:root /etc/cron.d
    chmod og-rwx /etc/cron.d
    if [ $(stat -c "%u" /etc/cron.d) == "0" ] && [ $(stat -c "%g" /etc/cron.d) == "0" ] && [ $(stat -c "%a" /etc/cron.d) == "700" ];then
        echo "permissions on /etc/cron.d are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "permissions on /etc/cron.d are not configured" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi

#------------------------------------------------------------------------------------

# Check if cron is restricted to authorized users
echo "Ensuring 'cron' is restricted to authorized users"
# Check if cron.allow file exists
if [ ! -f /etc/cron.allow ]; then
    # Create the file with permissions 640 and owned by root
    touch /etc/cron.allow
    chmod 640 /etc/cron.allow
    chown root:root /etc/cron.allow
    echo "audit" >> /etc/cron.allow
    echo "cron is restricted to authorized users" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    if [ -f /etc/cron.allow ]; then
        if [ $(stat -c %a /etc/cron.allow) != "640" ]; then
        chmod 640 /etc/cron.allow
        fi
    fi
    if ! grep -q 'audit' /etc/cron.allow ; then
        echo "audit" >> /etc/cron.allow
    fi
    echo "cron is restricted to authorized users" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check if cron.deny file exists
if [ -f /etc/cron.deny ]; then
    # Remove the cron.deny file
    rm /etc/cron.deny
fi

#------------------------------------------------------------------------------------

# Check if at is restricted to authorized users
echo "Ensuring 'at' is restricted to authorized users"
# Check if at.allow file exists
if [ ! -f /etc/at.allow ]; then
  # Create the file with permissions 640 and owned by root
    touch /etc/at.allow
    chmod 640 /etc/at.allow
    chown root:root /etc/at.allow
    echo "audit" >> /etc/at.allow
    echo "at is restricted to authorized users" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    if [ -f /etc/at.allow ]; then
        if [ $(stat -c %a /etc/at.allow) != "640" ]; then
        chmod 640 /etc/at.allow
        fi
    fi
    if ! grep -q 'audit' /etc/at.allow ; then
        echo "audit" >> /etc/at.allow
    fi
    echo "at is restricted to authorized users" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check if at.deny file exists
if [ -f /etc/at.deny ]; then
    # Remove the at.deny file
    rm /etc/at.deny
fi