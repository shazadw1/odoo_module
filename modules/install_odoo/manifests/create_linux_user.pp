class install_odoo::create_linux_user {
  # Fetch the linux username from Hiera or define it here
  $linux_username = lookup('linux_username', String, 'first', 'odoo17')

  # Check if the user and group exist and create them if they don't
  user { $linux_username:
    ensure     => present,
    managehome => true,
    home       => "/opt/${linux_username}",
    shell      => '/bin/bash',
    system     => true,
  }

  group { $linux_username:
    ensure => present,
  }

  # Log messages
  notify { "Creating system user and group: ${linux_username}":
    # Only notify if the user is being created
    withpath => false,
    refreshonly => true,
    subscribe => User[$linux_username],
  }

  notify { "User ${linux_username} already exists. Skipping user creation.":
    # Only notify if the user already exists
    withpath => false,
    refreshonly => true,
    unless => User[$linux_username],
  }
}
