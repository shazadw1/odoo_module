class install_odoo::clone_odoo_repositories {
  # Fetching variables from Hiera
  $linux_username = lookup('linux_username', String, 'first', 'odoo17')
  $odoo_version = lookup('odoo_version', String, 'first', '17.0')
  $target_directory = "/opt/${linux_username}"

  # Ensure the target directory exists and is owned by the user
  file { $target_directory:
    ensure  => 'directory',
    owner   => $linux_username,
    group   => $linux_username,
    require => Class['install_odoo::create_linux_user'],
  }

  # Clone the Odoo Community Edition repository
  exec { 'clone_odoo_ce':
    command => "git clone https://github.com/odoo/odoo --depth 1 --branch ${odoo_version} --single-branch ce",
    cwd     => $target_directory,
    creates => "${target_directory}/ce",
    user    => $linux_username,
    require => [Package['git'], File[$target_directory]],
  }


  # Clone the Odoo Enterprise repository
  exec { 'clone_odoo_enterprise':
    command => "git clone https://shazadw1@github.com/odoo/enterprise --depth 1 --branch ${odoo_version} --single-branch enterprise",
    cwd     => $target_directory,
    creates => "${target_directory}/enterprise",
    user    => $linux_username,
    require => [Package['git'], File[$target_directory]],
  }
}
