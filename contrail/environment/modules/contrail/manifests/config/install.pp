class contrail::config::install() {
  # Install a specific version of keepalived in non-ha
  # case also, to support upgrade of contrail software.
  # Below code is not required when keepalive dependency is fixed.
  #
  if ($contrail_internal_vip == "" and ($internal_vip == "" or !('openstack' in $contrail_host_roles))) {

      if ($lsbdistrelease == "14.04") {
          $keepalived_pkg         = '1.2.13-0~276~ubuntu14.04.1'
      } else {
          $keepalived_pkg         = '1:1.2.13-1~bpo70+1'
      }

      package { 'keepalived' :
          ensure => $keepalived_pkg,
          before => Package['contrail-openstack-config'],
      }
      ->
      service { "keepalived" :
          enable => false,
          require => [ Package['keepalived']],
          ensure => stopped,
          before => Package['contrail-openstack-config'],
      }
  }

  package { 'contrail-openstack-config' :
    ensure => latest
  }

}
