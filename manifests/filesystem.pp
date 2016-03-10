# = Class: avst_backup::filesystem
#
class avst_backup::filesystem(
    $backup_filesystem = $avst_backup::backup_filesystem,
    $filesystem_backup_setup = {},
    ) {
    if ($backup_filesystem == true){
        validate_hash($filesystem_backup_setup)
        create_resources(avst_backup::filesystem_backup, $filesystem_backup_setup)
    }
}
