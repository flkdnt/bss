# Files 

## scheduler.sh

The Scheduler is run by bss.service to validate the configuration file, and then create or modify any existing timers.

## timekeeper.sh 

Timekeeper is a time-unit conversion script to convert all inputs into systemd calendar events. this is sourced into scheduler.sh

# Template files

These files are templates that are modified during install

## bss.service

This installs a USER systemd service at ??????

## bss.timer

This installs a USER systemd service timer at ??????
