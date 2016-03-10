define avst_backup::database_backup(
  $from_server,
  $backup_user,
  $backup_user_private_key_path,
  $database_name,
  $database_user,
  $database_pass,
  $to_path,
  $ensure                       = 'present',
  $label                        = undef,
  $timestamped_backups          = true,
  $month                        = '*',
  $monthday                     = '*',
  $hour                         = 12,
  $minute                       = 1,
  $wrapper                      = $avst_backup::wrapper_script,
  $cron_user                    = 'root',
  ) {
    $label_setup = $label ? {
      undef   => '',
      default => "--label ${label}"
    }
    $cron_command="${wrapper} ${from_server} backup_database --use_hiera false \
      --to_path ${to_path} \
      --from_server ${from_server} \
      --backup_user ${backup_user} \
      --database_name ${database_name} \
      --database_user ${database_user} \
      --database_pass ${database_pass} \
      --backup_user_private_key_path ${backup_user_private_key_path} \
      --timestamped_backups ${timestamped_backups} ${label_setup}"

    cron {
      "backup_database_${name}_cronjob":
        ensure   => $ensure,
        command  => $cron_command,
        user     => $cron_user,
        month    => $month,
        monthday => $monthday,
        hour     => $hour,
        minute   => $minute,
    }
  }
