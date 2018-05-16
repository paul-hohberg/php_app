class php_app::site (
  $repo            = $php_app::params::repo,
  $user            = $php_app::params::user,
  $freq            = $php_app::params::freq,
  $rev             = $php_app::params::rev,
  $target          = $php_app::params::target,
  $specialdirs     = $php_app::params::specialdirs,
  $paramsfile      = $php_app::params::paramsfile,
  $logfiles        = $php_app::params::logfiles
  )
  inherits php_app::params {
  file { "/usr/share/httpd/.ssh":
    ensure => 'directory',
    owner  => apache,
    group  => apache,
    mode   => '0600',
  }
  file { '/usr/share/httpd/.ssh/id_rsa':
    source  => '/home/phohberg/deploy.key',
    owner   => apache,
    group   => apache,
    mode    => '0600',
  }
  file { '/usr/share/httpd/.ssh/known_hosts':
    owner   => apache,
    group   => apache,
    mode    => '0640',
    replace => false,
    content => "github.com,192.30.255.112,192.30.255.113 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==\n",
  }
  file { $target:
    ensure  => "directory",
    owner   => 'apache',
    group   => 'apache',
    mode    => '0774',
  }
  vcsrepo { $target:
    ensure      => $freq,
    provider    => git,
    source      => $repo,
    user        => apache,
    revision    => $rev,
    depth       => '1',
    require     => [
                   Package['git'],
                   File["/usr/share/httpd/.ssh/id_rsa"],
                   File[$target]
                   ],
  }
  file { '/var/www/html/root':
    ensure => 'link',
    force   => true,
    target => "${target}/web",
    require => Vcsrepo[$target],
  }
  file { "${target}/app/config/parameters.yml":
    mode => '0440',
    owner => 'apache',
    group => 'apache',
    source => $paramsfile,
    require => Vcsrepo[$target],
    notify => Exec['cache-clear']
  }
  file { $specialdirs:
    ensure => 'directory',
    owner  => 'apache',
    group  => 'apache',
    mode   => '0774',
    require => Vcsrepo[$target]
  }
  file { $logfiles:
    ensure  => present,
    owner   => 'apache',
    group   => 'apache',
    mode    => '0664',
  }
  file { '/etc/logrotate.d/thor_rotate':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('php_app/logrotate.erb'),
  }
  package { 'git':
    ensure => present,
  }
  exec { 'cache-clear':
    command     => "/usr/bin/php ${target}/bin/console cache:clear -e=prod && 
                    /usr/bin/php ${target}/bin/console cache:warmup -e=prod",
    cwd         => "${target}/bin",
    user        => 'apache',
    refreshonly => true,
  }
}
