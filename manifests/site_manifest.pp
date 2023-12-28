node default {
  include puppet_odoo::system_setup
  include puppet_odoo::install
  include puppet_odoo::install_nginx
  include puppet_odoo::set_backups
  include puppet_odoo::manage_traffic
  
  # Add other classes as needed for all nodes
}
