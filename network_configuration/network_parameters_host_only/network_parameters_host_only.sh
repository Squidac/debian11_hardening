#!/bin/bash

# Check if packet redirect sending is disabled for all interfaces
echo "Ensuring packet redirect sending is disabled for all interfaces"
if grep -q ".*net.ipv4.conf.all.send_redirects = 0" /etc/sysctl.conf; then
    echo "Packet redirect sending is disabled for all interfaces" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    # Check if there is already a line with the value 1
    if grep -q "#net.ipv4.conf.all.send_redirects = 1" /etc/sysctl.conf; then
        # Replace the line with value 1 with value 0
        sed -i 's/#net.ipv4.conf.all.send_redirects = 1/net.ipv4.conf.all.send_redirects = 0/' /etc/sysctl.conf
        echo "Packet redirect sending is disabled for all interfaces" >> "/home/lab/kovennukset/security_check_fix.txt"
    else
        if grep -q "net.ipv4.conf.all.send_redirects = 1" /etc/sysctl.conf; then
            # Replace the line with value 1 with value 0
            sed -i 's/net.ipv4.conf.all.send_redirects = 1/net.ipv4.conf.all.send_redirects = 0/' /etc/sysctl.conf
            echo "Packet redirect sending is disabled for all interfaces" >> "/home/lab/kovennukset/security_check_fix.txt"
        fi
    fi
fi

# Check if packet redirect sending is disabled for default interface
echo "Ensuring packet redirect sending is disabled for default interface"
if grep -q ".*net.ipv4.conf.default.send_redirects = 0" /etc/sysctl.conf; then
    echo "Packet redirect sending is disabled for default interface" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    # Check if there is already a line with the value 1
    if grep -q "#net.ipv4.conf.default.send_redirects = 1" /etc/sysctl.conf; then
        # Replace the line with value 1 with value 0
        sed -i 's/#net.ipv4.conf.default.send_redirects = 1/net.ipv4.conf.default.send_redirects = 0/' /etc/sysctl.conf
        echo "Packet redirect sending is disabled for default interface" >> "/home/lab/kovennukset/security_check_fix.txt"
    else
        if grep -q "net.ipv4.conf.default.send_redirects = 1" /etc/sysctl.conf; then
            # Replace the line with value 1 with value 0
            sed -i 's/net.ipv4.conf.default.send_redirects = 1/net.ipv4.conf.default.send_redirects = 0/' /etc/sysctl.conf
            echo "Packet redirect sending is disabled for default interface" >> "/home/lab/kovennukset/security_check_fix.txt"
        fi
    fi
fi

# Check if IP forwarding is disabled
echo "Ensuring IP forwarding is disabled"
if grep -q "#net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "IP forwarding is disabled" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    # Check if there is already a line with the value 1
    if grep -q "#net.ipv4.ip_forward=0" /etc/sysctl.conf; then
        echo "IP forwarding is disabled" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        if grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
            # Replace the line with value 1 with value 0
            sed -i 's/net.ipv4.ip_forward=1/net.ipv4.ip_forward=0/' /etc/sysctl.conf
            echo "Packet redirect sending is disabled for default interface" >> "/home/lab/kovennukset/security_check_fix.txt"
        fi
    fi
fi

# Check if all forwarding is disabled
echo "Ensuring all forwarding is disabled"
if grep -q "#net.ipv6.conf.all.forwarding=1" /etc/sysctl.conf; then
    echo "All forwarding is disabled" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    # Check if there is already a line with the value 1
    if grep -q "#net.ipv6.conf.all.forwarding=0" /etc/sysctl.conf; then
        echo "All forwarding is disabled" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        if grep -q "net.ipv6.conf.all.forwarding=1" /etc/sysctl.conf; then
            # Replace the line with value 1 with value 0
            sed -i 's/net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=0/' /etc/sysctl.conf
            echo "Packet redirect sending is disabled for default interface" >> "/home/lab/kovennukset/security_check_fix.txt"
        fi
    fi
fi