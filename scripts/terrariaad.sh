#!/usr/bin/env bash

set -Eeuo pipefail

send="`printf \"$*\r\"`"
attach="screen -r Terraria"
inject="screen -S Terraria -X stuff $send"

case $1 in
    start)
            /usr/bin/screen -c "/home/terraria/.screenrc" -dmS "Terraria" /bin/bash -c "/usr/lib/terraria/TerrariaServer -config /usr/lib/terraria/config.txt"
            exit 0
    ;;
    attach) cmd="$attach";;
    *)      cmd="$inject";;
esac

if [ "$(stat -c '%u' /var/run/screen/S-terraria/)" = "$UID" ]
then
    $cmd
else
    su - root -c "$cmd"
fi