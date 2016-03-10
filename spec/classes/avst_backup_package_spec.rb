require 'spec_helper'

describe 'avst_backup::package', :type => 'class' do

  context "Should install avst_backup package" do
    it do
      should contain_package('avst-backup').with(
      'ensure'      => 'latest',
      'provider'    => 'gem',
      'source'      => "http://gems.adaptavist.com",
      )
    end
  end

  context "Should avst_backup package from custom source" do
    let(:params) { {:package_source_repo => "avst.repo.com"} }

    it do
      should contain_package('avst-backup').with(
          'ensure' => 'latest',
          'provider' => 'gem',
          'source' => "avst.repo.com",
        )
    end
  end

end
