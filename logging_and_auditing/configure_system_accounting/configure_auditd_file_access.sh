# #!/bin/bash

# Ensure audit log files are mode 0640 or less permissive
echo "Ensuring audit log files are mode 0640 or less permissive"
# Check if /etc/audit/auditd.conf exists and get the log_file path
if [ -f /etc/audit/auditd.conf ]; then
  log_file=$(awk -F "=" '/^\s*log_file/ {print $2}' /etc/audit/auditd.conf | xargs)
  # Find all audit log files in the directory and ensure that they are mode 0640 or less permissive
  result=$(find "$(dirname "$log_file")" -type f \( ! -perm 600 -a ! -perm 0400 -a ! -perm 0200 -a ! -perm 0000 -a ! -perm 0640 -a ! -perm 0440 -a ! -perm 0040 \) -exec stat -Lc "%n %#a" {} +)
  if [ -z "$result" ]; then
    # Write pass result into pass.txt
    echo "Audit log files are mode 0640 or less permissive" >> "/home/lab/kovennukset/security_check_pass.txt"
  else
    # Fix file permissions
    find "$(dirname "$log_file")" -type f \( ! -perm 600 -a ! -perm 0400 -a ! -perm 0200 -a ! -perm 0000 -a ! -perm 0640 -a ! -perm 0440 -a ! -perm 0040 \) -exec chmod u-x,g-wx,o-rwx {} +
    echo "Audit log files are now mode 0640 or less permissive" >> "/home/lab/kovennukset/security_check_fix.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure only authorized users own audit log files
echo "Ensuring only authorized users own audit log files"
# Check if /etc/audit/auditd.conf exists and get the log_file path
if [ -f /etc/audit/auditd.conf ]; then
  log_file=$(awk -F "=" '/^\s*log_file/ {print $2}' /etc/audit/auditd.conf | xargs)
  # Find all audit log files in the directory and ensure that they are owned by root
  result=$(find "$(dirname "$log_file")" -type f ! -user root -exec stat -Lc "%n %U" {} +)
  if [ -z "$result" ]; then
    # Write pass result into pass.txt
    echo "Authorized users own audit log files" >> "/home/lab/kovennukset/security_check_pass.txt"
  else
    # Fix file ownership
    find "$(dirname "$log_file")" -type f ! -user root -exec chown root {} +
    echo "Authorized users now own audit log files" >> "/home/lab/kovennukset/security_check_fix.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure only authorized groups are assigned ownership of audit log files
