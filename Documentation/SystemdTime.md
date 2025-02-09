# SystemD DateTime Formats

From the man page( `man 7 systemd.time`): 

> In systemd, timestamps, time spans, and calendar events are displayed and may be specified in closely related syntaxes.


## BSS and Systemd DateTime Formats
In Systemd, there are 3 types of datetime formats:

1. Timestamps - "Timestamps refer to specific, unique points in time."  
    - **Timestamps are not supported with BSS!**

2. Time Spans - "Time spans refer to time durations." 
    - **Only Timespan Hours and Minutes are supported with BSS!**

3. Calendar Events - "Calendar events may be used to refer to one or more points in time in a single expression."
    - **Calendar Events are the Preffered format for datetime in BSS!**

## Note on Accuracy for Systemd Timers

In SystemD, the default accuracy for a timer unit is 1 minute, and "The timer is scheduled to elapse within a time window starting with the time specified"(Man Page: `man 5 systemd.timer`). This is to help spread the load of automated tasks in systemd, but also means that, **by default**, sub-minute backup jobs are questionably effective, and at worst, can create conflict or overstepping. 

# Usage

## Time Spans

You can use `systemd-analyze timespan "TIMESPAN"` to validate timespans, but here are some examples of valid timespans to get you started:

- 2 h
- 2hours
- 2hour 10 min
- 4hr 15 m
- 48hr

## Calendar Events

**Note**: Special thanks to `Divyansh Tripathi` for this cheat sheet from their website: [silentlad.com](https://silentlad.com/systemd-timers-oncalendar-(cron)-format-explained)

You can use `systemd-analyze calendar "EVENT"` to validate calendar events, but here are some examples of valid calendar events to get you started:

| Description |Systemd timer|
|---|---|
|Every Minute|`*-*-* *:*:00`|
|Every 2 minute|`*-*-* *:*/2:00`|
|Every 5 minutes|`*-*-* *:*/5:00`|
|Every 15 minutes|`*-*-* *:*/15:00`|
|Every quarter hour|`*-*-* *:*/15:00`|
|Every 30 minutes|`*-*-* *:*/30:00`|
|Every half an hour|`*-*-* *:*/30:00`|
|Every 60 minutes|`*-*-* */1:00:00`|
|Every 1 hour|`*-*-* *:00:00`|
|Every 2 hour|`*-*-* */2:00:00`|
|Every 3 hour|`*-*-* */3:00:00`|
|Every other hour|`*-*-* */2:00:00`|
|Every 6 hour|`*-*-* */6:00:00`|
|Every 12 hour|`*-*-* */12:00:00`|
|Hour Range|`*-*-* 9-17:00:00`|
|Between certain hours|`*-*-* 9-17:00:00`|
|Every day|`*-*-* 00:00:00`|
|Daily|`*-*-* 00:00:00`|
|Once A day|`*-*-* 00:00:00`|
|Every Night|`*-*-* 01:00:00`|
|Every Day at 1am|`*-*-* 01:00:00`|
|Every day at 2am|`*-*-* 02:00:00`|
|Every morning|`*-*-* 07:00:00`|
|Every midnight|`*-*-* 00:00:00`|
|Every day at midnight|`*-*-* 00:00:00`|
|Every night at midnight|`*-*-* 00:00:00`|
|Every sunday|`Sun *-*-* 00:00:00`|
|Every friday|`Fri *-*-* 01:00:00`|
|Every friday at midnight|`Fri *-*-* 00:00:00`|
|Every saturday|`Sat *-*-* 00:00:00`|
|Every weekday|`Mon...Fri *-*-* 00:00:00`|
|weekdays only|`Mon...Fri *-*-* 00:00:00`|
|monday to friday|`Mon...Fri *-*-* 00:00:00`|
|Every weekend|`Sat,Sun *-*-* 00:00:00`|
|weekends only|`Sat,Sun *-*-* 00:00:00`|
|Every 7 days|`* *-*-* 00:00:00`|
|Every week|`Sun *-*-* 00:00:00`|
|weekly|`Sun *-*-* 00:00:00`|
|once a week|`Sun *-*-* 00:00:00`|
|Every month|`* *-*-01 00:00:00`|
|monthly|`* *-*-01 00:00:00`|
|once a month|`* *-*-01 00:00:00`|
|Every quarter|`* *-01,04,07,10-01 00:00:00`|
|Every 6 months|`* *-01,07-01 00:00:00`|
|Every year|`* *-01-01 00:00:00`|

### Calendar Event Examples from the Manual

| Example | Normalized Form |
| - | - |
| `Sat,Thu,Mon..Wed,Sat..Sun` | `Mon..Thu,Sat,Sun *-*-* 00:00:00`|
| `Mon,Sun 12-*-* 2,1:23`| `Mon,Sun 2012-*-* 01,02:23:00` |
| `Wed *-1` | `Wed *-*-01 00:00:00`|
| `Wed..Wed,Wed *-1`| `Wed *-*-01 00:00:00`|
| `Wed, 17:48` | `Wed *-*-* 17:48:00` |
| `Wed..Sat,Tue 12-10-15 1:2:3` | `Tue..Sat 2012-10-15 01:02:03` |
| `*-*-7 0:0:0`| `*-*-07 00:00:00` |
| `10-15` | `*-10-15 00:00:00`|
| `monday *-12-* 17:00`| `Mon *-12-* 17:00:00`|
| `Mon,Fri *-*-3,1,2 *:30:45` | `Mon,Fri *-*-01,02,03 *:30:45` |
| `12,14,13,12:20,10,30` | `*-*-* 12,13,14:10,20,30:00`|
| `12..14:10,20,30` | `*-*-* 12..14:10,20,30:00`|
| `mon,fri *-1/2-1,3 *:30:45` | `Mon,Fri *-01/2-01,03 *:30:45` |
| `03-05 08:05:40`| `*-03-05 08:05:40`|
| `08:05:40`| `*-*-* 08:05:40`|
| `05:40` | `*-*-* 05:40:00`|
| `Sat,Sun 12-05 08:05:40` | `Sat,Sun *-12-05 08:05:40`|
| `Sat,Sun 08:05:40`| `Sat,Sun *-*-* 08:05:40`|
| `2003-03-05 05:40`| `2003-03-05 05:40:00`|
| `05:40:23.4200004/3.1700005`| `*-*-* 05:40:23.420000/3.170001` |
| `2003-02..04-05`| `2003-02..04-05 00:00:00` |
| `2003-03-05 05:40 UTC` | `2003-03-05 05:40:00 UTC` |
| `2003-03-05` | `2003-03-05 00:00:00`|
| `03-05` | `*-03-05 00:00:00`|
| `hourly`| `*-*-* *:00:00` |
| `daily` | `*-*-* 00:00:00`|
| `daily UTC`| `*-*-* 00:00:00 UTC` |
| `monthly` | `*-*-01 00:00:00` |
| `weekly`| `Mon *-*-* 00:00:00` |
| `weekly Pacific/Auckland`| `Mon *-*-* 00:00:00 Pacific/Auckland` |
| `yearly`| `*-01-01 00:00:00`|
| `annually`| `*-01-01 00:00:00`|
| `*:2/3` | `*-*-* *:02/3:00` |
