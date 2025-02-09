## YAML Configuration File Documentation

## Configuration File Parameters and Options
| Parameter | Default Value | Required? | Description |
|-|-|-|-|
| name | NONE | YES | Unique name of job |
| parameters |-|-| Specifications for job |
| parameters.command |-| YES | FUll Command |
| parameters.frequency | `daily` | NO |  Frequency to run backup job. See [Systemd Time](SystemdTime.md) for details on Valid DateTime Formats |


## Configuration Example
```yaml
jobs:
  - name: testjob
    parameters:
      command: "ls -la /tmp"
      frequency: daily
```

### Note on Schedule section

In a live config, you'll see a Schedule sub-section. This is used by the scheduler to map the job to a running systemd timer/service and check that timer for changes. Any modification or deletion of this section will cause the scheduler to recreate systemd timers and possibly cause issues.

```yaml
jobs:
  - name: testjob
    parameters:
      command: "ls -la /tmp"
      frequency: daily
    schedule:
      modified: Thu May 23 03:47:26 AM EDT 2024
      timer: run-recefe7ab7126451db1903a9c60e1a1f4.timer
```
