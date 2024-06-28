#!/usr/bin/env bash

systemctl status terraria > /dev/null
service_status=$?

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

if [ $service_status -eq 3 ]
then
  echo "2" > /usr/lib/terraria/proc/status
  printf "${RED}OFFLINE${NC}"
elif [ $service_status -eq 0 ]
then
  if [[ $(tail -n1 /usr/lib/terraria/log/terraria.log | awk '{print $1}') = ":" ]];
  then
    echo "0" > /usr/lib/terraria/proc/status
    printf "${GREEN}ONLINE${NC}"
  else
    echo "1" > /usr/lib/terraria/proc/status
    printf "${YELLOW}STARTING${NC}"
  fi
fi