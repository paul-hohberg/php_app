class php_app::cache_clear
  ( $target = $php_app::params::target )
  inherits php_app::params {
  exec { 'cache-clear':
    command => "/usr/bin/php ${target}/bin/console cache:clear -e=prod &&
                /usr/bin/php ${target}/bin/console cache:warmup -e=prod",
    cwd     => "${target}/bin",
    user    => 'apache',
  }
}
