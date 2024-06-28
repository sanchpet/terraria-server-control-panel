#!/usr/bin/env bash

set -Eeuo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

Script description here.

...
EOF
  exit
}

trap cleanup SIGINT SIGTERM ERR EXIT

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  rm -f "$script_dir"/version.json
  rm -rf "${script_dir:?}"/"$latest_ver"
  rm "${script_dir:?}"/"$ver_num"
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

install_dependencies() {
    echo "INSTALLING DEFAULT DEPENDENCIES"
    apt-get update && apt-get -y install jq unzip pwgen iptables-persistent
    echo "SUCCESSFULL INSTALATION OF DEPENDENCIES"
}

install_server() {
    echo "INSTALLING SERVER"
    wget https://terraria.org/api/get/dedicated-servers-names -O "$script_dir"/version.json
    latest_ver=$(jq < version.json | grep -Eo "terraria-server-.*.zip" | uniq )
    ver_num=$(echo "$latest_ver" | sed 's/terraria-server-//; s/.zip//')

    wget https://terraria.org/api/download/pc-dedicated-server/"$latest_ver"
    unzip "$latest_ver" && mv "$ver_num"/Linux /usr/lib/terraria 

    chmod +x /usr/lib/terraria/TerrariaServer && chmod +x /usr/lib/terraria/TerrariaServer.bin.x86_64
    echo "SUCCESSFULL INSTALATION OF SERVER"
}

create_dirs() {
    echo "CREATING DIRECTORIES"
    mkdir -p /usr/share/terraria
    mkdir -p /usr/lib/terraria/proc
    mkdir -p /home/terraria/
    mkdir -p /usr/lib/terraria/scripts
    mkdir -p /etc/terraria
    mkdir -p /usr/lib/terraria/log
    echo "SUCCESSFULL CREATION OF DIRECTORIES"
}

install_scripts() {
    echo "INSTALLING SCRIPTS"
    cp "$script_dir"/scripts/* /usr/lib/terraria/scripts/
    cp "$script_dir"/configs/* /usr/lib/terraria/
    touch /usr/lib/terraria/banlist.txt
    chmod +x /usr/local/bin/terrariaad

    ln -sv /usr/lib/terraria/config.txt /etc/terraria/config.txt
    ln -sv /usr/lib/terraria/banlist.txt /etc/terraria/banlist.txt
    install -m655 "$script_dir"/bashsimplecurses/simple_curses.sh /usr/lib/simple_curses.sh
    echo "SUCCESSFULL INSTALATION OF SCRIPTS"
}

prepare_system() {
    echo "PREPARING SYSTEM"
    echo "0" > /usr/lib/terraria/proc/status
    echo "${ver_num}" "${ver_num}" > /usr/lib/terraria/proc/version

    cp "$script_dir"/systemd/terraria.service /etc/systemd/system/
    cp "$script_dir"/configs/.screenrc /home/terraria/
    cp "$script_dir"/logrotate.d/terraria /etc/logrotate.d/

    useradd -rU terraria
    usermod --shell /usr/bin/bash terraria
    chown -R terraria:terraria /usr/lib/terraria
    chown -R terraria:terraria /usr/share/terraria
    chown -R terraria:terraria /home/terraria

    systemctl daemon-reload
    systemctl enable terraria
    logrotate /etc/logrotate.d/terraria
    echo "SYSTEM PREPARED SUCCESSFULLY"    
}

configure_terraria() {
    echo "CONFIGURE TERRARIA SERVER"
    pass=$(pwgen -cns 16 1)
    seed=$(pwgen -cns 30 1)
    sed -i "s/password=/password=${pass}/" /usr/lib/terraria/config.txt
    sed -i "s/seed=/seed=${seed}/" /usr/lib/terraria/config.txt
    echo "SUCCESSFUL CONFIGURATION"
}

set_panel_startup_on_login() {
    echo "SET PANEL STARTUP ON LOGIN"
    sed -i "s/root\:x\:0\:0\:root\:\/root\:\/bin\/bash/root\:x\:0\:0\:root\:\/root\:\/usr\/lib\/terraria\/scripts\/shell.sh/" /etc/passwd
    echo "SUCCESSFULLY SET PANEL STARTUP ON LOGIN"
}

setup_colors
install_dependencies
install_server
create_dirs
install_scripts
prepare_system
configure_terraria
set_panel_startup_on_login
