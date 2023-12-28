# puppet_odoo/manifests/secure_odoo.pp

class puppet_odoo::secure_odoo {

  # Read user list, allowed IPs, and allowed FQDNs from config.yaml
  $config_users = hiera('users', [])
  $allowed_ips = hiera('allowed_ips', [])
  $allowed_fqdns = hiera('allowed_fqdns', [])

  # Check if each user has a public SSH key set
  $users_with_keys = filter($config_users) |$user| {
    defined(File["/home/${user}/.ssh/id_rsa.pub"])
  }

  if size($users_with_keys) > 0 {
    # Users with keys exist, apply secure_odoo configurations

    # Allow only specific users to log in with SSH keys
    sshd_config { 'AllowUsers':
      value => join($users_with_keys, ' '),
    }

    # Allow SSH access from specified IPs and FQDNs
    firewall { '002 allow ssh from allowed IPs and FQDNs':
      proto  => 'tcp',
      dport  => 22,
      action => 'accept',
      source => union($allowed_ips, $allowed_fqdns),
    }
  }
  else {
    # No users with keys, do nothing or log a message if needed
    notify { 'No users with SSH keys found':
      message => 'The secure_odoo class will not be applied as no users with SSH keys were found.',
    }
  }
}
