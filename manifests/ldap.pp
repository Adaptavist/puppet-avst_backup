# = Class: avst_backup::ldap
#
class avst_backup::ldap(
    $backup_ldap = $avst_backup::backup_ldap,
    $ldap_backup_setup = {},
    ) {

    if ($backup_ldap == true){
        validate_hash($ldap_backup_setup)
        create_resources(avst_backup::ldap_backup, $ldap_backup_setup)
    }
}
