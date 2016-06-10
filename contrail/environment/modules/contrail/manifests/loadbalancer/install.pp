class contrail::loadbalancer::install (
  $contrail_logoutput = $::contrail::params::contrail_logoutput,
  $host_ip = $::contrail::params::host_ip,
  $contrail_package_name = $::contrail::params::contrail_repo_name,
  $loadbalancer_method = $::contrail::params::loadbalancer_method
) {
      # choose package to install, either bird or keepalived and haproxy
      if ($loadbalancer_method == "bird") {
          package { 'bird' :
            ensure => latest,
            notify => Service["bird"]
          }
      }
      # else keepalived would be installed as per keepalived role config as per contrail_all.pp
      #} else {
      #    if ($lsbdistrelease == "14.04") {
      #        $keepalived_pkg         = '1.2.13-0~276~ubuntu14.04.1'
      #    } else {
      #        $keepalived_pkg         = '1:1.2.13-1~bpo70+1'
      #    }
      #    package { 'keepalived' :
      #      ensure => $keepalived_pkg
      #    }
      #}
      #-> package { 'haproxy' : 
      #      ensure => present,
      #      notify => Service["haproxy"]
      #   }
}
