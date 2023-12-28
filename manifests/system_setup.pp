# puppet_odoo/manifests/system_setup.pp
class puppet_odoo::system_setup {

  # Function to update the package list
  exec { 'update-package-list':
    command => 'apt update',
    path    => ['/bin', '/usr/bin'],
  }

  # Function to upgrade installed packages
  exec { 'upgrade-installed-packages':
    command => 'apt upgrade -y',
    path    => ['/bin', '/usr/bin'],
  }

  # Function to install necessary packages
  exec { 'install-necessary-packages':
    command => 'apt install -y openssh-server fail2ban jq',
    path    => ['/bin', '/usr/bin'],
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
      groups     => ['root', 'odoo_group'], # Add user to 'root' and 'odoo_group' groups
    }

    file { "/home/${user}/.ssh":
      ensure  => 'directory',
      owner   => $user,
      group   => $user,
      mode    => '0700',
    }

    file { "/home/${user}/.ssh/authorized_keys":
      ensure  => 'file',
      owner   => $user,
      group   => $user,
      mode    => '0600',
      source  => "puppet:///modules/puppet_odoo/keys/${user}.pub", # Use the user-specific public key template
    }
  }
}
