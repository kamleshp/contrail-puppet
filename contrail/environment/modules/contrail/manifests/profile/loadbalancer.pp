class contrail::profile::loadbalancer (
    $enable_module = $::contrail::params::enable_loadbalancer,
    $host_roles = $::contrail::params::host_roles,
) {
    if ($enable_module and "loadbalancer" in $host_roles) {
        contain ::contrail::loadbalancer
    } 
}

