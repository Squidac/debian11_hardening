#!/bin/bash



# Check if AIDE is installed
echo "Ensuring 'AIDE' is installed"
if dpkg-query -W -f='${Status}' aide aide-common 2>/dev/null | grep -q "install ok installed"; then
    echo "AIDE is installed" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "AIDE is not installed" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

#------------------------------------------------------------------------------------

# Check if filesystem integrity is regularly checked
status1=$(systemctl is-enabled aidecheck.service)
status2=$(systemctl is-enabled aidecheck.timer)

if [ "$status1" = "enabled" ] && [ "$status2" = "enabled" ]; then
    echo "AIDE integrity check services and timers are already enabled and running" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    # Configuring and Enabling aidecheck.*
    echo "AIDE integrity check services and timers are not enabled and running, attempting to fix..."
    touch /etc/systemd/system/aidecheck.service
    touch /etc/systemd/system/aidecheck.timer
    echo -e "[Unit]\nDescription=Aide Check\n[Service]\nType=simple\nExecStart=/usr/bin/aide.wrapper --config /etc/aide/aide.conf --check\n[Install]\nWantedBy=multi-user.target" | sudo tee -a /etc/systemd/system/aidecheck.service &> /dev/null
    echo -e "[Unit]\nDescription=Aide check every day at 5AM\n[Timer]\nOnCalendar=*-*-* 05:00:00\nUnit=aidecheck.service\n[Install]\nWantedBy=multi-user.target" | sudo tee -a /etc/systemd/system/aidecheck.timer &> /dev/null
    chown root:root /etc/systemd/system/aidecheck.*
    chmod 0644 /etc/systemd/system/aidecheck.*
    systemctl -q enable aidecheck.service
    systemctl -q --now enable aidecheck.timer
    systemctl -q daemon-reload

    # Check if the fix was successful
    status1=$(systemctl is-enabled aidecheck.service)
    status2=$(systemctl is-enabled aidecheck.timer)

    if [ "$status1" = "enabled" ] && [ "$status2" = "enabled" ]; then
        echo "AIDE integrity check services and timers are now fixed and enabled" >> "/home/lab/kovennukset/security_check_fix.txt"
    else
        echo "Failed to fix AIDE integrity check services and timers" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi