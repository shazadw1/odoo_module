class puppet_odoo::install_nginx {
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
  command     => "certbot --nginx -d ${system_hostname} --redirect --hsts --non-interactive --agree-tos --email waseem@adaplo.io",
  path        => ['/bin', '/usr/bin'],
  refreshonly => true,
  subscribe   => Package['certbot'],
}


  # Remove the default Nginx configuration file created by Certbot
  file { "/etc/nginx/sites-enabled/${system_hostname}":
    ensure  => absent,
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

  # Configure Nginx with a template
  file { "/etc/nginx/sites-enabled/${system_hostname}":
    ensure  => file,
    source  => "puppet:///modules/puppet_odoo/nginx.conf",
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

  # Nginx service management
  service { 'nginx':
    ensure    => 'running',
    enable    => true,
    subscribe => File["/etc/nginx/sites-enabled/${system_hostname}"],
  }
}
