class odoo17_user {
  user { 'Odoo17':
    ensure     => present,
    home       => '/opt/odoo17',
    managehome => true,
  }
}
