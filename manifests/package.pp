# = Class: avst_backup::package
#
class avst_backup::package(
    $package_source_repo = 'http://gems.adaptavist.com',
    $package_ensure      = 'latest'
    ) {

    package {'avst-backup':
            ensure   => $package_ensure,
            provider => 'gem',
            source   => $package_source_repo,
    }

}
