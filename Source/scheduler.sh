#!/bin/bash
#######################################################
# Bash Systemd Scheduler(BSS) - Dante Foulke, 2023
#######################################################

#########################
#       Functions 
#########################
function check_schedule () {
  schedule=$( cat $configfile | yq ".jobs[$jci].schedule.modified" )
  option=$( cat $configfile | yq ".jobs[$jci].parameters.command" ) 

  # Check if Scheduling information exists in Config
  if [[ ($schedule == 'null') || ($schedule == '') ]]; then
    echo "New Backup Job found - '$job_name'"
    set_schedule
  else
    listed_timer=$( cat $configfile | yq ".jobs[$jci].schedule.timer" )
    # Check if timer is listed in the configfile
    if [[ ($listed_timer == 'null') || ($listed_timer == '') ]]; then
      echo "Scheduling $job_name"
      set_schedule
    else 
      # Check if Existing timer is active
      active_timer=$( systemctl list-timers --user | grep "$listed_timer" )
      if [[ ($active_timer == 'null') || ($active_timer == '') ]]; then
        echo "Creating new schedule for $job_name"
        set_schedule
      else
        freq_check=$(cat "$systemd_t_timer_path/$listed_timer" | grep "$job_freq" )
        # Check if timer frequency matches parameters in configfile
        # if not, delete and schedule a new timer
        if [[ ($freq_check == 'null') || ($freq_check == '') ]]; then
          systemctl --user stop "$listed_timer"
          echo "Updating schedule frequency for $job_name"
          set_schedule
        else
          timer_svc=$( echo $listed_timer | sed 's/timer/service/')
          svc_check=$(cat "$systemd_t_timer_path/$timer_svc" | grep "$job_cmd" )
          # Check if service execstart matches parameters in configfile
          # if not, delete and schedule a new timer
          if [[ ($svc_check == 'null') || ($svc_check == '') ]]; then
            systemctl --user stop "$listed_timer"
            echo "Updating schedule for $job_name"
            set_schedule
          fi
        fi
      fi
    fi
  fi
}

function error_exit () {
  job_err=$1
  err_param=$2
  RED='\033[1;31m'
  YELLOW='\033[1;33m'
  echo -e "${RED}Error at Job: ${YELLOW}$job_err${RED} - Parameter: ${YELLOW}$err_param"
  exit 1
}

function set_schedule (){
  systemd-run --user --on-calendar "$job_freq" bash -c "$job_cmd"
  timers=($( ls $systemd_t_timer_path | grep "run-" ))
  for timer in "${timers[@]}"; do
    timer_check=$(cat "$systemd_t_timer_path/$timer" | grep "$job_cmd" )
    if [[ ( $timer_check == 'null' ) || ( $timer_check == '' ) ]]; then
      continue
    else
      timer=$( echo $timer | sed 's/service/timer/')
      ttcheck=$( systemctl --user list-timers | grep "$timer" )
      if [[ ( $ttcheck == 'null' ) || ( $ttcheck == '' ) ]]; then
        timer=''
        continue
      else 
        yq -i ".jobs[$jci].schedule.modified = \"$now\"" $configfile
        yq -i ".jobs[$jci].schedule.timer = \"$timer\"" $configfile
        echo "Sucessfully created service for $job_name"
        break
      fi
    fi
  done
  if [[ ( $timer == 'null' ) || ( $timer == '' ) ]]; then
    error_exit $job_name SCHEDULING
  fi
}
function set_job () {
  check_schedule
}
function test_local_path () {
  local_path=$(stat $1 2> /dev/null)
  if [[ ( $local_path == 'null' ) || ( $local_path == '' ) ]]; then
    error_exit "$job_name - Local path '$1' does not exist!" PATH
  else
    return 0
  fi
}
function validate_job () {
  validate_name
  # Validate Frequency with timekeeper.sh
  source "${config_folder}/timekeeper.sh"
  validate_command
}

function validate_command () {
  cmd=$(cat $configfile | yq ".jobs[$jci].parameters.command")
  if [[ ( $cmd == 'null' ) || ( $cmd == '' ) ]]; then
    error_exit "$job_name - Command not Set, Exiting!"
  fi
}

function validate_name () {
  job_name=$(cat $configfile | yq ".jobs[$jci].name")
  if [[ ( $job_name == 'null' ) || ( $job_name == '' ) ]]; then
    num=$((jci+1))
    error_exit "#$num is missing required parameter" "Name"
  fi
}

#########################
#       Variables
#########################
config_folder="$HOME/bss"
configfile="${config_folder}/backups.yaml"

# Dynamic Variables
now=$(date)
job_count=$(cat $configfile | yq '.jobs | length')
user_id=$(id -u $(whoami))
systemd_t_timer_path="/run/user/${user_id}/systemd/transient"
# Job Count Iterator 
jci=0

#########################
#     Program Start
#########################

# TODO: Version Check

echo "BSS Started processing jobs for $(whoami) at $(date)"

# Loop through all the jobs
while [[ $jci < $job_count ]]; do
  # Job Variables
  job_freq=''
  job_freq_type=''
  job_name=''
  job_src=''
  job_src_name=''
  job_dest=''
  job_dest_name=''
  job_cmd=''
  # Validate inputs and assign variables
  validate_job
  # Schedule job if it doesn't exist and hasn't changed
  set_job
  # Increase counter by 1
  ((jci++))
done

echo "BSS Finished processing jobs for $(whoami) at $(date)"
