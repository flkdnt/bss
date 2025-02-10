# Bash SystemD Scheduler(BSS)

BSS is a simple job scheduler for Linux written in bash.

## Use-Cases

So, we have a scheduler, what can we do with it?

- Schedule per-directory backups using Rsync/Rclone/SCP, etc.
- Regulary update local git files
- Take a snapshot of a directory over time
- Anything else you can run via cli, whether a command or script

## How it works

1. Jobs are defined in a simple yaml configuration. 
2. The BSS service regularly check the configuration and creates user-level services and timers.
3. The systemd timers trigger the services and run the jobs.


# Documentation

## User Documentation

1. For instructions on how to Install BSS, see the [Installation Guide](Documentation/Install.md)

2. For instructions on how to use BSS, see the [User Guide](Documentation/UserGuide.md).

3. For information on the configuration file options, see the [YAML  Configuration Guide](Documentation/Configuration.md).

## Developer Documentation

For Detailed Developer Documentation, see the [Architecture Documentation](Documentation/Architecture.md)

## Open-Source Credits

BSS couldn't have been built without the following tools:

- [Bash](https://www.gnu.org/software/bash/)
- [systemd](https://systemd.io/)
- [yq](https://github.com/mikefarah/yq)

## Found a Bug? Have a Request? Want to get involved?

Please open a pull request or open a github issue if you want to contribute, thanks.
