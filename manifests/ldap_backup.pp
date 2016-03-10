define avst_backup::ldap_backup(
  $from_server,
  $backup_user,
  $backup_user_private_key_path,
  $ldap_databases,
  $gpg_key,
  $gpg_command,
  $ldap_backup_command,
  $ldap_backup_secret_command,
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
    $cron_command="${wrapper} ${from_server} backup_ldap --use_hiera false \
      --to_path ${to_path} \
      --from_path ${from_path} \
      --from_server ${from_server} \
      --backup_user ${backup_user} \
      --ldap_databases ${ldap_databases} \
      --gpg_key ${gpg_key} \
      --gpg_command ${gpg_command} \
      --ldap_backup_command ${ldap_backup_command} \
      --ldap_backup_secret_command ${ldap_backup_secret_command} \
      --timestamped_backups ${timestamped_backups} \
      --backup_user_private_key_path ${backup_user_private_key_path} ${label_setup}"

    cron {
      "backup_ldap_${name}_cronjob":
        ensure   => $ensure,
        command  => $cron_command,
        user     => $cron_user,
        month    => $month,
        monthday => $monthday,
        hour     => $hour,
        minute   => $minute,
    }
}
