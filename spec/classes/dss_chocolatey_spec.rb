require 'spec_helper'

describe 'dss_chocolatey' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'class chocolatey ($chocolatey_download_url, $use_7zip, $choco_install_timeout_seconds) {}' }

      it { is_expected.to compile }
    end
  end
end
