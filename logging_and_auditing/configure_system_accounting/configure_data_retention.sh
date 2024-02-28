#!/bin/bash

# Ensure audit log storage size is configured
echo "Ensuring audit log storage size is configured"
# Define the desired maximum audit log size in megabytes
MAX_LOG_SIZE_MB=100

# Check the current setting for max_log_file
MAX_LOG_FILE=$(grep -Po -- '^\h*max_log_file\h*=\h*\d+\b' /etc/audit/auditd.conf)

# If max_log_file is not set, add it to the config file
if [ -z "$MAX_LOG_FILE" ]; then
  echo "max_log_file = $MAX_LOG_SIZE_MB" >> /etc/audit/auditd.conf
  echo "Audit log storage size is configured to 100MB" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  # Get the current max_log_file value
  CURRENT_SIZE=$(echo $MAX_LOG_FILE | grep -Po '\d+')
  # If the current max_log_file is less than the desired size, update it
  if [ "$CURRENT_SIZE" -lt "$MAX_LOG_SIZE_MB" ]; then
    sed -i "s/^max_log_file =.*/max_log_file = $MAX_LOG_SIZE_MB/" /etc/audit/auditd.conf
    NEW_MAX_LOG_FILE=$(grep -Po -- '^\h*max_log_file\h*=\h*\d+\b' /etc/audit/auditd.conf)
    NEW_CURRENT_SIZE=$(echo $NEW_MAX_LOG_FILE | grep -Po '\d+')
    if [ "$NEW_CURRENT_SIZE" -lt "$MAX_LOG_SIZE_MB" ]; then
      echo "Failed to configure audit log storage size, the default is 8MB" >> "/home/lab/kovennukset/security_check_fail.txt"
    else
      systemctl restart auditd
      echo "Audit log storage size is configured to 100MB" >> "/home/lab/kovennukset/security_check_fix.txt"
    fi
  else
    echo "Audit log storage size is configured to 100MB or more" >> "/home/lab/kovennukset/security_check_pass.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure audit logs are not automatically deleted
echo "Ensuring audit logs are not automatically deleted"
# Check if audit logs are automatically deleted
if grep -q "^max_log_file_action = keep_logs" /etc/audit/auditd.conf; then
  echo "Audit logs are not automatically deleted" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  # Disable automatic deletion of audit logs
  sudo sed -i 's/^max_log_file_action =.*/max_log_file_action = keep_logs/' /etc/audit/auditd.conf
  if grep -q "^max_log_file_action = keep_logs" /etc/audit/auditd.conf; then
    systemctl restart auditd
    echo "Automatic deletion of audit logs has been disabled" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to disable automatic deletion of audit logs" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure system is disabled when audit logs are full
echo "Ensuring system is rotating old logs when audit logs are full"
# Check if the system is set to be disabled when audit logs are full
if [ "$(grep "^space_left_action" /etc/audit/auditd.conf | awk '{print $3}')" = "SYSLOG" ] && [ "$(grep "^admin_space_left_action" /etc/audit/auditd.conf | awk '{print $3}')" = "rotate" ]; then
  echo "System is set to rotate old logs when audit logs are full" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  # Configure the system to be disabled when audit logs are full
  sudo sed -i 's/^space_left_action =.*/space_left_action = SYSLOG/' /etc/audit/auditd.conf
  sudo sed -i 's/^admin_space_left_action =.*/admin_space_left_action = rotate/' /etc/audit/auditd.conf
  if [ "$(grep "^space_left_action" /etc/audit/auditd.conf | awk '{print $3}')" = "SYSLOG" ] && [ "$(grep "^admin_space_left_action" /etc/audit/auditd.conf | awk '{print $3}')" = "rotate" ]; then
    sudo systemctl restart auditd
    echo "System has been configured to rotate old logs when audit logs are full" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to configure the system to rotate old logs when audit logs are full" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi