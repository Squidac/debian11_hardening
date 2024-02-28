#!/bin/bash

O_PATH=/home/user/kovennukset

# Värikoodit
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
NC="\033[0m" # No Color

# Otsikkofunktio
print_header() {
    echo -e "${YELLOW}\n########################################################${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${YELLOW}########################################################${NC}"
}

####### Check if package manager repositories are configured
print_header "## 1.2.1 ## Check if the package manager repositories are configured" | tee -a "$O_PATH/manual_security_check.txt"
{
    output=$(apt-cache policy 2>/dev/null)
    DREPO="deb.debian.org"
    # NREPO="repo.netum.fi"

    # # Tarkista onko Netumin repositorio listassa
    # if ! echo "$output" | grep -q "$NREPO"; then
    # echo "$NREPO not found. Configuring it now..." | tee -a "$O_PATH/manual_security_check.txt"


    #     echo "deb http://$NREPO main" >> /etc/apt/sources.list
    #     apt-get update

    #     echo -e "$NREPO has been configured." | tee -a "$O_PATH/manual_security_check.txt"
    # else
    #     echo -e "$NREPO is configured." | tee -a "$O_PATH/manual_security_check.txt"
    # fi

    # Tarkista onko Debianin repositoriot listassa
    if ! echo "$output" | grep -q "$DREPO"; then
        echo "Debian repositories not found. Configuring it now..." | tee -a "$O_PATH/manual_security_check.txt"

        echo "deb http://$DREPO/debian/ bookworm main non-free-firmware" >> /etc/apt/sources.list
        echo "deb-src http://$DREPO/debian/ bookworm main non-free-firmware" >> /etc/apt/sources.list
        apt-get update

        echo -e "Debian repositories has been configured." | tee -a "$O_PATH/manual_security_check.txt"
    else
        echo -e "Debian repositories are configured." | tee -a "$O_PATH/manual_security_check.txt"
    fi
}

