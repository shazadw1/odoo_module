class create_linux_user {

  # Variable for the username
  $linux_username = 'odoo'

  # Check if the user exists and create if it does not
  user { $linux_username:
    ensure     => present,
    managehome => true,
    home       => "/opt/${linux_username}",
    shell      => '/bin/bash', # or your preferred shell
    comment    => 'Odoo User',
    provider   => 'useradd',
    require    => Group[$linux_username],
  }

  # Ensure the group exists
  group { $linux_username:
    ensure => present,
  }
}
