class php_app::offline (
  $apip = $php_app::params::apip,
  $target = $php_app::params::target
  )
  inherits php_app::params {
  file { '/var/www/html/A10healthCheck/a10_check.html':
    ensure  => file,
    mode    => '0664',
    owner   => 'root',
    group   => 'root',
    content => 'offline',
    notify  => Exec["rm -rf ${target} and root symlink"]
  }
  file_line { '/etc/hosts':
    path => '/etc/hosts',
    line => "${apip} api.iam.ucla.edu",
  }
  exec { "rm -rf ${target} and root symlink":
    command     => "/usr/bin/rm -rf ${target} /var/www/html/root",
    cwd         => '/var/www/html',
    refreshonly => true
  }
}
