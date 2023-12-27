class puppet_odoo::install_nginx {
  # Set linux_username to 'odoo'
  $linux_username = 'odoo'
  $odoo_config_file = "/etc/${linux_username}.conf"

  # Retrieve the actual hostname of the system
  $system_hostname = $facts['networking']['hostname']

  # Stop Apache service
  service { 'apache2':
    ensure => 'stopped',
    enable => false,
  }

  # Install Nginx and Certbot packages
  package { ['nginx', 'certbot', 'python3-certbot-nginx', 'python3-certbot-apache']:
    ensure => installed,
  }

  # Enable HTTPS with Certbot for Nginx
  exec { 'enable_https_certbot':
    command     => "certbot --nginx -d ${system_hostname} --redirect --hsts",
    path        => ['/bin', '/usr/bin'],
    refreshonly => true,
    subscribe   => Package['certbot'],
  }

  # Configure Nginx
  file { "/etc/nginx/sites-enabled/${system_hostname}":
    ensure  => file,
    source  => "puppet:///modules/puppet_odoo/nginx.conf",
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

  # Update the Odoo configuration file
  exec { 'update_odoo_config_file':
    command     => "echo -e 'xmlrpc_interface = 127.0.0.1\\nnetrpc_interface = 127.0.0.1\\nproxy_mode = True' >> ${odoo_config_file}",
    path        => ['/bin', '/usr/bin'],
    unless      => "grep -q 'xmlrpc_interface = 127.0.0.1' ${odoo_config_file}",
    require     => File[$odoo_config_file],
    refreshonly => true,
  }

  # Nginx service management
  service { 'nginx':
    ensure    => 'running',
    enable    => true,
    subscribe => File["/etc/nginx/sites-enabled/${system_hostname}"],
  }
}
