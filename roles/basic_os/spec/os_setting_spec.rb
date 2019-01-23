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
  end
end

describe 'OS setting' do
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

end
