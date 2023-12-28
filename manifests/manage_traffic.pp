# puppet_odoo/manifests/manage_traffic.pp
class puppet_odoo::manage_traffic {
  # Allowed incoming ports
  $allowed_ports = ['80', '443', '8443', '22', '8069']

  # Domain and ports to block
  $block_domain = 'services.odoo.com'
  $block_ports = ['80', '443']

  # Flush existing rules
  firewall { '000 clear iptables rules':
    ensure => 'absent',
    before => Firewall['100 allow incoming traffic'],
  }

  # Set the default policy to DROP for incoming traffic
  resources { 'firewall':
    purge => true,
  }

  Firewall {
    proto  => 'tcp',
    action => 'accept',
  }

  # Allow incoming traffic on specified ports
  firewallchain { 'INPUT:filter:IPv4':
    policy => 'drop',
  }

  firewallchain { 'OUTPUT:filter:IPv4':
    policy => 'accept',
  }

  # Allow specific incoming traffic
  $allowed_ports.each |$port| {
    firewall { "100 allow incoming traffic on port ${port}":
      dport => $port,
    }
  }

  # Block specific outgoing traffic to a domain
  $block_ports.each |$port| {
    firewall { "200 block outgoing traffic to ${block_domain} on port ${port}":
      chain  => 'OUTPUT',
      dport  => $port,
      dest   => $block_domain,
      action => 'drop',
    }
  }

  # Save iptables rules
  exec { 'save iptables rules':
    command => 'iptables-save > /etc/iptables/rules.v4',
    path    => ['/bin', '/usr/bin'],
    refreshonly => true,
    subscribe => Firewall['100 allow incoming traffic'],
  }
}
