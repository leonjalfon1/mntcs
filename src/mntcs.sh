#!/bin/bash

#=====================================================
# USER INPUT
#=====================================================

CONFIG_FILE="/etc/mntcs/mntcs.conf"
LOG_FILE="/var/log/mntcs.log"

#=====================================================
# FUNCTIONS
#=====================================================

# help function

function help
{
    echo ''
    echo '========================================='
    echo '    MNTCS - MOUNT CENTRALIZED SYSTEM     '
    echo '========================================='
    echo ''
    echo 'DESCRIPTION'
    echo '-----------'
    echo 'mntcs is a tool that allows you to mange filesystem mounts in a centralized and easy way. It was created to answer the following use case: Manage filesystem mounts in several ubuntu servers using a single configuration file allowing users without previous knowledge on Linux mounts to use the system'
    echo 'For more info see: https://github.com/leonjalfon1/mntcs'
    echo ''
    echo 'PREREQUISITES'
    echo '----------'
    echo 'mntcs must be run as sudo (sudo is required to perform the mounts)'
    echo ''
    echo 'PARAMETERS'
    echo '----------'
    echo '--config-file: path to the mntcs configuration file (default: /etc/mntcs/mntcs.conf)'
    echo '--log-file: path to the mntcs log file (default: /var/log/mntcs.log)'
    echo ''
    echo 'USAGE'
    echo '----------'
    echo 'mntc --config-file "/etc/mntcs/mntcs.conf" --log-file "/var/log/mntcs.log"'
    echo ''

    exit
}

# parameters management functions

function load-parameters
{
    # assign parameters
    
    while [ "$1" != "" ]; do
        case "$1" in
            --config-file )     CONFIG_FILE="$2";      shift;;
            --log-file )        LOG_FILE="$2";         shift;;
            --help )            help;                  exit;; # quit and show usage
            * )                 args+=("$1")           # if no match, add it to the positional args
        esac
        shift # move to next kv pair
    done
}

# main function

function main
{
    # load passed parameters in global variables
    load-parameters $@

    # exit if the script is not executed by root
    validate-root

    # print configuration details
    print-mntcs-config

    # Initialize the configuration index counter
    counter=0

    # Read the config file line by line
    while IFS="" read -r p || [ -n "$p" ]
    do

      # Create an array with the configurations
      config=( $p )

      # Skip line if it's empty or if is a comment (start with '#')
      [[ $p =~ ^#.* ]] && continue
      [ -z "$p" ] && continue

      # print the mount configuration
      print-mount-config $counter $config

      # create the target path if it doesn't exist
      create-target-path ${config[1]}

      # mount the target file system
      mount-directory ${config[0]} ${config[1]}

      # Increment the counter value
      let counter=counter+1

    done <"${CONFIG_FILE}"

    # return 0 to indicate success
    exit 0
}

# exit if the script is not executed by root
function validate-root
{
  if [ "$(id -u)" -ne 0 ]; then
    printf "\n[`date +'%F_%T'`] Error, This script must be run by root"
    exit 1
  fi
}

# print configuration details
function print-mntcs-config
{
  printf "[`date +'%F_%T'`] Initialing mntcs..." | tee -a ${LOG_FILE}
  printf "\n[`date +'%F_%T'`] config-file: ${CONFIG_FILE})" | tee -a ${LOG_FILE}
  printf "\n[`date +'%F_%T'`] log-file: ${LOG_FILE})" | tee -a ${LOG_FILE}
}

# print the mount configuration
function print-mount-config
{
  counter=$1
  config=$2

  printf "\n[`date +'%F_%T'`] Processing configuration, index: %s" "$counter" | tee -a ${LOG_FILE}
  printf "\n[`date +'%F_%T'`] Source --> %s" "${config[0]}" | tee -a ${LOG_FILE}
  printf "\n[`date +'%F_%T'`] Target --> %s" "${config[1]}" | tee -a ${LOG_FILE}
}

# create the target path if it doesn't exist
function create-target-path
{
  targetpath=$1

  if [ -d "$targetpath" ]; then
    printf "\n[`date +'%F_%T'`] Target directory found" | tee -a ${LOG_FILE}
  else
    printf "\n[`date +'%F_%T'`] Target directory not found, Creating..." | tee -a ${LOG_FILE}
    mkdir -p "$targetpath"
  fi
}

# mount the target file system
function mount-directory
{
  source=$1
  target=$2

  printf "\n[`date +'%F_%T'`] Mounting the source directory into the target" | tee -a ${LOG_FILE}
  mount $source $target
}

#=====================================================
# SCRIPT
#=====================================================

# show help if parameters are not passed, else start script
if [ -z "$1" ]
then
    help
else
    main $@
fi