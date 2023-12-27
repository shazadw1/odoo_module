class install_odoo::make_data_and_backup_directories {
  $linux_username = lookup('linux_username', String, 'first', 'odoo17')
  $data_dir = "/opt/${linux_username}/data_dir"

  file { $data_dir:
    ensure => 'directory',
    owner  => $linux_username,
    group  => 'root',
  }
}
