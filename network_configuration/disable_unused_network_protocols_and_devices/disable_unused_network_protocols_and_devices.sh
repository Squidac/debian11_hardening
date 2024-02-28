#!/usr/bin/env bash

# List of modules to check and disable if necessary
modules=("dccp" "sctp" "rds" "tipc")

# Function to disable the module and log the results
disable_module() {
    local module=$1
    local loadable
    local is_loaded
    local is_blacklisted

    # Check if the module can be loaded or is already loaded
    loadable=$(modprobe -n -v $module)
    is_loaded=$(lsmod | grep $module)
    is_blacklisted=$(grep "^blacklist $module" /etc/modprobe.d/*)

    # If the module is not loaded and not set to be loaded, it's considered as passing
    if [[ -z "$is_loaded" && "$loadable" != *"install /bin/false"* ]]; then
        echo "install $module /bin/false" > /etc/modprobe.d/$module.conf
        echo "$module module is disabled." >> "/home/lab/kovennukset/security_check_pass.txt"
    else
        # If the module is loaded or not correctly configured, it's a fail
        if [[ -n "$is_loaded" ]]; then
            echo "$module module is loaded and should be unloaded." >> "/home/lab/kovennukset/security_check_fail.txt"
            modprobe -r $module
        fi
        if [[ "$loadable" == *"install /bin/false"* && -z "$is_blacklisted" ]]; then
            echo "blacklist $module" >> /etc/modprobe.d/$module.conf
            echo "$module module is now blacklisted." >> "/home/lab/kovennukset/security_check_pass.txt"
        else
            echo "$module module is not correctly configured." >> "/home/lab/kovennukset/security_check_fail.txt"
        fi
    fi
}

# Iterate over each module and apply the disable function
for module in "${modules[@]}"; do
    disable_module "$module"
done
