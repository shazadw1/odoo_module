class install_odoo::install_package_dependencies {
  $linux_username = lookup('linux_username', String, 'first', 'odoo17')
  $odoo_ce_path = "/opt/${linux_username}/ce/debian/control"

  exec { 'install_odoo_package_dependencies':
    command     => "sed -n -e '/^Depends:/,/^Pre/ s/ python3-(.*),/python3-\\1/p' ${odoo_ce_path} | xargs apt-get install -y",
    path        => ['/bin', '/usr/bin'],
    refreshonly => true,
    subscribe   => File[$odoo_ce_path],
    require     => Class['install_odoo::clone_odoo_repositories'],
  }
}
