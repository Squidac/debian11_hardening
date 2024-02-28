#!/bin/bash

#------------------------------------------------------------------------------------

# Check if pwquality.conf file exists
echo "Ensuring pwquality.conf file exists"
if [ ! -f /etc/security/pwquality.conf ]; then
    echo "pwquality.conf file doesn't exist. Password creation requirements can't be configured." >> "/home/lab/kovennukset/security_check_fail.txt"
else
    echo "pwquality.conf file exists." >> "/home/lab/kovennukset/security_check_pass.txt"
fi

#------------------------------------------------------------------------------------

# Check if password creation requirements are configured
echo "Ensuring password creation requirements are configured"
if grep -qE '^\s*# minlen\s*=' /etc/security/pwquality.conf; then
    sed -i "s/^# minlen.*/minlen = 14/g" /etc/security/pwquality.conf
else
    echo "minlen = 14" >> /etc/security/pwquality.conf
fi

if grep -qE '^\s*# dcredit\s*=' /etc/security/pwquality.conf; then
    sed -i "s/^# dcredit.*/dcredit = -1/g" /etc/security/pwquality.conf
else
    echo "dcredit = -1" >> /etc/security/pwquality.conf
fi

if grep -qE '^\s*# ucredit\s*=' /etc/security/pwquality.conf; then
    sed -i "s/^# ucredit.*/ucredit = -1/g" /etc/security/pwquality.conf
else
    echo "ucredit = -1" >> /etc/security/pwquality.conf
fi

if grep -qE '^\s*# lcredit\s*=' /etc/security/pwquality.conf; then
    sed -i "s/^# lcredit.*/lcredit = -1/g" /etc/security/pwquality.conf
else
    echo "lcredit = -1" >> /etc/security/pwquality.conf
fi

if grep -qE '^\s*# ocredit\s*=' /etc/security/pwquality.conf; then
    sed -i "s/^# ocredit.*/ocredit = -1/g" /etc/security/pwquality.conf
else
    echo "ocredit = -1" >> /etc/security/pwquality.conf
fi

echo "Password creation requirements are configured" >> "/home/lab/kovennukset/security_check_pass.txt"

#------------------------------------------------------------------------------------

# Check that lockout for failed password attempts is configured in common-auth file
echo "Ensuring lockout for failed password attempts is configured in common-auth file"
# Check if the pam_faillock.so lines are present in the common-auth file
if ! grep -q "pam_faillock.so" /etc/pam.d/common-auth; then
    # Check if pam_unix.so line exists in the file
    if grep -q "pam_unix.so" /etc/pam.d/common-auth; then
        # Add the pam_faillock.so lines to the common-auth file in the correct order
        sed -i '/^auth.*pam_unix.so/ i auth required pam_faillock.so preauth' /etc/pam.d/common-auth
        sed -i '/^auth.*pam_unix.so/ a auth [default=die] pam_faillock.so authfail\nauth sufficient pam_faillock.so authsucc' /etc/pam.d/common-auth
        echo "Lockout for failed password is configured in common-auth file" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "Lockout for failed passwords is not configured in common-auth file" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
else
    echo "Lockout for failed password is configured in common-auth file" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Check that lockout for failed password attempts is configured in common-account file
echo "Ensuring lockout for failed password attempts is configured in common-account file"
# Check if the pam_faillock.so lines are present in the common-account file
if ! grep -q "pam_faillock.so" /etc/pam.d/common-account; then
    # Add the pam_faillock.so lines to the common-auth file in the correct order
    echo "account required pam_faillock.so" >> /etc/pam.d/common-account
    echo "Lockout for failed password is configured in common-account file" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "Lockout for failed passwords is configured in common-account file" >> "/home/lab/kovennukset/security_check_pass.txt"
fi

# Define the configuration file
CONF_FILE="/etc/security/faillock.conf"

# Check the deny option
if grep -q "^#[[:space:]]*deny" $CONF_FILE; then
    echo "deny option is in default value 3" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    DENY_OPTION=$(grep "deny =.*" $CONF_FILE | awk '{print $3}')
    if [ "$DENY_OPTION" -gt "4" ]; then
        sed -i "s/deny =.*/deny = 4/" $CONF_FILE
        echo "deny option is set to 4" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "deny option is set to 4 or lower" >> "/home/lab/kovennukset/security_check_pass.txt"
    fi
fi

# Check the fail_interval option
if grep -q "^#[[:space:]]*fail_interval" $CONF_FILE; then
    echo "fail_interval option is in default value 900" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    FAIL_INTERVAL=$(grep "fail_interval =.*" $CONF_FILE | awk '{print $3}')
    if [ $FAIL_INTERVAL -gt "900" ]; then
        sed -i "s/fail_interval =.*/fail_interval = 900/" $CONF_FILE
        echo "fail_interval option is set to 900" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "fail_interval option is set to 900 or lower" >> "/home/lab/kovennukset/security_check_pass.txt"
    fi
fi

# Check the unlock_time option
if grep -q "^#[[:space:]]*unlock_time" $CONF_FILE; then
    echo "unlock_time option is in default value 600" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    UNLOCK_TIME=$(grep "unlock_time =.*" $CONF_FILE | awk '{print $3}')
    if [ $UNLOCK_TIME -lt "600" ]; then
        sed -i "s/unlock_time =.*/unlock_time = 600/" $CONF_FILE
        echo "unlock_time option is set to 600" >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        echo "unlock_time option is set to 600 or greater" >> "/home/lab/kovennukset/security_check_pass.txt"
    fi
fi

------------------------------------------------------------------------------------

# Check if password reuse is limited
if grep -q "^password.*required.*pam_pwhistory.so.*remember=[5-9]$\|^[1-9][0-9]*$" /etc/pam.d/common-password; then
    echo "password reuse is limited" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    sed -i 's/remember=[5-9]$\|^[1-9][0-9]*/remember=10/' /etc/pam.d/common-password
    echo "password reuse is not limited, set remember option to more than 5" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

------------------------------------------------------------------------------------

# Check if password hashing algorithm is up to date with the latest standards
hash_algorithm=$(grep -E '^password.*sufficient.*pam_unix.so.*' /etc/pam.d/common-password | awk '{print $4}' | cut -d = -f 2)
if [[ $hash_algorithm == "sha512" || $hash_algorithm == "bcrypt" || $hash_algorithm == "argon2" ]]; then
    echo "password hashing algorithm is up to date with the latest standards" >> "/home/lab/kovennukset/security_check_pass.txt"
else
    echo "password hashing algorithm is not up to date with the latest standards" >> "/home/lab/kovennukset/security_check_fail.txt"
fi