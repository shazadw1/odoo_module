# puppet_odoo/manifests/sites.pp
node default {
  # Include classes from puppet_odoo module
  include puppet_odoo::system_setup
  include puppet_odoo::install
  include puppet_odoo::install_nginx
  include puppet_odoo::set_backups
  include puppet_odoo::manage_traffic
  
  
  include puppet_odoo::github_access
  #include puppet_odoo::secure_odoo


  # Add other classes as needed for all nodes
}
