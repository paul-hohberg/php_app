class php_app::online (
  $apip = $php_app::params::apip
  )
  inherits php_app::params {
  file_line { '/etc/hosts':
    ensure => absent
    path   => '/etc/hosts',
    line   => "${apip} api.iam.ucla.edu",
  }
  file { '/var/www/html/A10healthCheck/a10_check.html':
    ensure  => file,
    mode    => '0664',
    owner   => 'root',
    group   => 'root',
    content => 'A10_Passed_healthCheck',
  }
}
