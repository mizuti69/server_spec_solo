require 'spec_helper'

describe 'apache setting' do
  describe package('httpd') do
    it { should be_installed }
    it { should be_installed.with_version("#{property['apache_version']}") }
    describe service('httpd') do
      it { should be_enabled }
      it { should be_running }
      # active only test (not good)
      status = Specinfra.backend.run_command("systemctl status httpd |awk '/Active/{print $2}'")
      if status.stdout == "active\n"
        describe command("httpd -V") do
          its(:stdout) { should contain("#{property['apache_mpm']}").after('Server MPM') }
        end
        # include confs
        property['apache_include_conf'].each do |configs|
          describe file("#{configs}") do
            it { should exist }
          end
        end
        property['apache_listen_ports'].each do |ports|
          describe port("#{ports}") do
            it { should be_listening.with('tcp') }
          end
        end
      end
    end
    property['apache_sub_packages'].each do |packages|
      describe package("#{packages}") do
        it { should be_installed }
      end
    end
  end
end
