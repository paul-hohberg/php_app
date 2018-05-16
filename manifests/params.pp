class php_app::params {

    # Symfony cache and log dirs that require special write permissions.
    $specialdirs    = [
        "${target}/var/cache",
        "${target}/var/logs"
    ]

    # Config file that stores secrets.
    $paramsfile = '/opt/etc/php_app/parameters.yml'

  case $fqdn {
    'host.com': {
       $url = 'host.com'
       $repo = 'git@github.com:owner/project.git'
       $freq = 'latest'
       $rev = 'latest'
       $logfiles = [ '/var/log/php_app.log', '/var/log/php_app.log' ]
       $target = '/var/www/html/php_app'
    }
    default: {
      fail("Unsupported node: ${fqdn}.  Please implement")
    }
  }
}
