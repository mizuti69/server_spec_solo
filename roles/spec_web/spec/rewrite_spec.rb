require 'spec_helper'

# apache rewrite checke spec
describe 'redirect check' do
  property['apache_rewrite_rule'].each do |url|
    describe command("curl -I #{url['from']}") do
        its(:stdout) { should match /#{Regexp.escape("HTTP/1.1 #{url['status']}")}/ }
        its(:stdout) { should match "^Location: #{url['to']}" }
    end
  end
end
