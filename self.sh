#!/bin/bash
# ufw settings
ufw default allow outgoing
ufw default deny incoming
ufw deny ssh



# Installing required packets.
sudo apt-get update
sudo apt-get install -y libpam-pwquality libpam-modules aide aide-common sudo rsyslog ufw auditd

sudo apt install dialog apt-utils