#!/bin/bash

# Check if NIS Client is not installed
echo "Ensuring NIS Client is not installed"
if dpkg-query -W -f='${Status}' ypbind 2>/dev/null | grep -q "^install ok installed$"; then
    apt purge -y nis > /dev/null 2>&1
    if dpkg-query -W -f='${Status}' ypbind 2>/dev/null | grep -q "^install ok installed$"; then
        echo "NIS client is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "NIS client has been uninstalled" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "NIS client is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check if rsh client is not installed
echo "Ensuring rsh client is not installed"
if dpkg-query -W -f='${Status}' rsh-client 2>/dev/null | grep -q "^install ok installed$"; then
    apt purge -y rsh-client > /dev/null 2>&1
    if dpkg-query -W -f='${Status}' rsh-client 2>/dev/null | grep -q "^install ok installed$"; then
        echo "rsh client is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "rsh client has been uninstalled" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "rsh client is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check if talk client is not installed
echo "Ensuring talk client is not installed"
if dpkg-query -W -f='${Status}' talk 2>/dev/null | grep -q "^install ok installed$"; then
    apt purge -y talk > /dev/null 2>&1
    if dpkg-query -W -f='${Status}' talk 2>/dev/null | grep -q "^install ok installed$"; then
        echo "talk client is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "talk client has been uninstalled" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "talk client is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check if LDAP client is not installed
echo "Ensuring LDAP client is not installed"
if dpkg-query -W -f='${Status}' ldap-utils 2>/dev/null | grep -q "^install ok installed$"; then
    apt purge -y ldap-utils > /dev/null 2>&1
    if dpkg-query -W -f='${Status}' ldap-utils 2>/dev/null | grep -q "^install ok installed$"; then
        echo "LDAP client is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "LDAP client has been uninstalled" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "LDAP client is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check if RPC is not installed
echo "Ensuring RPC is not installed"
if dpkg-query -W -f='${Status}' rpcbind 2>/dev/null | grep -q "^install ok installed$"; then
    apt purge -y rpcbind > /dev/null 2>&1
    if dpkg-query -W -f='${Status}' rpcbind 2>/dev/null | grep -q "^install ok installed$"; then
        echo "RPC is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "RPC has been uninstalled" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "RPC is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi