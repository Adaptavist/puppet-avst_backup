require 'spec_helper'
 
describe 'avst_backup::uninstall', :type => 'class' do
    
  context "Should uninstall avst_backup package" do
    it do
      should contain_package('avst-backup').with(
      'ensure'      => 'absent',
      'provider'    => 'gem',
      )
    end
  end
end
