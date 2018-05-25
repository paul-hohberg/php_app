class php_app::site (
  $repo            = $php_app::params::repo,
  $user            = $php_app::params::user,
  $freq            = $php_app::params::freq,
  $rev             = $php_app::params::rev,
  $target          = $php_app::params::target,
  $specialdirs     = $php_app::params::specialdirs,
  $paramsdir       = $php_app::params::paramsdir,
  $logfiles        = $php_app::params::logfiles
  )
  inherits php_app::params {
  file { '/usr/share/httpd/.ssh':
    ensure => 'directory',
    owner  => apache,
    group  => apache,
    mode   => '0600',
  }
  file { '/usr/share/httpd/.ssh/id_rsa':
    source  => "${paramsdir}/deploy.key",
    owner   => apache,
    group   => apache,
    mode    => '0600',
  }
  file { '/usr/share/httpd/.ssh/known_hosts':
    owner   => apache,
    group   => apache,
    mode    => '0640',
    replace => true,
    source  => 'puppet:///modules/php_app/known_hosts.txt'
  }
  file { $target:
    ensure  => directory,
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
                   File['/usr/share/httpd/.ssh/id_rsa'],
                   File['/usr/share/httpd/.ssh/known_hosts'],
                   File[$target]
                   ],
  }
  file { '/var/www/html/root':
    ensure => 'link',
    force   => true,
    target => "${target}/web",
    require => Vcsrepo[$target],
  }
  file { $paramsdir:
    ensure => directory,
    mode   => '0770',
    owner  => 'root',
    group  => 'ims_iamucla_admins',
    notify => Exec["setfacl -Rdm g:ims_iamucla_admins:rwx ${paramsdir}"]
  }
  exec { "setfacl -Rdm g:ims_iamucla_admins:rwx ${paramsdir}":
    cwd         => '/usr/bin',
    path        => '/usr/bin',
    refreshonly => true,
    notify      => Exec["setfacl -Rm g:ims_iamucla_admins:rwx ${paramsdir}"]
  }
  exec { "setfacl -Rm g:ims_iamucla_admins:rwx ${paramsdir}":
    cwd         => '/usr/bin',
    path        => '/usr/bin',
    refreshonly => true
  }
  file { "${target}/app/config/parameters.yml":
    mode => '0440',
    owner => 'apache',
    group => 'apache',
    source => "${paramsdir}/parameters.yml",
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
    command     => "/usr/bin/php ${target}/bin/console cache:clear --env=prod && 
                    /usr/bin/php ${target}/bin/console cache:warmup --env=prod",
    cwd         => "${target}/bin",
    user        => 'apache',
    refreshonly => true,
  }
}
