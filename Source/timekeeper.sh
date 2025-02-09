#!/bin/bash
#######################################################
# Bash Systemd Scheduler(BSS) - Dante Foulke, 2023
#######################################################

function convert_time(){
  if [[ ( $job_freq_type == 'timestamp' ) ]]; then
    # Only Repeat tasks are supported ATT!
    echo "TimeStamps are not supported At This time, please use a Time-Span or Calendar event instead."
    error_exit $job_name FREQUENCY
  fi
  if [[ ( $job_freq_type == 'timespan' ) ]]; then
    year_code="*"
    month_code="*"
    day_code="*"
    hour_code="00"
    minute_code="00"
    # Calculating seconds is a waste of computing effort ATT
    human_time=$(systemd-analyze timespan "$job_freq" | grep Human | sed 's/.*Human: //')
    #echo "DEBUG convert_time: Specified Time - '${job_freq}' Human Time - '${human_time}'"
    if [[ "$human_time" =~ 'y' ]]; then
      if [[ "$human_time" =~ '1y' ]]; then
        continue
      else
        echo "Cannot Convert Year-based Timespans At This time"
        exit 1
        #year=$(echo "${human_time%%y*}")
        #year_code="0/${year}"
        #human_time=$(echo "${human_time##*y }")
      fi
    fi
    if [[ "$human_time" =~ 'month' ]]; then
      if [[ "$human_time" =~ '1month' ]]; then
        continue
      else
        echo "Cannot Convert Month-based Timespans At This time"
        exit 1
        #month=$(echo "${human_time%%month*}")
        #month_code="0/${month}"
        #human_time=$(echo "${human_time##*month }")
      fi
    fi
    if [[ "$human_time" =~ 'd' ]]; then
      if [[ "$human_time" =~ '1d' ]]; then
        continue
      else
        echo "Cannot Convert Day-based Timespans At This time"
        exit 1
        #day=$(echo "${human_time%%d*}")
        #day_code="0/${day}"
        #human_time=$(echo "${human_time##*d }")
      fi
    fi
    if [[ "$human_time" =~ 'h' ]]; then
      if [[ "$human_time" =~ '1h' ]]; then
        continue
      else
        hour=$(echo "${human_time%%h*}")
        hour_code="0/${hour}"
        human_time=$(echo "${human_time##*h }")
      fi
    fi
    if [[ "$human_time" =~ 'min' ]]; then 
      if [[ "$human_time" =~ '1min' ]]; then
        continue
      else
        min=$(echo "${human_time%%min*}")
        minute_code="0/${min}"
      fi
    fi
    job_freq="${year_code}-${month_code}-${day_code} ${hour_code}:${minute_code}:00"
    #echo "DEBUG convert_time: Converted Time - ${job_freq}"
  fi
}

# START
job_freq=$(cat $configfile | yq ".jobs[$jci].parameters.frequency")
if [[ ( $job_freq == 'null' ) || ( $job_freq == '' ) ]]; then
  yq -i ".jobs[$jci].parameters.frequency= \"daily\"" $configfile
  job_freq="daily"
fi
# Check if calendar event
valid_freq=$(systemd-analyze calendar "${job_freq}" 2> /dev/null)
if [[ ( $valid_freq == 'null' ) || ( $valid_freq == '' ) ]]; then
  # Check if timespan event
  valid_freq=$(systemd-analyze timespan "${job_freq}" 2> /dev/null)
  if [[ ( $valid_freq == 'null' ) || ( $valid_freq == '' ) ]]; then
    # Check if timestamp event
    valid_freq=$(systemd-analyze timestamp "${job_freq}" 2> /dev/null)
    if [[ ( $valid_freq == 'null' ) || ( $valid_freq == '' ) ]]; then
      error_exit $job_name Frequency
    else
      job_freq_type="timestamp"
      convert_time
    fi
  else
    job_freq_type="timespan"
    convert_time
  fi
else
  job_freq_type="calendar"
fi
