#!/usr/bin/env bash

sum=$(md5sum /etc/terraria/config.txt | awk '{print $1}')
nano -t /etc/terraria/config.txt
sum2=$(md5sum /etc/terraria/config.txt | awk '{print $1}')

if [ "$sum" != "$sum2" ] && [ "$(cat /usr/lib/terraria/proc/status)" -eq 0 ]
then
  echo -n "A server restart is required to apply the changes. Do it now? (y/n) [default n] > "
  read -rn1 ans

  if [ "$ans" == 'y' ]
  then
    systemctl restart terraria
  fi
fi