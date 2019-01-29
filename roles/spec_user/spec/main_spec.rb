require 'spec_helper'

# group exist check
describe 'group check' do
  property['group'].each do |groups|
    describe group("#{groups['name']}") do
      it { should exist }
      it { should have_gid "#{groups['gid']}" }
    end
  end
end

# user exist check
# not good catn't user sub group check
describe 'group check' do
  #p property['user']
  property['user'].each do |users|
  #p "#{users}"
  #p "#{users['sgid']}"
  #p "#{users['sgid'][0]}"
    describe user("#{users['name']}") do
      it { should exist }
      it { should have_uid "#{users['uid']}" }
    end
    #"#{users['sgid']}".each do |sgids|
    #  p "#{sgids}"
    #end
  end
end

