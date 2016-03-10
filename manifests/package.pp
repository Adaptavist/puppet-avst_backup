# = Class: avst_backup::package
#
class avst_backup::package(
    $package_source_repo = 'http://gems.adaptavist.com',
    ) {
    
    package {'avst-backup':
            ensure   => 'latest',
            provider => 'gem',
            source   => $package_source_repo,
    }

}