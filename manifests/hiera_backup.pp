define avst_backup::hiera_backup(
  $ensure           = 'present',
  $hiera_config     = {},
  $backup_commands  = undef,
  $hiera_datadir    = $avst_backup::hiera::config_dir,
  $wrapper          = $avst_backup::wrapper_script,
  $timestamp_format = undef,
  $label            = undef,
  $month            = '*',
  $monthday         = '*',
  $hour             = 12,
  $minute           = 1,
  $cron_user        = 'root',
  $create_cron      = 'false',
  $run_now          = 'false',
  $cron_command     = 'false',
  ) {

  $label_setup = $label ? {
    undef   => '',
    default => "--label ${label}"
  }

  $hiera_datadir_flag = $hiera_datadir ? {
    undef   => '',
    default => "--hiera_datadir \"${hiera_datadir}\""
  }

  $timestamp_format_flag = $timestamp_format ? {
    undef   => '',
    default => "--timestamp_format \"${timestamp_format}\""
  }

  $delete_unmanaged_configs_bool = str2bool($avst_backup::hiera::delete_unmanaged_configs)
  
  # endure the config directory exists
  if !defined(File[$hiera_datadir]) {
    file { $hiera_datadir:
      ensure  => 'directory',
      purge   => $delete_unmanaged_configs_bool,
      recurse => $delete_unmanaged_configs_bool,
    }
  }

  # crete a hiera config file for this job, the template just converts the hiera_config hash back into YAML
  file { "${hiera_datadir}/${name}.yaml":
    ensure  => 'present',
    content => template("${module_name}/yaml_config.erb"),
    require => File[$hiera_datadir]
  }

  if ( $cron_command == 'false' or $cron_command == false ) {
    $run_command="${wrapper} ${name} \"${backup_commands}\" ${hiera_datadir_flag} ${timestamp_format_flag}"
  }
  else {
    $run_command = $cron_command
  }

  # if this job is set to run as a cron and hiera jobs are not set to run as one create the cron job
  if ( !str2bool($avst_backup::hiera::run_as_one_job) or str2bool($create_cron) ) {
    cron {
      "backup_hiera_${name}_cronjob":
        ensure   => $ensure,
        command  => $run_command,
        user     => $cron_user,
        month    => $month,
        monthday => $monthday,
        hour     => $hour,
        minute   => $minute,
    }
  }
  # if not ensure the cron is absent
  elsif (str2bool($run_now)) {
    exec { 'run_avst_backup':
            command   => "at now (${run_command})",
            logoutput => on_failure,
    }
  }
}
