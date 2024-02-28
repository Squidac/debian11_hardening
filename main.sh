#!/bin/bash

# Create a directory for the output files
mkdir /home/lab/kovennukset

# Initialize the pass and fail output files
touch "/home/lab/kovennukset/security_check_pass.txt"
touch "/home/lab/kovennukset/security_check_fail.txt"
touch "/home/lab/kovennukset/security_check_fix.txt"

passFile="/home/lab/kovennukset/security_check_pass.txt"
failFile="/home/lab/kovennukset/security_check_fail.txt"
fixFile="/home/lab/kovennukset/security_check_fix.txt"
lyellow='\e[33m'
yellow='\e[93m'
reset='\e[0m'

pathInitial="/home/lab/Scripts/initial_setup"
pathServices="/home/lab/Scripts/services"
pathNetwork="/home/lab/Scripts/network_configuration"
pathLogging="/home/lab/Scripts/logging_and_auditing"
pathAccess="/home/lab/Scripts/access_authentication_and_authorization"
pathSystem="/home/lab/Scripts/system_maintenance"

echo -e "${yellow}\n-----------------------------------------------------------------------------\n############################### Initial Setup ###############################\n${reset}" | tee -a $passFile $failFile $fixFile
echo -e "${lyellow}\n--------------------------------------------------\n#### Filesystem Configuration\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathInitial/filesystem_configuration/disable_unused_filesystems.sh
bash $pathInitial/filesystem_configuration/configure_tmp.sh
bash $pathInitial/filesystem_configuration/configure_var.sh
bash $pathInitial/filesystem_configuration/configure_var_tmp.sh
bash $pathInitial/filesystem_configuration/configure_var_log.sh
bash $pathInitial/filesystem_configuration/configure_var_log_audit.sh
bash $pathInitial/filesystem_configuration/configure_home.sh
bash $pathInitial/filesystem_configuration/configure_dev_shm.sh
echo -e "${lyellow}\n--------------------------------------------------\n#### Configure Software Updates\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathInitial/configure_software_updates/configure_software_updates.sh
echo -e "${lyellow}\n--------------------------------------------------\n#### Filesystem Integrity Checking\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathInitial/filesystem_integrity_checking/filesystem_integrity_checking.sh
echo -e "${lyellow}\n--------------------------------------------------\n#### Secure Boot Settings\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathInitial/secure_boot_settings/secure_boot_settings.sh
echo -e "${lyellow}\n--------------------------------------------------\n#### Additional Process Hardening\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathInitial/additional_process_hardening/additional_process_hardening.sh
echo -e "${lyellow}\n--------------------------------------------------\n#### Mandatory Access Control\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathInitial/mandatory_access_control/configure_apparmor.sh
echo -e "${lyellow}\n--------------------------------------------------\n#### Command Line Warning Banners\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathInitial/command_line_warning_banners/command_line_warning_banners.sh
echo -e "${lyellow}\n--------------------------------------------------\n#### Gnome Display Manager\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathInitial/gnome_display_manager/gnome_display_manager.sh
echo -e "${yellow}\n-----------------------------------------------------------------------------\n################################# Services ##################################\n${reset}" | tee -a $passFile $failFile $fixFile
echo -e "${lyellow}\n--------------------------------------------------\n#### Configure Time Synchronization\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathServices/configure_time_synchronization/ensure_time_synchronization_is_in_use.sh
bash $pathServices/configure_time_synchronization/configure_chrony.sh
bash $pathServices/configure_time_synchronization/configure_systemd_timesyncd.sh
bash $pathServices/configure_time_synchronization/configure_ntp.sh
echo -e "${lyellow}\n--------------------------------------------------\n#### Special Purpose Services\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathServices/special_purpose_services/special_purpose_services.sh
echo -e "${lyellow}\n--------------------------------------------------\n#### Service Clients\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathServices/service_clients/service_clients.sh
echo -e "${yellow}\n-----------------------------------------------------------------------------\n########################### Network Configuration ###########################\n${reset}" | tee -a $passFile $failFile $fixFile
echo -e "${lyellow}\n--------------------------------------------------\n#### Disable Unused Network Protocols And Devices\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathNetwork/disable_unused_network_protocols_and_devices/disable_unused_network_protocols_and_devices.sh
echo -e "${lyellow}\n--------------------------------------------------\n#### Network Parameters Host Only\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathNetwork/network_parameters_host_only/network_parameters_host_only.sh
echo -e "${lyellow}\n--------------------------------------------------\n#### Network Parameters Host And Router\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathNetwork/network_parameters_host_and_router/network_parameters_host_and_router.sh
echo -e "${lyellow}\n--------------------------------------------------\n#### Firewall Configuration (ufw)\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathNetwork/firewall_configuration/configure_uncomplicatedfirewall.sh
bash $pathNetwork/firewall_configuration/configure_nftables.sh
bash $pathNetwork/firewall_configuration/configure_iptables.sh
echo -e "${yellow}\n-----------------------------------------------------------------------------\n########################### Logging and Auditing ############################\n${reset}" | tee -a $passFile $failFile $fixFile
echo -e "${lyellow}\n--------------------------------------------------\n#### Configure System Accounting (auditd)\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathLogging/configure_system_accounting/ensure_auditing_is_enabled.sh
bash $pathLogging/configure_system_accounting/configure_data_retention.sh
bash $pathLogging/configure_system_accounting/configure_auditd_rules.sh
bash $pathLogging/configure_system_accounting/configure_auditd_file_access.sh
echo -e "${lyellow}\n--------------------------------------------------\n#### Configure Logging (rsyslog)\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathLogging/configure_logging/configure_journald.sh
bash $pathLogging/configure_logging/configure_rsyslog.sh
echo -e "${yellow}\n-----------------------------------------------------------------------------\n################## Access Authentication And Authorization ##################\n${reset}" | tee -a $passFile $failFile $fixFile
echo -e "${lyellow}\n--------------------------------------------------\n#### Configure Time-Based Job Schedulers (cron)\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathAccess/configure_time-based_job_schedulers/configure_time-based_job_schedulers.sh
echo -e "${lyellow}\n--------------------------------------------------\n#### Configure SSH Server\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathAccess/configure_ssh_server/configure_ssh_server.sh
echo -e "${lyellow}\n--------------------------------------------------\n#### Configure Privilege Escalation\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathAccess/configure_privilege_escalation/configure_privilege_escalation.sh
echo -e "${lyellow}\n--------------------------------------------------\n#### Configure PAM\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathAccess/configure_pam/configure_pam.sh
echo -e "${lyellow}\n--------------------------------------------------\n#### User Accounts And Environment\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathAccess/user_accounts_and_environment/set_shadow_password_suite_parameters.sh
echo -e "${yellow}\n-----------------------------------------------------------------------------\n############################ System Maintenance #############################\n${reset}" | tee -a $passFile $failFile $fixFile
echo -e "${lyellow}\n--------------------------------------------------\n#### System File Permissions\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathSystem/system_file_permissions/system_file_permissions.sh
echo -e "${lyellow}\n--------------------------------------------------\n#### Local User And Group Settings\n${reset}" | tee -a $passFile $failFile $fixFile
bash $pathSystem/local_user_and_group_settings/local_user_and_group_settings.sh