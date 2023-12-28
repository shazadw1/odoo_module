# puppet_odoo/manifests/system_setup.pp
class puppet_odoo::system_setup {

  # Function to update the package list
  exec { 'update-package-list':
    command => 'apt update',
    path    => ['/bin', '/usr/bin'],
    require => Package['apt'],
  }

  # Function to upgrade installed packages
  exec { 'upgrade-installed-packages':
    command => 'apt upgrade -y',
    path    => ['/bin', '/usr/bin'],
    require => Exec['update-package-list'],
  }

  # Function to install necessary packages
  package { ['openssh-server', 'fail2ban', 'jq']:
    ensure => 'installed',
    require => Exec['upgrade-installed-packages'],
  }

  # Create group 'odoo_group'
  group { 'odoo_group':
    ensure => 'present',
  }

  # Retrieve user names from the configuration file
  $users = lookup('users_and_keys').keys

  # Loop through the user names
  each($users) |$user| {
    user { $user:
      ensure     => 'present',
      shell      => '/bin/bash',
      home       => "/home/${user}",
      managehome => true,
      groups     => ['root', 'odoo_group'],
      require    => Group['odoo_group'],
    }

    file { "/home/${user}/.ssh":
      ensure  => 'directory',
      owner   => $user,
      group   => $user,
      mode    => '0700',
      require => User[$user],
    }

    file { "/home/${user}/.ssh/authorized_keys":
      ensure  => 'file',
      owner   => $user,
      group   => $user,
      mode    => '0600',
      content => file("puppet:///modules/puppet_odoo/filess/${user}.yaml"),
      require => File["/home/${user}/.ssh"],
    }
  }
}

