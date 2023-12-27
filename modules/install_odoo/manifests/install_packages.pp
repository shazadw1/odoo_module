class install_odoo::install_packages {
  # Notify about package installation
  notify { 'Installing necessary packages':
    message => "Installing necessary packages for Odoo",
  }

  # Packages to be installed via apt-get
  $apt_packages = ['wkhtmltopdf', 'postgresql', 'postgresql-client', 'python3-pip']

  package { $apt_packages:
    ensure   => installed,
    provider => 'apt',
    require  => Exec['apt-get update'],
  }

  # Exec resource to ensure apt-get update is run
  exec { 'apt-get update':
    command     => '/usr/bin/apt-get update',
    path        => ['/bin', '/usr/bin'],
    refreshonly => true,
  }

  # Python packages to be installed via pip3
  $pip_packages = ['cryptography', 'cerberus', 'pyquerystring', 'parse-accept-language',
                   'apispec>=4.0.0', 'marshmallow', 'jsondiff', 'extendable-pydantic==0.0.4',
                   'pydantic==1.10.7', 'cachetools', 'marshmallow-objects>=2.0.0', 'extendable',
                   'contextvars', 'typing-extensions', 'plotly', 'pandas', 'openpyxl', 'docx',
                   'phonenumbers', 'google-auth']

  exec { 'install_pip_packages':
    command => "/usr/bin/pip3 install ${pip_packages.join(' ')}",
    path    => ['/bin', '/usr/bin'],
    require => Package['python3-pip'],
  }
}
