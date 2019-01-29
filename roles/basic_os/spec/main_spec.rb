require 'spec_helper'

describe 'Network Parameter Test' do
  # networkmanager enable check
  describe package('NetworkManager') do
    it { should be_installed }
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
    describe command("nmcli -p c show #{interfaces} |grep connection.id |awk '{print $2}'") do
      its(:stdout) { should match "#{interfaces}" }
    end
  end

  # networkinterface method check
  property['system_interface'].each do |interfaces|
    describe command("nmcli -p c show #{interfaces} |grep ipv4.method |awk '{print $2}'") do
      its(:stdout) { should match property['system_interface_ipv4method'] }
      # static only test (not good) 
      status = Specinfra.backend.run_command("nmcli -p c show #{interfaces} |grep ipv4.method |awk '{print $2}'")
      if status.stdout == "manual\n"
        describe command("nmcli -p c show #{interfaces} |grep ipv4.addresses |awk '{print $2}'") do
          its(:stdout) { should match property['system_interface_ipv4address'] }
        end
      end
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
    its(:content) { should match "^#{property['system_locale']}" }
  end

  # os time zone check
  describe file("/etc/localtime") do
    its(:content) { should match "^#{property['system_time_zone']}" }
  end

  # history customizee check
  describe file('/etc/profile.d/history.sh') do
    it { should exist }
    its(:content) { should match Regexp.escape("HISTTIMEFORMAT='%Y/%m/%d %H:%M:%S '") }
  end

  # console customize check
  describe file('/etc/profile.d/ps1.sh') do
    it { should exist }
    its(:content) { should match /PS1=/ }
  end

  # systemd setting check
  describe file("/etc/systemd/system.conf") do
    its(:content) { should match "^#{property['system_systemd_loglevel']}" }
  end

  # os user home check
  describe file("/etc/default/useradd") do
    its(:content) { should match "^HOME=#{property['system_default_user_home']}" }
    describe file("#{property['system_default_user_home']}") do
      it { should be_directory }
    end
  end

  # os password setting check
  describe file("/etc/login.defs") do
    its(:content) { should match "^PASS_MIN_LEN #{property['system_default_pass_minlen']}" }
    its(:content) { should match "^SU_WHEEL_ONLY #{property['system_su_wheel']}" }
  end
  describe file("/etc/security/pwquality.conf") do
    its(:content) { should match "^minlen = #{property['system_default_pass_minlen']}" }
    its(:content) { should match "^dcredit = #{property['system_default_pass_dcredit']}" }
    its(:content) { should match "^ucredit = #{property['system_default_pass_ucredit']}" }
    its(:content) { should match "^lcredit = #{property['system_default_pass_lcredit']}" }
  end

  # pam setting check
  describe file("/etc/pam.d/system-auth-ac") do
    its(:content) { should match "^auth        required      #{property['system_pam_auth_lock']}" }
    its(:content) { should match /^#{Regexp.escape("auth        [default=die] #{property['system_pam_auth_die']}")}/ }
    its(:content) { should match "^account     required      #{property['system_pam_auth_faillock']}" }
    its(:content) { should match "^password    required      #{property['system_pam_auth_pwquality']}" }
  end
  describe file("/etc/pam.d/password-auth-ac") do
    its(:content) { should match "^auth        required      #{property['system_pam_auth_lock']}" }
    its(:content) { should match /^#{Regexp.escape("auth        [default=die] #{property['system_pam_auth_die']}")}/ }
    its(:content) { should match "^account     required      #{property['system_pam_auth_faillock']}" }
    its(:content) { should match "^password    required      #{property['system_pam_auth_pwquality']}" }
  end

  # su/sudo check
  # Modification and addition of test code is necessary according to the environment
  property['system_sudo_set'].each do |sudoers|
    describe file("#{sudoers}") do
      it { should exist }
=begin in comment
      status = Specinfra.backend.run_command("basename #{sudoers}")
      if status.stdout == "default\n"
        describe file("#{sudoers}") do
          its(:content) { should match "Defaults timestamp_timeout = #{property['system_sudo_default_timeout']}" }
          its(:content) { should match "Defaults passwd_tries = #{property['system_sudo_default_passtries']}" }
        end
      end
      status = Specinfra.backend.run_command("basename #{sudoers}")
      if status.stdout == "opegrp\n"
        describe file("#{sudoers}") do
          its(:content) { should match "#{property['system_sudo_opegrp_permit']}\n" }
        end
      end
=end out comment
    end
  end

  # yum setting check
  describe file("/etc/yum.conf") do
    its(:content) { should match "^exclude=#{property['system_yum_exclude']}" }
    its(:content) { should match "^keepcache=#{property['system_yum_keepcache']}" }
  end
=begin in comment
  describe file("/etc/yum.repos.d/epel.repo") do
    it { should exist }
    # active only test (not good)
    status = Specinfra.backend.run_command("stat /etc/yum.repos.d/epel.repo")
    if status.exit_status == 0
      describe command("yum-config-manager epel |grep enabled") do
        its(:stdout) { should match "^enabled = #{property['system_yum_epel_enable']}" }
      end
    end
  end  
  describe file("/etc/yum.repos.d/ius.repo") do
    it { should exist }
    # active only test (not good)
    status = Specinfra.backend.run_command("stat /etc/yum.repos.d/ius.repo")
    if status.exit_status == 0
      describe command("yum-config-manager ius |grep enabled") do
        its(:stdout) { should match "^enabled = #{property['system_yum_ius_enable']}" }
      end
    end
  end  
=end out comment

  # firewalld enable check
  describe package('firewalld') do
    it { should be_installed }
    describe service('firewalld') do
      it { should be_enabled }
      it { should be_running }
      # active only test (not good)
      status = Specinfra.backend.run_command("systemctl status firewalld |awk '/Active/{print $2}'")
      if status. == "active\n"
        property['system_interface'].each do |interfaces|
          describe command("nmcli -p c show #{interfaces} |grep connection.zone |awk '{print $2}'") do
            its(:stdout) { should match property['firewalld_zone'] }
          end
        end 
        describe command("firewall-cmd --query-lockdown") do
          its(:stdout) { should match property['firewalld_lockdown'] }
        end
      end
    end
  end
end

# audit setting check
describe 'Audit setting' do
  describe package('audit') do
    it { should be_installed }
    describe service('auditd') do
      it { should be_enabled }
      it { should be_running }
      # active only test (not good)
      status = Specinfra.backend.run_command("systemctl status auditd |awk '/Active/{print $2}'")
      if status.stdout == "active\n"
        describe file("/etc/audit/auditd.conf") do
          its(:content) { should match "^max_log_file = #{property['audit_max_logfile']}" }
          its(:content) { should match "^num_logs = #{property['audit_num_logs']}" }
        end
      end
    end
  end
end

# cron setting check
describe 'Cron setting' do
  describe file("/etc/anacrontab") do
    its(:content) { should match "^START_HOURS_RANGE=#{property['cron_anacron_range']}" }
    its(:content) { should match "^MAILTO=root" }
  end
=begin in comment
  describe file("/etc/crontab") do
    its(:content) { should match "^05 0 \* \* \* root run-parts \/etc\/cron.daily" }
    its(:content) { should match "^25 0 \* \* 0 root run-parts \/etc\/cron.weekly" }
    its(:content) { should match "^45 0 1 \* \* root run-parts \/etc\/cron.monthly" }
    its(:content) { should match "^MAILTO=root" }
  end
  describe file("/etc/cron.d/0hourly") do
    its(:content) { should match "^01 \* \* \* \* root run-parts \/etc\/cron.hourly" }
    its(:content) { should match "^MAILTO=root" }
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

# logrotate setting check
describe 'logrotate setting' do
  describe file("/etc/logrotate.conf") do
    its(:content) { should match "^#{property['logrotate_details']}" }
    its(:content) { should match "^#{property['logrotate_backlogs']}" }
    its(:content) { should match "^#{property['logrotate_suffix']}" }
    its(:content) { should match "^#{property['logrotate_compressed']}" }
  end
end

# ssh setting check
describe 'ssh setting' do
  describe service('sshd') do
    it { should be_enabled }
    it { should be_running }
  end
  describe file("/etc/ssh/sshd_config") do
    its(:content) { should match "^Port #{property['ssh_port']}" }
    its(:content) { should match "^PermitRootLogin #{property['ssh_permit_rootlogin']}" }
    its(:content) { should match "^PubkeyAuthentication #{property['ssh_pubkey_auth']}" }
    its(:content) { should match "^PasswordAuthentication #{property['ssh_password_auth']}" }
    its(:content) { should match "^ChallengeResponseAuthentication #{property['ssh_cr_auth']}" }
    its(:content) { should match "^UsePAM #{property['ssh_usedns']}" }
    its(:content) { should match "^Subsystem sftp #{property['ssh_subsystem']}" }
    its(:content) { should match "^AllowGroups #{property['ssh_allow_groups']}" }
  end
end

# chrony setting check
describe 'chrony setting' do
  describe package('chrony') do
    it { should be_installed }
    describe service('chronyd') do
      it { should be_enabled }
      it { should be_running }
      # active only test (not good)
      status = Specinfra.backend.run_command("systemctl status chronyd |awk '/Active/{print $2}'")
      if status.stdout == "active\n"
        describe command("timedatectl |awk -F\: '/NTP enabled/{print $2}'") do
          its(:stdout) { should match /yes/ }
        end
        describe file("/etc/chrony.conf") do
          its(:content) { should match "^port #{property['chrony_port']}" }
          its(:content) { should match "^leapsecmode #{property['chrony_leapsecmode']}" }
        end
        describe command("chronyc sources") do
          its(:stdout) { should match Regexp.escape("^* ") }
        end
      end
    end
  end
end

# sysstat setting check
describe 'sysstat setting' do
  describe package('sysstat') do
    it { should be_installed }
    describe service('sysstat') do
      it { should be_enabled }
      it { should be_running }
      # active only test (not good)
      status = Specinfra.backend.run_command("systemctl status sysstat |awk '/Active/{print $2}'")
      if status.stdout == "active\n"
        describe file('/etc/cron.d/sysstat') do
          its(:content) { should match /^#{Regexp.escape("*/5 * * * * root /usr/lib64/sa/sa1 1 1")}/ }
          its(:content) { should match /^#{Regexp.escape("58 23 * * * root /usr/lib64/sa/sa2 -A")}/ }
        end
        describe file('/etc/sysconfig/sysstat') do
          its(:content) { should match "^HISTORY=#{property['sysstat_history']}" }
        end
      end
    end
  end
end

# install tools check
describe 'install tools' do
  property['system_package_installs'].each do |packages|
    describe package("#{packages}") do
      it { should be_installed }
    end
  end
end

