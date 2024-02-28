#!/bin/bash

# Check if rsyslog is installed
echo "Ensuring rsyslog in installed"
if dpkg -s rsyslog &> /dev/null; then
    echo "rsyslog is installed" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "rsyslog is not installed" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

#------------------------------------------------------------------------------------

# Check if rsyslog service is enabled
echo "Ensuring rsyslog service is enabled"
if systemctl -q is-enabled rsyslog; then
    echo "rsyslog service is enabled" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    sudo systemctl enable rsyslog
    echo "rsyslog service is enabled" >> "/home/lab/kovennukset/security_check_fix.txt"
fi

#------------------------------------------------------------------------------------

# Check if rsyslog default file permissions are configured
echo "Ensuring rsyslog default file permissions are configured"
if grep -q "^$FileCreateMode.*0640.*$" /etc/rsyslog.conf; then
    echo "rsyslog default file permissions are configured" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    sudo sed -i '/^\$FileCreateMode.*/c\$FileCreateMode 0640' /etc/rsyslog.conf
    echo "rsyslog default file permissions are configured" >> "/home/lab/kovennukset/security_check_fix.txt"
fi

#------------------------------------------------------------------------------------

# Ensure rsyslog is not configured to receive logs from a remote client
echo "Ensuring rsyslog is not configured to receive logs from a remote client"

# Check if the imtcp module is loaded
MODULE_LOADED=$(grep -P -- '^\h*module\(load="imtcp"\)' /etc/rsyslog.conf /etc/rsyslog.d/*.conf)
if [ ! -z "$MODULE_LOADED" ]; then
    # Remove the imtcp module loading configuration
    sudo sed -i '/^\s*module(load="imtcp")/d' /etc/rsyslog.conf /etc/rsyslog.d/*.conf
    echo "Removed imtcp module loading configuration" >> "/home/lab/kovennukset/security_check_fix.txt"
else
    echo "IMTCP module is not loaded" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check if remote logging via imtcp is enabled
REMOTE_LOGGING_ENABLED=$(grep -P -- '^\h*input\(type="imtcp" port="514"\)' /etc/rsyslog.conf /etc/rsyslog.d/*.conf)
if [ ! -z "$REMOTE_LOGGING_ENABLED" ]; then
    # Remove the imtcp input configuration
    sudo sed -i '/^\s*input(type="imtcp" port="514")/d' /etc/rsyslog.conf /etc/rsyslog.d/*.conf
    echo "Removed imtcp input configuration" >> "/home/lab/kovennukset/security_check_fix.txt"
else
    echo "Remote logging via IMTCP is not enabled" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Restart the rsyslog service if any changes were made
if [ ! -z "$MODULE_LOADED" ] || [ ! -z "$REMOTE_LOGGING_ENABLED" ]; then
    sudo systemctl restart rsyslog
    echo "Restarted rsyslog service"
fi

#------------------------------------------------------------------------------------

# Ensure all logfiles have appropriate permissions and ownership
echo "Ensuring all logfiles have appropriate permissions and ownership"
{
# Print a message to start the analysis and remediation of logfile permissions and ownership
echo "Start analysis and remediation of logfile permissions and ownership"

# Use the find command to search for files in the /var/log directory, pipe the result to a while loop
find /var/log -type f | while read -r fname; do
    # Get the base name of the file and store it in the bname variable
    bname="$(basename "$fname")"
    # Print the current file being checked
    echo "Checking file: $fname"

    # Use stat command to get the permissions of the file and grep to check if it matches the correct format
    # If the file does not have appropriate permissions, change the mode using chmod
    if stat -Lc "%a" "$fname" | grep -Pq -- '^\h*[0,2,4,6][0,2,4,6][0,4]\h*$' || stat -Lc "%a" "$fname" | grep -Pq -- '^\h*[0,2,4,6][0,4]0\h*$'; then
        echo "Permissions on $fname are appropriate" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "Changing mode on $fname" >> "/home/lab/kovennukset/security_check_fix.txt"
        case "$bname" in
        # Different cases to change the permissions of specific log files
        lastlog | lastlog.* | wtmp | wtmp.* | btmp | btmp.*)
            chmod ug-x,o-wx "$fname"
            ;;
        secure | auth.log)
            chmod u-x,g-wx,o-rwx "$fname"
            ;;
        SSSD | sssd)
            chmod ug-x,o-rwx "$fname"
            ;;
        gdm | gdm3)
            chmod ug-x,o-rwx "$fname"
            ;;
        *.journal)
            chmod u-x,g-wx,o-rwx "$fname"
            ;;
        *)
            chmod u-x,g-wx,o-rwx "$fname"
            ;;
        esac
    fi

# Use stat command to get the owner of the file and grep to check if it matches the correct format
# If the file does not have the appropriate owner, change it using chown
    if stat -Lc "%U" "$fname" | grep -Pq -- '^\h*root\h*$' || stat -Lc "%U" "$fname" | grep -Pq -- '^\h*(syslog|SSSD)\h*$'; then
        echo "Owner on $fname is appropriate" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "Changing owner to root on $fname" >> "/home/lab/kovennukset/security_check_fix.txt"
        chown root "$fname"
    fi

# Use stat command to get the group of the file and grep to check if it matches the correct format
# If the file does not have the appropriate group, change it using chgrp
    if stat -Lc "%G" "$fname" | grep -Pq -- '^\h*(utmp|root)\h*$' || stat -Lc "%G" "$fname" | grep -Pq -- '^\h*(adm|SSSD|gdm3?|systemd-journal)\h*$'; then
        echo "Group on $fname is appropriate" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "Changing group to root on $fname" >> "/home/lab/kovennukset/security_check_fix.txt"
        chgrp root "$fname"
    fi
done
}