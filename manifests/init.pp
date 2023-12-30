# /etc/puppetlabs/code/environments/common/puppet_odoo/manifests/init.pp

class puppet_odoo {
  # Include classes from puppet_odoo module
  include puppet_odoo::system_setup
  include puppet_odoo::install_odoo
  include puppet_odoo::install_nginx
  include puppet_odoo::set_backups
  include puppet_odoo::manage_traffic
  include puppet_odoo::github_access
  # include puppet_odoo::secure_odoo

  # Add other classes as needed for all nodes
}

# Node definition (if required)
node 'd2.adaplo.io' {
  include puppet_odoo
}
