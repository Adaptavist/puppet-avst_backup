# Avst-backup Module

## Overview

The **Avst_backup** module handles the installation, running and configuration of 
the avst-backup application to provide backup of database, svn, ldap and filesystem.

The backups can be individual jobs per backup type (db, svn, ldap and filesystem)
which will be implemented as a cron calling avst-backup with command line arguments.
Alternativly jobs can be created that are controlled by hiera config files, this allows
for more complex backups that can perform multiple operations per host.

By default hiera based jobs will be run as individual crons (one per job), however it
is possible to have them all run as a single cron job.   This is controlled by the
`avst_backup::hiera::run_as_one_job` flag, this is set to **false** by default.  If set to true
the content of `avst_backup::hiera::config_dir` (which defaults to **/etc/avst-backup**) is purged 
before the hiera config files are generated, this ensures that only expected jobs are run.  
When using a single cron the jobs will be executed sequentially in directory order (the same as ls -U) 
which is filesystem specific.   

The hiera multi job runner script will output the avst-backup log only if an 
error is detected, the default mode is to display the log to stdout, however it is
possible to have these logs emailed somewhere, if the `avst_backup::hiera::job_failure_email` 
parameter is set (defaults to false) then the output will be emailed to the address(s) 
contained in the param if avst-backup errors.

The hiera multi job runner script is also capable of creating log files(s) for the jobs,
these log files are created no matter if the job succeeded or failed, it is also
possible to configure a logrotate job to manage the log files, by default logging is not enabled,
the following parameters control the logging configuration:

`avst_backup::hiera:job_log_file` - The destination of the job output logs, defaults to **false** which means there wil be no logging

`avst_backup::hiera:rotate_logs` - Flag to control if job output log(s) should be rotated, defaults to **false**

`avst_backup::hiera:rotate_logs_period` - How oftern the log(s) should be rotated, defaults to **weekly**

`avst_backup::hiera:rotate_logs_compress` - flag to control if rotated logs should be compressed ,defaults to **true**

`avst_backup::hiera:rotate_logs_keep` - The number of historic logs to keep ,defaults to **4**

`avst_backup::hiera:rotate_logs_filter` - The logrotate filter to use to identify the log(s) ,defaults to **false** and therefore the value of `avst_backup::hiera:job_log_file` will be used

`avst_backup::hiera:logrotate_config_file` - The name of the logrotate config file ,defaults to **/etc/logrotate.d/avst-backup**

Make sure that gem repo is available. Location can be customized by 
avst_backup::package::package_source_repo: "custom_url" 

#Hiera Examples:

This module is configured via Hiera.

```

# disable filesystem backups
avst_backup::backup_filesystem: 'false'

# disable svn backups
avst_backup::backup_svn: 'false'

# disable ldap backups
avst_backup::backup_ldap: 'false'

# configure a simple database backup cron
avst_backup::database::databases_backup_setup:
  'jira':
    database_name: 'jira'
    database_user: 'avstuser'
    database_pass: 'avstpass'
    from_server: 'avst-temp1.vagrant'
    backup_user: 'root'
    backup_user_private_key_path: '/tmp/id_rsa.pub'
    to_path: '/tmp/id_rsa.pub'

# enable "complex" hiera backups
avst_backup::backup_hiera: true

# configure "complex" backup job
avst_backup::hiera::run_as_one_job: true
avst_backup::hiera::hour: '02'
avst_backup::hiera::minute: '0'
avst_backup::hiera::job_failure_email: 'admin@example.com'
avst_backup::hiera::job_log_file: '/var/log/avst-backup/${JOB_NAME}.log'
avst_backup::hiera::rotate_logs: true
avst_backup::hiera::rotate_logs_filter: '/var/log/avst-backup/*.log'
avst_backup::hiera::hiera_backup_setup:
  jira-mirror:
    backup_commands: 'backup_database|backup_system'
    hour: '*/2'
    minute: '0'
    hiera_config:
      timestamp_format: "%Y%m%d-%H%M-%a-%d-%b"
      from_server: 'avst-temp1.vagrant'
      from_path:
        - '/home'
        - '/opt'
        - '/etc'
      to_path: '/data/backups'
      backup_user: 'backup-user'
      backup_user_private_key_path: '/home/backup-user/.ssh/id_rsa'
      timestamped_backups: true
      databases:
        - database_name: 'jira'
          database_user: 'avstuser'
          database_pass: 'avstpass'
          to_path: '/home/backup-user/database_backups'
          timestamped_backups: false
        - database_name: 'confluence'
          database_user: 'avstuser'
          database_pass: 'avstpass'
          to_path: '/home/backup-user/database_backups'
          timestamped_backups: false
        - database_name: 'crowd'
          database_user: 'avstuser'
          database_pass: 'avstpass'
          to_path: '/home/backup-user/database_backups'
          timestamped_backups: false
  fecru-mirror:
    backup_commands: 'backup_database|backup_system'
    hour: '*/2'
    minute: '0'
    hiera_config:
      timestamp_format: "%Y%m%d-%H%M-%a-%d-%b"
      from_server: 'avst-temp2.vagrant'
      from_path:
        - '/opt'
      to_path: '/data/backups'
      backup_user: 'backup-user'
      backup_user_private_key_path: '/home/backup-user/.ssh/id_rsa'
      timestamped_backups: true
      databases:
        - database_name: 'fecru'
          database_user: 'avstuser'
          database_pass: 'avstpass'
          to_path: '/home/backup-user/database_backups'
          timestamped_backups: false



```

## Dependencies

None
