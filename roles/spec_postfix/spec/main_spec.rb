require 'spec_helper'

# postfix setting check
describe 'postfix setting' do
  describe package('postfix') do
    it { should be_installed }
    describe service('postfix') do
      it { should be_enabled }
      it { should be_running }
      # active only test (not good)
      status = Specinfra.backend.run_command("systemctl status postfix |awk '/Active/{print $2}'")
      if status.stdout == "active\n"
        describe file('/usr/sbin/sendmail.postfix') do
          it { should exist }
        end
        describe command("postconf") do
          its(:stdout) { should match "myhostname = #{property['postfix_myhostname']}" }
          its(:stdout) { should match "mydomain = #{property['postfix_mydomain']}" }
          its(:stdout) { should match Regexp.escape("mydestination = #{property['postfix_mydestination']}") }
          its(:stdout) { should match Regexp.escape("smtp_helo_name = #{property['postfix_heloname']}") }
          its(:stdout) { should match "disable_vrfy_command = #{property['postfix_vrfy_command']}" }
          its(:stdout) { should match "mail_name = #{property['postfix_mailname']}" }
          its(:stdout) { should match "smtpd_helo_required = #{property['postfix_helo_required']}" }
          its(:stdout) { should match "smtpd_helo_restrictions = #{property['postfix_help_restrictions']}" }
          its(:stdout) { should match "smtpd_recipient_restrictions = #{property['postfix_recipient_restrictions']}" }
          its(:stdout) { should match "smtpd_client_restrictions = #{property['postfix_client_restrictions']}" }
          its(:stdout) { should match "smtpd_sender_restrictions = #{property['postfix_sender_restrictions']}" }
          its(:stdout) { should match "smtpd_etrn_restrictions = #{property['postfix_etrn_restrictions']}" }
          its(:stdout) { should match Regexp.escape("mynetworks = #{property['postfix_mynetwork']}") }
          its(:stdout) { should match "inet_interfaces = #{property['postfix_inetinterfaces']}" }
          its(:stdout) { should match Regexp.escape("header_checks = #{property['postfix_header_checks']}") }
          its(:stdout) { should match "allow_min_user = #{property['postfix_min_user']}" }
          its(:stdout) { should match "strict_rfc821_envelopes = #{property['postfix_rfc821_envelopes']}" }
        end
        describe file('/etc/postfix/header_checks') do
          its(:content) { should match Regexp.escape('/(^Received:.*) \[[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\](.*)/ REPLACE $1$2') }
        end
        # test is host wnvironment switch
        # sender
        if "#{property['postfix_host_type']}" == 'server'
          describe command("postconf") do
            its(:stdout) { should match "sender_canonical_classes = #{property['postfix_canonical_classes']}" }
            its(:stdout) { should match Regexp.escape("sender_canonical_maps = #{property['postfix_canonical_maps']}") }
          end
        end
        # client
        if "#{property['postfix_host_type']}" == 'client'
          describe command("postconf") do
            its(:stdout) { should match Regexp.escape("relayhost = #{property['postfix_relayhost']}") }
            its(:stdout) { should match Regexp.escape("fallback_relay = #{property['postfix_fallback_relay']}") }
            its(:stdout) { should match Regexp.escape("fallback_transport = smtp: #{property['postfix_fallback_relay']}") }
          end
        end
      end
    end
    describe port(25) do
      it { should be_listening.with('tcp') }
    end
  end
end
