class puppet_odoo {
  # Include the install_odoo class
  include puppet_odoo::install_odoo

  # Include the install_nginx class
  include puppet_odoo::install_nginx

  # Include the manage_traffic class
  include puppet_odoo::manage_traffic

  # You can add more classes here as your module expands
}

