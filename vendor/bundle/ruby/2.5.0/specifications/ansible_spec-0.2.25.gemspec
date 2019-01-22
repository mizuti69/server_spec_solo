# -*- encoding: utf-8 -*-
# stub: ansible_spec 0.2.25 ruby lib

Gem::Specification.new do |s|
  s.name = "ansible_spec".freeze
  s.version = "0.2.25"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["volanja".freeze]
  s.date = "2018-08-26"
  s.description = "Ansible Config Parser for Serverspec. Run test Multi Role and Multi Host by Ansible Configuration".freeze
  s.email = ["volaaanja@gmail.com".freeze]
  s.executables = ["ansiblespec-init".freeze]
  s.files = ["bin/ansiblespec-init".freeze]
  s.homepage = "https://github.com/volanja/ansible_spec".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Ansible Config Parser for Serverspec. Run test Multi Role and Multi Host by Ansible Configuration".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<diff-lcs>.freeze, [">= 0"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<serverspec>.freeze, [">= 2.0.0"])
      s.add_runtime_dependency(%q<hostlist_expression>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<oj>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<winrm>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<inifile>.freeze, [">= 0"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<diff-lcs>.freeze, [">= 0"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_dependency(%q<serverspec>.freeze, [">= 2.0.0"])
      s.add_dependency(%q<hostlist_expression>.freeze, [">= 0"])
      s.add_dependency(%q<oj>.freeze, [">= 0"])
      s.add_dependency(%q<winrm>.freeze, [">= 0"])
      s.add_dependency(%q<inifile>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<diff-lcs>.freeze, [">= 0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<serverspec>.freeze, [">= 2.0.0"])
    s.add_dependency(%q<hostlist_expression>.freeze, [">= 0"])
    s.add_dependency(%q<oj>.freeze, [">= 0"])
    s.add_dependency(%q<winrm>.freeze, [">= 0"])
    s.add_dependency(%q<inifile>.freeze, [">= 0"])
  end
end
