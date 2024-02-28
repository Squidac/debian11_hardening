#!/bin/bash

# Check if source routed packets are not accepted
if grep -q "^net.ipv4.conf.all.accept_source_route =.*0.*$" /etc/sysctl.conf; then
    echo "Source routed packets are not accepted" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "Source routed packets are accepted" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

# Check if ICMP redirects are not accepted
if grep -q "^net.ipv4.conf.all.accept_redirects =.*0.*$" /etc/sysctl.conf; then
    echo "ICMP redirects are not accepted" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "ICMP redirects are accepted" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

# Check if secure ICMP redirects are not accepted
if grep -q "^net.ipv4.conf.all.secure_redirects =.*0.*$" /etc/sysctl.conf; then
    echo "Secure ICMP redirects are not accepted" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "Secure ICMP redirects are accepted" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

# Check if source routed packets are not accepted
if grep -q "^net.ipv4.conf.all.accept_source_route =.*0.*$" /etc/sysctl.conf; then
    echo "Source routed packets are not accepted" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "Source routed packets are accepted" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

# Check if ICMP redirects are not accepted
if grep -q "^net.ipv4.conf.all.accept_redirects =.*0.*$" /etc/sysctl.conf; then
    echo "ICMP redirects are not accepted" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "ICMP redirects are accepted" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

# Check if secure ICMP redirects are not accepted
if grep -q "^net.ipv4.conf.all.secure_redirects =.*0.*$" /etc/sysctl.conf; then
    echo "Secure ICMP redirects are not accepted" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "Secure ICMP redirects are accepted" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

# Check if suspicious packets are logged
if grep -q "^net.ipv4.conf.all.log_martians =.*1.*$" /etc/sysctl.conf; then
    echo "Suspicious packets are logged" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "Suspicious packets are not logged" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

# Check if broadcast ICMP requests are ignored
if grep -q "^net.ipv4.icmp_echo_ignore_broadcasts =.*1.*$" /etc/sysctl.conf; then
    echo "Broadcast ICMP requests are ignored" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "Broadcast ICMP requests are not ignored" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

# Check if bogus ICMP responses are ignored
if grep -q "^net.ipv4.icmp_ignore_bogus_error_responses =.*1.*$" /etc/sysctl.conf; then
    echo "Bogus ICMP responses are ignored" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "Bogus ICMP responses are not ignored" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

# Check if Reverse Path Filtering is enabled
if grep -q "^net.ipv4.conf.all.rp_filter =.*1.*$" /etc/sysctl.conf; then
    echo "Reverse Path Filtering is enabled" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "Reverse Path Filtering is not enabled" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

# Check if TCP SYN Cookies is enabled
if grep -q "^net.ipv4.tcp_syncookies =.*1.*$" /etc/sysctl.conf; then
    echo "TCP SYN Cookies is enabled" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "TCP SYN Cookies is not enabled" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

# Check if IPv6 router advertisements are not accepted
if grep -q "^net.ipv6.conf.all.accept_ra =.*0.*$" /etc/sysctl.conf; then
    echo "IPv6 router advertisements are not accepted" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "IPv6 router advertisements are accepted" >> "/home/lab/kovennukset/security_check_fail.txt"
fi