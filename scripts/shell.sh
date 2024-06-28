#!/bin/bash -l

. /usr/lib/simple_curses.sh

BIN="/usr/lib/terraria/scripts"

CL_N="\033[0m"
CL_D="\033[1;30m"
CL_R="\033[0;31m"
CL_G="\033[0;32m"
CL_Y="\033[0;33m"
label_editconf="Edit config.txt"
label_editbanl="Edit banlist.txt"
label_shell="Drop to the linux shell"
label_logout="Logout"

main() {
	status=$(cat /usr/lib/terraria/proc/status)

	iver=$(awk '{print $1}' < /usr/lib/terraria/proc/version)
	rver=$(awk '{print $2}' < /usr/lib/terraria/proc/version)

	window "Terraria server status"
	mem_total=$(awk '/MemTotal/ {print int($2/1024)}' < /proc/meminfo)
    mem_free=$(awk '/MemAvailable/ {print int($2/1024)}' < /proc/meminfo)
	mem_used=$((mem_total-mem_free))

	[ "$iver" != "$rver" ] && label_server_version=$(printf "Server Version|${iver} (${CL_Y}${rver}${CL_N})") || label_server_version="Server Version|${iver}"
	ipaddr=$(ip a | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/2[3,4]" | sed 's/\/2[3,4]//')
	port=$(grep ^port /etc/terraria/config.txt | sed 's/port=//')

    append_tabbed "Memory Usage|${mem_used}/${mem_total}" 2 "|"
	append_tabbed "${label_server_version}" 2 "|"
	append_tabbed "Server Status|$(bash ${BIN}/serverstatus.sh)" 2 "|"
	[ "${status}" -eq 1 ] && append_tabbed "Start Status|$(tail -n2 /usr/lib/terraria/log/terraria.log | head -n1)" 2 "|"
	append_tabbed "Server IP address|${ipaddr}" 2 "|"
	append_tabbed "Server Port|${port}" 2 "|"

	if [ "${status}" -eq 0 ]
	then
		append_tabbed "Players|$(sudo -u terraria terrariaad playing; tail -n2 /usr/lib/terraria/log/terraria.log | head -n1 | cat -v | tr -d "^M" | grep -v "exit")" 2 "|"
	fi

	endwin

	window "Please press [1..6] key"

	if [ "$iver" != "$rver" ];
	then
		[ "${status}" -eq 0 ] && label_update=$(printf "${CL_D}Update Terraria server (unavailable - server online)${CL_N}") || label_update="Update Terraria server"
	else
		label_update=$(printf "${CL_D}Update Terraria server (unavailable - latest version)${CL_N}")
	fi
	
	if [ "${status}" -eq 0 ];
	then
		label_startstop="Stop terraria server"
		label_terraria_console="Open Terraria console (Ctrl+A + Ctrl+D to close)"
	else
		label_startstop="Start terraria server"
		label_terraria_console=$(printf "${CL_D}Open Terraria console (unavailable - server offline)${CL_N}")
	fi
	
	append_tabbed "1) ${label_startstop}|4) ${label_terraria_console}" 2 "|"
	append_tabbed "2) ${label_editconf}|5) ${label_update}" 2 "|"
	append_tabbed "3) ${label_editbanl}|6) ${label_shell}" 2 "|"
	append
	append_tabbed "0) ${label_logout}" 1 "|"
	endwin
}

update() {
	local ret

	read -r -n 1 -s -t 1 ret

	case $ret in
		1)
			if [ "${status}" -eq 2 ]
			then
				systemctl start terraria
			else
				systemctl stop terraria
			fi
		;;
		2)
			bash ${BIN}/editconfig.sh
		;;
		3)
			nano -t /etc/terraria/banlist.txt
		;;
		4)
			if [ "${status}" -eq 0 ];
			then
				clear
				sudo -u terraria terrariaad attach
			fi
		;;
		5)
			if [ "$iver" != "$rver" ] && [ "${status}" -eq 2 ];
			then
				bash ${BIN}/download.sh "${rver}"
			fi
		;;
		6)
			clear
			bash -l
		;;
		0)
			exit 0
		;;
	 esac
}


if [ "$1" == "-c" ];
then
	/usr/bin/bash "$@"
else
	main_loop "$@"
fi
