class php_app::maintenance {
  file { '/var/www/html/maintenance':
    ensure  => "directory",
    owner   => 'apache',
    group   => 'apache',
    mode    => '0774',
    source  => 'puppet:///modules/php_app/maintenance',
    recurse => true
  }
  file { '/var/www/html/root':
  ensure => 'link',
  target => '/var/www/html/maintenance',
  }
}
