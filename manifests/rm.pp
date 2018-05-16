class php_app::rm
  ( $target = $php_app::params::target )
  inherits php_app::params {
  exec { "rm -rf ${target} and root symlink":
    command => "/usr/bin/rm -rf ${target} /var/www/html/root",
    cwd     => '/var/www/html',
  }
}
