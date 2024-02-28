#!/bin/bash

# Check if ufw is installed
echo "Ensuring ufw is installed"
if dpkg-query -W -f='${Status}' ufw 2>/dev/null | grep -q "install ok installed"; then
    echo "ufw is installed" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    systemctl unmask ufw.service
    systemctl --now enable ufw.service
    ufw enable
    if dpkg-query -W -f='${Status}' ufw > 2>/dev/null | grep -q "install ok installed"; then
        echo "ufw is now enabled" >> "/home/lab/kovennukset/security_check_fix.txt"
    else
        echo "ufw is not installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi

#------------------------------------------------------------------------------------

# Check if iptables packages are installed
echo "Ensuring iptables is not installed"
if dpkg-query -W -f='${Status}' iptables 2>/dev/null | grep -q "install ok installed"; then
    sudo systemctl --now mask iptables
    if dpkg-query -W -f='${Status}' iptables > 2>/dev/null | grep -q "install ok installed"; then
        echo "iptables packages are installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "iptables packages have been masked" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "iptables packages are not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

#------------------------------------------------------------------------------------

# Check if nftables is installed
echo "Ensuring nftables is not installed"
if dpkg-query -W -f='${Status}' nftables 2>/dev/null | grep -q "install ok installed"; then
    apt-get purge nftables -y
    if dpkg-query -W -f='${Status}' nftables > 2>/dev/null | grep -q "install ok installed"; then
        echo "nftables is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "nftables has been removed" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "nftables is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

#------------------------------------------------------------------------------------

# Check if iptables-persistent is not installed with ufw
echo "Ensuring iptables-persisten is not installed with ufw"
if dpkg-query -W -f='${Status}' iptables-persistent 2>/dev/null | grep -q "install ok installed"; then
    apt-get purge iptables-persistent -y
    if dpkg-query -W -f='${Status}' iptables-persistent > 2>/dev/null | grep -q "install ok installed"; then
        echo "iptables-persistent is installed" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "iptables-persistent has been removed" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "iptables-persistent is not installed" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

#------------------------------------------------------------------------------------

# Check if ufw service is enabled
echo "Ensuring ufw service is enabled"
if systemctl is-enabled ufw 2>/dev/null | grep -q "enabled"; then
    echo "ufw service is enabled" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    systemctl enable ufw
    if systemctl is-enabled ufw > 2>/dev/null | grep -q "enabled"; then
        echo "ufw service is enabled" >> "/home/lab/kovennukset/security_check_fix.txt"
    else
        echo "ufw service is not enabled" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi

#------------------------------------------------------------------------------------

# Check if loopback traffic is allowed
echo "Ensuring loopback traffic is allowed"
if ! (ufw status | grep -q "ALLOW.*Anywhere"); then
    ufw allow in on lo
    if ! (ufw status | grep -q "ALLOW.*Anywhere"); then
        echo "ufw loopback traffic isn't configured 1/4" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "ufw loopback traffic is configured 1/4" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "ufw loopback traffic is configured 1/4" >> "/home/lab/kovennukset/security_check_pass.txt"
    
fi
if ! (ufw status | grep -q "ALLOW OUT.*Anywhere.*lo"); then
    ufw allow out on lo
    if ! (ufw status | grep -q "ALLOW OUT.*Anywhere.*lo"); then
        echo "ufw loopback traffic isn't configured 2/4" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "ufw loopback traffic is configured 2/4" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "ufw loopback traffic is configured 2/4" >> "/home/lab/kovennukset/security_check_pass.txt"
fi
if ! (ufw status | grep -q "DENY.*127.0.0.0/8"); then
    ufw deny in from 127.0.0.0/8
    if ! (ufw status | grep -q "DENY.*127.0.0.0/8"); then
        echo "ufw loopback traffic isn't configured 3/4" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "ufw loopback traffic is configured 3/4" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "ufw loopback traffic is configured 3/4" >> "/home/lab/kovennukset/security_check_pass.txt"
fi
if ! (ufw status | grep -q "DENY.*::1"); then
    ufw deny in from ::1
    if ! (ufw status | grep -q "DENY.*::1"); then
        echo "ufw loopback traffic isn't configured 4/4" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "ufw loopback traffic is configured 4/4" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "ufw loopback traffic is configured 4/4" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

#------------------------------------------------------------------------------------

# Check if ufw outbound connections are configured
echo "Ensuring ufw outbound connections are configured"
if ! (ufw status | grep -q "ALLOW OUT.*Anywhere on all"); then
    ufw allow out on all
    if ! (ufw status | grep -q "ALLOW OUT.*Anywhere on all"); then
        echo "ufw outbound connections are not configured" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "ufw outbound connections are configured" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
else
    echo "ufw outbound connections are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

#------------------------------------------------------------------------------------

# Check if the ufw firewall rules exist for all open ports
echo "Ensuring ufw firewall rules exist for all open ports"
# Get the output of ufw status in verbose mode
ufw_out="$(ufw status verbose)"

# Get the list of open ports
open_ports=$(ss -tuln | awk '($5!~/%lo:/ && $5!~/127.0.0.1:/ && $5!~/::1/) {split($5, a, ":"); print a[2]}' | sort | uniq)

# Check each open port
for port in $open_ports; do
    # Check if the port is missing a firewall rule
    if ! grep -Pq "^\h*$port\b" <<< "$ufw_out"; then
        missing_rules="$missing_rules└ Port \"$port\" was missing firewall rule.\n"
        # Add firewall rule to deny incoming traffic from the port
        ufw deny from any to any port "$port"
    fi
done

if [ -z "$missing_rules" ]; then
    echo "ufw rules exist for all open ports." >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo -e "The following ufw rules were missing for open ports but are now fixed:\n$missing_rules" >> "/home/lab/kovennukset/security_check_fix.txt"
fi

#------------------------------------------------------------------------------------

# Check if ufw default deny firewall policy
echo "Ensuring ufw deny firewall policy by default"
if [ "$(ufw status verbose | grep -c 'Default: deny (incoming), deny (outgoing), disabled (routed)')" -eq 1 ]; then
    ufw default deny incoming
    ufw default deny outgoing
    ufw default deny routed
    if [ "$(ufw status verbose | grep -c 'Default: deny (incoming), deny (outgoing), disabled (routed)')" -eq 1 ]; then
    echo "ufw default deny firewall policy is set" >> "/home/lab/kovennukset/security_check_fix.txt"
else
    echo "ufw default deny firewall policy is not set" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

#------------------------------------------------------------------------------------

