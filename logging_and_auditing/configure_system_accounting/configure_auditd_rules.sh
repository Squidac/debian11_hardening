#!/bin/bash

# Ensure changes to system administration scope (sudoers) is collected
echo "Ensuring changes to system administration scope (sudoers) is collected"
# Check if changes to system administration scope (sudoers) are collected
if grep -qe "-k scope" -e "key=scope" /etc/audit/rules.d/*.rules; then
  echo "Changes to system administration scope (sudoers) are collected" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  # Configure collection of changes to system administration scope (sudoers)
  echo -e "\n#Configuring auditd to collect changes to system administration scope" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-w /etc/sudoers -p wa -k scope" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-w /etc/sudoers.d/ -p wa -k scope" | sudo tee -a /etc/audit/rules.d/audit.rules
  if grep -qe "-k scope" -e "key=scope" /etc/audit/rules.d/*.rules; then
    sudo systemctl restart auditd
    echo "Collection of changes to system administration scope (sudoers) has been configured" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to configure collection of changes to system administration scope (sudoers)" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure actions as another user are always logged
echo "Ensuring actions as another user are always logged"
# Check if actions as another user are always logged
if grep -qe "-k user_emulation" -e "key=user_emulation" /etc/audit/rules.d/*.rules; then
  echo "Changes to system administration scope (sudoers) are collected" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  # Configure logging of actions as another user
  echo -e "\n#Configuring auditd to collect another user actions" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-a always,exit -F arch=b64 -C euid!=uid -F auid!=unset -S execve -k user_emulation" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-a always,exit -F arch=b32 -C euid!=uid -F auid!=unset -S execve -k user_emulation" | sudo tee -a /etc/audit/rules.d/audit.rules
  if grep -qe "-k user_emulation" -e "key=user_emulation" /etc/audit/rules.d/*.rules; then
    sudo systemctl restart auditd
    echo "Logging of actions as another user has been configured" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to configure logging of actions as another user" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure events that modify the sudo log file are collected
echo "Ensuring events that modify the sudo log file are collected"
# Check if events that modify the sudo log file are collected
if grep -qe "-k sudo_log_file" -e "key=sudo_log_file" /etc/audit/rules.d/*.rules; then
  echo "Events that modify the sudo log file are collected" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  # Configure collection of events that modify the sudo log file
  echo -e "\n#Configuring auditd to collect sudo log file modification events" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-w /var/log/sudo.log -p wa -k sudo_log_file" | sudo tee -a /etc/audit/rules.d/audit.rules
  if grep -qe "-k sudo_log_file" -e "key=sudo_log_file" /etc/audit/rules.d/*.rules; then
    sudo systemctl restart auditd
    echo "Collection of events that modify the sudo log file has been configured" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to configure collection of events that modify the sudo log file" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure events that modify date and time information are collected
echo "Ensuring events that modify date and time information are collected"
# Check if events that modify date and time information are collected
if grep -qe "-k time-change" -e "key=time-change" /etc/audit/rules.d/*.rules; then
  echo "Events that modify date and time information are collected" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  # Configure collection of events that modify date and time information
  echo -e "\n#Configuring auditd to collect date and time modification events" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-a always,exit -F arch=b64 -S adjtimex,settimeofday,clock_settime -k time-change" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-a always,exit -F arch=b32 -S adjtimex,settimeofday,clock_settime -k time-change" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-w /etc/localtime -p wa -k time-change" | sudo tee -a /etc/audit/rules.d/audit.rules
  if grep -qe "-k time-change" -e "key=time-change" /etc/audit/rules.d/*.rules; then
    sudo systemctl restart auditd
    echo "Collection of events that modify date and time information has been configured" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to configure collection of events that modify date and time information" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure events that modify the system's network environment are collected
echo "Ensuring events that modify the system's network environment are collected"
# Check if events that modify the system's network environment are collected
if grep -qe "-k system-locale" -e "key=system-locale" /etc/audit/rules.d/*.rules; then
  echo "Events that modify the system's network environment are collected" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  # Configure collection of events that modify the system's network environment
  echo -e "\n#Configuring auditd to collect network environment modification events" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-a always,exit -F arch=b64 -S sethostname,setdomainname -k system-locale" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-a always,exit -F arch=b32 -S sethostname,setdomainname -k system-locale" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-w /etc/issue -p wa -k system-locale" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-w /etc/issue.net -p wa -k system-locale" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-w /etc/hosts -p wa -k system-locale" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-w /etc/networks -p wa -k system-locale" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-w /etc/network/ -p wa -k system-locale" | sudo tee -a /etc/audit/rules.d/audit.rules
  if grep -qe "-k system-locale" -e "key=system-locale" /etc/audit/rules.d/*.rules; then
    sudo systemctl restart auditd
    echo "Collection of events that modify the system's network environment has been configured" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to configure collection of events that modify the system's network environment" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi

#------------------------------------------------------------------------------------
{
  # Ensure use of privileged commands are collected
  echo "Ensuring use of privileged commands are collected"

  UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)
  AUDIT_RULE_FILE="/etc/audit/rules.d/50-privileged.rules"
  NEW_DATA=()

  for PARTITION in $(findmnt -n -l -k -it $(awk '/nodev/ { print $2 }' /proc/filesystems | paste -sd,) | grep -Pv "noexec|nosuid" | awk '{print $1}'); do
    readarray -t DATA < <(find "${PARTITION}" -xdev -perm /6000 -type f | awk -v UID_MIN=${UID_MIN} '{print "-a always,exit -F path=" $1 " -F perm=x -F auid>="UID_MIN" -F auid!=unset -k privileged" }')
    
    for ENTRY in "${DATA[@]}"; do
      NEW_DATA+=("${ENTRY}")
    done
  done

  readarray &> /dev/null -t OLD_DATA < "${AUDIT_RULE_FILE}"
  COMBINED_DATA=( "${OLD_DATA[@]}" "${NEW_DATA[@]}" )

  if [ "${#NEW_DATA[@]}" -gt 0 ]; then
    printf '%s\n' "${COMBINED_DATA[@]}" | sort -u > "${AUDIT_RULE_FILE}"
    echo "Use of privileged commands are collected" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Use of privileged commands is not being collected" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
}
#------------------------------------------------------------------------------------
{
  # Ensure unsuccessful file access attempts are collected
  echo "Ensuring unsuccessful file access attempts are collected"
  # Check if the relevant rules to monitor unsuccessful file access attempts already exist
  if grep -qe "-k access" /etc/audit/rules.d/*.rules; then
    echo "Unsuccessful file access attempts are collected" >> "/home/lab/kovennukset/security_check_pass.txt"
  else
    # Get the minimum user ID from the /etc/login.defs file
    UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)

    # Append the relevant rules to a file in the /etc/audit/rules.d/ directory
    if [ -n "${UID_MIN}" ]; then
      echo -e "\n#Configuring auditd to collect unsuccessful file access attempts" >> /etc/audit/rules.d/50-access.rules
      echo "-a always,exit -F arch=b64 -S creat,open,openat,truncate,ftruncate -F exit=-EACCES -F auid>=${UID_MIN} -F auid!=unset -k access" >> /etc/audit/rules.d/50-access.rules
      echo "-a always,exit -F arch=b64 -S creat,open,openat,truncate,ftruncate -F exit=-EPERM -F auid>=${UID_MIN} -F auid!=unset -k access" >> /etc/audit/rules.d/50-access.rules
      echo "-a always,exit -F arch=b32 -S creat,open,openat,truncate,ftruncate -F exit=-EACCES -F auid>=${UID_MIN} -F auid!=unset -k access" >> /etc/audit/rules.d/50-access.rules
      echo "-a always,exit -F arch=b32 -S creat,open,openat,truncate,ftruncate -F exit=-EPERM -F auid>=${UID_MIN} -F auid!=unset -k access" >> /etc/audit/rules.d/50-access.rules
      if grep -qe "-k access" /etc/audit/rules.d/*.rules; then
        echo "Unsuccessful file access attempts are collected" >> "/home/lab/kovennukset/security_check_fix.txt"
      else
        echo "Unsuccessful file access attempts are not collected" >> "/home/lab/kovennukset/security_check_fail.txt"
      fi
    else
      echo "ERROR: Variable 'UID_MIN' is unset." >> "/home/lab/kovennukset/security_check_fail.txt"
    fi
  fi
}
#------------------------------------------------------------------------------------

# Ensure events that modify user/group information are collected
echo "Ensuring events that modify user/group information are collected"
# Check if events that modify user/group information are collected
if grep -qe "-k identity" -e "key=identity" /etc/audit/rules.d/*.rules; then
  echo "Events that modify user/group information are collected" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  # Configure collection of events that modify user/group information
  echo -e "\n#Configuring auditd to collect events that modify user/group information" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-w /etc/group -p wa -k identity" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-w /etc/passwd -p wa -k identity" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-w /etc/gshadow -p wa -k identity" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-w /etc/shadow -p wa -k identity" | sudo tee -a /etc/audit/rules.d/audit.rules
  echo "-w /etc/security/opasswd -p wa -k identity" | sudo tee -a /etc/audit/rules.d/audit.rules
  if grep -qe "-k identity" -e "key=identity" /etc/audit/rules.d/*.rules; then
    sudo systemctl restart auditd
    echo "Events that modify user/group information are collected" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Events that modify user/group information are not collected" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure discretionary access control permission modification events are collected
echo "Ensuring discretionary access control permission modification events are collected"
# Check if discretionary access control permission modification events are collected
if grep -qe "-k perm_mod" -e "key=perm_mod" /etc/audit/rules.d/*.rules; then
  echo "Discretionary access control permission modification events are collected" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  # Configure collection of discretionary access control permission modification events
  echo -e "\n#Configuring auditd to collect discretionary access control permission modification events" | sudo tee -a /etc/audit/rules.d/50-perm_mod.rules
  echo "-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=-1 -F key=perm_mod" | sudo tee -a /etc/audit/rules.d/50-perm_mod.rules
  echo "-a always,exit -F arch=b64 -S chown,fchown,lchown,fchownat -F auid>=1000 -F auid!=-1 -F key=perm_mod" | sudo tee -a /etc/audit/rules.d/50-perm_mod.rules
  echo "-a always,exit -F arch=b32 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=-1 -F key=perm_mod" | sudo tee -a /etc/audit/rules.d/50-perm_mod.rules
  echo "-a always,exit -F arch=b32 -S lchown,fchown,chown,fchownat -F auid>=1000 -F auid!=-1 -F key=perm_mod" | sudo tee -a /etc/audit/rules.d/50-perm_mod.rules
  echo "-a always,exit -F arch=b64 -S setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr -F auid>=1000 -F auid!=-1 -F key=perm_mod" | sudo tee -a /etc/audit/rules.d/50-perm_mod.rules
  echo "-a always,exit -F arch=b32 -S setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr -F auid>=1000 -F auid!=-1 -F key=perm_mod" | sudo tee -a /etc/audit/rules.d/50-perm_mod.rules
  if grep -qe "-k perm_mod" -e "key=perm_mod" /etc/audit/rules.d/*.rules; then
    sudo systemctl restart auditd
    echo "Discretionary access control permission modification events are collected" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Discretionary access control permission modification events are not collected" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure successful file system mounts are collected
echo "Ensuring successful file system mounts are collected"
# Check if successful file system mounts are collected
if grep -qe "-k mounts" -e "key=mounts" /etc/audit/rules.d/*.rules; then
  echo "Successful file system mounts are collected" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  echo "Successful file system mounts are not collected"
  # Configure collection of successful file system mounts
  echo "-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=unset -k mounts" | sudo tee -a /etc/audit/rules.d/50-mounts.rules
  echo "-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=unset -k mounts" | sudo tee -a /etc/audit/rules.d/50-mounts.rules
  if grep -qe "-k mounts" -e "key=mounts" /etc/audit/rules.d/*.rules; then
    sudo systemctl restart auditd
    echo "Collection of successful file system mounts has been configured" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to configure collection of successful file system mounts" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure session initiation information is collected
echo "Ensuring session initiation information is collected"
# Check if session initiation information is collected
if grep -qe "-k session" -e "key=session" /etc/audit/rules.d/*.rules; then
  echo "Session initiation information is collected" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  echo "Session initiation information is not collected"
  # Configure collection of session initiation information
  echo "-w /var/run/utmp -p wa -k session" | sudo tee -a /etc/audit/rules.d/50-session.rules
  echo "-w /var/log/wtmp -p wa -k session" | sudo tee -a /etc/audit/rules.d/50-session.rules
  echo "-w /var/log/btmp -p wa -k session" | sudo tee -a /etc/audit/rules.d/50-session.rules
  if grep -qe "-k session" -e "key=session" /etc/audit/rules.d/*.rules; then
    sudo systemctl restart auditd
    echo "Collection of session initiation information has been configured" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to configure collection of session initiation information" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure login and logout events are collected
echo "Ensuring login and logout events are collected"
# Check if login and logout events are collected
if grep -qe "-k logins" -e "key=logins" /etc/audit/rules.d/*.rules; then
  echo "Login and logout events are collected" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  # Configure collection of login and logout events
  echo "-w /var/log/faillog -p wa -k logins" | sudo tee -a /etc/audit/rules.d/50-login.rules
  echo "-w /var/log/lastlog -p wa -k logins" | sudo tee -a /etc/audit/rules.d/50-login.rules
  if grep -qe "-k logins" -e "key=logins" /etc/audit/rules.d/*.rules; then
    sudo systemctl restart auditd
    echo "Collection of login and logout events has been configured" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to configure collection of login and logout events" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure file deletion events by users are collected
echo "Ensuring file deletion events by users are collected"
# Check if file deletion events by users are collected
if grep -qe "-k delete" -e "key=delete" /etc/audit/rules.d/*.rules; then
  echo "File deletion events by users are collected" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  # Configure collection of file deletion events by users
  echo "-a always,unlink -F arch=b64 -S unlink -F auid>=1000 -F auid!=unset -k delete" | sudo tee -a /etc/audit/rules.d/50-delete.rules
  echo "-a always,unlink -F arch=b32 -S unlink -F auid>=1000 -F auid!=unset -k delete" | sudo tee -a /etc/audit/rules.d/50-delete.rules
  if grep -qe "-k delete" -e "key=delete" /etc/audit/rules.d/*.rules; then
    sudo systemctl restart auditd
    echo "Collection of file deletion events by users has been configured" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to configure collection of file deletion events by users" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi

#------------------------------------------------------------------------------------

# # Ensure events that modify the system's Mandatory Access Controls are collected

#------------------------------------------------------------------------------------

# Ensure successful and unsuccessful attempts to use the chcon command are recorded
echo "Ensuring successful and unsuccessful attempts to use the chcon command are recorded"
# Check if successful and unsuccessful attempts to use the chcon command are recorded
if grep -qe "-k perm_chng" -e "key=perm_chng" /etc/audit/rules.d/*.rules; then
  echo "Successful and unsuccessful attempts to use the chcon command are recorded" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  echo "Successful and unsuccessful attempts to use the chcon command are not recorded"
  # Configure recording of successful and unsuccessful attempts to use the chcon command
  echo "-a always,exit -F path=/usr/bin/chcon -F perm=x -F auid>=1000 -F auid!=unset -k perm_chng" | sudo tee -a /etc/audit/rules.d/50-perm_chng.rules
  if grep -qe "-k perm_chng" -e "key=perm_chng" /etc/audit/rules.d/*.rules; then
    sudo systemctl restart auditd
    echo "Recording of successful and unsuccessful attempts to use the chcon command has been configured" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to configure recording of successful and unsuccessful attempts to use the chcon command" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure successful and unsuccessful attempts to use the setfacl command are recorded
echo "Ensuring successful and unsuccessful attempts to use the setfacl command are recorded"
# Check if successful and unsuccessful attempts to use the setfacl command are recorded
if grep -qe "-k perm_chng" -e "key=perm_chng" /etc/audit/rules.d/*.rules; then
  echo "Successful and unsuccessful attempts to use the setfacl command are recorded" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  echo "Successful and unsuccessful attempts to use the setfacl command are not recorded"
  # Configure recording of successful and unsuccessful attempts to use the setfacl command
  echo "-a always,exit -F path=/usr/bin/setfacl -F perm=x -F auid>=1000 -F auid!=unset -k perm_chng" | sudo tee -a /etc/audit/rules.d/50-perm_chng.rules
  if grep -qe "-k perm_chng" -e "key=perm_chng" /etc/audit/rules.d/*.rules; then
    sudo systemctl restart auditd
    echo "Recording of successful and unsuccessful attempts to use the setfacl command has been configured" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to configure recording of successful and unsuccessful attempts to use the setfacl command" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure successful and unsuccessful attempts to use the chacl command are recorded
echo "Ensuring successful and unsuccessful attempts to use the chacl command are recorded"
# Check if successful and unsuccessful attempts to use the chacl command are recorded
if grep -qe "-k priv_cmd" -e "key=priv_cmd" /etc/audit/rules.d/*.rules; then
  echo "Successful and unsuccessful attempts to use the chacl command are recorded" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  # Configure recording of successful and unsuccessful attempts to use the chacl command
  echo "-a always,exit -F path=/usr/bin/chacl -F perm=x -F auid>=1000 -F auid!=unset -k priv_cmd" | sudo tee -a /etc/audit/rules.d/50-priv_cmd.rules
  if grep -qe "-k priv_cmd" -e "key=priv_cmd" /etc/audit/rules.d/*.rules; then
    sudo systemctl restart auditd
    echo "Recording of successful and unsuccessful attempts to use the chacl command has been configured" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to configure recording of successful and unsuccessful attempts to use the chacl command" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure successful and unsuccessful attempts to use the usermod command are recorded
echo "Ensuring successful and unsuccessful attempts to use the usermod command are recorded"
# Check if successful and unsuccessful attempts to use the usermod command are recorded
if grep -qe "-k usermod" -e "key=usermod" /etc/audit/rules.d/*.rules; then
  echo "Successful and unsuccessful attempts to use the usermod command are recorded" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  # Configure recording of successful and unsuccessful attempts to use the usermod command
  echo "-a always,exit -F path=/usr/sbin/usermod -F perm=x -F auid>=1000 -F auid!=unset -k usermod" | sudo tee -a /etc/audit/rules.d/50-usermod.rules
  if grep -qe "-k usermod" -e "key=usermod" /etc/audit/rules.d/*.rules; then
    sudo systemctl restart auditd
    echo "Recording of successful and unsuccessful attempts to use the usermod command has been configured" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to configure recording of successful and unsuccessful attempts to use the usermod command" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure kernel module loading unloading and modification is collected
echo "Ensuring kernel module loading unloading and modification is collected"
# Check if kernel module loading, unloading, and modification are collected
if grep -qe "-k kernel_modules" -e "key=kernel_modules" /etc/audit/rules.d/*.rules; then
  echo "Kernel module loading, unloading, and modification are collected" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  # Configure kernel module loading, unloading, and modification collection
  echo "-a always,exit -F arch=b64 -S create_module,init_module,delete_module,query_module,finit_module -F auid>=1000 -F auid!=-1 -F key=kernel_modules" | sudo tee -a /etc/audit/rules.d/50-kernel_modules.rules
  echo "-a always,exit -S all -F path=/usr/bin/kmod -F perm=x -F auid>=1000 -F auid!=-1 -F key=kernel_modules" | sudo tee -a /etc/audit/rules.d/50-kernel_modules.rules
  if grep -qe "-k kernel_modules" -e "key=kernel_modules" /etc/audit/rules.d/*.rules; then
    sudo systemctl restart auditd
    echo "Kernel module loading, unloading, and modification collection has been configured" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to configure kernel module loading, unloading, and modification collection" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi

#------------------------------------------------------------------------------------

# Ensure the audit configuration is immutable
echo "Ensuring the audit configuration is immutable"
if grep -qe "-e 2" /etc/audit/rules.d/*.rules; then
  echo "The audit configuration is immutable" >> "/home/lab/kovennukset/security_check_pass.txt"
else
  # Set the audit configuration to be immutable
  echo "-e 2" | sudo tee -a /etc/audit/rules.d/99-finalize.rules
  if grep -qe "-e 2" /etc/audit/rules.d/*.rules; then
    sudo systemctl restart auditd
    echo "The audit configuration has been set to be immutable" >> "/home/lab/kovennukset/security_check_fix.txt"
  else
    echo "Failed to set the audit configuration to be immutable" >> "/home/lab/kovennukset/security_check_fail.txt"
  fi
fi
augenrules --load