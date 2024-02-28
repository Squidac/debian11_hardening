#!/bin/bash

# Check if minimum days between password changes is configured
echo "Ensuring minimum days between password changes is configured"
if grep -q "^PASS_MIN_DAYS" /etc/login.defs; then
    PASS_MIN_DAYS=$(grep "^PASS_MIN_DAYS.*" /etc/login.defs | awk '{print $2}')
    if [ $PASS_MIN_DAYS -eq 0 ]; then
        sed -i "s/PASS_MIN_DAYS.*/PASS_MIN_DAYS  1/g" /etc/login.defs
        echo "minimum days between password changes is set to 1 days" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "minimum days between password changes is 1 days or more" >> "/home/lab/kovennukset/security_check_pass.txt"
    fi
else
    echo "minimum days between password changes is not configured" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

#------------------------------------------------------------------------------------

# Check if password expiration is 365 or less
echo "Ensuring password expiration is 365 days or less"
if grep -q "^PASS_MAX_DAYS" /etc/login.defs; then
    PASS_MAX_DAYS=$(grep "^PASS_MAX_DAYS.*" /etc/login.defs | awk '{print $2}')
    if [ $PASS_MAX_DAYS -gt 365 ]; then
        sed -i "s/PASS_MAX_DAYS.*/PASS_MAX_DAYS  365/g" /etc/login.defs
        echo "password expiration is set to 365 days" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "password expiration is 365 days or less" >> "/home/lab/kovennukset/security_check_pass.txt"
    fi
else
    echo "password expiration is not configured" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

#------------------------------------------------------------------------------------

# Check if password expiration warning days is 7 or more
echo "Ensuring password expiration warning days is 7 or more"
if grep -q "^PASS_WARN_AGE" /etc/login.defs; then
    PASS_WARN_AGE=$(grep "^PASS_WARN_AGE.*" /etc/login.defs | awk '{print $2}')
    if [ $PASS_WARN_AGE -lt 7 ]; then
        sed -i "s/PASS_WARN_AGE.*/PASS_WARN_AGE  7/g" /etc/login.defs
        echo "password expiration warning days is set to 7" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "password expiration warning days is 7 or more" >> "/home/lab/kovennukset/security_check_pass.txt"
    fi
else
    echo "password expiration warning days are not configured" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

#------------------------------------------------------------------------------------

# # Check if inactive password lock is 30 days or less
# if grep -q "^INACTIVE=[days].*$" /etc/default/useradd; then
#     inactive_days=$(grep -E '^INACTIVE=[0-9]+.*$' /etc/default/useradd | awk '{print $1}' | cut -d = -f 2)
#     if [ $inactive_days -le 30 ]; then
#         echo "inactive password lock is 30 days or less" >> "/home/lab/kovennukset/security_check_pass.txt"
#     else
#         echo "inactive password lock is greater than 30 days" >> "/home/lab/kovennukset/security_check_fail.txt"
#     fi
# else
#     echo "inactive password lock is not configured" >> "/home/lab/kovennukset/security_check_fail.txt"
# fi

#------------------------------------------------------------------------------------

# Check if all users last password change date is in the past
echo "Ensuring all users last password change date is in the past"
awk -F: '/^[^:]+:[^!*]/{print $1}' /etc/shadow | while read -r usr; do
    change=$(date -d "$(chage --list $usr | grep '^Last password change' | cut -d: -f2 | grep -v 'never$')" +%s)
    if [[ "$change" -gt "$(date +%s)" ]]; then
        echo "User: \"$usr\" last password change is in the future." >> "/home/lab/kovennukset/security_check_fail.txt"
    else
        echo "User: \"$usr\" last password change is in the past." >> "/home/lab/kovennukset/security_check_pass.txt"
    fi
done

#------------------------------------------------------------------------------------

# Check system accounts for security
echo "Ensuring all accounts are secured"
unsecured_accounts=$(awk -F: '$1!~/(root|sync|shutdown|halt|^\+)/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"' && $7!~/((\/usr)?\/sbin\/nologin)/ && $7!~/(\/bin)?\/false/ {print $1}' /etc/passwd)

# If unsecured accounts are found, modify them to use nologin shell
if [[ -n "$unsecured_accounts" ]]; then
    for user in $unsecured_accounts; do
        usermod -s $(which nologin) $user
    done
    echo "Modified unsecured accounts: $unsecured_accounts" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "All accounts are secured" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

#------------------------------------------------------------------------------------

# Check if default group for the root account is GID 0
echo "Ensuring default group for the root account is GID 0"
if id -g root | grep -q "^0$"; then
    echo "default group for the root account is GID 0" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    # fix the issue by setting the group ID to 0
    usermod -g 0 root
    if id -g root | grep -q "^0$"; then
        echo "default group for the root account is GID 0" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "default group for the root account is not GID 0" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi

#------------------------------------------------------------------------------------

# Check if default user mask is 027 or more restrictive
echo "Ensuring default user mask is 027 or more restrictive"
current_umask=$(umask)

if [ "$current_umask" != "0027" ]
then
    echo "umask 027" >> /home/lab/.bashrc
    echo "Umask changed to 027 in .bashrc" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "Umask is 0027 in .bashrc" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

#------------------------------------------------------------------------------------

# Check if default user shell timeout is 900 seconds or less
echo "Ensuring default user shell timeout is 900 seconds or less"
timeout=$(grep -m1 -E '^(readonly )?TMOUT=[0-9]+' /etc/bash.bashrc)

if [ -z "$timeout" ]
then
    echo "readonly TMOUT=900 ; export TMOUT" >> /etc/bash.bashrc
    echo "Timeout added with value 900 seconds and made readonly." >> "/home/lab/kovennukset/security_check_pass.txt"
else
    current_timeout=$(echo $timeout | grep -o '[0-9]*')
    if [ $current_timeout -gt 900 ]
    then
        sed -i "s/$timeout/readonly TMOUT=900 ; export TMOUT/g" /etc/bash.bashrc
        echo "Timeout was changed to 900 seconds and made readonly." >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "Timeout is already 900 seconds or less and made readonly." >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
fi