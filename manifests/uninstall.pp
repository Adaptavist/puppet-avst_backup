# = Class: avst_backup::uninstall
#
class avst_backup::uninstall {
    package {
        'avst-backup':
            ensure   => absent,
            provider => gem,
    }
}