#!/bin/bash
#######################################################
# Bash Systemd Scheduler(BSS) - Dante Foulke, 2024
#######################################################

#########################
#     Functions
#########################
function check_dependencies() {  
  if ! command -v yq &> /dev/null
  then
    error_exit "yq is not installed! :( Please See Install instructions at https://github.com/mikefarah/yq/#install !"
  fi
}

function error_exit () {
  message=$1
  RED='\033[1;31m'
  YELLOW='\033[1;33m'
  echo -e "${RED}Error: ${YELLOW}$message"
  exit 1
}

function install_services() {
  # Create Service files and service link
  services=("bss-${user_id}.service" "bss-${user_id}.timer")
  for item in "${services[@]}"
  do
    # Create File
    if [ ! -f "${svc_folder}/${item}" ]; then
      echo "Creating ${svc_folder}/${item}..."
      if [[ "$item" == *".service"*  ]]; then
        cp "./Source/bss.service" "${svc_folder}/${item}" || error_exit "Error Copying File, Exiting..."
        # Edit Service File with user home directory 
        sed -i "s|USER_HOME_DIRECTORY|$HOME|" "${svc_folder}/${item}"
      fi
      if [[ "$item" == *".timer"*  ]]; then
        cp "./Source/bss.timer" "${svc_folder}/${item}" || error_exit "Error Copying File, Exiting..."
      fi
      sudo chown $USERNAME:$USERNAME "${svc_folder}/${item}" || error_exit "Error changing ownership, Exiting..."
      chmod 754 "${svc_folder}/${item}" || error_exit "Error changing file permissions File, Exiting..."
    fi
    # Create Services Link
    if [ ! -f "/etc/systemd/user/${item}" ]; then
      echo "Linking ${svc_folder}/${item}..."
      sudo ln -s "${svc_folder}/${item}" "/etc/systemd/user/${item}" || error_exit "Error Linking File, Exiting..."
    fi
  done

  # Enable bss services
  systemctl enable --user "bss-${user_id}.service" || error_exit "Error enabling bss service, Exiting..."
  systemctl start --user "bss-${user_id}.service" || error_exit "Error starting bss service, Exiting..."
  systemctl enable --user "bss-${user_id}.timer" || error_exit "Error enabling bss timer, Exiting..."

  # Print bss service info
  echo "bss successfully created"
  systemctl list-unit-files --user | grep bss
}

#########################
#    Installer Start
#########################

user_id=$(id -u $(whoami))
config_folder="${HOME}/bss"
svc_folder="${HOME}/.config/systemd/user"
configfile="${config_folder}/backups.yaml"

check_dependencies

# Create Program folder if it doesn't exist
if [ ! -d "$config_folder" ]; then
  mkdir $config_folder
fi

# Create Config file if it doesn't exist
if [ ! -d "$configfile" ]; then
  touch $configfile
fi

# Copy Program files
installers=(scheduler.sh timekeeper.sh)
for item in "${installers[@]}"
do
  if [ ! -d "${config_folder}/${item}" ]; then
    cp "./Source/$item" "${config_folder}/${item}"
  fi
done

# Change file permissions for config folder
chmod -R 754 $config_folder

install_services
