Codeup PHP Ansible Role
=======================

[![Build Status](https://travis-ci.org/bbatsche/Ansible-Codeup-PHP-Role.svg?branch=master)](https://travis-ci.org/bbatsche/Ansible-Codeup-PHP-Role)

This is a light weight Ansible role for installing PHP and configuring a site with it in Nginx. It is primarily intended for [Codeup](http://codeup.com/) students. If you need more flexibility in setting up PHP, I would recommend you look at my [Ansible Phpenv Role](https://github.com/bbatsche/Ansible-Phpenv-Site-Role) instead of this one.

Role Variables
--------------

- `domain` &mdash; Site domain to be created
- `dynamic_php` &mdash; Whether or not Nginx should rewrite all requests on your site through `index.php`. This is used for most modern frameworks. Default is no
- `max_upload_size` &mdash; Maximum upload size in MB. Default is "10"
- `timezone` &mdash; Timezone that should be configured in PHP. Default is "Etc/UTC"
- `phpunit_version` &mdash; Version of [PHPUnit](https://phpunit.de/) to install with Composer. Default is "~4.8"
- `psysh_version` &mdash; Version of [PsySH](http://psysh.org/) to install with Composer. Default is "~0.7"
- `copy_index_php` &mdash; Whether to copy an `index.php` stub file to the new site. Default is no
- `enable_suhosin` &mdash; Whether or not to install and setup [Suhosin extension](https://suhosin.org/stories/index.html). Because this can interfere with some libraries, the default is no.
- `disabled_function` &mdash; A list of functions to disable when PHP is running from the web. The default value blocks functions that could be used to execute shell code or manipulate other processes on the server.
- `http_root` &mdash; Directory all sites will be created under. Default is "/srv/http"
- `storage_dir` &mdash; Directory on local machine to store generated configuration data. In particular, encryption keys for [Suhosin](https://suhosin.org/stories/index.html) will be stored locally so they can be safely reinserted for subsequent provisions.

Dependencies
------------

This role depends on bbatsche.Nginx. You must install that role first using:

```bash
ansible-galaxy install bbatsche.Nginx
```

Example Playbook
----------------

```yml
- hosts: servers
  roles:
  - role: bbatsche.Codeup-PHP
    domain: my-php-site.dev
    enable_suhosin: yes
    storage_dir: ./storage
```

License
-------

MIT

Testing
-------

Included with this role is a set of specs for testing each task individually or as a whole. To run these tests you will first need to have [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) installed. The spec files are written using [Serverspec](http://serverspec.org/) so you will need Ruby and [Bundler](http://bundler.io/). _**Note:** To keep things nicely encapsulated, everything is run through `rake`, including Vagrant itself. Because of this, your version of bundler must match Vagrant's version requirements. As of this writing (Vagrant version 1.8.1) that means your version of bundler must be between 1.5.2 and 1.10.6._

To run the full suite of specs:

```bash
$ gem install bundler -v 1.10.6
$ bundle install
$ rake
```

To see the available rake tasks (and specs):

```bash
$ rake -T
```

There are several rake tasks for interacting with the test environment, including:

- `rake vagrant:up` &mdash; Boot the test environment (_**Note:** This will **not** run any provisioning tasks._)
- `rake vagrant:provision` &mdash; Provision the test environment
- `rake vagrant:destroy` &mdash; Destroy the test environment
- `rake vagrant[cmd]` &mdash; Run some arbitrary Vagrant command in the test environment. For example, to log in to the test environment run: `rake vagrant[ssh]`

These specs are **not** meant to test for idempotence. They are meant to check that the specified tasks perform their expected steps. Idempotency can be tested independently as a form of integration testing.
