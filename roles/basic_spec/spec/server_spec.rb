require 'spec_helper'

# cpu cores
describe command("cat /proc/stat |egrep -c '^cpu[0-9]'") do
  its(:stdout) { should match property['system_cpu_core']  }
end

# memory size
describe command("free -m |awk '/Mem/{print $2}'") do
  its('stdout.to_i') { should be >= property['system_memory_size'] }
end

# swap memory size
describe command("free -m |awk '/Swap/{print $2}'") do
  its('stdout.to_i') { should be >= property['system_swap_size'] }
end

# disk size /
describe command("df -h |awk '/\\/$/{print $2}' |cut -d '.' -f1") do
  its('stdout.to_i') { should be >= property['system_disk_size'] }
end

# os platform
if host_inventory['platform'] == 'redhat'
  describe file('/etc/redhat-release') do
  it { should contain property['system_platform'] }
  end
end

# os architecture
#describe command("uname -m") do
#  its(:stdout) { should match property['system_architecture_type'] }
#end

# os kernel version
describe command("uname -r") do
  its(:stdout) { should match property['system_kernel_version'] }
end

