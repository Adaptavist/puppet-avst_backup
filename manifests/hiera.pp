# = Class: avst_backup::hiera
#
class avst_backup::hiera(
    $backup_hiera             = $avst_backup::backup_hiera,
    $config_dir               = '/etc/avst-backup',
    $hiera_backup_setup       = {},
    $run_as_one_job           = 'false',
    $wrapper                  = $avst_backup::wrapper_script,
    $job_runner_script        = '/usr/local/bin/avst-backup-runner.sh',
    $job_runner_pause         = '/usr/local/bin/pause-backups',
    $job_runner_resume        = '/usr/local/bin/resume-backups',
    $job_filter               = 'find $CONFIG_DIR -type f \( -name \*.yaml -o -name \*.eyaml \) -a  ! -name hiera.\*yaml',
    $month                    = '*',
    $monthday                 = '*',
    $hour                     = 12,
    $minute                   = 1,
    $cron_user                = 'root',
    $job_failure_email        = 'false',
    $job_log_file             = 'false',
    $rotate_logs              = 'false',
    $rotate_logs_period       = 'weekly',
    $rotate_logs_compress     = 'true',
    $rotate_logs_keep         = 4,
    $rotate_logs_filter       = 'false',
    $logrotate_config_file    = '/etc/logrotate.d/avst-backup',
    $delete_unmanaged_configs = 'false',
    $runner_script_template   = "${module_name}/job_runner.erb",
    $runner_pause_template    = "${module_name}/pause-backups.erb",
    $runner_resume_template   = "${module_name}/resume-backups.erb",
    ) {

    $run_as_one_job_bool = str2bool($run_as_one_job)
    $delete_unmanaged_configs_bool = str2bool($delete_unmanaged_configs)
    # endure the config directory exists
    file { $config_dir:
        ensure  => 'directory',
        purge   => $delete_unmanaged_configs_bool,
        recurse => $delete_unmanaged_configs_bool,
    }

    if str2bool($backup_hiera){
        validate_hash($hiera_backup_setup)
        create_resources(avst_backup::hiera_backup, $hiera_backup_setup)
    }

    # if we are running all the hiera jobs in one cron, create it
    if ( $run_as_one_job_bool ) {

        # work out if we are using job alert emails
        if ($job_failure_email != 'false' and $job_failure_email != false) {
            $real_job_failure_email = $job_failure_email
        } else {
            $real_job_failure_email = undef
        }

        # work out if we are using job logs
        if ($job_log_file != 'false' and $job_log_file != false) {
            $real_job_log_file = $job_log_file
        } else {
            $real_job_log_file = undef
        }

        # ensure the job runner script exists, the runner deals with running multiple jobs
        file { $job_runner_script:
            ensure  => 'present',
            mode    => '0755',
            content => template($runner_script_template),
        }

        # ensure the job runner stop script exists
        file { $job_runner_pause:
            ensure  => 'present',
            mode    => '0755',
            content => template($runner_pause_template),
        }

        # ensure the job runner resume script exists
        file { $job_runner_resume:
            ensure  => 'present',
            mode    => '0755',
            content => template($runner_resume_template),
        }

        cron {
            'backup_hiera_jobrunner_cronjob':
                ensure   => 'present',
                command  => $job_runner_script,
                user     => $cron_user,
                month    => $month,
                monthday => $monthday,
                hour     => $hour,
                minute   => $minute,
        }

        # if a log file is defined and log rotation is enabled create an logrotate config
        if ( $real_job_log_file and str2bool($rotate_logs) ) {
            if (str2bool($rotate_logs_filter) and str2bool($rotate_logs_filter)) {
                $real_rotate_logs_filter = $rotate_logs_filter
            } else {
                $real_rotate_logs_filter = $real_job_log_file
            }

            file { $logrotate_config_file:
                ensure  => file,
                content => template("${module_name}/avst-backup-logrotate.erb"),
                owner   => 'root',
                group   => 'root',
                mode    => '0644',
            }
        }
        else {
            file { $logrotate_config_file:
                ensure  => 'absent',
            }
        }
    }
    # if not ensure the cron is absent
    else {
        cron {
            'backup_hiera_jobrunner_cronjob':
                ensure   => 'absent',
        }
    }
}