####### Check if GPG keys are configured
print_header "## 1.2.2 ## Check if GPG keys are configured" | tee -a "$O_PATH/manual_security_check.txt"
{
    netum_key_found=false
    debian_key_found=false

    # Luodaan väliaikainen gpg-hakemisto
    temp_gpg_dir=$(mktemp -d)

    # Käy läpi kaikki tiedostot /etc/apt/trusted.gpg.d/ hakemistossa
    for file in /etc/apt/trusted.gpg.d/*.{gpg,asc}; do
        gpg --no-default-keyring --keyring "$temp_gpg_dir/temp_keyring.gpg" --import "$file" > /dev/null 2>&1
        if gpg --no-default-keyring --keyring "$temp_gpg_dir/temp_keyring.gpg" --list-keys | grep -qi "Netum"; then
            netum_key_found=true
        fi
        if gpg --no-default-keyring --keyring "$temp_gpg_dir/temp_keyring.gpg" --list-keys | grep -qi "Debian"; then
            debian_key_found=true
        fi
    done

    # Poista väliaikainen hakemisto
    rm -r "$temp_gpg_dir"

    # Tarkista onko merkintä Netumin repositoriosta
    if [ "$netum_key_found" = false ]; then
        echo "Netum GPG keys not found. Adding it now... (KESKENERÄINEN)" | tee -a "$O_PATH/manual_security_check.txt"
    else
        echo "Netum GPG keys are present." | tee -a "$O_PATH/manual_security_check.txt"
    fi

    # Tarkista onko merkintä "Debian" avainlistassa
    if [ "$debian_key_found" = false ]; then
        echo "Debian GPG keys not found. Please check the keys manually..." | tee -a "$O_PATH/manual_security_check.txt"
    else
        echo "Debian GPG keys are present." | tee -a "$O_PATH/manual_security_check.txt"
    fi
}

####### Check if updates, patches, and additional security software are installed
print_header "## 1.9 ## Check if updates, patches, and additional security software are installed" | tee -a "$O_PATH/manual_security_check.txt"
{

    output=$(apt-get --just-print upgrade 2>/dev/null)

    # Jos päivityksiä on saatavilla, asennetaan ne
    if echo "$output" | grep -q "Inst"; then
        echo -e "Updates available. Installing now..." | tee -a "$O_PATH/manual_security_check.txt"
        apt-get update && apt-get upgrade -y
        echo -e "Updates installed successfully." | tee -a "$O_PATH/manual_security_check.txt"
    else
        echo -e "No updates available." | tee -a "$O_PATH/manual_security_check.txt"
    fi
}

####### Check if ntp is configured with authorized timeserver
print_header "## 2.1.4.2 ## Check if ntp is configured with authorized timeserver" | tee -a "$O_PATH/manual_security_check.txt"
{
    # Tarkista, onko ntp asennettu
    if dpkg -l | grep -qw ntp; then
        echo -e "ntp is installed." | tee -a "$O_PATH/manual_security_check.txt"
    else
        echo -e "ntp ei ole asennettu. Asennetaan ntp..." | tee -a "$O_PATH/manual_security_check.txt"
        apt-get update && apt-get install -y ntp
    fi

    # Tarkista molemmista poluista
    for config_path in /etc/ntp.conf /etc/ntpsec/ntp.conf; do
        if [[ -f "$config_path" ]]; then
            server_count=$(grep -Pc -- '^\h*server\h+\H+' "$config_path")
            pool_count=$(grep -Pc -- '^\h*pool\h+\H+' "$config_path")

            echo -e "Checking $config_path" | tee -a "$O_PATH/manual_security_check.txt"
            echo -e "Server lines: $server_count" | tee -a "$O_PATH/manual_security_check.txt"
            echo -e "Pool lines: $pool_count\n" | tee -a "$O_PATH/manual_security_check.txt"

            if [[ $pool_count -eq 1 && $server_count -ge 3 ]]; then
                echo -e "NTP configuration in $config_path is following the recommendation." | tee -a "$O_PATH/manual_security_check.txt"
            else
                echo -e "NTP configuration in $config_path is NOT following the recommendation." | tee -a "$O_PATH/manual_security_check.txt"

                # Korjataan konfiguraatio suosituksen mukaiseksi
                sed -i '/^\s*pool\|^\s*server/d' "$config_path"

                echo -e "\n# CIS Benchmark recommendations."
                echo "pool fi.pool.ntp.org" >> "$config_path"

                echo -e "Updated the $config_path." | tee -a "$O_PATH/manual_security_check.txt"
            fi
        fi
    done

    # Käynnistä ntp uudelleen, jotta muutokset astuvat voimaan
    systemctl restart ntp
}

####### Ensure nonessential services are removed or masked
print_header "## 2.4 ## Ensure nonessential services are removed or masked" | tee -a "$O_PATH/manual_security_check.txt"
{
    output=$(ss -plntu)
    echo -e "$output\n" | tee -a "$O_PATH/manual_security_check.txt"
}

####### Ensure system is checked to determine if IPv6 is enabled
print_header "## 3.1.1 ## Ensure system is checked to determine if IPv6 is enabled" | tee -a "$O_PATH/manual_security_check.txt"
{
    #!/usr/bin/env bash

    grubfile=$(find /boot -type f \( -name 'grubenv' -o -name 'grub.conf' -o -name 'grub.cfg' \) -exec grep -Pl -- '^\h*(kernelopts=|linux|kernel)' {} \;)
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"

    ipv6_disabled_in_grub=false
    ipv6_disabled_in_sysctl=false

    if [ -s "$grubfile" ]; then
        if ! grep -P -- "^\h*(kernelopts=|linux|kernel)" "$grubfile" | grep -q -- ipv6.disable=1; then
            # Disable IPv6 through the GRUB2 config
            sed -i '/^GRUB_CMDLINE_LINUX=/s/"$/ ipv6.disable=1"/' /etc/default/grub
            update-grub
            ipv6_disabled_in_grub=true
        fi
    fi

    if ! grep -Pqs -- "^\h*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" $searchloc || \
    ! grep -Pqs -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$" $searchloc || \
    ! sysctl net.ipv6.conf.all.disable_ipv6 | grep -Pqs -- "^\h*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" || \
    ! sysctl net.ipv6.conf.default.disable_ipv6 | grep -Pqs -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$"; then
        # Disable IPv6 through sysctl settings
        printf "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\n" >> /etc/sysctl.d/60-disable_ipv6.conf
        sysctl -w net.ipv6.conf.all.disable_ipv6=1
        sysctl -w net.ipv6.conf.default.disable_ipv6=1
        sysctl -w net.ipv6.route.flush=1
        ipv6_disabled_in_sysctl=true
    fi

    if $ipv6_disabled_in_grub || $ipv6_disabled_in_sysctl; then
        echo "IPv6 has been disabled on the system." | tee -a "$O_PATH/manual_security_check.txt"
    else
        echo "IPv6 is disabled on the system." | tee -a "$O_PATH/manual_security_check.txt"
    fi
}

####### Ensure ufw outbound connections are configured
print_header "## 3.5.1.5 ## Ensure ufw outbound connections are configured" | tee -a "$O_PATH/manual_security_check.txt"
{
    output=$(ufw status numbered)
    echo -e "$output\n" | tee -a "$O_PATH/manual_security_check.txt"

    # Tarkista onko UFW aktiivinen
    if ufw status | grep -q "inactive"; then
        echo "UFW is inactive. Activating it now..." | tee -a "$O_PATH/manual_security_check.txt"
        ufw enable
    fi

    # Tarkista onko oletuksena tulevat yhteydet kielletty ja lähtevät yhteydet sallittu
    status=$(ufw status verbose | grep "Default:")

    if ! echo "$status" | grep -q "deny (incoming)"; then
        echo "Changing default incoming connections to DENY..." | tee -a "$O_PATH/manual_security_check.txt"
        ufw default deny incoming
    fi

    if ! echo "$status" | grep -q "allow (outgoing)"; then
        echo "Changing default outgoing connections to ALLOW..." | tee -a "$O_PATH/manual_security_check.txt"
        ufw default allow outgoing
    fi

    # Tallenna muutokset ja käynnistä UFW uudelleen
    ufw reload
}

####### Ensure the running and on disk configuration is the same (LVL2)
print_header "## 4.1.3.21 ## Ensure the running and on disk configuration is the same" | tee -a "$O_PATH/manual_security_check.txt"
{
    output=$(augenrules --check 2>&1)

    if echo "$output" | grep -q "No change"; then
        echo "Running and on disk configuration is the same" | tee -a "$O_PATH/manual_security_check.txt"
    else
        echo "Running and on disk configuration is not the same" | tee -a "$O_PATH/manual_security_check.txt"
        echo "Output: $output" | tee -a "$O_PATH/manual_security_check.txt"
        
        # Ladataan levylle tallennettu konfiguraatio aktiiviseen käyttöön
        echo "Updating running configuration to match the on disk configuration..." | tee -a "$O_PATH/manual_security_check.txt"
        augenrules --load

        # Tarkistetaan, onnistuiko päivitys
        if [ $? -eq 0 ]; then
            echo "Running configuration successfully updated." | tee -a "$O_PATH/manual_security_check.txt"
        else
            echo "Failed to update the running configuration. Manual intervention might be required." | tee -a "$O_PATH/manual_security_check.txt"
        fi
    fi
}

####### Check if logging is configured
print_header "## 4.2.2.5 ## Ensure logging is configured" | tee -a "$O_PATH/manual_security_check.txt"
{
    if grep -q "^.*log.*$" /etc/rsyslog.conf; then
        echo -e "logging is configured" | tee -a "$O_PATH/manual_security_check.txt"
    else
        echo -e "logging is not configured" | tee -a "$O_PATH/manual_security_check.txt"
    fi
}

####### Ensure all current passwords use the configured hashing algorithm
print_header "## 5.4.5 ## Ensure all current passwords use the configured hashing algorithm" | tee -a "$O_PATH/manual_security_check.txt"
{
    #!/usr/bin/env bash
    declare -A HASH_MAP=( ["y"]="yescrypt" ["1"]="md5" ["2"]="blowfish" ["5"]="SHA256" ["6"]="SHA512" ["g"]="gost-yescrypt" )
    CONFIGURED_HASH=$(sed -n "s/^\s*ENCRYPT_METHOD\s*\(.*\)\s*$/\1/p" /etc/login.defs | xargs) # xargs poistaa ylimääräiset välilyönnit

    CHECK_PASSED=true

    for MY_USER in $(sed -n "s/^\(.*\):\\$.*/\1/p" /etc/shadow); do
        CURRENT_HASH=$(sed -n "s/${MY_USER}:\\$\(.\).*/\1/p" /etc/shadow)
        if [[ "${HASH_MAP["${CURRENT_HASH}"]^^}" != "${CONFIGURED_HASH^^}" ]]; then
            CHECK_PASSED=false
            echo -e "The password for '${MY_USER}' is using '${HASH_MAP["${CURRENT_HASH}"]}' instead of the configured '${CONFIGURED_HASH}'." | tee -a "$O_PATH/manual_security_check.txt"
        fi
    done

    if $CHECK_PASSED; then
        echo -e "All current passwords use the configured hashing algorithm" | tee -a "$O_PATH/manual_security_check.txt"
    else
        echo -e "Not all passwords use the configured hashing algorithm. Please review the output and make necessary corrections." | tee -a "$O_PATH/manual_security_check.txt"
    fi
}

