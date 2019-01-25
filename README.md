# server spec
This is an infrastructure test for redhat7 / centos7

## How to Use

### Step 0
Please install ruby on the execution server  
& Setting ssh key authentication to test server  

### Step 1
Clone spec

```
$ git clone -b develop https://github.com/mizuti69/server_spec_solo.git 
```

setup  

```
$ bundle install --path vendor/bundle
```

### Step2
Definition of target, environment definition  

**environment**  

```
$ vim .ansiblespec
---
-
  # production
  #playbook: production.yml
  #inventory: hosts/production
  #vars_dirs_path: .

  # stage
  #playbook: stage.yml
  #inventory: hosts/stage
  #vars_dirs_path: .

  # develop
  playbook: develop.yml
  inventory: hosts/develop
  vars_dirs_path: .
```

**servers**  

```
$ vim hosts/develop
[devwebservers]
localhost ansible_connection=local
test01    ansible_connection=ssh ansible_ssh_host=10.128.56.88

[devdbservers]

[develop:children]
devwebservers
```

**executable file**  

```
$ vim develop.yml
---
# [Develop]
- name: Basic-Test
  hosts: develop
  roles:
    - spec_basic

- name: Basic-Os-Test
  hosts: develop
  roles:
    - basic_os
```

### Step3
Adjust test case to run  
Write test case in `spec`  
`vars` is a file that defines the desired test results  

```
/opt/spec.test/roles
|--basic_os
|  |--spec
|  |  |--os_setting_spec.rb
|  |--vars
|  |  |--main.yml
|--spec_basic
|  |--spec
|  |  |--server_spec.rb
|  |--vars
|  |  |--main.yml
```

Add, change test cases, change variables according to the test object  

### Step4
Run test

```
$ bundle exec rake -T
rake all                       # Run serverspec to all test
rake serverspec:Basic-Os-Test  # Run serverspec for Basic-Os-Test
rake serverspec:Basic-Test     # Run serverspec for Basic-Test

$ SSH_CONFIG_FILE=.ssh/config bundle exec rake all
```

reference:  
* https://serverspec.org/  
* https://github.com/volanja/ansible_spec  
* https://mizuti69.github.io/book_configure_centos7/  

