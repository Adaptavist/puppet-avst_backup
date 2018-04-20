# = Class: avst_backup
#
class avst_backup(
    $ensure            = 'present',
    $backup_filesystem = true,
    $backup_database   = true,
    $backup_svn        = true,
    $backup_ldap       = true,
    $backup_hiera      = false,
    $backup_yaml       = false,
    $manage_repo       = 'false',
    $wrapper_script    = '/usr/local/bin/avst-backup-wrapper',
    ) {
    case $ensure {
        'present': {
          # ensure the wrapper file exists, the wrapper deals with setting up the rvm environment
          file { $wrapper_script:
            ensure => 'present',
            mode   => '0755',
            source => "puppet:///modules/${module_name}/avst-backup-wrapper",
          }

          anchor { 'avst_backup::begin': }
          -> class { 'avst_backup::package': }
          -> class { 'avst_backup::database': }
          -> class { 'avst_backup::svn': }
          -> class { 'avst_backup::ldap': }
          -> class { 'avst_backup::filesystem': }
          -> class { 'avst_backup::hiera': }
          -> class { 'avst_backup::yaml': }
          -> anchor { 'avst_backup::end': }
        }
        'absent': {
          class { 'avst_backup::uninstall': }
        }
        default: {
          fail("${ensure} is not supported for ensure.
            Allowed values are 'present' and 'absent'.")
        }
      }

}