####### Audit SUID executables
print_header "## 6.1.12 ## Audit SUID executables" | tee -a "$O_PATH/manual_security_check.txt"
{
    files=$(df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type f -perm -4000)

    for file in $files; do
        # Tarkistaa, kuuluuko tiedosto mihinkään pakettiin.
        package=$(dpkg -S "$file" 2>/dev/null)

        if [ $? -eq 0 ]; then
            echo "$file belongs to package $package" | tee -a "$O_PATH/manual_security_check.txt"
        else
            echo "WARNING: $file does not belong to any package. Potential rogue binary!" | tee -a "$O_PATH/manual_security_check.txt"
        fi
    done

    echo -e "\nReview the above files and confirm the integrity of these binaries." | tee -a "$O_PATH/manual_security_check.txt"
}

####### Audit SGID executables
print_header "## 6.1.13 ## Audit SGID executables" | tee -a "$O_PATH/manual_security_check.txt"
{
    files=$(df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type f -perm -2000)

    for file in $files; do
        # Tarkistaa, kuuluuko tiedosto mihinkään pakettiin.
        package=$(dpkg -S "$file" 2>/dev/null)

        if [ $? -eq 0 ]; then
            echo "$file belongs to package $package" | tee -a "$O_PATH/manual_security_check.txt"
        else
            echo "WARNING: $file does not belong to any package. Potential rogue binary!" | tee -a "$O_PATH/manual_security_check.txt"
        fi
    done

    echo -e "\nReview the above files and confirm the integrity of these binaries." | tee -a "$O_PATH/manual_security_check.txt"
}