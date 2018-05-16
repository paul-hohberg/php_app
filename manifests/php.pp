class php_app::php (
  $phpver = '71',
  $pkgs = [
    'php',
    'php-xml',
    'php-process',
    'php-intl',
    'php-mbstring',
    'php-mcrypt',
    'php-mysqlnd',
    'php-ldap',
    'php-soap',
    'php-opcache',
    'php-pecl-apcu',
    'php-pecl-redis',
    'php-pdo',
    'php-sqlsrv',
    'php-devel',
    'unixODBC-devel'
  ]
) {
  yumrepo { "remi-php${phpver}":
    name       => "remi-php${phpver}",
    descr      => 'remi php repository',
    mirrorlist => "http://rpms.remirepo.net/enterprise/${::operatingsystemmajrelease}/php${phpver}/mirror",
    enabled    => 1,
    gpgcheck   => 1,
    gpgkey     => 'https://rpms.remirepo.net/RPM-GPG-KEY-remi',
    require    => Yumrepo['epel'],
  }
  yumrepo { 'epel':
    mirrorlist => "https://mirrors.fedoraproject.org/metalink?repo=epel-${::operatingsystemmajrelease}&arch=x86_64",
    gpgcheck   => '1',
    gpgkey     => "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-${::operatingsystemmajrelease}",
    enabled    => '1',
  }
  package { $pkgs:
    ensure => present,
    before => Yumrepo['mssql-release'] 
  }
  yumrepo { 'mssql-release':
    name     => 'mssql-release',
    descr    => 'packages-microsoft-com-prod',
    baseurl  => "https://packages.microsoft.com/rhel/${::operatingsystemmajrelease}/prod/",
    enabled  => 1,
    gpgcheck => 1,
    gpgkey   => 'https://packages.microsoft.com/keys/microsoft.asc',
    notify   => Exec['install msodbcsql17 mssql-tools']
  }
  exec { 'install msodbcsql17 mssql-tools':
    command     => '/bin/yum -y install msodbcsql17 mssql-tools',
    cwd         => '/bin',
    environment => "ACCEPT_EULA=Y",
    refreshonly => true,
  }
  file_line { 'php_ini_timezone':
    ensure             => present,
    path               => '/etc/php.ini',
    line               => "date.timezone = 'America/Los_Angeles'",
    match              => '^;date.timezone',
    append_on_no_match => false,
    require            => Package['php'],
  }
  file { '/etc/profile.d/mssql-tools.sh':
    ensure  => file,
    replace => false,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/php_app/mssql-tools.sh'
  }
}
