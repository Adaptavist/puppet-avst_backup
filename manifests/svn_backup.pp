define avst_backup::svn_backup(
  $from_server,
  $backup_user,
  $backup_user_private_key_path,
  $repo_name,
  $repo_path,
  $from_path,
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
    $cron_command="${wrapper} ${from_server} backup_subversion --use_hiera false \
        --to_path ${to_path} \
        --from_path ${from_path} \
        --from_server ${from_server} \
        --backup_user ${backup_user} \
        --repo_name ${repo_name} \
        --repo_path ${repo_path} \
        --backup_user_private_key_path ${backup_user_private_key_path} \
        --timestamped_backups ${timestamped_backups} ${label_setup}"

    cron {
      "backup_svn_${name}_cronjob":
        ensure   => $ensure,
        command  => $cron_command,
        user     => $cron_user,
        month    => $month,
        monthday => $monthday,
        hour     => $hour,
        minute   => $minute,
    }
}
