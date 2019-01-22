# -*- encoding: utf-8 -*-
# stub: hostlist_expression 0.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "hostlist_expression".freeze
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Daniel Schroeder".freeze]
  s.date = "2014-12-24"
  s.description = "Expand hostlist expression like those defined in pdsh or Ansible inventory files.\n  \nAn expression like \"host-[1-3].com\" will expand into an array containing the elements host-1.com, host-2.com and host-3.com\n\nSee https://github.com/udondan/hostlist_expression-ruby for documentation\n".freeze
  s.email = "daniel@phatthanan.com".freeze
  s.homepage = "https://github.com/udondan/hostlist_expression-ruby".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Expand hostlist expression".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version
end
