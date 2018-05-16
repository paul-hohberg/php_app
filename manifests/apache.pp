class php_app::apache (
  $url = $php_app::params::url
  )
  inherits php_app::params {
  class { '::apache':
    default_mods      => ['auth_digest', ],
    default_vhost     => false,
    default_ssl_vhost => false,
    default_ssl_chain => '/etc/pki/tls/certs/intermediates.crt',
    logroot_mode      => '0755',
    scriptalias       => '/var/www/cgi-bin',
    trace_enable      => off
  }
  class { 'apache::mod::alias':
    icons_options => 'MultiViews'
  }
  class { 'apache::mod::auth_basic': }
  class { 'apache::mod::authn_core': }
  class { 'apache::mod::authz_user': }
  class { 'apache::mod::cgi': }
  class { 'apache::mod::headers': }
  class { 'apache::mod::rewrite': }
  class { 'apache::mod::negotiation': }
  class { 'apache::mod::dir': }
  class { 'apache::mod::ssl':
    ssl_protocol => ['all','-SSLv3','-TLSv1','-TLSv1.1'],
    ssl_cipher   => 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256'
  }
  class { 'apache::mod::shib':
    suppress_warning => true,
    mod_full_path    => '/usr/lib64/shibboleth/mod_shib_24.so',
    package_name     => 'shibboleth'
  }
  class { 'apache::mod::php':
    package_name => 'php',
    path         => '/etc/httpd/modules/libphp7.so',
    php_version  => '7',
    source       => 'puppet:///modules/php_app/php.conf'
  }
  apache::vhost { '_default_80':
    port    => '80',
    docroot => '/var/www/html',
    options => [ 'FollowSymLinks', 'MultiViews' ],
    redirect_status => 'permanent',
    redirect_dest   => "https://${url}/"
  }
  apache::vhost { "${url}-443":
    port          => '443',
    servername    => "${url}",
    serveraliases => ["${fqdn}",],
    docroot       => '/var/www/html/root',
    options       => [ 'FollowSymLinks', 'MultiViews' ],
    directories   => [
      {
        path            => '/var/www/html/root',
        allow_override  => ['All'],
      },
    ],
    custom_fragment => '
      <Location /Shibboleth.sso>
        RewriteCond %{REQUEST_URI}/Shibboleth.sso/?(.*) -U
        RewriteRule .? - [L]
        AuthType None
        Require all granted
      </Location>
      <IfModule mod_alias.c>
        <Location /shibboleth-sp>
          AuthType None
          Require all granted
        </Location>
        Alias /shibboleth-sp/main.css /usr/share/shibboleth/main.css
      </IfModule>
      <Location />
        AuthType Shibboleth
        ShibRequestSetting requireSession 1
        ShibUseHeaders On
        Require valid-user
      </Location>
      <Location /#>
        RewriteEngine On
        RewriteRule .? %{ENV:BASE}/app.php [L]
      </Location>',
    ssl             => true,
    ssl_cert        => "/etc/pki/tls/certs/${url}.crt",
    ssl_key         => "/etc/pki/tls/private/${url}.key",
  }
  file { "/etc/pki/tls/certs/${url}.crt":
    ensure => present,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source => "puppet:///modules/php_app/${url}.crt",
  }
  file { "/etc/pki/tls/private/${url}.key":
    ensure => present,
    mode   => '0640',
    owner  => 'root',
    group  => 'root',
    source => "/opt/etc/php_app/${url}.key",
  }
  file { '/etc/pki/tls/certs/intermediates.crt':
    ensure => present,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/php_app/intermediates.crt',
  }
  yumrepo { 'security_shibboleth':
    name     => 'security_shibboleth',
    descr    => "Shibboleth ${::operatingsystem}_${::operatingsystemmajrelease}",
    ensure   => present,
    baseurl  => "http://downloadcontent.opensuse.org/repositories/security:/shibboleth/${::operatingsystem}_${::operatingsystemmajrelease}/",
    gpgcheck => '1',
    gpgkey   => "http://downloadcontent.opensuse.org/repositories/security:/shibboleth/${::operatingsystem}_${::operatingsystemmajrelease}/repodata/repomd.xml.key",
    enabled  => '1',
  }
  package { 'shibboleth':
    ensure => 'present',
  }
  service { 'shibd':
    ensure => true,
    enable => true,
    notify => Exec['setfacl -Rdm g:ims_iamucla_admins:r-x /var/log/shibboleth*']
  }
  file { '/etc/shibboleth/inc-md-cert.pem':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/php_app/inc-md-cert.pem',
    before => File['/etc/shibboleth/shibboleth2.xml']
  }
  file { '/etc/shibboleth/shibboleth2.xml':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("php_app/shibboleth2.xml.${environment}.erb"),
    notify  => Service['shibd']
  }
  exec { 'setfacl -Rdm g:web_admins:r-x /var/log/shibboleth*':
    cwd         => '/usr/bin',
    path        => '/usr/bin',
    refreshonly => true,
    notify      => Exec['setfacl -Rm g:web_admins:r-x /var/log/shibboleth*']
  }
  exec { 'setfacl -Rm g:web_admins:r-x /var/log/shibboleth*':
    cwd         => '/usr/bin',
    path        => '/usr/bin',
    refreshonly => true
  }
}
