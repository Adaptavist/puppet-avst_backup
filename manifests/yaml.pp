# = Class: avst_backup::yaml
#
class avst_backup::yaml(
    $backup_yaml          = $avst_backup::backup_yaml,
    $config_template_file = '/etc/puppet/files/avst_backup/restore.yaml',
    $config_template_json = '{}',
    $server_name          = 'hostname1',
    $backup_access_user   = 'restore_user',
    $backup_access_uid    = '',
    $backup_access_group  = 'staff',
    $backup_timestamp     = 'false',
    $backup_access_user_private_key_path = '/etc/puppet/files/avst_backup/keys/backup/id_rsa',
    $backup_access_user_private_key = 'key_content',
    $actions              = 'restore_filesystem|restore_database',
    $deps                 = 'Class[avstapp]',
    $report_state         = '',
    ) {
    if str2bool($backup_yaml) {
        $restore_command_json_params_json = parsejson($config_template_json)
        $restore_command_json_params = inline_template("<%= @restore_command_json_params_json['backup_user_private_key_path'] = @backup_access_user_private_key_path; @restore_command_json_params_json['backup_user'] = @backup_access_user; @restore_command_json_params_json['backup_timestamp']= (@backup_timestamp != '' and @backup_timestamp != 'false') ? @backup_timestamp : 'latest'; @restore_command_json_params_json.to_json %>")
        $restore_command="source /usr/local/rvm/scripts/rvm; avst-backup ${server_name} \"${actions}\" --custom_config_template_file=\"${config_template_file}\" --custom_config='${restore_command_json_params}' > /tmp/run_restore.log"
        $backup_access_user_private_key_folder = inline_template('<%= File.dirname(@backup_access_user_private_key_path) %>')
        if ($backup_access_uid and $backup_access_uid != ''){
            $real_user = $backup_access_uid
        } else {
            $real_user = $backup_access_user
        }

        package {
            'at':
                ensure => installed,
        } ->
        service {
            'atd':
                ensure => running,
                enable => true,
        } ->
        file { $backup_access_user_private_key_folder:
            ensure => directory,
            owner  => $real_user,
            group  => $backup_access_group,
            mode   => '0600',
        } ->
        file { $backup_access_user_private_key_path:
            ensure  => file,
            owner   => $real_user,
            content => $backup_access_user_private_key,
            group   => $backup_access_group,
            mode    => '0600',
        } ->
        file { '/tmp/run_restore.sh':
            ensure  => file,
            content => inline_template('<%= "#{@restore_command}\n#{@report_state}" %>'),
        } ->
        exec {
            'execute_avst_backup_command_based_on_yaml_config':
                command   => 'at -f /tmp/run_restore.sh now',
                logoutput => on_failure,
                onlyif    => ["test -f ${config_template_file}"],
                require   => $deps,
        }
    }
}
