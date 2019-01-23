require 'spec_helper'

describe 'Network Parameter Test' do
  # networkmanager enable check
  describe 'NetworkManager use' do
    describe package('NetworkManager') do
      it { should be_installed }
    end
    describe service('NetworkManager') do
      it { should be_enabled }
      it { should be_running }
    end
  end
  
  # networkinterface up check
  property['system_interface'].each do |interfaces|
    describe interface("#{interfaces}") do
      it { should be_up }
    end
  end

  # networkinterface method check
  property['system_interface'].each do |interfaces|
    describe command("nmcli -p c show #{interfaces} |grep ipv4.method |awk '{print $2}'") do
      its(:stdout) { should match property['system_interface_ipv4method'] }
    end
    describe command("nmcli -p c show #{interfaces} |grep ipv6.method |awk '{print $2}'") do
      its(:stdout) { should match property['system_interface_ipv6method'] }
    end
  end

  # name resolution check
  property['system_resolve'].each do |resolver|
    describe file("/etc/resolv.conf") do
      its(:content) { should match "#{resolver}" }
    end
    describe command("dig google.com @#{resolver}") do
      its(:exit_status) { should eq 0 }
    end
  end

  # kernel parameter check
  describe 'linux kernel parameters' do
    context linux_kernel_parameter('net.ipv6.conf.all.disable_ipv6') do
      its(:value) { should eq property['system_kernel_disable_ipv6']}
    end
    context linux_kernel_parameter('net.ipv6.conf.default.disable_ipv6') do
      its(:value) { should eq property['system_kernel_disable_ipv6']}
    end
    context linux_kernel_parameter('net.ipv4.icmp_echo_ignore_broadcasts') do
      its(:value) { should eq property['system_kernel_icmp_echo_ignore_broadcasts']}
    end
    context linux_kernel_parameter('net.ipv4.conf.all.accept_source_route') do
      its(:value) { should eq property['system_kernel_accept_source_route']}
    end
    context linux_kernel_parameter('net.ipv4.conf.default.rp_filter') do
      its(:value) { should eq property['system_kernel_rp_filter']}
    end
    context linux_kernel_parameter('net.ipv4.tcp_syncookies') do
      its(:value) { should eq property['system_kernel_tcp_syncookies']}
    end
    context linux_kernel_parameter('kernel.panic') do
      its(:value) { should eq property['system_kernel_panic']}
    end
  end
end

describe 'OS setting' do
  # boot mode
  describe command("systemctl get-default") do
    its(:stdout) { should match property['system_boot_mode'] }
  end

  # selinux check
  if property['system_selinux'] == 'disabled'
    describe selinux do
      it { should be_disabled }
    end
  else
    describe selinux do
      it { should be_enforcing }
    end
  end

  # os locale check
  describe file("/etc/locale.conf") do
    its(:content) { should match /^#{property['system_locale']}/ }
  end

  # os time zone check
  describe file("/etc/localtime") do
    its(:content) { should match /^#{property['system_time_zone']}/ }
  end

  # history customizee check
  describe file('/etc/profile.d/history.sh') do
    it { should exist }
    its(:content) { should match /HISTTIMEFORMAT=\'%Y\/%m\/%d %H:%M:%S \'/ }
  end

  # console customize check
  describe file('/etc/profile.d/ps1.sh') do
    it { should exist }
    its(:content) { should match /PS1=/ }
  end

  # systemd setting check
  describe file("/etc/systemd/system.conf") do
    its(:content) { should match /^#{property['system_systemd_loglevel']}/ }
  end
end

describe 'Cron setting' do
  describe file("/etc/anacrontab") do
    its(:content) { should match /^START_HOURS_RANGE=#{property['cron_anacron_range']}/ }
    its(:content) { should match /^MAILTO=root/ }
  end
=begin in comment
  describe file("/etc/crontab") do
    its(:content) { should match /^05 0 \* \* \* root run-parts \/etc\/cron.daily/ }
    its(:content) { should match /^25 0 \* \* 0 root run-parts \/etc\/cron.weekly/ }
    its(:content) { should match /^45 0 1 \* \* root run-parts \/etc\/cron.monthly/ }
    its(:content) { should match /^MAILTO=root/ }
  end
  describe file("/etc/cron.d/0hourly") do
    its(:content) { should match /^01 \* \* \* \* root run-parts \/etc\/cron.hourly/ }
    its(:content) { should match /^MAILTO=root/ }
  end
  describe file("/etc/cron.daily/0anacron") do
    it { should exist }
    it { should be_executable }
    its(:content) { should match /cron.daily/ }
  end
  describe file("/etc/cron.weekly/0anacron") do
    it { should exist }
    it { should be_executable }
    its(:content) { should match /cron.weekly/ }
  end
  describe file("/etc/cron.monthly/0anacron") do
    it { should exist }
    it { should be_executable }
    its(:content) { should match /cron.monthly/ }
  end
=end out comment
end

describe 'logrotate setting' do
  describe file("/etc/logrotate.conf") do
    its(:content) { should match /^#{property['logrotate_details']}/ }
    its(:content) { should match /^#{property['logrotate_backlogs']}/ }
    its(:content) { should match /^#{property['logrotate_suffix']}/ }
    its(:content) { should match /^#{property['logrotate_compressed']}/ }
  end
end