echo "Ensuring only authorized groups are assigned ownership of audit log files"
# Check if /etc/audit/auditd.conf exists and get the log_file path and group
if [ -f /etc/audit/auditd.conf ]; then
  log_file=$(awk -F "=" '/^\s*log_file/ {print $2}' /etc/audit/auditd.conf | xargs)
  log_group=$(grep -Piw -- '^\h*log_group\h*=\h*(adm|root)\b' /etc/audit/auditd.conf | cut -d "=" -f2 | xargs)
  # Check if the audit log files are owned by the authorized group
  result=$(stat -c "%n %G" "$(dirname "$log_file")"/* | grep -Pv '^\h*\H+\h+('"$log_group"')\b')
  if [ -z "$result" ]; then
    # Write pass result into pass.txt
    echo "Only authorized groups are assigned ownership of audit log files" >> "/home/lab/kovennukset/security_check_pass.txt"
  else
    # Fix file ownership and configuration
    find "$(dirname "$log_file")" -type f \( ! -group adm -a ! -group root \) -exec chgrp adm {} +
    chgrp adm "$(dirname "$log_file")"
    sed -ri 's/^\s*#?\s*log_group\s*=\s*\S+(\s*#.*)?.*$/log_group = adm\1/' /etc/audit/auditd.conf
    systemctl restart auditd
    echo "Only authorized groups are now assigned ownership of audit log files" >> "/home/lab/kovennukset/security_check_fix.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure the audit log directory is 0750 or more restrictive
echo "Ensuring the audit log directory is 0750 or more restrictive"
# Check if /etc/audit/auditd.conf exists and get the log_file directory
if [ -f /etc/audit/auditd.conf ]; then
  log_dir=$(dirname "$(awk -F "=" '/^\s*log_file/ {print $2}' /etc/audit/auditd.conf)")
  # Check if the audit log directory is 0750 or more restrictive
  result=$(stat -Lc "%n %a" "$log_dir" | grep -Pv -- '^\h*\H+\h+([0,5,7][0,5]0)')
  if [ -z "$result" ]; then
    # Write pass result into pass.txt
    echo "The audit log directory is 0750 or more restrictive" >> "/home/lab/kovennukset/security_check_pass.txt"
  else
    # Fix file permissions
    chmod g-w,o-rwx "$log_dir"
    echo "The audit log directory is 0750 or more restrictive" >> "/home/lab/kovennukset/security_check_fix.txt"
  fi
fi


#------------------------------------------------------------------------------------

# Ensure audit configuration files are 640 or more restrictive
echo "Ensuring audit configuration files are 640 or more restrictive"
# Check if any audit configuration files exist in /etc/audit/
if [ -n "$(find /etc/audit/ -type f \( -name '*.conf' -o -name '*.rules' \))" ]; then
  # Check if the audit configuration files are 640 or more restrictive and owned by root
  result=$(find /etc/audit/ -type f \( -name '*.conf' -o -name '*.rules' \) -exec stat -Lc "%n %a %U:%G" {} + | grep -Pv -- '^\h*\H+\h*([0,2,4,6][0,4]0)\h*root:root$')
  if [ -z "$result" ]; then
    # Write pass result into pass.txt
    echo "Audit configuration files are 640 or more restrictive" >> "/home/lab/kovennukset/security_check_pass.txt"
  else
    # Fix file permissions
    find /etc/audit/ -type f \( -name '*.conf' -o -name '*.rules' \) -exec chmod u-x,g-wx,o-rwx {} +
    echo "Audit configuration files are 640 or more restrictive" >> "/home/lab/kovennukset/security_check_fix.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure audit configuration files are owned by root
echo "Ensuring audit configuration files are owned by root"
# Check if any audit configuration files exist in /etc/audit/
if [ -n "$(find /etc/audit/ -type f \( -name '*.conf' -o -name '*.rules' \))" ]; then
  # Check if the audit configuration files are owned by root
  result=$(find /etc/audit/ -type f \( -name '*.conf' -o -name '*.rules' \) ! -user root)
  if [ -z "$result" ]; then
    # Write pass result into pass.txt
    echo "Audit configuration files are owned by root" >> "/home/lab/kovennukset/security_check_pass.txt"
  else
    # Fix file ownership
    find /etc/audit/ -type f \( -name '*.conf' -o -name '*.rules' \) ! -user root -exec chown root {} +
    echo "Audit configuration files are now owned by root" >> "/home/lab/kovennukset/security_check_fix.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure audit configuration files belong to group root
echo "Ensuring audit configuration files belong to group root"
# Check if any audit configuration files exist in /etc/audit/
if [ -n "$(find /etc/audit/ -type f \( -name '*.conf' -o -name '*.rules' \))" ]; then
  # Check if the audit configuration files belong to group root
  result=$(find /etc/audit/ -type f \( -name '*.conf' -o -name '*.rules' \) ! -group root)
  if [ -z "$result" ]; then
    # Write pass result into pass.txt
    echo "Audit configuration files belong to group root" >> "/home/lab/kovennukset/security_check_pass.txt"
  else
    # Fix file group
    find /etc/audit/ -type f \( -name '*.conf' -o -name '*.rules' \) ! -group root -exec chgrp root {} +
    echo "Audit configuration files now belong to group root" >> "/home/lab/kovennukset/security_check_fix.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure audit tools are 755 or more restrictive
echo "Ensuring audit tools are 755 or more restrictive"
# Check if any audit tools exist in /sbin/
if [ -n "$(find /sbin/ -type f \( -name 'auditctl' -o -name 'aureport' -o -name 'ausearch' -o -name 'autrace' -o -name 'auditd' -o -name 'augenrules' \))" ]; then
  # Check if the audit tools are 755 or more restrictive and owned by root
  result=$(stat -c "%n %a %U:%G" /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/augenrules | grep -Pv -- '^\h*\H+\h+([0-7][0,1,4,5][0,1,4,5])\h*root:root$')
  if [ -z "$result" ]; then
    # Write pass result into pass.txt
    echo "Audit toold are 755 or more restrictive" >> "/home/lab/kovennukset/security_check_pass.txt"
  else
    # Fix file permissions
    chmod go-w /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/augenrules
    echo "Audit toold are now 755 or more restrictive" >> "/home/lab/kovennukset/security_check_fix.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure audit tools are owned by root
echo "Ensuring audit tools are owned by root"
# Check if any audit tools exist in /sbin/
if [ -n "$(find /sbin/ -type f \( -name 'auditctl' -o -name 'aureport' -o -name 'ausearch' -o -name 'autrace' -o -name 'auditd' -o -name 'augenrules' \))" ]; then
  # Check if the audit tools are owned by root
  result=$(stat -c "%n %U:%G" /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/augenrules | grep -Pv -- '^\h*\H+\h*root:root$')
  if [ -z "$result" ]; then
    # Write pass result into pass.txt
    echo "Audit tools are owned by root" >> "/home/lab/kovennukset/security_check_pass.txt"
  else
    # Fix file ownership
    chown root /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/augenrules
    echo "Audit tools are now owned by root" >> "/home/lab/kovennukset/security_check_fix.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure audit tools belong to group root
echo "Ensuring audit tools belong to group root"
# Check if any audit tools exist in /sbin/
if [ -n "$(find /sbin/ -type f \( -name 'auditctl' -o -name 'aureport' -o -name 'ausearch' -o -name 'autrace' -o -name 'auditd' -o -name 'augenrules' \))" ]; then
  # Check if the audit tools belong to the root group
  result=$(stat -c "%n %a %U %G" /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/augenrules | grep -Pv -- '^\h*\H+\h+([0-7][0,1,4,5][0,1,4,5])\h+root\h+root\h*$')
  if [ -z "$result" ]; then
    # Write pass result into pass.txt
    echo "Audit tools belong to group root" >> "/home/lab/kovennukset/security_check_pass.txt"
  else
    # Fix file ownership and group
    chown root:root /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/augenrules
    echo "Audit tools now belong to group root" >> "/home/lab/kovennukset/security_check_fix.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure cryptographic mechanisms are used to protect the integrity of audit tools
if grep -Ps -- '(\/sbin\/(audit|au)\H*\b)' /etc/aide/aide.conf.d/*.conf /etc/aide/aide.conf | grep -q -v 'p\+i\+n\+u\+g\+s\+b\+acl\+xattrs\+sha512'; then
    # If the test fails, add or update the selection lines for audit tools in the AIDE configuration
    echo "Audit tools are not properly configured in AIDE. Updating configuration..."
    echo "/sbin/auditctl p+i+n+u+g+s+b+acl+xattrs+sha512" >> /etc/aide/aide.conf.d/aide_custom.conf
    echo "/sbin/auditd p+i+n+u+g+s+b+acl+xattrs+sha512" >> /etc/aide/aide.conf.d/aide_custom.conf
    echo "/sbin/ausearch p+i+n+u+g+s+b+acl+xattrs+sha512" >> /etc/aide/aide.conf.d/aide_custom.conf
    echo "/sbin/aureport p+i+n+u+g+s+b+acl+xattrs+sha512" >> /etc/aide/aide.conf.d/aide_custom.conf
    echo "/sbin/autrace p+i+n+u+g+s+b+acl+xattrs+sha512" >> /etc/aide/aide.conf.d/aide_custom.conf
    echo "/sbin/augenrules p+i+n+u+g+s+b+acl+xattrs+sha512" >> /etc/aide/aide.conf.d/aide_custom.conf
    echo "Audit tools configuration updated successfully." >> "/home/lab/kovennukset/security_check_fix.txt"
else
    # If the test passes, display a message indicating that the configuration is correct
    echo "Audit tools are properly configured in AIDE." >> "/home/lab/kovennukset/security_check_pass.txt"
fi
