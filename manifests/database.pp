# = Class: avst_backup::database
#
class avst_backup::database(
    $backup_database = $avst_backup::backup_database,
    $databases_backup_setup = {},
    ) {

    if ($backup_database == true){
        validate_hash($databases_backup_setup)
        create_resources(avst_backup::database_backup, $databases_backup_setup)
    }
}
