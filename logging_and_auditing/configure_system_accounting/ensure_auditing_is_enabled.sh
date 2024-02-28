#!/bin/bash

# Ensure auditd is installed
echo "Ensuring auditd is installed"
# Check if auditd is installed
if dpkg-query -W -f='${Status}' auditd 2>/dev/null | grep -q "^install ok installed$"; then
  echo "auditd is installed" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  echo "auditd is not installed" >> "/home/lab/kovennukset/security_check_fail.txt"
fi

#------------------------------------------------------------------------------------

# Ensure auditd service is enabled and active
echo "Ensuring auditd service is enabled and active"
# Check if auditd service is enabled and active
if systemctl is-enabled --quiet auditd && systemctl is-active --quiet auditd; then
  echo "auditd service is enabled and active" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  # Enable and start auditd service
  sudo systemctl enable auditd
  sudo systemctl start auditd
  if systemctl is-enabled --quiet auditd && systemctl is-active --quiet auditd; then
    echo "auditd service has been enabled and started" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to enable and start auditd service" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure auditing for processes that start prior to auditd is enabled 1/2
echo "Ensuring auditing for processes that start prior to auditd is enabled 1/2"
if grep -q "^GRUB_CMDLINE_LINUX=.*" /etc/default/grub; then
  if grep -q "^GRUB_CMDLINE_LINUX=.*\"audit=1\".*" /etc/default/grub; then
    echo "Auditing for processes that start prior to auditd is enabled 1/2" >> "/home/lab/kovennukset/security_check_pass.txt"
  else
    if sudo grep -q "^GRUB_CMDLINE_LINUX=""" /etc/default/grub; then
      sudo sed -E 's/(^GRUB_CMDLINE_LINUX=.*)(".*$)/\1audit=1\2/' -i /etc/default/grub
    else
      if sudo grep -q "^GRUB_CMDLINE_LINUX=.*$" /etc/default/grub; then
        sudo sed -E 's/(^GRUB_CMDLINE_LINUX=.*)(".*$)/\1 audit=1\2/' -i /etc/default/grub
      else
        sudo sh -c 'echo "GRUB_CMDLINE_LINUX=\"audit=1\"" >> /etc/default/grub'
      fi
    fi
    if grep -q "^GRUB_CMDLINE_LINUX=.*\"audit=1\".*" /etc/default/grub; then
      echo "Auditing for processes that start prior to auditd is enabled 1/2" >> "/home/lab/kovennukset/security_check_fix.txt"
    else
      echo "Failed to enable auditing for processes that start prior to auditd 1/2" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
    sudo update-grub
  fi
else
  echo -e "\n#Adding new line for GRUB_CMDLINE_LINUX" >> /etc/default/grub
  echo "GRUB_CMDLINE_LINUX=\"audit=1\"" >> /etc/default/grub
  if grep -q "^GRUB_CMDLINE_LINUX=\"audit=1\"" /etc/default/grub; then
    echo "Auditing for processes that start prior to auditd is enabled 1/2" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to enable auditing for processes that start prior to auditd 1/2" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
  sudo update-grub
fi

# Ensure auditing for processes that start prior to auditd is enabled 2/2
echo "Ensuring auditing for processes that start prior to auditd is enabled 2/2"
if grep -q "^GRUB_RECORDFAIL_TIMEOUT=.*" /etc/default/grub; then
  if grep -q "^GRUB_RECORDFAIL_TIMEOUT=\"auditfail=1\"" /etc/default/grub; then
    echo "Auditing for processes that start prior to auditd is enabled 2/2" >> "/home/lab/kovennukset/security_check_pass.txt"
  else
    if sudo grep -q "^GRUB_RECORDFAIL_TIMEOUT=.*$" /etc/default/grub; then
      sudo sed -E 's/(^GRUB_RECORDFAIL_TIMEOUT=.*)(".*$)/\1 auditfail=1\2/' -i /etc/default/grub
    else
      sudo sh -c 'echo "GRUB_RECORDFAIL_TIMEOUT=\"auditfail=1\"" >> /etc/default/grub'
    fi
    if grep -q "^GRUB_RECORDFAIL_TIMEOUT=.*auditfail=1" /etc/default/grub; then
      echo "Auditing for processes that start prior to auditd is enabled 2/2" >> "/home/lab/kovennukset/security_check_fix.txt"
    else
      echo "Failed to enable auditing for processes that start prior to auditd 2/2" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
    sudo update-grub
  fi
else
  echo -e "\n#Adding new line for GRUB_RECORDFAIL_TIMEOUT" >> /etc/default/grub
  echo "GRUB_RECORDFAIL_TIMEOUT=\"auditfail=1\"" >> /etc/default/grub
  if grep -q "^GRUB_RECORDFAIL_TIMEOUT=.*auditfail=1" /etc/default/grub; then
    echo "Auditing for processes that start prior to auditd is enabled 2/2" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to enable auditing for processes that start prior to auditd 2/2" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
  sudo update-grub
fi

#------------------------------------------------------------------------------------

# Ensure audit_backlog_limit is sufficient
echo "Ensuring audit_backlog_limit is sufficient"
if grep -q "^GRUB_CMDLINE_LINUX=.*" /etc/default/grub; then
  if grep -q "^GRUB_CMDLINE_LINUX=.*\"audit_backlog_limit=8192\".*" /etc/default/grub; then
    echo "Audit_backlog_limit is sufficient" >> "/home/lab/kovennukset/security_check_pass.txt"
  else
    # Enable auditing for processes that start prior to auditd
    if sudo grep -q "^GRUB_CMDLINE_LINUX=.*$" /etc/default/grub; then
      sudo sed -E 's/(^GRUB_CMDLINE_LINUX=.*)(".*$)/\1 audit_backlog_limit=8192\2/' -i /etc/default/grub
    else
      sudo sh -c 'echo "GRUB_CMDLINE_LINUX=\"audit_backlog_limit=8192\"" >> /etc/default/grub'
    fi
    if grep -q "^GRUB_CMDLINE_LINUX=\".*audit_backlog_limit=8192.*\"" /etc/default/grub; then
      echo "Audit_backlog_limit is sufficient" >> "/home/lab/kovennukset/security_check_fix.txt"
    else
      echo "Audit_backlog_limit is not sufficient" >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
    sudo update-grub
  fi
else
  echo -e "\n#Adding new line for GRUB_CMDLINE_LINUX" >> /etc/default/grub
  echo "GRUB_CMDLINE_LINUX=\"audit_backlog_limit=8192\"" >> /etc/default/grub
  if grep -q "^GRUB_CMDLINE_LINUX=\"audit_backlog_limit=8192\"" /etc/default/grub; then
    echo "Audit_backlog_limit is sufficient" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Audit_backlog_limit is not sufficient" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
  sudo update-grub
fi