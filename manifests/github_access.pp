# puppet_odoo/manifests/github_access.pp
class puppet_odoo::github_access {

  $environment = $::environment

  $github_private_key = lookup("ssh_keys_common::github_private_key_${environment}")

  # Create group 'odoo_group' before user-related resources
  group { 'odoo_group':
    ensure => present,
  }

  user { 'github':
    ensure     => present,
    managehome => true,
    require    => Group['odoo_group'],
  }

  file { "/home/github/.ssh":
    ensure  => directory,
    mode    => '0700',
    owner   => 'github',
    group   => 'github',
    recurse => true,
    require => User['github'],
  }

  file { "/home/github/.ssh/id_rsa":
    content => epp('ssh_keys_common/github_private_key.erb'),
    ensure  => file,
    mode    => '0600',
    owner   => 'github',
    group   => 'github',
    require => File["/home/github/.ssh"],
  }
}

