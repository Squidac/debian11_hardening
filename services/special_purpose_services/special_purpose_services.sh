#!/bin/bash

# Check if Avahi Server is not installed
echo "Ensuring Avahi Server is not installed"
if dpkg-query -W -f='${Status}' avahi-daemon 2>/dev/null | grep -q "^install ok installed$"; then
    systemctl -q stop avahi-daemon.service
    systemctl -q stop avahi-daemon.socket
    apt purge -y avahi-daemon &> /dev/null
    if dpkg-query -W -f='${Status}' avahi-daemon 2>/dev/null | grep -q "^install ok installed$"; then
        echo "Avahi Server is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "Avahi Server has been uninstalled" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
        echo "Avahi Server is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check if DHCP Server is not installed
echo "Ensuring DHCP Server is not installed"
if dpkg-query -W -f='${Status}' isc-dhcp-server 2>/dev/null | grep -q "^install ok installed$"; then
    apt purge -y isc-dhcp-server &> /dev/null
    if dpkg-query -W -f='${Status}' isc-dhcp-server 2>/dev/null | grep -q "^install ok installed$"; then
        echo "DHCP Server is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "DHCP Server has been uninstalled" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "DHCP Server is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Ensure CUPS is not installed
echo "Ensuring CUPS is not installed"
# Check if CUPS is installed
if dpkg-query -W -f='${Status}' cups 2>/dev/null | grep -q "^install ok installed$"; then
    apt purge -y cups > /dev/null 2>&1
    if dpkg-query -W -f='${Status}' cups 2>/dev/null | grep -q "^install ok installed$"; then
        echo "cups is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "cups has been uninstalled" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "cups is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check if LDAP server is not installed
echo "Ensuring LDAP server is not installed"
if dpkg-query -W -f='${Status}' slapd 2>/dev/null | grep -q "^install ok installed$"; then
    apt purge -y slapd &> /dev/null
    if dpkg-query -W -f='${Status}' slapd 2>/dev/null | grep -q "^install ok installed$"; then
        echo "LDAP server is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "LDAP server has been uninstalled" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "LDAP server is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check if NFS is not installed
echo "Ensuring NFS is not installed"
if dpkg-query -W -f='${Status}' nfs-common 2>/dev/null | grep -q "^install ok installed$"; then
    apt purge -y nfs-kernel-server &> /dev/null
    if dpkg-query -W -f='${Status}' nfs-common 2>/dev/null | grep -q "^install ok installed$"; then
        echo "NFS is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "NFS has been uninstalled" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "NFS is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check if DNS Server is not installed
echo "Ensuring DNS Server is not installed"
if dpkg-query -W -f='${Status}' bind9 2>/dev/null | grep -q "^install ok installed$"; then
    apt purge -y bind9 &> /dev/null
    if dpkg-query -W -f='${Status}' bind9 2>/dev/null | grep -q "^install ok installed$"; then
        echo "DNS Server is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "DNS Server has been uninstalled" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "DNS Server is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check if IMAP and POP3 server are not installed
echo "Ensuring IMAP and POP3 server are not installed"
if dpkg-query -W -f='${Status}' dovecot-imapd 2>/dev/null | grep -q "^install ok installed$"; then
    apt purge -y dovecot-imapd &> /dev/null
    if dpkg-query -W -f='${Status}' dovecot-imapd 2>/dev/null | grep -q "^install ok installed$"; then
        echo "IMAP server is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "IMAP server has been uninstalled" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "IMAP server is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

if dpkg-query -W -f='${Status}' dovecot-pop3d 2>/dev/null | grep -q "^install ok installed$"; then
    apt purge -y dovecot-pop3d &> /dev/null
    if dpkg-query -W -f='${Status}' dovecot-pop3d 2>/dev/null | grep -q "^install ok installed$"; then
        echo "POP3 server is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "POP3 server has been uninstalled" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "POP3 server is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check if HTTP Proxy Server is not installed
echo "Ensuring HTTP Proxy Server is not installed"
if dpkg-query -W -f='${Status}' squid 2>/dev/null | grep -q "^install ok installed$"; then
    apt purge -y squid > /dev/null
    if dpkg-query -W -f='${Status}' squid 2>/dev/null | grep -q "^install ok installed$"; then
        echo "HTTP Proxy Server is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "HTTP Proxy Server has been uninstalled" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "HTTP Proxy Server is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check if NIS Server is not installed
echo "Ensuring NIS Server is not installed"
if dpkg-query -W -f='${Status}' nis 2>/dev/null | grep -q "^install ok installed$"; then
    apt purge -y nis &> /dev/null
    if dpkg-query -W -f='${Status}' nis 2>/dev/null | grep -q "^install ok installed$"; then
        echo "NIS Server is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "NIS Server has been uninstalled" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "NIS Server is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check if mail transfer agent postfix is installed
echo "Ensuring mail transfer agent postfix is installed"
if dpkg-query -W -f='${Status}' postfix 2>/dev/null | grep -q "^install ok installed$"; then
    apt purge -y postfix &> /dev/null
    if dpkg-query -W -f='${Status}' postfix 2>/dev/null | grep -q "^install ok installed$"; then
        echo "Postfix MTA is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "Postfix MTA has been uninstalled" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "Postfix MTA is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check if mail transfer agent exim is installed
echo "Ensuring mail transfer agent exim is installed"
if dpkg-query -W -f='${Status}' exim 2>/dev/null | grep -q "^install ok installed$"; then
    apt purge -y exim &> /dev/null
    if dpkg-query -W -f='${Status}' exim 2>/dev/null | grep -q "^install ok installed$"; then
        echo "Exim MTA is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "Exim MTA has been uninstalled" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "Exim MTA is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check if mail transfer agent sendmail is installed
echo "Ensuring mail transfer agent sendmail is installed"
if dpkg-query -W -f='${Status}' sendmail 2>/dev/null | grep -q "^install ok installed$"; then
    apt purge -y sendmail &> /dev/null
    if dpkg-query -W -f='${Status}' sendmail 2>/dev/null | grep -q "^install ok installed$"; then
        echo "Sendmail MTA is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "Sendmail MTA has been uninstalled" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "Sendmail MTA is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi