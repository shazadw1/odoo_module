# puppet_odoo/manifests/set_backups.pp
class puppet_odoo::set_backups {
  # Ensure the cron.daily directory exists
  file { '/etc/cron.daily':
    ensure => directory,
  }

  # Create the nightly backup script
  file { '/etc/cron.daily/odoo_backup':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('puppet_odoo/odoo_backup.sh.erb'),
    require => File['/etc/cron.daily'],
  }

  # Define the backup base directory
  $backup_base = '/opt/backups'

  # Ensure the backup base directory exists
  file { $backup_base:
    ensure => directory,
  }

  # Define the remote directory on Google Drive
  $remote_directory = "remote:/backups/${::hostname}/$(strftime('%Y%m%d'))"

  # Create the remote hostname directory if it doesn't exist
  exec { 'create-remote-directory':
    command => "rclone mkdir ${remote_directory} --log-file /var/log/rclone_backup.log",
    path    => ['/bin', '/usr/bin'],
    creates => $remote_directory,
  }

  # Ensure the backup script is executable
  exec { 'make-backup-script-executable':
    command => 'chmod +x /etc/cron.daily/odoo_backup',
    path    => ['/bin', '/usr/bin'],
    require => File['/etc/cron.daily/odoo_backup'],
  }

  # Schedule the nightly backup
  cron { 'odoo_nightly_backup':
    command => '/etc/cron.daily/odoo_backup',
    hour    => '2', # Adjust the backup time as needed
    minute  => '0',
  }
}
