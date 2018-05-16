class php_app::selinux {
  require selinux
  selinux::boolean { 'httpd_can_network_connect':
    ensure  => "on",
    require => Package['httpd'],
  }
  selinux::boolean { 'httpd_can_network_connect_db':
    ensure  => "on",
    require => Package['httpd'],
  }
  selinux::module { 'mod_shib-to-shibd':
    ensure    => 'present',
    source_te => 'puppet:///modules/php_app/mod_shib-to-shibd.te',
  }
}
