class install_odoo {
  # Fetching variables from Hiera or defining default values
  $linux_username = lookup('linux_username', String, 'first', 'odoo17')
  $odoo_version = lookup('odoo_version', String, 'first', '17.0')
  $postgres_username = lookup('postgres_username', String, 'first', 'odoo17')
  $db_password = lookup('db_password', String, 'first', 'Od00786-')
  $odoo_port = lookup('odoo_port', String, 'first', '8069')

  # Install necessary packages
  package { ['wkhtmltopdf', 'postgresql', 'postgresql-client', 'python3-pip', ...]:
    ensure => installed,
  }

  # Create Linux user and group
  user { $linux_username:
    ensure     => present,
    managehome => true,
    home       => "/opt/${linux_username}",
    shell      => '/bin/bash',
  }
  group { $linux_username:
    ensure => present,
  }

  # Create necessary directories
  file { ["/opt/${linux_username}", "/opt/${linux_username}/data_dir", '/var/log/odoo']:
    ensure => directory,
    owner  => $linux_username,
    group  => 'root',
  }

  # Clone Odoo repositories
  exec { "clone_odoo_ce":
    command => "git clone https://github.com/odoo/odoo --depth 1 --branch ${odoo_version} --single-branch ce",
    cwd     => "/opt/${linux_username}",
    creates => "/opt/${linux_username}/ce",
    user    => $linux_username,
    require => Package['git'],
  }
  # ... repeat for other repositories ...

  # Create Odoo configuration file
  file { "/etc/${linux_username}.conf":
    ensure  => file,
    content => template('install_odoo/odoo.conf.erb'),
    owner   => $linux_username,
    group   => $linux_username,
    mode    => '0640',
  }

  # Create systemd service file
  file { "/etc/systemd/system/${linux_username}.service":
    ensure  => file,
    content => template('install_odoo/odoo.service.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  # Ensure Odoo service is running and enabled
  service { "${linux_username}.service":
    ensure    => 'running',
    enable    => true,
    subscribe => File["/etc/${linux_username}.conf"],
  }

  # Create PostgreSQL user
  exec { 'create_postgres_user':
    command => "createuser --createdb --username postgres --no-createrole --no-superuser ${postgres_username}; psql -c \"ALTER USER ${postgres_username} WITH SUPERUSER PASSWORD '${db_password}'\"",
    path    => ['/bin', '/usr/bin'],
    user    => 'postgres',
    unless  => "psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='${postgres_username}'\" | grep -q 1",
  }
}
