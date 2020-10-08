#!/bin/bash

file="/etc/mntcs/mntcs.conf"
log="/var/log/mntcs.log"

# Exit if it's not executed by root
if [ "$(id -u)" -ne 0 ]; then
  printf "[`date +'%F_%T'`] Error, This script must be run by root\n"
  exit 1
fi

printf "\n[`date +'%F_%T'`] Initialing the mounting process" | tee -a ${log}

# Initialize the configuration index counter
COUNTER=0

# Read the config file line by line
while IFS="" read -r p || [ -n "$p" ]
do

  # Create an array with the configurations
  config=( $p )

  # Skip line if it's empty or if is a comment (start with '#')
  [[ $p =~ ^#.* ]] && continue
  [ -z "$p" ] && continue

  # Write to log/console
  printf "[`date +'%F_%T'`] Processing configuration: index %s\n" "$COUNTER" | tee -a ${log}
  printf "[`date +'%F_%T'`] Source --> %s\n" "${config[0]}" | tee -a ${log}
  printf "[`date +'%F_%T'`] Target --> %s\n" "${config[1]}" | tee -a ${log}

  # Create the target path if it doesn't exist
  if [ -d "${config[1]}" ]; then
    printf "[`date +'%F_%T'`] Target directory found\n" | tee -a ${log}
  else
    printf "[`date +'%F_%T'`] Target directory not found, Creating\n" | tee -a ${log}
    mkdir -p "${config[1]}"
  fi

  # Mount the target file system
  printf "[`date +'%F_%T'`] Mounting the source directory into the target\n" | tee -a ${log}
  mount ${config[0]} ${config[1]}

  # Increment the counter value
  let COUNTER=COUNTER+1

done <"$file"