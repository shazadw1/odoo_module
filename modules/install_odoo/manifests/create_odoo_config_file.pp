class install_odoo::create_odoo_config_file {
  $linux_username = lookup('linux_username', String, 'first', 'odoo17')
  $postgres_username = lookup('postgres_username', String, 'first', 'odoo17')
  $db_password = lookup('db_password', String, 'first', 'Od00786-')
  $odoo_port = lookup('odoo_port', String, 'first', '8069')
  $config_file = "/etc/${linux_username}.conf"

  file { $config_file:
    ensure  => file,
    content => template('install_odoo/odoo.conf.erb'),
    owner   => $linux_username,
    group   => $linux_username,
    mode    => '0640',
  }
}
