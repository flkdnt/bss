# Using BSS

1. To create backup jobs, create (or edit an existing file) at `~/bss/backups.yaml`. 
    - See [Configuration](Configuration.md) to configure your own jobs.
    - See [Systemd Time](SystemdTime.md) for examples on how to specify time codes.

2. To manually run the bss scheduler, run `systemctl start bss-USERID.service --user`.
    - To fund your user id, run `id -u $(whoami)`

3. To check the status of the scheduler, run `systemctl status bss-USERID.service --user`
    - To fund your user id, run `id -u $(whoami)`
