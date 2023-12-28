# puppet_odoo/manifests/github_access.pp

class puppet_odoo::github_access {

  $environment = $::environment

  $github_private_key = lookup("ssh_keys_common::github_private_key_${environment}")

  user { 'github':
    ensure     => present,
    managehome => true,
  }

  file { "/home/github/.ssh":
    ensure => directory,
    mode   => '0700',
    owner  => 'github',
    group  => 'github',
  }

  file { "/home/github/.ssh/id_rsa":
    content => epp('ssh_keys_common/github_private_key.erb'),
    ensure  => file,
    mode    => '0600',
    owner   => 'github',
    group   => 'github',
  }

  group { 'odoo_group':
    ensure => present,
  }

  user { 'github':
    groups => ['odoo_group'],
  }

}

