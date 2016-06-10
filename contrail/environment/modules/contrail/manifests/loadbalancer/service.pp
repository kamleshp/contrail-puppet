class contrail::loadbalancer::service (
  $loadbalancer_method = $::contrail::params::loadbalancer_method
) {
    if ($loadbalancer_method == "bird") {
        service { 'bird':
          ensure => running,
          enable => true,
          subscribe => File['/etc/bird/bird.conf'],
        }
    }
}
