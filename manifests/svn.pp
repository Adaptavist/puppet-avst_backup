# = Class: avst_backup::svn
#
class avst_backup::svn(
    $backup_svn = $avst_backup::backup_svn,
    $svn_repos_backup_setup = {},
    ) {

    if ($backup_svn == true){
        validate_hash($svn_repos_backup_setup)
        create_resources(avst_backup::svn_backup, $svn_repos_backup_setup)
    }
}
