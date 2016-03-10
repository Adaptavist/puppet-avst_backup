require 'spec_helper'
 
describe 'avst_backup', :type => 'class' do
    
  context "Should install avst_backup" do
    it do
      should contain_class('avst_backup::package').that_comes_before("Class[avst_backup::database]")
      should contain_class('avst_backup::database').that_comes_before("Class[avst_backup::svn]")
      should contain_class('avst_backup::svn').that_comes_before("Class[avst_backup::ldap]")
      should contain_class('avst_backup::ldap').that_comes_before("Class[avst_backup::filesystem]")
      should contain_class('avst_backup::filesystem').that_comes_before("Class[avst_backup::hiera]")
      should contain_class('avst_backup::yaml')
      should contain_class('avst_backup::hiera')
    end
  end

  context "Should uninstall avst_backup" do
    let(:params) { {:ensure => "absent"} }
    it do
      should_not contain_class('avst_backup::package')
      should_not contain_class('avst_backup::database')
      should_not contain_class('avst_backup::svn')
      should_not contain_class('avst_backup::yaml')
      should_not contain_class('avst_backup::ldap')
      should_not contain_class('avst_backup::filesystem')
      should_not contain_class('avst_backup::hiera')
      should contain_class('avst_backup::uninstall')
    end
  end

end
