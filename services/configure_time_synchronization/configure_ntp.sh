#!/bin/bash

# Check if ntp access control is configured
echo "Ensuring ntp access control is configured"
grep_output=$(grep -P -- '^\h*restrict\h+((-4\h+)?|-6\h+)default\h+(?:[^#\n\r]+\h+)*(?!(?:\2|\3|\4|\5))(\h*\bkod\b\h*|\h*\bnomodify\b\h*|\h*\bnotrap\b\h*|\h*\bnopeer\b\h*|\h*\bnoquery\b\h*)\h+(?:[^#\n\r]+\h+)*(?!(?:\1|\3|\4|\5))(\h*\bkod\b\h*|\h*\bnomodify\b\h*|\h*\bnotrap\b\h*|\h*\bnopeer\b\h*|\h*\bnoquery\b\h*)\h+(?:[^#\n\r]+\h+)*(?!(?:\1|\2|\4|\5))(\h*\bkod\b\h*|\h*\bnomodify\b\h*|\h*\bnotrap\b\h*|\h*\bnopeer\b\h*|\h*\bnoquery\b\h*)\h+(?:[^#\n\r]+\h+)*(?!(?:\1|\2|\3|\5))(\h*\bkod\b\h*|\h*\bnomodify\b\h*|\h*\bnotrap\b\h*|\h*\bnopeer\b\h*|\h*\bnoquery\b\h*)\h+(?:[^#\n\r]+\h+)*(?!(?:\1|\2|\3|\4))(\h*\bkod\b\h*|\h*\bnomodify\b\h*|\h*\bnotrap\b\h*|\h*\bnopeer\b\h*|\h*\bnoquery\b\h*)\h*(?:\h+\H+\h*)*(?:\h+#.*)?$' /etc/ntp.conf)

if [ "$grep_output" != "restrict -4 default kod notrap nomodify nopeer noquery
restrict -6 default kod notrap nomodify nopeer noquery" ]; then
    sed -i -e 's/^restrict -4.*/restrict -4 default kod notrap nomodify nopeer noquery/' -e 's/^restrict -6.*/restrict -6 default kod notrap nomodify nopeer noquery/' /etc/ntp.conf
    echo "ntp access control is configured" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "ntp access control is configured" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check if ntp is running as user ntp
echo "Ensuring ntp is running as user ntp"
ntp_user=$(grep -P -- '^\h*RUNASUSER=' /etc/init.d/ntp | awk -F= '{print $2}')

if [ "$ntp_user" == "ntp" ]; then
    # ntp is running as user ntp
    echo "ntp is running as user ntp" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    sed -i -e 's/^RUNASUSER=*/RUNASUSER=ntp/' /etc/init.d/ntp
    systemctl restart ntp.service
    if [ "$ntp_user" == "ntp" ]; then
        echo "ntp is running as user ntp" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "ntp is not running as user ntp" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi

# Check if ntp is enabled and running
echo "Ensuring ntp is enabled and running"
ntp_status=$(systemctl is-active ntp)

if [ $ntp_status == "active" ]; then
    echo "ntp is enabled and running" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    systemctl enable ntp
    systemctl start ntp
    ntp_status_re=$(systemctl is-active ntp)
    if [ $ntp_status_re == "active" ]; then
        echo "ntp is enabled and running" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "ntp is not enabled and running" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi