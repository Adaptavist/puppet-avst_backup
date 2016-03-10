require 'spec_helper'
 
describe 'avst_backup', :type => 'class' do
  
  real_user = 'restore_user'
  backup_access_group = 'staff'
  context "Should setup system as restore" do
    let(:params) { {:backup_yaml => "true"} }
    it do
      should contain_file('/etc/puppet/files/avst_backup/keys/backup').with(
        'ensure' => 'directory',
        'owner'  => real_user,
        'group'  => backup_access_group,
        'mode'   => '0600',
      )
      should contain_file('/etc/puppet/files/avst_backup/keys/backup/id_rsa').with(
        'ensure' => 'file',
        'owner'  => real_user,
        'group'  => backup_access_group,
        'mode'   => '0600',
      )
      should contain_package('at')
      should contain_service('atd').with_ensure('running')

      should contain_file('/tmp/run_restore.sh').with(
        'ensure'  => 'file',
      )
      
      should contain_exec('execute_avst_backup_command_based_on_yaml_config').with(
        'command'   => 'at -f /tmp/run_restore.sh now'
      )
    end
  end

end
